using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Services;
using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Representa uma série executada dentro de um treino.
/// Suporta pré-preenchimento, tipos rápidos (WarmUp, Normal, DropSet, Failure) e autorregulação (RIR).
/// </summary>
public class WorkoutSetLog
{
    public Guid Id { get; private set; }
    public int SetOrder { get; private set; }
    public SetType Type { get; private set; }
    public Weight Weight { get; private set; }
    public int Repetitions { get; private set; }
    public int? RepsInReserve { get; private set; } // RIR (0 a 5)
    public bool IsCompleted { get; private set; }
    public DateTime? CompletedAt { get; private set; }

    private WorkoutSetLog() 
    {
        Weight = Weight.FromKilograms(0);
    }

    public WorkoutSetLog(Guid id, int setOrder, SetType type, Weight weight, int repetitions, int? repsInReserve = null)
    {
        if (setOrder <= 0)
            throw new ArgumentOutOfRangeException(nameof(setOrder), "A ordem da série deve ser maior que zero.");
        if (repetitions < 0)
            throw new ArgumentOutOfRangeException(nameof(repetitions), "O número de repetições não pode ser negativo.");

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        SetOrder = setOrder;
        Type = type;
        Weight = weight ?? throw new ArgumentNullException(nameof(weight));
        Repetitions = repetitions;
        RepsInReserve = repsInReserve;
    }

    public void MarkCompleted()
    {
        IsCompleted = true;
        CompletedAt = DateTime.UtcNow;
    }

    /// <summary>
    /// Volume total da série (Carga x Repetições).
    /// </summary>
    public decimal CalculateVolume() => Weight.Value * Repetitions;

    /// <summary>
    /// 1RM estimado da série.
    /// </summary>
    public Weight GetEstimatedOneRepMax() => OneRepMaxCalculator.CalculateEpley(Weight, Repetitions);

    /// <summary>
    /// Indica se a série conta como volume efetivo para hipertrofia (séries de trabalho, não de aquecimento).
    /// </summary>
    public bool IsEffectiveSet() => IsCompleted && Type != SetType.WarmUp && Repetitions > 0;
}
