using FluentValidation;
using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Application.Workouts.Commands.LogWorkout;

public record LogSetCommand(
    Guid? Id,
    int SetOrder,
    SetType Type,
    decimal Weight,
    string Unit,
    int Repetitions,
    int? RepsInReserve,
    bool IsCompleted
);

public record LogExerciseCommand(
    Guid? Id,
    Guid ExerciseId,
    int Order,
    string? Notes,
    List<LogSetCommand> Sets
);

public record LogWorkoutCommand(
    Guid? Id,
    Guid UserId,
    string Name,
    DateTime StartedAt,
    DateTime? FinishedAt,
    Guid? ClientSyncId,
    string? Notes,
    List<LogExerciseCommand> Exercises,
    Guid? RoutineTemplateId = null,
    Guid? RoutineDayId = null,
    Guid? MesocycleId = null
) : IRequest<Guid>;

public class LogWorkoutCommandValidator : AbstractValidator<LogWorkoutCommand>
{
    public LogWorkoutCommandValidator()
    {
        RuleFor(x => x.UserId).NotEmpty().WithMessage("Usuário é obrigatório.");
        RuleFor(x => x.Name).NotEmpty().MaximumLength(150).WithMessage("O nome do treino é obrigatório.");
        RuleFor(x => x.StartedAt).NotEmpty();
        RuleForEach(x => x.Exercises).ChildRules(exercise =>
        {
            exercise.RuleFor(e => e.ExerciseId).NotEmpty();
            exercise.RuleForEach(e => e.Sets).ChildRules(set =>
            {
                set.RuleFor(s => s.Weight).GreaterThanOrEqualTo(0);
                set.RuleFor(s => s.Repetitions).GreaterThanOrEqualTo(0);
                set.RuleFor(s => s.SetOrder).GreaterThan(0);
            });
        });
    }
}

public class LogWorkoutCommandHandler : IRequestHandler<LogWorkoutCommand, Guid>
{
    private readonly IWorkoutSessionRepository _repository;
    private readonly ICacheService _cacheService;
    private readonly IMesocycleRepository _mesocycleRepository;

    public LogWorkoutCommandHandler(
        IWorkoutSessionRepository repository,
        ICacheService cacheService,
        IMesocycleRepository mesocycleRepository)
    {
        _repository = repository;
        _cacheService = cacheService;
        _mesocycleRepository = mesocycleRepository;
    }

    public async Task<Guid> Handle(LogWorkoutCommand request, CancellationToken cancellationToken)
    {
        // Verificação de Idempotência para Resiliência Offline:
        // Se o aplicativo mobile já submeteu esse treino com o mesmo ClientSyncId, apenas retornamos o ID existente.
        if (request.ClientSyncId.HasValue)
        {
            var existingSession = await _repository.GetByClientSyncIdAsync(request.ClientSyncId.Value, cancellationToken);
            if (existingSession != null)
            {
                return existingSession.Id;
            }
        }

        // Resolução do Mesociclo:
        // Se MesocycleId foi passado diretamente, buscamos por ele.
        // Se apenas RoutineTemplateId foi passado, resolvemos o mesociclo ativo vinculado à rotina.
        Mesocycle? activeMesocycle = null;
        if (request.MesocycleId.HasValue)
        {
            activeMesocycle = await _mesocycleRepository.GetByIdAsync(request.MesocycleId.Value, cancellationToken);
        }
        else if (request.RoutineTemplateId.HasValue)
        {
            activeMesocycle = await _mesocycleRepository.GetActiveByRoutineIdAsync(request.RoutineTemplateId.Value, cancellationToken);
        }

        var resolvedMesocycleId = activeMesocycle?.Id ?? request.MesocycleId;

        var session = new WorkoutSession(
            request.Id ?? Guid.NewGuid(),
            request.UserId,
            request.Name,
            request.StartedAt,
            request.ClientSyncId,
            request.Notes,
            request.RoutineTemplateId,
            request.RoutineDayId,
            resolvedMesocycleId
        );

        if (request.FinishedAt.HasValue)
        {
            session.FinishSession(request.FinishedAt.Value);
        }

        foreach (var exerciseCommand in request.Exercises)
        {
            var exerciseLog = new WorkoutExerciseLog(
                exerciseCommand.Id ?? Guid.NewGuid(),
                exerciseCommand.ExerciseId,
                exerciseCommand.Order,
                exerciseCommand.Notes
            );

            foreach (var setCommand in exerciseCommand.Sets)
            {
                var weight = setCommand.Unit.Equals("lbs", StringComparison.OrdinalIgnoreCase)
                    ? Weight.FromPounds(setCommand.Weight)
                    : Weight.FromKilograms(setCommand.Weight);

                var setLog = new WorkoutSetLog(
                    setCommand.Id ?? Guid.NewGuid(),
                    setCommand.SetOrder,
                    setCommand.Type,
                    weight,
                    setCommand.Repetitions,
                    setCommand.RepsInReserve
                );

                if (setCommand.IsCompleted)
                {
                    setLog.MarkCompleted();
                }

                exerciseLog.AddSet(setLog);
            }

            session.AddExercise(exerciseLog);
        }

        await _repository.AddAsync(session, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        // Incremento automático e rastreável do Mesociclo de 30 treinos
        if (activeMesocycle != null && activeMesocycle.Status == MesocycleStatus.Active)
        {
            activeMesocycle.RecordSessionCompletion(session.Id, session.FinishedAt ?? DateTime.UtcNow);
            await _mesocycleRepository.SaveChangesAsync(cancellationToken);
        }

        // Invalidação reativa do Hot Cache de última performance no Redis para cada exercício executado
        foreach (var exerciseCommand in request.Exercises)
        {
            var cacheKey = $"users:{request.UserId}:exercises:{exerciseCommand.ExerciseId}:last-performance";
            await _cacheService.RemoveAsync(cacheKey, cancellationToken);
        }

        return session.Id;
    }
}
