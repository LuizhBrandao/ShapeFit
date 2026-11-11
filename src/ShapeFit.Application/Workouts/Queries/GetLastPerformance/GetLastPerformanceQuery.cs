using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Workouts.DTOs;

namespace ShapeFit.Application.Workouts.Queries.GetLastPerformance;

public record GetLastPerformanceQuery(Guid UserId, Guid ExerciseId) : IRequest<LastExercisePerformanceDto?>;

public class GetLastPerformanceQueryHandler : IRequestHandler<GetLastPerformanceQuery, LastExercisePerformanceDto?>
{
    private readonly IWorkoutReadRepository _readRepository;

    public GetLastPerformanceQueryHandler(IWorkoutReadRepository readRepository)
    {
        _readRepository = readRepository;
    }

    public async Task<LastExercisePerformanceDto?> Handle(GetLastPerformanceQuery request, CancellationToken cancellationToken)
    {
        return await _readRepository.GetLastPerformanceAsync(request.UserId, request.ExerciseId, cancellationToken);
    }
}
