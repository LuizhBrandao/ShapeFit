namespace ShapeFit.Domain.ValueObjects;

/// <summary>
/// Objeto de Valor (Value Object) imutável para a faixa de repetições planejada (ex: 8-12 reps).
/// </summary>
public sealed record RepRange
{
    public int MinReps { get; }
    public int MaxReps { get; }

    public RepRange(int minReps, int maxReps)
    {
        if (minReps <= 0)
            throw new ArgumentOutOfRangeException(nameof(minReps), "Repetições mínimas devem ser maiores que zero.");
        if (maxReps < minReps)
            throw new ArgumentException("Repetições máximas não podem ser menores que repetições mínimas.", nameof(maxReps));

        MinReps = minReps;
        MaxReps = maxReps;
    }

    public static RepRange Exact(int reps) => new(reps, reps);

    public static RepRange Parse(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return new RepRange(8, 12); // Padrão de hipertrofia padrão

        var trimmed = value.Trim();
        var parts = trimmed.Split(new[] { '-', 'a', 'A', 'x', 'X' }, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

        if (parts.Length == 2 && int.TryParse(parts[0], out var min) && int.TryParse(parts[1], out var max))
        {
            if (min > 0 && max >= min)
                return new RepRange(min, max);
        }

        if (parts.Length == 1 && int.TryParse(parts[0], out var exact) && exact > 0)
        {
            return new RepRange(exact, exact);
        }

        return new RepRange(8, 12);
    }

    public override string ToString() => MinReps == MaxReps ? $"{MinReps}" : $"{MinReps}-{MaxReps}";
}
