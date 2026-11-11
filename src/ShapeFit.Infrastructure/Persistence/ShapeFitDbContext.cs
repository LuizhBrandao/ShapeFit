using System.Reflection;
using Microsoft.EntityFrameworkCore;
using ShapeFit.Domain.Entities;

namespace ShapeFit.Infrastructure.Persistence;

public class ShapeFitDbContext : DbContext
{
    public DbSet<WorkoutSession> WorkoutSessions => Set<WorkoutSession>();
    public DbSet<WorkoutExerciseLog> WorkoutExerciseLogs => Set<WorkoutExerciseLog>();
    public DbSet<WorkoutSetLog> WorkoutSetLogs => Set<WorkoutSetLog>();
    public DbSet<Exercise> Exercises => Set<Exercise>();

    public ShapeFitDbContext(DbContextOptions<ShapeFitDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
        base.OnModelCreating(modelBuilder);
    }
}
