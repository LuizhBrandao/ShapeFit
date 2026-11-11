using ShapeFit.Domain.Entities;

namespace ShapeFit.Application.Common.Interfaces;

public interface IWorkoutSessionRepository
{
    Task<WorkoutSession?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<WorkoutSession?> GetByClientSyncIdAsync(Guid clientSyncId, CancellationToken cancellationToken = default);
    Task AddAsync(WorkoutSession session, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
