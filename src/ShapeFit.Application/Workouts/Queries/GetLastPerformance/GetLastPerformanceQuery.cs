using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Workouts.DTOs;

namespace ShapeFit.Application.Workouts.Queries.GetLastPerformance;

public record GetLastPerformanceQuery(Guid UserId, Guid ExerciseId) : IRequest<LastExercisePerformanceDto?>;

public class GetLastPerformanceQueryHandler : IRequestHandler<GetLastPerformanceQuery, LastExercisePerformanceDto?>
{
    private readonly IWorkoutReadRepository _readRepository;
    private readonly ICacheService _cacheService;

    public GetLastPerformanceQueryHandler(IWorkoutReadRepository readRepository, ICacheService cacheService)
    {
        _readRepository = readRepository;
        _cacheService = cacheService;
    }

    public async Task<LastExercisePerformanceDto?> Handle(GetLastPerformanceQuery request, CancellationToken cancellationToken)
    {
        var cacheKey = $"users:{request.UserId}:exercises:{request.ExerciseId}:last-performance";
        var ttl = TimeSpan.FromHours(12);

        return await _cacheService.GetOrSetAsync(
            cacheKey,
            () => _readRepository.GetLastPerformanceAsync(request.UserId, request.ExerciseId, cancellationToken),
            ttl,
            cancellationToken
        );
    }
}
