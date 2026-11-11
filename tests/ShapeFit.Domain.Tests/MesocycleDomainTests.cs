using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Events;
using Xunit;

namespace ShapeFit.Domain.Tests;

public class MesocycleDomainTests
{
    [Fact]
    public void Mesocycle_ShouldInitialize_WithDefault30SessionsAndActiveStatus()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var routineId = Guid.NewGuid();

        // Act
        var mesocycle = new Mesocycle(
            Guid.NewGuid(),
            userId,
            routineId,
            cycleNumber: 1,
            goal: "Hipertrofia Focada em Peito"
        );

        // Assert
        Assert.Equal(userId, mesocycle.UserId);
        Assert.Equal(routineId, mesocycle.RoutineTemplateId);
        Assert.Equal(1, mesocycle.CycleNumber);
        Assert.Equal(30, mesocycle.TargetSessionsCount);
        Assert.Equal(0, mesocycle.CompletedSessionsCount);
        Assert.Equal(MesocycleStatus.Active, mesocycle.Status);
        Assert.Equal(0.0, mesocycle.ProgressRatio);
        Assert.False(mesocycle.IsCompleted);
        Assert.Null(mesocycle.FinishedAt);
        Assert.Empty(mesocycle.DomainEvents);
    }

    [Fact]
    public void RecordSessionCompletion_ShouldIncrementCountAndProgressRatio()
    {
        // Arrange
        var mesocycle = new Mesocycle(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), targetSessionsCount: 30);
        var sessionId = Guid.NewGuid();
        var now = DateTime.UtcNow;

        // Act
        mesocycle.RecordSessionCompletion(sessionId, now);

        // Assert
        Assert.Equal(1, mesocycle.CompletedSessionsCount);
        Assert.Equal(1.0 / 30.0, mesocycle.ProgressRatio, 4);
        Assert.Equal(MesocycleStatus.Active, mesocycle.Status);
        Assert.Empty(mesocycle.DomainEvents);
    }

    [Fact]
    public void RecordSessionCompletion_WhenReachingTarget_ShouldCompleteAndRaiseDomainEvent()
    {
        // Arrange: mesociclo com meta de 3 treinos para teste rápido de conclusão
        var userId = Guid.NewGuid();
        var routineId = Guid.NewGuid();
        var mesocycle = new Mesocycle(Guid.NewGuid(), userId, routineId, cycleNumber: 2, targetSessionsCount: 3);
        var finishedAt = new DateTime(2026, 11, 11, 14, 0, 0, DateTimeKind.Utc);

        // Act: conclui as 3 sessões
        mesocycle.RecordSessionCompletion(Guid.NewGuid(), finishedAt.AddDays(-2));
        mesocycle.RecordSessionCompletion(Guid.NewGuid(), finishedAt.AddDays(-1));
        mesocycle.RecordSessionCompletion(Guid.NewGuid(), finishedAt);

        // Assert
        Assert.Equal(3, mesocycle.CompletedSessionsCount);
        Assert.Equal(1.0, mesocycle.ProgressRatio);
        Assert.Equal(MesocycleStatus.Completed, mesocycle.Status);
        Assert.True(mesocycle.IsCompleted);
        Assert.Equal(finishedAt, mesocycle.FinishedAt);

        // Validação estrita do evento de domínio
        Assert.Single(mesocycle.DomainEvents);
        var domainEvent = Assert.IsType<MesocycleCompletedEvent>(mesocycle.DomainEvents.First());
        Assert.Equal(mesocycle.Id, domainEvent.MesocycleId);
        Assert.Equal(userId, domainEvent.UserId);
        Assert.Equal(routineId, domainEvent.RoutineTemplateId);
        Assert.Equal(2, domainEvent.CycleNumber);
        Assert.Equal(3, domainEvent.TotalCompletedSessions);
        Assert.Equal(finishedAt, domainEvent.CompletedAt);
    }

    [Fact]
    public void RecordSessionCompletion_WhenAlreadyCompleted_ShouldThrowInvalidOperationException()
    {
        // Arrange
        var mesocycle = new Mesocycle(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid(), targetSessionsCount: 1);
        mesocycle.RecordSessionCompletion(Guid.NewGuid(), DateTime.UtcNow);

        // Act & Assert
        var ex = Assert.Throws<InvalidOperationException>(() => 
            mesocycle.RecordSessionCompletion(Guid.NewGuid(), DateTime.UtcNow));

        Assert.Contains("Não é possível registrar sessões em um mesociclo com status 'Completed'", ex.Message);
    }

    [Fact]
    public void Cancel_ActiveMesocycle_ShouldChangeStatusToCancelled()
    {
        // Arrange
        var mesocycle = new Mesocycle(Guid.NewGuid(), Guid.NewGuid(), Guid.NewGuid());

        // Act
        mesocycle.Cancel("Usuário optou por trocar para divisão ABCD");

        // Assert
        Assert.Equal(MesocycleStatus.Cancelled, mesocycle.Status);
        Assert.NotNull(mesocycle.FinishedAt);

        Assert.Throws<InvalidOperationException>(() => 
            mesocycle.RecordSessionCompletion(Guid.NewGuid(), DateTime.UtcNow));
    }
}
