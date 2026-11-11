using ShapeFit.Domain.Entities;

namespace ShapeFit.Application.Common.Interfaces;

public interface IRoutineTemplateRepository
{
    Task<RoutineTemplate?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<RoutineTemplate?> GetActiveByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task AddAsync(RoutineTemplate template, CancellationToken cancellationToken = default);
    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
