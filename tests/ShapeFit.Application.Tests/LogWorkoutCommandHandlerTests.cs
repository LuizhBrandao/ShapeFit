using NSubstitute;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Workouts.Commands.LogWorkout;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using Xunit;

namespace ShapeFit.Application.Tests;

public class LogWorkoutCommandHandlerTests
{
    private readonly IWorkoutSessionRepository _sessionRepo;
    private readonly ICacheService _cacheService;
    private readonly IMesocycleRepository _mesocycleRepo;
    private readonly LogWorkoutCommandHandler _sut;

    public LogWorkoutCommandHandlerTests()
    {
        _sessionRepo = Substitute.For<IWorkoutSessionRepository>();
        _cacheService = Substitute.For<ICacheService>();
        _mesocycleRepo = Substitute.For<IMesocycleRepository>();

        _sut = new LogWorkoutCommandHandler(_sessionRepo, _cacheService, _mesocycleRepo);
    }

    [Fact]
    public async Task LogWorkoutCommandHandler_WhenMesocycleIdProvided_ShouldRecordSessionCompletion_AndSaveMesocycle()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var routineId = Guid.NewGuid();
        var mesocycle = new Mesocycle(Guid.NewGuid(), userId, routineId, targetSessionsCount: 30);

        _mesocycleRepo.GetByIdAsync(mesocycle.Id, Arg.Any<CancellationToken>())
            .Returns(mesocycle);

        var command = new LogWorkoutCommand(
            Id: null,
            UserId: userId,
            Name: "Treino A - Peito",
            StartedAt: DateTime.UtcNow.AddHours(-1),
            FinishedAt: DateTime.UtcNow,
            ClientSyncId: null,
            Notes: null,
            Exercises: new List<LogExerciseCommand>(),
            RoutineTemplateId: routineId,
            RoutineDayId: Guid.NewGuid(),
            MesocycleId: mesocycle.Id
        );

        // Act
        var sessionId = await _sut.Handle(command, CancellationToken.None);

        // Assert
        Assert.NotEqual(Guid.Empty, sessionId);
        Assert.Equal(1, mesocycle.CompletedSessionsCount); // Avançou o contador!
        await _sessionRepo.Received(1).AddAsync(Arg.Any<WorkoutSession>(), Arg.Any<CancellationToken>());
        await _sessionRepo.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
        await _mesocycleRepo.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task LogWorkoutCommandHandler_WhenRoutineTemplateIdProvided_ShouldResolveActiveMesocycle_AndIncrement()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var routineId = Guid.NewGuid();
        var mesocycle = new Mesocycle(Guid.NewGuid(), userId, routineId, targetSessionsCount: 30);

        _mesocycleRepo.GetActiveByRoutineIdAsync(routineId, Arg.Any<CancellationToken>())
            .Returns(mesocycle);

        var command = new LogWorkoutCommand(
            Id: null,
            UserId: userId,
            Name: "Treino B - Costas",
            StartedAt: DateTime.UtcNow.AddHours(-1),
            FinishedAt: DateTime.UtcNow,
            ClientSyncId: null,
            Notes: null,
            Exercises: new List<LogExerciseCommand>(),
            RoutineTemplateId: routineId,
            RoutineDayId: Guid.NewGuid(),
            MesocycleId: null // Não enviou mesocycleId explicitamente
        );

        // Act
        var sessionId = await _sut.Handle(command, CancellationToken.None);

        // Assert
        Assert.NotEqual(Guid.Empty, sessionId);
        Assert.Equal(1, mesocycle.CompletedSessionsCount); // Resolveu e avançou!
        await _mesocycleRepo.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task LogWorkoutCommandHandler_WhenClientSyncIdAlreadyExists_ShouldNotIncrementMesocycle()
    {
        // Arrange
        var clientSyncId = Guid.NewGuid();
        var existingSession = new WorkoutSession(Guid.NewGuid(), Guid.NewGuid(), "Treino Existente", DateTime.UtcNow);

        _sessionRepo.GetByClientSyncIdAsync(clientSyncId, Arg.Any<CancellationToken>())
            .Returns(existingSession);

        var command = new LogWorkoutCommand(
            Id: null,
            UserId: existingSession.UserId,
            Name: "Treino Duplicado",
            StartedAt: DateTime.UtcNow,
            FinishedAt: DateTime.UtcNow,
            ClientSyncId: clientSyncId,
            Notes: null,
            Exercises: new List<LogExerciseCommand>(),
            RoutineTemplateId: Guid.NewGuid(),
            MesocycleId: Guid.NewGuid()
        );

        // Act
        var resultId = await _sut.Handle(command, CancellationToken.None);

        // Assert
        Assert.Equal(existingSession.Id, resultId);
        await _mesocycleRepo.DidNotReceive().GetByIdAsync(Arg.Any<Guid>(), Arg.Any<CancellationToken>());
        await _mesocycleRepo.DidNotReceive().SaveChangesAsync(Arg.Any<CancellationToken>());
    }
}
