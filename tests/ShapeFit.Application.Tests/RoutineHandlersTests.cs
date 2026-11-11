using NSubstitute;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Routines.Commands.PrescribeRoutine;
using ShapeFit.Application.Routines.Queries.GetActiveRoutine;
using ShapeFit.Application.Routines.Queries.GetMesocycleProgress;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using Xunit;

namespace ShapeFit.Application.Tests;

public class RoutineHandlersTests
{
    private readonly IRoutineTemplateRepository _routineRepo;
    private readonly IMesocycleRepository _mesocycleRepo;

    public RoutineHandlersTests()
    {
        _routineRepo = Substitute.For<IRoutineTemplateRepository>();
        _mesocycleRepo = Substitute.For<IMesocycleRepository>();
    }

    [Fact]
    public async Task PrescribeRoutineCommandHandler_ShouldDeactivatePrevious_AndSaveNewRoutineAndMesocycle()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var previousRoutine = new RoutineTemplate(
            Guid.NewGuid(), 
            userId, 
            "Rotina Antiga", 
            "Desc", 
            WorkoutDivision.UpperLower
        );
        var previousMesocycle = new Mesocycle(
            Guid.NewGuid(), 
            userId, 
            previousRoutine.Id
        );

        _routineRepo.GetActiveByUserIdAsync(userId, Arg.Any<CancellationToken>())
            .Returns(previousRoutine);
        _mesocycleRepo.GetActiveByUserIdAsync(userId, Arg.Any<CancellationToken>())
            .Returns(previousMesocycle);

        var handler = new PrescribeRoutineCommandHandler(_routineRepo, _mesocycleRepo);
        var command = new PrescribeRoutineCommand(
            userId,
            "Nova Ficha ABC PPL",
            WorkoutDivision.PushPullLegs,
            60,
            "Treino hipertrófico calibrado"
        );

        // Act
        var response = await handler.Handle(command, CancellationToken.None);

        // Assert
        Assert.False(previousRoutine.IsActive);
        Assert.Equal(MesocycleStatus.Cancelled, previousMesocycle.Status);

        Assert.NotEqual(Guid.Empty, response.RoutineTemplateId);
        Assert.NotEqual(Guid.Empty, response.MesocycleId);
        Assert.Equal("Nova Ficha ABC PPL", response.RoutineName);
        Assert.Equal(3, response.TotalDays); // PPL = 3 dias
        Assert.Equal(18 * 3, response.TotalTargetSets); // 18 séries por dia x 3 dias = 54 séries

        await _routineRepo.Received(1).AddAsync(Arg.Any<RoutineTemplate>(), Arg.Any<CancellationToken>());
        await _mesocycleRepo.Received(1).AddAsync(Arg.Any<Mesocycle>(), Arg.Any<CancellationToken>());
        await _routineRepo.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
        await _mesocycleRepo.Received(1).SaveChangesAsync(Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetActiveRoutineQueryHandler_WhenFound_ShouldReturnMappedDto()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var routine = new RoutineTemplate(
            Guid.NewGuid(),
            userId,
            "Hipertrofia AB",
            "Treino Upper / Lower",
            WorkoutDivision.UpperLower
        );
        var day = new RoutineDay(Guid.NewGuid(), "Treino A", 1);
        routine.AddDay(day);

        _routineRepo.GetActiveByUserIdAsync(userId, Arg.Any<CancellationToken>())
            .Returns(routine);

        var handler = new GetActiveRoutineQueryHandler(_routineRepo);

        // Act
        var result = await handler.Handle(new GetActiveRoutineQuery(userId), CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(routine.Id, result.Id);
        Assert.Equal("Hipertrofia AB", result.Name);
        Assert.Single(result.Days);
    }

    [Fact]
    public async Task GetActiveRoutineQueryHandler_WhenNotFound_ShouldReturnNull()
    {
        // Arrange
        var userId = Guid.NewGuid();
        _routineRepo.GetActiveByUserIdAsync(userId, Arg.Any<CancellationToken>())
            .Returns((RoutineTemplate?)null);

        var handler = new GetActiveRoutineQueryHandler(_routineRepo);

        // Act
        var result = await handler.Handle(new GetActiveRoutineQuery(userId), CancellationToken.None);

        // Assert
        Assert.Null(result);
    }

    [Fact]
    public async Task GetMesocycleProgressQueryHandler_WhenFound_ShouldReturnMappedProgressDto()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var mesocycle = new Mesocycle(
            Guid.NewGuid(),
            userId,
            Guid.NewGuid(),
            cycleNumber: 1,
            targetSessionsCount: 30,
            goal: "Construção de base de força"
        );

        // Simula 6 treinos concluídos
        for (int i = 0; i < 6; i++)
        {
            mesocycle.RecordSessionCompletion(Guid.NewGuid(), DateTime.UtcNow);
        }

        _mesocycleRepo.GetActiveByUserIdAsync(userId, Arg.Any<CancellationToken>())
            .Returns(mesocycle);

        var handler = new GetMesocycleProgressQueryHandler(_mesocycleRepo);

        // Act
        var result = await handler.Handle(new GetMesocycleProgressQuery(userId), CancellationToken.None);

        // Assert
        Assert.NotNull(result);
        Assert.Equal(6, result.CompletedSessionsCount);
        Assert.Equal(30, result.TargetSessionsCount);
        Assert.Equal(0.2, result.ProgressRatio, 2); // 6 / 30 = 20%
        Assert.Equal(MesocycleStatus.Active, result.Status);
    }
}
