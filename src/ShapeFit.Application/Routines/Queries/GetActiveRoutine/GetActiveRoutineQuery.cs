using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Routines.DTOs;

namespace ShapeFit.Application.Routines.Queries.GetActiveRoutine;

public record GetActiveRoutineQuery(Guid UserId) : IRequest<RoutineTemplateDto?>;

public class GetActiveRoutineQueryHandler : IRequestHandler<GetActiveRoutineQuery, RoutineTemplateDto?>
{
    private readonly IRoutineTemplateRepository _repository;

    public GetActiveRoutineQueryHandler(IRoutineTemplateRepository repository)
    {
        _repository = repository;
    }

    public async Task<RoutineTemplateDto?> Handle(GetActiveRoutineQuery request, CancellationToken cancellationToken)
    {
        var routine = await _repository.GetActiveByUserIdAsync(request.UserId, cancellationToken);
        if (routine == null)
            return null;

        var daysDto = routine.Days.Select(day => new RoutineDayDto(
            day.Id,
            day.Name,
            day.Order,
            day.Description,
            day.TotalTargetSets,
            day.Exercises.Select(ex => new RoutineExerciseDto(
                ex.Id,
                ex.ExerciseId,
                ex.CustomExerciseName,
                ex.TargetMuscle,
                ex.Order,
                ex.TargetSets,
                ex.RepRange.ToString(),
                ex.TargetRir,
                ex.RestIntervalSeconds,
                ex.Notes
            )).ToList()
        )).ToList();

        return new RoutineTemplateDto(
            routine.Id,
            routine.UserId,
            routine.Name,
            routine.Description,
            routine.Division,
            routine.IsActive,
            routine.IsAiGenerated,
            routine.CreatedAt,
            routine.TotalExercisesCount,
            routine.TotalTargetSets,
            daysDto
        );
    }
}
