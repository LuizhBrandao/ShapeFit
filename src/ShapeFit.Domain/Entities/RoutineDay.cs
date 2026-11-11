namespace ShapeFit.Domain.Entities;

/// <summary>
/// Entidade interna do agregado de rotina: representa um dia específico de treino dentro da divisão (ex.: Treino A - Push).
/// </summary>
public class RoutineDay
{
    public Guid Id { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public int Order { get; private set; }
    public string? Description { get; private set; }

    public IReadOnlyCollection<RoutineExercise> Exercises => _exercises.OrderBy(e => e.Order).ToList().AsReadOnly();
    private readonly List<RoutineExercise> _exercises = new();

    private RoutineDay() { }

    public RoutineDay(Guid id, string name, int order, string? description = null)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("O nome do dia de treino é obrigatório.", nameof(name));
        if (order <= 0)
            throw new ArgumentOutOfRangeException(nameof(order), "A ordem do dia deve ser maior que zero.");

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        Name = name.Trim();
        Order = order;
        Description = description?.Trim();
    }

    public void AddExercise(RoutineExercise exercise)
    {
        ArgumentNullException.ThrowIfNull(exercise);
        _exercises.Add(exercise);
    }

    public void RemoveExercise(Guid routineExerciseId)
    {
        _exercises.RemoveAll(e => e.Id == routineExerciseId || e.ExerciseId == routineExerciseId);
    }

    public int TotalTargetSets => _exercises.Sum(e => e.TargetSets);
}
