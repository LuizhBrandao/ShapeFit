using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.ValueObjects;
using Xunit;

namespace ShapeFit.Domain.Tests;

public class RoutineTemplateDomainTests
{
    [Fact]
    public void RepRange_ValidRange_ShouldInstantiateAndFormatCorrectly()
    {
        // Act
        var range = new RepRange(8, 12);
        var exact = RepRange.Exact(10);
        var parsedRange = RepRange.Parse("6-10");
        var parsedExact = RepRange.Parse("12");

        // Assert
        Assert.Equal(8, range.MinReps);
        Assert.Equal(12, range.MaxReps);
        Assert.Equal("8-12", range.ToString());

        Assert.Equal(10, exact.MinReps);
        Assert.Equal(10, exact.MaxReps);
        Assert.Equal("10", exact.ToString());

        Assert.Equal(6, parsedRange.MinReps);
        Assert.Equal(10, parsedRange.MaxReps);

        Assert.Equal(12, parsedExact.MinReps);
        Assert.Equal(12, parsedExact.MaxReps);
    }

    [Fact]
    public void RepRange_InvalidRange_ShouldThrowException()
    {
        // Assert
        Assert.Throws<ArgumentOutOfRangeException>(() => new RepRange(0, 10));
        Assert.Throws<ArgumentException>(() => new RepRange(12, 8));
    }

    [Fact]
    public void RoutineTemplate_CreateWithDaysAndExercises_ShouldCalculateTotalsCorrectly()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var template = new RoutineTemplate(
            Guid.NewGuid(),
            userId,
            "Divisão ABC Clássica (PPL)",
            "Push, Pull e Legs para hipertrofia",
            WorkoutDivision.PushPullLegs,
            isAiGenerated: true
        );

        var pushDay = new RoutineDay(Guid.NewGuid(), "Treino A • Push", 1, "Peito, Ombro e Tríceps");
        pushDay.AddExercise(new RoutineExercise(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Supino Inclinado com Halteres",
            MuscleGroup.Chest,
            order: 1,
            targetSets: 4,
            repRange: new RepRange(8, 12),
            targetRir: 2,
            restIntervalSeconds: 120
        ));
        pushDay.AddExercise(new RoutineExercise(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Desenvolvimento com Halteres",
            MuscleGroup.Shoulders,
            order: 2,
            targetSets: 4,
            repRange: new RepRange(8, 12),
            targetRir: 2,
            restIntervalSeconds: 90
        ));

        var pullDay = new RoutineDay(Guid.NewGuid(), "Treino B • Pull", 2, "Costas, Bíceps e Trapézio");
        pullDay.AddExercise(new RoutineExercise(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Puxada Frontal na Polia",
            MuscleGroup.Back,
            order: 1,
            targetSets: 4,
            repRange: new RepRange(8, 12),
            targetRir: 1,
            restIntervalSeconds: 90
        ));

        // Act
        template.AddDay(pushDay);
        template.AddDay(pullDay);

        // Assert
        Assert.True(template.IsActive);
        Assert.True(template.IsAiGenerated);
        Assert.Equal(2, template.Days.Count);
        Assert.Equal(3, template.TotalExercisesCount);
        Assert.Equal(12, template.TotalTargetSets); // 4 + 4 + 4
        Assert.Equal(8, pushDay.TotalTargetSets);
        Assert.Equal(4, pullDay.TotalTargetSets);
    }

    [Fact]
    public void RoutineTemplate_AddDuplicateDayName_ShouldThrowInvalidOperationException()
    {
        // Arrange
        var template = new RoutineTemplate(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Divisão AB",
            "Upper / Lower",
            WorkoutDivision.UpperLower
        );

        template.AddDay(new RoutineDay(Guid.NewGuid(), "Treino A", 1));

        // Act & Assert
        var ex = Assert.Throws<InvalidOperationException>(() => 
            template.AddDay(new RoutineDay(Guid.NewGuid(), "treino a", 2)));

        Assert.Contains("Já existe um dia com o nome", ex.Message);
    }

    [Fact]
    public void RoutineTemplate_DeactivateAndActivate_ShouldChangeState()
    {
        // Arrange
        var template = new RoutineTemplate(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Full Body 3x",
            "Treino de corpo inteiro",
            WorkoutDivision.FullBody
        );

        // Act
        template.Deactivate();
        Assert.False(template.IsActive);

        template.Activate();
        Assert.True(template.IsActive);
    }

    [Fact]
    public void WorkoutSession_LinkToRoutine_ShouldAssociateRoutineAndDaySuccessfully()
    {
        // Arrange
        var session = new WorkoutSession(
            Guid.NewGuid(),
            Guid.NewGuid(),
            "Execução Treino A",
            DateTime.UtcNow
        );

        var routineId = Guid.NewGuid();
        var dayId = Guid.NewGuid();
        var mesocycleId = Guid.NewGuid();

        // Act
        session.LinkToRoutine(routineId, dayId, mesocycleId);

        // Assert
        Assert.Equal(routineId, session.RoutineTemplateId);
        Assert.Equal(dayId, session.RoutineDayId);
        Assert.Equal(mesocycleId, session.MesocycleId);
    }
}
