using ShapeFit.Domain.Common;

namespace ShapeFit.Domain.Events;

/// <summary>
/// Evento de Domínio disparado quando um mesociclo atinge a meta planejada de treinos (padrão 30 sessões),
/// sinalizando a necessidade de recalibração de volume, deload ou progressão pela IA.
/// </summary>
public sealed record MesocycleCompletedEvent(
    Guid MesocycleId,
    Guid UserId,
    Guid RoutineTemplateId,
    int CycleNumber,
    int TotalCompletedSessions,
    DateTime CompletedAt
) : IDomainEvent
{
    public DateTime OccurredOn { get; } = DateTime.UtcNow;
}
