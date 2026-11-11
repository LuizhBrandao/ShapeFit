using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Services;
using ShapeFit.Domain.ValueObjects;
using Xunit;

namespace ShapeFit.Domain.Tests;

public class WorkoutDomainTests
{
    [Fact]
    public void CalculateEpley_ShouldCalculateCorrectEstimatedOneRepMax()
    {
        // Arrange: 100 kg para 10 reps
        // Fórmula Epley: 100 * (1 + 10 / 30) = 100 * 1.3333... = 133.33 kg
        var weight = Weight.FromKilograms(100);
        int reps = 10;

        // Act
        var oneRepMax = OneRepMaxCalculator.CalculateEpley(weight, reps);

        // Assert
        Assert.Equal(133.33m, oneRepMax.Value);
        Assert.Equal("kg", oneRepMax.Unit);
    }

    [Fact]
    public void SetLog_WarmUpSet_ShouldNotBeConsideredEffectiveSet()
    {
        // Arrange
        var warmUpSet = new Entities.WorkoutSetLog(
            Guid.NewGuid(), 
            1, 
            SetType.WarmUp, 
            Weight.FromKilograms(40), 
            15
        );
        warmUpSet.MarkCompleted();

        // Act & Assert
        Assert.False(warmUpSet.IsEffectiveSet());
    }

    [Fact]
    public void SetLog_NormalCompletedSet_ShouldBeConsideredEffectiveSet()
    {
        // Arrange
        var normalSet = new Entities.WorkoutSetLog(
            Guid.NewGuid(), 
            1, 
            SetType.Normal, 
            Weight.FromKilograms(80), 
            8
        );
        normalSet.MarkCompleted();

        // Act & Assert
        Assert.True(normalSet.IsEffectiveSet());
        Assert.Equal(640m, normalSet.CalculateVolume());
    }
}
