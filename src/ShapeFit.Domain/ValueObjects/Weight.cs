namespace ShapeFit.Domain.ValueObjects;

/// <summary>
/// Objeto de Valor imutável para Carga/Peso.
/// Garante consistência de valores e conversão entre kg e lbs.
/// </summary>
public sealed record Weight
{
    public decimal Value { get; }
    public string Unit { get; }

    private Weight(decimal value, string unit)
    {
        if (value < 0)
            throw new ArgumentException("O peso não pode ser negativo.", nameof(value));

        Value = Math.Round(value, 2);
        Unit = unit.ToLowerInvariant();
    }

    public static Weight FromKilograms(decimal value) => new(value, "kg");
    public static Weight FromPounds(decimal value) => new(value, "lbs");

    public Weight ToKilograms() => Unit == "kg" ? this : FromKilograms(Value * 0.45359237m);
    public Weight ToPounds() => Unit == "lbs" ? this : FromPounds(Value / 0.45359237m);

    public override string ToString() => $"{Value} {Unit}";
}
