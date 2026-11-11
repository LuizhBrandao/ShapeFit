using ShapeFit.Domain.Enums;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Exercício com mapeamento anatômico para visualização e heatmap.
/// </summary>
public class Exercise
{
    public Guid Id { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public string Description { get; private set; } = string.Empty;
    public MuscleGroup PrimaryMuscle { get; private set; }
    public IReadOnlyCollection<MuscleGroup> SecondaryMuscles => _secondaryMuscles.AsReadOnly();
    public string? MediaUrl { get; private set; }
    public bool IsCustom { get; private set; }

    private readonly List<MuscleGroup> _secondaryMuscles = new();

    private Exercise() { }

    public Exercise(Guid id, string name, string description, MuscleGroup primaryMuscle, IEnumerable<MuscleGroup>? secondaryMuscles = null, string? mediaUrl = null, bool isCustom = false)
    {
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("O nome do exercício não pode ser vazio.", nameof(name));

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        Name = name.Trim();
        Description = description?.Trim() ?? string.Empty;
        PrimaryMuscle = primaryMuscle;
        MediaUrl = mediaUrl;
        IsCustom = isCustom;

        if (secondaryMuscles != null)
        {
            _secondaryMuscles.AddRange(secondaryMuscles.Distinct().Where(m => m != primaryMuscle));
        }
    }
}
