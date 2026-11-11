using Microsoft.EntityFrameworkCore;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;

namespace ShapeFit.Infrastructure.Persistence.Repositories;

public class MesocycleRepository : IMesocycleRepository
{
    private readonly ShapeFitDbContext _context;

    public MesocycleRepository(ShapeFitDbContext context)
    {
        _context = context;
    }

    public async Task<Mesocycle?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.Mesocycles
            .FirstOrDefaultAsync(m => m.Id == id, cancellationToken);
    }

    public async Task<Mesocycle?> GetActiveByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.Mesocycles
            .Where(m => m.UserId == userId && m.Status == MesocycleStatus.Active)
            .OrderByDescending(m => m.StartedAt)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task<Mesocycle?> GetActiveByRoutineIdAsync(Guid routineTemplateId, CancellationToken cancellationToken = default)
    {
        return await _context.Mesocycles
            .Where(m => m.RoutineTemplateId == routineTemplateId && m.Status == MesocycleStatus.Active)
            .OrderByDescending(m => m.StartedAt)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task AddAsync(Mesocycle mesocycle, CancellationToken cancellationToken = default)
    {
        await _context.Mesocycles.AddAsync(mesocycle, cancellationToken);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
