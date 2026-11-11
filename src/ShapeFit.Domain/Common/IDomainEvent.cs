namespace ShapeFit.Domain.Common;

/// <summary>
/// Contrato base para eventos de domínio ocorridos no núcleo de negócio.
/// </summary>
public interface IDomainEvent
{
    DateTime OccurredOn { get; }
}
