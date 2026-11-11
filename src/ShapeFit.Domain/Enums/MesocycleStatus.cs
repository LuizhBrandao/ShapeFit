namespace ShapeFit.Domain.Enums;

/// <summary>
/// Ciclo de vida e estado de um Mesociclo de Treino.
/// </summary>
public enum MesocycleStatus
{
    Active = 1,       // Em andamento
    Completed = 2,    // Concluído (atingiu a meta de 30 treinos)
    Cancelled = 3     // Cancelado/Interrompido precocemente
}
