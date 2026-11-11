using System.Data;
using Dapper;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Workouts.DTOs;
using ShapeFit.Domain.Enums;

namespace ShapeFit.Infrastructure.Persistence.Repositories;

public class WorkoutReadRepository : IWorkoutReadRepository
{
    private readonly IDbConnection _dbConnection;

    public WorkoutReadRepository(IDbConnection dbConnection)
    {
        _dbConnection = dbConnection;
    }

    private sealed record RawLastPerformanceRow(
        Guid ExerciseId,
        string ExerciseName,
        DateTime PerformedAt,
        int SetOrder,
        int Type,
        decimal Weight,
        string Unit,
        int Repetitions,
        int? RepsInReserve
    );

    private sealed record RawWeeklyMuscleVolumeRow(
        int Muscle,
        long EffectiveSetsCount
    );

    public async Task<LastExercisePerformanceDto?> GetLastPerformanceAsync(Guid userId, Guid exerciseId, CancellationToken cancellationToken = default)
    {
        // Query Dapper com CTE (Common Table Expression): 
        // 1. Acha a última sessão de treino em que o usuário realizou o exercício em questão.
        // 2. Extrai todas as séries realizadas naquela sessão específica para pré-preenchimento instantâneo.
        const string sql = """
            WITH last_exercise AS (
                SELECT 
                    e.id AS exercise_id,
                    e.name AS exercise_name,
                    s.started_at,
                    wel.id AS exercise_log_id
                FROM workout_sessions s
                INNER JOIN workout_exercise_logs wel ON wel.workout_session_id = s.id
                INNER JOIN exercises e ON e.id = wel.exercise_id
                WHERE s.user_id = @UserId 
                  AND wel.exercise_id = @ExerciseId
                  AND s.finished_at IS NOT NULL
                ORDER BY s.started_at DESC
                LIMIT 1
            )
            SELECT 
                le.exercise_id AS ExerciseId,
                le.exercise_name AS ExerciseName,
                le.started_at AS PerformedAt,
                wsl.set_order AS SetOrder,
                wsl.type AS Type,
                wsl.weight_value AS Weight,
                wsl.weight_unit AS Unit,
                wsl.repetitions AS Repetitions,
                wsl.reps_in_reserve AS RepsInReserve
            FROM last_exercise le
            INNER JOIN workout_set_logs wsl ON wsl.workout_exercise_log_id = le.exercise_log_id
            ORDER BY wsl.set_order ASC;
        """;

        var command = new CommandDefinition(
            sql, 
            new { UserId = userId, ExerciseId = exerciseId }, 
            cancellationToken: cancellationToken
        );

        var rows = (await _dbConnection.QueryAsync<RawLastPerformanceRow>(command)).ToList();

        if (rows.Count == 0)
            return null;

        var first = rows[0];
        var sets = rows.Select(r => new PreviousSetDto(
            r.SetOrder,
            (SetType)r.Type,
            r.Weight,
            r.Unit,
            r.Repetitions,
            r.RepsInReserve
        )).ToList();

        return new LastExercisePerformanceDto(
            first.ExerciseId,
            first.ExerciseName,
            first.PerformedAt,
            sets
        );
    }

    public async Task<IEnumerable<MuscleWeeklyVolumeDto>> GetWeeklyMuscleVolumeAsync(Guid userId, DateTime referenceDate, CancellationToken cancellationToken = default)
    {
        var startDate = referenceDate.Date.AddDays(-7);

        // Agregação semanal de séries de trabalho por grupo muscular primário
        const string sql = """
            SELECT 
                e.primary_muscle AS Muscle,
                COUNT(wsl.id) AS EffectiveSetsCount
            FROM workout_sessions s
            INNER JOIN workout_exercise_logs wel ON wel.workout_session_id = s.id
            INNER JOIN exercises e ON e.id = wel.exercise_id
            INNER JOIN workout_set_logs wsl ON wsl.workout_exercise_log_id = wel.id
            WHERE s.user_id = @UserId
              AND s.started_at >= @StartDate 
              AND s.started_at <= @ReferenceDate
              AND wsl.is_completed = true
              AND wsl.type != 2 -- Exclui WarmUp (aquecimento)
              AND wsl.repetitions > 0
            GROUP BY e.primary_muscle;
        """;

        var command = new CommandDefinition(
            sql, 
            new { UserId = userId, StartDate = startDate, ReferenceDate = referenceDate }, 
            cancellationToken: cancellationToken
        );

        var results = await _dbConnection.QueryAsync<RawWeeklyMuscleVolumeRow>(command);

        return results.Select(r =>
        {
            var muscle = (MuscleGroup)r.Muscle;
            return new MuscleWeeklyVolumeDto(
                muscle,
                muscle.ToString(),
                (int)r.EffectiveSetsCount
            );
        });
    }
}
