using ShapeFit.Domain.Common;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Events;

namespace ShapeFit.Domain.Entities;

/// <summary>
/// Raiz do Agregado: Mesociclo de Treino.
/// Gerencia a periodização e o ciclo de sessões (padrão 30 treinos) por rotina/ficha,
/// garantindo consistência transacional e disparando o evento MesocycleCompletedEvent ao ser concluído.
/// </summary>
public class Mesocycle : AggregateRoot
{
    public const int DefaultTargetSessionsCount = 30;

    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public Guid RoutineTemplateId { get; private set; }
    public int CycleNumber { get; private set; }
    public int TargetSessionsCount { get; private set; }
    public int CompletedSessionsCount { get; private set; }
    public MesocycleStatus Status { get; private set; }
    public DateTime StartedAt { get; private set; }
    public DateTime? FinishedAt { get; private set; }
    public string? Goal { get; private set; }

    public double ProgressRatio => TargetSessionsCount > 0 
        ? Math.Clamp((double)CompletedSessionsCount / TargetSessionsCount, 0.0, 1.0) 
        : 0.0;

    public bool IsCompleted => Status == MesocycleStatus.Completed;

    private Mesocycle() { }

    public Mesocycle(
        Guid id,
        Guid userId,
        Guid routineTemplateId,
        int cycleNumber = 1,
        int targetSessionsCount = DefaultTargetSessionsCount,
        DateTime? startedAt = null,
        string? goal = null)
    {
        if (userId == Guid.Empty)
            throw new ArgumentException("O usuário proprietário do mesociclo é obrigatório.", nameof(userId));
        if (routineTemplateId == Guid.Empty)
            throw new ArgumentException("A rotina vinculada ao mesociclo é obrigatória.", nameof(routineTemplateId));
        if (cycleNumber <= 0)
            throw new ArgumentOutOfRangeException(nameof(cycleNumber), "O número do ciclo deve ser maior que zero.");
        if (targetSessionsCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(targetSessionsCount), "A meta de sessões do mesociclo deve ser maior que zero.");

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        UserId = userId;
        RoutineTemplateId = routineTemplateId;
        CycleNumber = cycleNumber;
        TargetSessionsCount = targetSessionsCount;
        CompletedSessionsCount = 0;
        Status = MesocycleStatus.Active;
        StartedAt = startedAt ?? DateTime.UtcNow;
        Goal = goal?.Trim();
    }

    /// <summary>
    /// Registra a conclusão de uma sessão de treino neste mesociclo.
    /// Se a meta for atingida (ex: 30 treinos), o mesociclo é marcado como concluído
    /// e o evento de domínio MesocycleCompletedEvent é emitido.
    /// </summary>
    public void RecordSessionCompletion(Guid sessionId, DateTime completedAt)
    {
        if (sessionId == Guid.Empty)
            throw new ArgumentException("O ID da sessão de treino é obrigatório.", nameof(sessionId));

        if (Status != MesocycleStatus.Active)
            throw new InvalidOperationException($"Não é possível registrar sessões em um mesociclo com status '{Status}'.");

        CompletedSessionsCount++;

        if (CompletedSessionsCount >= TargetSessionsCount)
        {
            Status = MesocycleStatus.Completed;
            FinishedAt = completedAt;

            RaiseDomainEvent(new MesocycleCompletedEvent(
                Id,
                UserId,
                RoutineTemplateId,
                CycleNumber,
                CompletedSessionsCount,
                completedAt
            ));
        }
    }

    /// <summary>
    /// Cancela o mesociclo ativo caso o usuário troque de ficha ou decida reiniciar a periodização.
    /// </summary>
    public void Cancel(string? reason = null)
    {
        if (Status != MesocycleStatus.Active)
            throw new InvalidOperationException("Apenas mesociclos ativos podem ser cancelados.");

        Status = MesocycleStatus.Cancelled;
        FinishedAt = DateTime.UtcNow;
    }
}
