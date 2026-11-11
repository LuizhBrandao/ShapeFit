using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;

namespace ShapeFit.Infrastructure.Persistence.Configurations;

public class WorkoutSessionConfiguration : IEntityTypeConfiguration<WorkoutSession>
{
    public void Configure(EntityTypeBuilder<WorkoutSession> builder)
    {
        builder.ToTable("workout_sessions");

        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();

        builder.Property(x => x.UserId).IsRequired();
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.StartedAt).IsRequired();
        builder.Property(x => x.FinishedAt);
        builder.Property(x => x.Notes).HasMaxLength(1000);
        builder.Property(x => x.ClientSyncId).HasColumnName("client_sync_id");

        builder.HasIndex(x => new { x.UserId, x.StartedAt });
        builder.HasIndex(x => x.ClientSyncId).IsUnique().HasFilter("\"client_sync_id\" IS NOT NULL");

        builder.HasMany(x => x.Exercises)
            .WithOne()
            .HasForeignKey("workout_session_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.Metadata.FindNavigation(nameof(WorkoutSession.Exercises))!
            .SetPropertyAccessMode(PropertyAccessMode.Field);
    }
}

public class WorkoutExerciseLogConfiguration : IEntityTypeConfiguration<WorkoutExerciseLog>
{
    public void Configure(EntityTypeBuilder<WorkoutExerciseLog> builder)
    {
        builder.ToTable("workout_exercise_logs");

        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();

        builder.Property(x => x.ExerciseId).IsRequired();
        builder.Property(x => x.Order).IsRequired();
        builder.Property(x => x.Notes).HasMaxLength(500);

        builder.HasMany(x => x.Sets)
            .WithOne()
            .HasForeignKey("workout_exercise_log_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.Metadata.FindNavigation(nameof(WorkoutExerciseLog.Sets))!
            .SetPropertyAccessMode(PropertyAccessMode.Field);
    }
}

public class WorkoutSetLogConfiguration : IEntityTypeConfiguration<WorkoutSetLog>
{
    public void Configure(EntityTypeBuilder<WorkoutSetLog> builder)
    {
        builder.ToTable("workout_set_logs");

        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();

        builder.Property(x => x.SetOrder).IsRequired();
        builder.Property(x => x.Type).IsRequired();
        builder.Property(x => x.Repetitions).IsRequired();
        builder.Property(x => x.RepsInReserve);
        builder.Property(x => x.IsCompleted).IsRequired();
        builder.Property(x => x.CompletedAt);

        // Mapeamento do Value Object Weight
        builder.OwnsOne(x => x.Weight, weightBuilder =>
        {
            weightBuilder.Property(w => w.Value)
                .HasColumnName("weight_value")
                .HasPrecision(8, 2)
                .IsRequired();

            weightBuilder.Property(w => w.Unit)
                .HasColumnName("weight_unit")
                .HasMaxLength(10)
                .IsRequired();
        });
    }
}

public class ExerciseConfiguration : IEntityTypeConfiguration<Exercise>
{
    public void Configure(EntityTypeBuilder<Exercise> builder)
    {
        builder.ToTable("exercises");

        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();

        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(1000);
        builder.Property(x => x.PrimaryMuscle).IsRequired();
        builder.Property(x => x.MediaUrl).HasMaxLength(500);
        builder.Property(x => x.IsCustom).IsRequired();

        var secondaryMusclesConverter = new ValueConverter<List<MuscleGroup>, string>(
            v => string.Join(",", v.Select(m => (int)m)),
            v => string.IsNullOrEmpty(v)
                ? new List<MuscleGroup>()
                : v.Split(',', StringSplitOptions.RemoveEmptyEntries).Select(s => (MuscleGroup)int.Parse(s)).ToList()
        );

        var secondaryMusclesComparer = new ValueComparer<List<MuscleGroup>>(
            (c1, c2) => c1 != null && c2 != null && c1.SequenceEqual(c2),
            c => c.Aggregate(0, (a, v) => HashCode.Combine(a, (int)v)),
            c => c.ToList()
        );

        builder.Property<List<MuscleGroup>>("_secondaryMuscles")
            .HasColumnName("secondary_muscles")
            .HasConversion(secondaryMusclesConverter)
            .Metadata.SetValueComparer(secondaryMusclesComparer);
    }
}
