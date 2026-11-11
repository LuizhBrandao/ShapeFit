using System.Data;
using Dapper;
using Microsoft.Extensions.Configuration;
using Npgsql;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Workouts.DTOs;
using ShapeFit.Domain.Enums;

namespace ShapeFit.Infrastructure.Persistence.Repositories;

public class WorkoutReadRepository : IWorkoutReadRepository
{
    private readonly string _connectionString;

    public WorkoutReadRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection") 
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' não encontrada.");
    }

    private IDbConnection CreateConnection() => new NpgsqlConnection(_connectionString);

    public async Task<LastExercisePerformanceDto?> GetLastPerformanceAsync(Guid userId, Guid exerciseId, CancellationToken cancellationToken = default)
    {
        using var connection = CreateConnection();

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

        var rows = await connection.QueryAsync<dynamic>(sql, new { UserId = userId, ExerciseId = exerciseId });
        var rowsList = rows.ToList();

        if (!rowsList.Any())
            return null;

        var first = rowsList.First();
        var sets = rowsList.Select(r => new PreviousSetDto(
            (int)r.setorder,
            (SetType)(int)r.type,
            (decimal)r.weight,
            (string)r.unit,
            (int)r.repetitions,
            r.repsinreserve != null ? (int?)r.repsinreserve : null
        )).ToList();

        return new LastExercisePerformanceDto(
            (Guid)first.exerciseid,
            (string)first.exercisename,
            (DateTime)first.performedat,
            sets
        );
    }

    public async Task<IEnumerable<MuscleWeeklyVolumeDto>> GetWeeklyMuscleVolumeAsync(Guid userId, DateTime referenceDate, CancellationToken cancellationToken = default)
    {
        using var connection = CreateConnection();

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

        var results = await connection.QueryAsync<dynamic>(sql, new { UserId = userId, StartDate = startDate, ReferenceDate = referenceDate });

        return results.Select(r =>
        {
            var muscle = (MuscleGroup)(int)r.muscle;
            return new MuscleWeeklyVolumeDto(
                muscle,
                muscle.ToString(),
                (int)r.effectivesetscount
            );
        });
    }
}
