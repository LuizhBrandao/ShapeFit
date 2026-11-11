using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using ShapeFit.Application.Workouts.Commands.LogWorkout;
using ShapeFit.Application.Workouts.DTOs;
using ShapeFit.Application.Workouts.Queries.GetLastPerformance;

namespace ShapeFit.Api.Endpoints;

public record LogWorkoutResponse(Guid Id);

public static class WorkoutEndpoints
{
    public static RouteGroupBuilder MapWorkoutEndpoints(this RouteGroupBuilder group)
    {
        group.MapPost("/", LogWorkoutAsync)
            .WithName("LogWorkout")
            .WithSummary("Registra ou sincroniza uma sessão de treino completa.")
            .Produces<LogWorkoutResponse>(StatusCodes.Status201Created)
            .ProducesValidationProblem();

        group.MapGet("/users/{userId:guid}/exercises/{exerciseId:guid}/last-performance", GetLastPerformanceAsync)
            .WithName("GetLastPerformance")
            .WithSummary("Recupera as cargas e repetições da última execução do exercício para pré-preenchimento rápido.")
            .Produces<LastExercisePerformanceDto>(StatusCodes.Status200OK)
            .Produces(StatusCodes.Status404NotFound);

        return group;
    }

    public static async Task<Results<Created<LogWorkoutResponse>, ValidationProblem>> LogWorkoutAsync(
        [FromBody] LogWorkoutCommand command,
        IMediator mediator,
        IValidator<LogWorkoutCommand> validator,
        CancellationToken cancellationToken)
    {
        var validationResult = await validator.ValidateAsync(command, cancellationToken);
        if (!validationResult.IsValid)
        {
            return TypedResults.ValidationProblem(validationResult.ToDictionary());
        }

        var sessionId = await mediator.Send(command, cancellationToken);
        return TypedResults.Created($"/api/workouts/{sessionId}", new LogWorkoutResponse(sessionId));
    }

    public static async Task<Results<Ok<LastExercisePerformanceDto>, NotFound>> GetLastPerformanceAsync(
        Guid userId,
        Guid exerciseId,
        IMediator mediator,
        CancellationToken cancellationToken)
    {
        var result = await mediator.Send(new GetLastPerformanceQuery(userId, exerciseId), cancellationToken);
        return result is not null 
            ? TypedResults.Ok(result) 
            : TypedResults.NotFound();
    }
}
