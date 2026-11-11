using ShapeFit.Domain.Enums;

namespace ShapeFit.Application.Workouts.DTOs;

public record PreviousSetDto(
    int SetOrder,
    SetType Type,
    decimal Weight,
    string Unit,
    int Repetitions,
    int? RepsInReserve
);

public record LastExercisePerformanceDto(
    Guid ExerciseId,
    string ExerciseName,
    DateTime PerformedAt,
    IReadOnlyList<PreviousSetDto> Sets
);

public record MuscleWeeklyVolumeDto(
    MuscleGroup Muscle,
    string MuscleName,
    int EffectiveSetsCount
);
