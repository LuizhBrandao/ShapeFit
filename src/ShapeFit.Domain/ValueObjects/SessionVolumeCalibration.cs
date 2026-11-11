namespace ShapeFit.Domain.ValueObjects;

/// <summary>
/// Objeto de Valor com os limites fisiológicos calibrados de exercícios e séries
/// para uma determinada duração de sessão de treino.
/// </summary>
public sealed record SessionVolumeCalibration(
    int DurationMinutes,
    int MinExercises,
    int MaxExercises,
    int TargetExerciseCount,
    int MinSets,
    int MaxSets,
    int TargetSets,
    string Rationale
);
