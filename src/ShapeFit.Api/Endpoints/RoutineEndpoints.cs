using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using ShapeFit.Application.Routines.Commands.PrescribeRoutine;
using ShapeFit.Application.Routines.DTOs;
using ShapeFit.Application.Routines.Queries.GetActiveRoutine;
using ShapeFit.Application.Routines.Queries.GetMesocycleProgress;

namespace ShapeFit.Api.Endpoints;

public static class RoutineEndpoints
{
    public static RouteGroupBuilder MapRoutineEndpoints(this RouteGroupBuilder group)
    {
        group.MapPost("/prescribe", PrescribeRoutineAsync)
            .WithName("PrescribeRoutine")
            .WithSummary("Prescreve cientificamente uma Ficha de Treino e inicializa seu Mesociclo de 30 treinos.")
            .Produces<PrescribeRoutineResponse>(StatusCodes.Status201Created)
            .ProducesValidationProblem();

        group.MapGet("/users/{userId:guid}/active", GetActiveRoutineAsync)
            .WithName("GetActiveRoutine")
            .WithSummary("Recupera a rotina ativa planejada do usuário com todos os seus dias e exercícios.")
            .Produces<RoutineTemplateDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound);

        group.MapGet("/users/{userId:guid}/mesocycle", GetMesocycleProgressAsync)
            .WithName("GetMesocycleProgress")
            .WithSummary("Consulta o progresso atual do mesociclo ativo de 30 treinos do usuário.")
            .Produces<MesocycleProgressDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound);

        return group;
    }

    public static async Task<Results<Created<PrescribeRoutineResponse>, ValidationProblem>> PrescribeRoutineAsync(
        [FromBody] PrescribeRoutineCommand command,
        IMediator mediator,
        IValidator<PrescribeRoutineCommand> validator,
        CancellationToken cancellationToken)
    {
        var validationResult = await validator.ValidateAsync(command, cancellationToken);
        if (!validationResult.IsValid)
        {
            return TypedResults.ValidationProblem(validationResult.ToDictionary());
        }

        var response = await mediator.Send(command, cancellationToken);
        return TypedResults.Created($"/api/routines/users/{command.UserId}/active", response);
    }

    public static async Task<Results<Ok<RoutineTemplateDto>, NotFound>> GetActiveRoutineAsync(
        Guid userId,
        IMediator mediator,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetActiveRoutineQuery(userId), cancellationToken);
        return result is not null 
            ? TypedResults.Ok(result) 
            : TypedResults.NotFound();
    }

    public static async Task<Results<Ok<MesocycleProgressDto>, NotFound>> GetMesocycleProgressAsync(
        Guid userId,
        IMediator mediator,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetMesocycleProgressQuery(userId), cancellationToken);
        return result is not null 
            ? TypedResults.Ok(result) 
            : TypedResults.NotFound();
    }
}
