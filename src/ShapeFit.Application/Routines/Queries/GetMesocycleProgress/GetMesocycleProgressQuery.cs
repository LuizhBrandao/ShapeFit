using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Routines.DTOs;

namespace ShapeFit.Application.Routines.Queries.GetMesocycleProgress;

public record GetMesocycleProgressQuery(Guid UserId) : IRequest<MesocycleProgressDto?>;

public class GetMesocycleProgressQueryHandler : IRequestHandler<GetMesocycleProgressQuery, MesocycleProgressDto?>
{
    private readonly IMesocycleRepository _repository;

    public GetMesocycleProgressQueryHandler(IMesocycleRepository repository)
    {
        _repository = repository;
    }

    public async Task<MesocycleProgressDto?> Handle(GetMesocycleProgressQuery request, CancellationToken cancellationToken)
    {
        var mesocycle = await _repository.GetActiveByUserIdAsync(request.UserId, cancellationToken);
        if (mesocycle == null)
            return null;

        return new MesocycleProgressDto(
            mesocycle.Id,
            mesocycle.UserId,
            mesocycle.RoutineTemplateId,
            mesocycle.CycleNumber,
            mesocycle.TargetSessionsCount,
            mesocycle.CompletedSessionsCount,
            mesocycle.ProgressRatio,
            mesocycle.Status,
            mesocycle.StartedAt,
            mesocycle.FinishedAt,
            mesocycle.Goal
        );
    }
}
