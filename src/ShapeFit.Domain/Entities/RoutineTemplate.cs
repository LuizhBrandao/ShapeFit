using ShapeFit.Domain.Common;
using ShapeFit.Domain.Enums;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Raiz do Agregado: Ficha de Treino / Molde Planejado (Routine Template).
/// Modela a estrutura da rotina (ex: Push/Pull/Legs, AB, ABCD, etc.) com seus dias e exercícios planejados.
/// </summary>
public class RoutineTemplate : AggregateRoot
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string Description { get; private set; } = string.Empty;
    public WorkoutDivision Division { get; private set; }
    public bool IsActive { get; private set; }
    public bool IsAiGenerated { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime? UpdatedAt { get; private set; }

    public IReadOnlyCollection<RoutineDay> Days => _days.OrderBy(d => d.Order).ToList().AsReadOnly();
    private readonly List<RoutineDay> _days = new();

    private RoutineTemplate() { }

    public RoutineTemplate(
        Guid id,
        Guid userId,
        string name,
        string description,
        WorkoutDivision division,
        bool isAiGenerated = false)
    {
        if (userId == Guid.Empty)
            throw new ArgumentException("O usuário proprietário da rotina é obrigatório.", nameof(userId));
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("O nome da rotina não pode ser vazio.", nameof(name));

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        UserId = userId;
        Name = name.Trim();
        Description = description?.Trim() ?? string.Empty;
        Division = division;
        IsActive = true;
        IsAiGenerated = isAiGenerated;
        CreatedAt = DateTime.UtcNow;
    }

    public void AddDay(RoutineDay day)
    {
        ArgumentNullException.ThrowIfNull(day);

        if (_days.Any(d => d.Name.Equals(day.Name, StringComparison.OrdinalIgnoreCase)))
            throw new InvalidOperationException($"Já existe um dia com o nome '{day.Name}' nesta rotina.");

        _days.Add(day);
        UpdatedAt = DateTime.UtcNow;
    }

    public void RemoveDay(Guid dayId)
    {
        _days.RemoveAll(d => d.Id == dayId);
        UpdatedAt = DateTime.UtcNow;
    }

    public void Deactivate()
    {
        IsActive = false;
        UpdatedAt = DateTime.UtcNow;
    }

    public void Activate()
    {
        IsActive = true;
        UpdatedAt = DateTime.UtcNow;
    }

    public void UpdateDetails(string name, string description, WorkoutDivision division)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("O nome da rotina não pode ser vazio.", nameof(name));

        Name = name.Trim();
        Description = description?.Trim() ?? string.Empty;
        Division = division;
        UpdatedAt = DateTime.UtcNow;
    }

    public int TotalExercisesCount => _days.Sum(d => d.Exercises.Count);
    public int TotalTargetSets => _days.Sum(d => d.TotalTargetSets);
}
