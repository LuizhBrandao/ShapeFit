using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Services;
using ShapeFit.Domain.ValueObjects;
using Xunit;

namespace ShapeFit.Domain.Tests;

public class VolumeCalibrationServiceTests
{
    [Theory]
    [InlineData(45, 4, 5, 13, 15)]
    [InlineData(60, 6, 7, 16, 20)]
    [InlineData(75, 7, 8, 20, 24)]
    [InlineData(90, 9, 10, 24, 30)]
    public void Calibrate_ShouldReturnStrictPhysiologicalLimits_ForDuration(
        int durationMinutes, 
        int expectedMinExercises, 
        int expectedMaxExercises, 
        int expectedMinSets, 
        int expectedMaxSets)
    {
        // Act
        var calibration = VolumeCalibrationService.Calibrate(durationMinutes);

        // Assert
        Assert.Equal(durationMinutes, calibration.DurationMinutes);
        Assert.Equal(expectedMinExercises, calibration.MinExercises);
        Assert.Equal(expectedMaxExercises, calibration.MaxExercises);
        Assert.Equal(expectedMinSets, calibration.MinSets);
        Assert.Equal(expectedMaxSets, calibration.MaxSets);
    }

    [Fact]
    public void AuditDayVolume_ShouldEvaluateComplianceCorrectly()
    {
        // Arrange: 45 min espera 4-5 exercícios e 13-15 séries
        var daySuboptimal = new RoutineDay(Guid.NewGuid(), "Treino Curto", 1);
        daySuboptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino", MuscleGroup.Chest, 1, 3, new RepRange(8, 12)));
        daySuboptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Crucifixo", MuscleGroup.Chest, 2, 3, new RepRange(8, 12)));
        // Total: 2 exercícios, 6 séries

        var dayOptimal = new RoutineDay(Guid.NewGuid(), "Treino Ideal", 2);
        dayOptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Ex 1", MuscleGroup.Chest, 1, 4, new RepRange(8, 12)));
        dayOptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Ex 2", MuscleGroup.Chest, 2, 4, new RepRange(8, 12)));
        dayOptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Ex 3", MuscleGroup.Shoulders, 3, 3, new RepRange(8, 12)));
        dayOptimal.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Ex 4", MuscleGroup.Triceps, 4, 3, new RepRange(8, 12)));
        // Total: 4 exercícios, 14 séries

        var dayJunkVolume = new RoutineDay(Guid.NewGuid(), "Treino Excessivo", 3);
        for (int i = 1; i <= 6; i++)
        {
            dayJunkVolume.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), $"Ex {i}", MuscleGroup.Chest, i, 4, new RepRange(8, 12)));
        }
        // Total: 6 exercícios, 24 séries

        // Act
        var auditSuboptimal = VolumeCalibrationService.AuditDayVolume(daySuboptimal, 45);
        var auditOptimal = VolumeCalibrationService.AuditDayVolume(dayOptimal, 45);
        var auditJunkVolume = VolumeCalibrationService.AuditDayVolume(dayJunkVolume, 45);

        // Assert
        Assert.Equal(VolumeCompliance.Suboptimal, auditSuboptimal.Compliance);
        Assert.Equal(VolumeCompliance.Optimal, auditOptimal.Compliance);
        Assert.Equal(VolumeCompliance.ExcessiveJunkVolume, auditJunkVolume.Compliance);
    }

    [Fact]
    public void RoutinePrescriptionService_PrescribeUpperLower_45Minutes_ShouldHave4ExercisesPerDay()
    {
        // Arrange
        var userId = Guid.NewGuid();

        // Act
        var routine = RoutinePrescriptionService.PrescribeRoutine(
            userId,
            "Rotina AB Rápida",
            WorkoutDivision.UpperLower,
            sessionDurationMinutes: 45
        );

        // Assert
        Assert.Equal(2, routine.Days.Count);
        var dayUpper = routine.Days.First(d => d.Order == 1);
        var dayLower = routine.Days.First(d => d.Order == 2);

        Assert.Equal(4, dayUpper.Exercises.Count);
        Assert.Equal(4, dayLower.Exercises.Count);
        Assert.True(routine.IsAiGenerated);
        Assert.True(routine.IsActive);
    }

    [Fact]
    public void RoutinePrescriptionService_PrescribePushPullLegs_60Minutes_ShouldHave6ExercisesPerDay()
    {
        // Arrange
        var userId = Guid.NewGuid();

        // Act
        var routine = RoutinePrescriptionService.PrescribeRoutine(
            userId,
            "Rotina ABC PPL 60min",
            WorkoutDivision.PushPullLegs,
            sessionDurationMinutes: 60
        );

        // Assert
        Assert.Equal(3, routine.Days.Count);
        foreach (var day in routine.Days)
        {
            Assert.Equal(6, day.Exercises.Count);
            Assert.Equal(18, day.TotalTargetSets); // 6 exercícios x 3 séries = 18 séries
        }
    }
}
