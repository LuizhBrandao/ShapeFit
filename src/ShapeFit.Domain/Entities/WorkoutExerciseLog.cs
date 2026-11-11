using ShapeFit.Domain.Enums;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Agrupador de séries de um exercício específico dentro de uma sessão de treino.
/// </summary>
public class WorkoutExerciseLog
{
    public Guid Id { get; private set; }
    public Guid ExerciseId { get; private set; }
    public int Order { get; private set; }
    public string? Notes { get; private set; }
    public IReadOnlyCollection<WorkoutSetLog> Sets => _sets.AsReadOnly();

    private readonly List<WorkoutSetLog> _sets = new();

    private WorkoutExerciseLog() { }

    public WorkoutExerciseLog(Guid id, Guid exerciseId, int order, string? notes = null)
    {
        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        ExerciseId = exerciseId;
        Order = order;
        Notes = notes;
    }

    public void AddSet(WorkoutSetLog set)
    {
        ArgumentNullException.ThrowIfNull(set);
        _sets.Add(set);
    }

    public int GetEffectiveSetsCount() => _sets.Count(s => s.IsEffectiveSet());
    public decimal GetTotalVolume() => _sets.Where(s => s.IsCompleted).Sum(s => s.CalculateVolume());
}
