namespace ShapeFit.Domain.Enums;

/// <summary>
/// Modelos clássicos e customizados de divisões de treino (Workout Splits).
/// </summary>
public enum WorkoutDivision
{
    FullBody = 1,       // 1 a 3 dias - Corpo Inteiro
    UpperLower = 2,     // Divisão AB (Membros Superiores / Inferiores)
    PushPullLegs = 3,   // Divisão ABC (Push / Pull / Legs)
    ABCD = 4,           // 4 dias (Peito+Ombro / Costas+Trapézio / Pernas / Braços)
    ABCDE = 5,          // 5 dias (Isolamento Máximo por grupo)
    Custom = 99         // Divisão customizada personalizada pelo usuário
}
