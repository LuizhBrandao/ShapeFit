using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Domain.Services;

/// <summary>
/// Serviço de domínio para estimativa de 1RM (One Repetition Max) e cálculo de volume.
/// Implementa as fórmulas consagradas de Epley e Brzycki.
/// </summary>
public static class OneRepMaxCalculator
{
    /// <summary>
    /// Calcula 1RM estimado utilizando a fórmula de Epley: Peso * (1 + Reps / 30).
    /// </summary>
    public static Weight CalculateEpley(Weight weight, int reps)
    {
        if (reps <= 0) return weight;
        if (reps == 1) return weight;

        var estimatedValue = weight.Value * (1m + (decimal)reps / 30m);
        return weight.Unit == "kg" 
            ? Weight.FromKilograms(Math.Round(estimatedValue, 2)) 
            : Weight.FromPounds(Math.Round(estimatedValue, 2));
    }

    /// <summary>
    /// Calcula 1RM estimado utilizando a fórmula de Brzycki: Peso * (36 / (37 - Reps)).
    /// </summary>
    public static Weight CalculateBrzycki(Weight weight, int reps)
    {
        if (reps <= 0) return weight;
        if (reps >= 37) throw new ArgumentOutOfRangeException(nameof(reps), "Fórmula de Brzycki é aplicável para até 36 repetições.");

        var estimatedValue = weight.Value * (36m / (37m - (decimal)reps));
        return weight.Unit == "kg" 
            ? Weight.FromKilograms(Math.Round(estimatedValue, 2)) 
            : Weight.FromPounds(Math.Round(estimatedValue, 2));
    }
}
