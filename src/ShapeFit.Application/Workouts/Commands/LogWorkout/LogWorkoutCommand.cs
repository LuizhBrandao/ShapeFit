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
    List<LogExerciseCommand> Exercises
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

    public LogWorkoutCommandHandler(IWorkoutSessionRepository repository)
    {
        _repository = repository;
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

        var session = new WorkoutSession(
            request.Id ?? Guid.NewGuid(),
            request.UserId,
            request.Name,
            request.StartedAt,
            request.ClientSyncId,
            request.Notes
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

        return session.Id;
    }
}
