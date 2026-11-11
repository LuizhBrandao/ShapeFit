using ShapeFit.Application.Workouts.DTOs;

namespace ShapeFit.Application.Common.Interfaces;

public interface IWorkoutReadRepository
{
    /// <summary>
    /// Busca de alta performance via Dapper do histórico anterior daquele exercício para o usuário,
    /// permitindo pré-preenchimento inteligente de carga e repetições na UI do mobile.
    /// </summary>
    Task<LastExercisePerformanceDto?> GetLastPerformanceAsync(Guid userId, Guid exerciseId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Consulta o resumo semanal de séries efetivas por grupo muscular.
    /// </summary>
    Task<IEnumerable<MuscleWeeklyVolumeDto>> GetWeeklyMuscleVolumeAsync(Guid userId, DateTime referenceDate, CancellationToken cancellationToken = default);
}
