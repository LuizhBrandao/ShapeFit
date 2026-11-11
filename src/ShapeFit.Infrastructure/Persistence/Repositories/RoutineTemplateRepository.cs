using Microsoft.EntityFrameworkCore;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Domain.Entities;

namespace ShapeFit.Infrastructure.Persistence.Repositories;

public class RoutineTemplateRepository : IRoutineTemplateRepository
{
    private readonly ShapeFitDbContext _context;

    public RoutineTemplateRepository(ShapeFitDbContext context)
    {
        _context = context;
    }

    public async Task<RoutineTemplate?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.RoutineTemplates
            .Include(r => r.Days)
            .ThenInclude(d => d.Exercises)
            .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);
    }

    public async Task<RoutineTemplate?> GetActiveByUserIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _context.RoutineTemplates
            .Include(r => r.Days)
            .ThenInclude(d => d.Exercises)
            .Where(r => r.UserId == userId && r.IsActive)
            .OrderByDescending(r => r.CreatedAt)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public async Task AddAsync(RoutineTemplate template, CancellationToken cancellationToken = default)
    {
        await _context.RoutineTemplates.AddAsync(template, cancellationToken);
    }

    public async Task SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        await _context.SaveChangesAsync(cancellationToken);
    }
}
