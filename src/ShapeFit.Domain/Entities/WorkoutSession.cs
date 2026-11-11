namespace ShapeFit.Domain.Entities;

/// <summary>
/// Raiz do Agregado: Sessão de Treino.
/// Gerencia a integridade da sessão, controle de tempo e idempotência para sincronização offline.
/// </summary>
public class WorkoutSession
{
    public Guid Id { get; private set; }
    public Guid UserId { get; private set; }
    public string Name { get; private set; } = string.Empty;
    public DateTime StartedAt { get; private set; }
    public DateTime? FinishedAt { get; private set; }
    public TimeSpan Duration => FinishedAt.HasValue ? FinishedAt.Value - StartedAt : DateTime.UtcNow - StartedAt;
    public string? Notes { get; private set; }
    public Guid? ClientSyncId { get; private set; } // UUID gerado pelo app Flutter para idempotência offline

    public IReadOnlyCollection<WorkoutExerciseLog> Exercises => _exercises.AsReadOnly();
    private readonly List<WorkoutExerciseLog> _exercises = new();

    private WorkoutSession() { }

    public WorkoutSession(Guid id, Guid userId, string name, DateTime startedAt, Guid? clientSyncId = null, string? notes = null)
    {
        if (userId == Guid.Empty)
            throw new ArgumentException("O usuário é obrigatório.", nameof(userId));
        if (string.IsNullOrWhiteSpace(name))
            throw new ArgumentException("O nome do treino não pode ser vazio.", nameof(name));

        Id = id == Guid.Empty ? Guid.NewGuid() : id;
        UserId = userId;
        Name = name.Trim();
        StartedAt = startedAt;
        ClientSyncId = clientSyncId;
        Notes = notes;
    }

    public void AddExercise(WorkoutExerciseLog exerciseLog)
    {
        ArgumentNullException.ThrowIfNull(exerciseLog);
        _exercises.Add(exerciseLog);
    }

    public void FinishSession(DateTime finishedAt)
    {
        if (finishedAt < StartedAt)
            throw new InvalidOperationException("A data de término não pode ser anterior à data de início.");

        FinishedAt = finishedAt;
    }

    public decimal GetTotalSessionVolume() => _exercises.Sum(e => e.GetTotalVolume());
}
