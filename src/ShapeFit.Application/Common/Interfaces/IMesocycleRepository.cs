using ShapeFit.Domain.Entities;

namespace ShapeFit.Application.Common.Interfaces;

public interface IMesocycleRepository
{
    Task<Mesocycle?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<Mesocycle?> GetActiveByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<Mesocycle?> GetActiveByRoutineIdAsync(Guid routineTemplateId, CancellationToken cancellationToken = default);
    Task AddAsync(Mesocycle mesocycle, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
