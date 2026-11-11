using Microsoft.EntityFrameworkCore;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Domain.Entities;

namespace ShapeFit.Infrastructure.Persistence.Repositories;

public class WorkoutSessionRepository : IWorkoutSessionRepository
{
    private readonly ShapeFitDbContext _context;

    public WorkoutSessionRepository(ShapeFitDbContext context)
    {
        _context = context;
    }

    public async Task<WorkoutSession?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.WorkoutSessions
            .Include(s => s.Exercises)
            .ThenInclude(e => e.Sets)
            .FirstOrDefaultAsync(s => s.Id == id, cancellationToken);
    }

    public async Task<WorkoutSession?> GetByClientSyncIdAsync(Guid clientSyncId, CancellationToken cancellationToken = default)
    {
        return await _context.WorkoutSessions
            .FirstOrDefaultAsync(s => s.ClientSyncId == clientSyncId, cancellationToken);
    }

    public async Task AddAsync(WorkoutSession session, CancellationToken cancellationToken = default)
    {
        await _context.WorkoutSessions.AddAsync(session, cancellationToken);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
