using ShapeFit.Domain.Enums;

namespace ShapeFit.Application.Routines.DTOs;

public record RoutineExerciseDto(
    Guid Id,
    Guid ExerciseId,
    string CustomExerciseName,
    MuscleGroup TargetMuscle,
    int Order,
    int TargetSets,
    string RepRange,
    int? TargetRir,
    int RestIntervalSeconds,
    string? Notes
);

public record RoutineDayDto(
    Guid Id,
    string Name,
    int Order,
    string? Description,
    int TotalTargetSets,
    IReadOnlyList<RoutineExerciseDto> Exercises
);

public record RoutineTemplateDto(
    Guid Id,
    Guid UserId,
    string Name,
    string Description,
    WorkoutDivision Division,
    bool IsActive,
    bool IsAiGenerated,
    DateTime CreatedAt,
    int TotalExercisesCount,
    int TotalTargetSets,
    IReadOnlyList<RoutineDayDto> Days
);

public record MesocycleProgressDto(
    Guid Id,
    Guid UserId,
    Guid RoutineTemplateId,
    int CycleNumber,
    int TargetSessionsCount,
    int CompletedSessionsCount,
    double ProgressRatio,
    MesocycleStatus Status,
    DateTime StartedAt,
    DateTime? FinishedAt,
    string? Goal
);

public record PrescribeRoutineResponse(
    Guid RoutineTemplateId,
    Guid MesocycleId,
    string RoutineName,
    WorkoutDivision Division,
    int TotalDays,
    int TotalTargetSets,
    string VolumeRationale
);
