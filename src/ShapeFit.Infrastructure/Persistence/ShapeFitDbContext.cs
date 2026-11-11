using System.Reflection;
using Microsoft.EntityFrameworkCore;
using ShapeFit.Domain.Common;
using ShapeFit.Domain.Entities;

namespace ShapeFit.Infrastructure.Persistence;

public class ShapeFitDbContext : DbContext
{
    public DbSet<WorkoutSession> WorkoutSessions => Set<WorkoutSession>();
    public DbSet<WorkoutExerciseLog> WorkoutExerciseLogs => Set<WorkoutExerciseLog>();
    public DbSet<WorkoutSetLog> WorkoutSetLogs => Set<WorkoutSetLog>();
    public DbSet<Exercise> Exercises => Set<Exercise>();
    public DbSet<RoutineTemplate> RoutineTemplates => Set<RoutineTemplate>();
    public DbSet<RoutineDay> RoutineDays => Set<RoutineDay>();
    public DbSet<RoutineExercise> RoutineExercises => Set<RoutineExercise>();
    public DbSet<Mesocycle> Mesocycles => Set<Mesocycle>();

    public ShapeFitDbContext(DbContextOptions<ShapeFitDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Ignore<IDomainEvent>();
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
        base.OnModelCreating(modelBuilder);
    }
}
