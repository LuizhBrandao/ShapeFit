using ShapeFit.Domain.Enums;
using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Entidade interna do agregado de rotina: representa a prescrição planejada de um exercício para um dia específico.
/// </summary>
public class RoutineExercise
{
    public Guid Id { get; private set; }
    public Guid ExerciseId { get; private set; }
    public string CustomExerciseName { get; private set; } = string.Empty;
    public MuscleGroup TargetMuscle { get; private set; }
    public int Order { get; private set; }
    public int TargetSets { get; private set; }
    public RepRange RepRange { get; private set; } = null!;
    public int? TargetRir { get; private set; } // Repetições em reserva alvo (ex: 1 ou 2)
    public int RestIntervalSeconds { get; private set; } // Descanso planejado em segundos
    public string? Notes { get; private set; }

    private RoutineExercise() { }

    public RoutineExercise(
        Guid id,
        Guid exerciseId,
        string customExerciseName,
        MuscleGroup targetMuscle,
        int order,
        int targetSets,
        RepRange repRange,
        int? targetRir = null,
        int restIntervalSeconds = 90,
        string? notes = null)
    {
        if (exerciseId == Guid.Empty)
            throw new ArgumentException("O exercício de referência é obrigatório.", nameof(exerciseId));
        if (string.IsNullOrWhiteSpace(customExerciseName))
            throw new ArgumentException("O nome do exercício não pode ser vazio.", nameof(customExerciseName));
        if (order <= 0)
            throw new ArgumentOutOfRangeException(nameof(order), "A ordem de execução deve ser maior que zero.");
        if (targetSets <= 0)
            throw new ArgumentOutOfRangeException(nameof(targetSets), "O número de séries deve ser maior que zero.");
        if (restIntervalSeconds < 0)
            throw new ArgumentOutOfRangeException(nameof(restIntervalSeconds), "O descanso não pode ser negativo.");

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        ExerciseId = exerciseId;
        CustomExerciseName = customExerciseName.Trim();
        TargetMuscle = targetMuscle;
        Order = order;
        TargetSets = targetSets;
        RepRange = repRange ?? throw new ArgumentNullException(nameof(repRange));
        TargetRir = targetRir;
        RestIntervalSeconds = restIntervalSeconds;
        Notes = notes?.Trim();
    }

    public void UpdateConfiguration(int targetSets, RepRange repRange, int? targetRir, int restIntervalSeconds, string? notes)
    {
        if (targetSets <= 0)
            throw new ArgumentOutOfRangeException(nameof(targetSets), "O número de séries deve ser maior que zero.");
        if (restIntervalSeconds < 0)
            throw new ArgumentOutOfRangeException(nameof(restIntervalSeconds), "O descanso não pode ser negativo.");

        TargetSets = targetSets;
        RepRange = repRange ?? throw new ArgumentNullException(nameof(repRange));
        TargetRir = targetRir;
        RestIntervalSeconds = restIntervalSeconds;
        Notes = notes?.Trim();
    }
}
