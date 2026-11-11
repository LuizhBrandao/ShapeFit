using FluentValidation;
using MediatR;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Application.Routines.DTOs;
using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.Services;

namespace ShapeFit.Application.Routines.Commands.PrescribeRoutine;

public record PrescribeRoutineCommand(
    Guid UserId,
    string RoutineName,
    WorkoutDivision Division,
    int SessionDurationMinutes,
    string? CustomDescription = null
) : IRequest<PrescribeRoutineResponse>;

public class PrescribeRoutineCommandValidator : AbstractValidator<PrescribeRoutineCommand>
{
    public PrescribeRoutineCommandValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty().WithMessage("Usuário é obrigatório.");

        RuleFor(x => x.RoutineName)
            .NotEmpty().WithMessage("O nome da rotina é obrigatório.")
            .MaximumLength(150).WithMessage("O nome da rotina deve ter no máximo 150 caracteres.");

        RuleFor(x => x.Division)
            .IsInEnum().WithMessage("Divisão de treino inválida.");

        RuleFor(x => x.SessionDurationMinutes)
            .InclusiveBetween(15, 180).WithMessage("A duração da sessão deve estar entre 15 e 180 minutos.");
    }
}

public class PrescribeRoutineCommandHandler : IRequestHandler<PrescribeRoutineCommand, PrescribeRoutineResponse>
{
    private readonly IRoutineTemplateRepository _routineRepository;
    private readonly IMesocycleRepository _mesocycleRepository;

    public PrescribeRoutineCommandHandler(
        IRoutineTemplateRepository routineRepository,
        IMesocycleRepository mesocycleRepository)
    {
        _routineRepository = routineRepository;
        _mesocycleRepository = mesocycleRepository;
    }

    public async Task<PrescribeRoutineResponse> Handle(PrescribeRoutineCommand request, CancellationToken cancellationToken)
    {
        // 1. Desativa a rotina ativa anterior (se houver) para evitar conflitos de ciclo
        var existingActiveRoutine = await _routineRepository.GetActiveByUserIdAsync(request.UserId, cancellationToken);
        if (existingActiveRoutine != null)
        {
            existingActiveRoutine.Deactivate();
        }

        // 2. Cancela o mesociclo ativo anterior (se houver)
        var existingActiveMesocycle = await _mesocycleRepository.GetActiveByUserIdAsync(request.UserId, cancellationToken);
        if (existingActiveMesocycle != null)
        {
            existingActiveMesocycle.Cancel("Substituído por nova prescrição de rotina.");
        }

        // 3. Executa a inteligência de prescrição fisiológica no Domínio C#
        var routine = RoutinePrescriptionService.PrescribeRoutine(
            request.UserId,
            request.RoutineName,
            request.Division,
            request.SessionDurationMinutes,
            request.CustomDescription
        );

        // 4. Inicializa o 1º Mesociclo de 30 Treinos para a nova ficha
        var mesocycle = new Mesocycle(
            Guid.NewGuid(),
            request.UserId,
            routine.Id,
            cycleNumber: 1,
            targetSessionsCount: Mesocycle.DefaultTargetSessionsCount,
            goal: $"Mesociclo 1 • {routine.Name}"
        );

        await _routineRepository.AddAsync(routine, cancellationToken);
        await _mesocycleRepository.AddAsync(mesocycle, cancellationToken);

        await _routineRepository.SaveChangesAsync(cancellationToken);
        await _mesocycleRepository.SaveChangesAsync(cancellationToken);

        var calibration = VolumeCalibrationService.Calibrate(request.SessionDurationMinutes);

        return new PrescribeRoutineResponse(
            routine.Id,
            mesocycle.Id,
            routine.Name,
            routine.Division,
            routine.Days.Count,
            routine.TotalTargetSets,
            calibration.Rationale
        );
    }
}
