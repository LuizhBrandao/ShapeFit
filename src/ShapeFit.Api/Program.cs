using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using ShapeFit.Application;
using ShapeFit.Application.Workouts.Commands.LogWorkout;
using ShapeFit.Application.Workouts.Queries.GetLastPerformance;
using ShapeFit.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Configuração das camadas Clean Architecture
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

var workoutsGroup = app.MapGroup("/api/workouts").WithTags("Workouts");

// Endpoint de Registro de Treino com Resiliência Offline (Idempotência via ClientSyncId)
workoutsGroup.MapPost("/", async (
    [FromBody] LogWorkoutCommand command, 
    IMediator mediator, 
    IValidator<LogWorkoutCommand> validator) =>
{
    var validationResult = await validator.ValidateAsync(command);
    if (!validationResult.IsValid)
    {
        return Results.ValidationProblem(validationResult.ToDictionary());
    }

    var sessionId = await mediator.Send(command);
    return Results.Created($"/api/workouts/{sessionId}", new { Id = sessionId });
})
.WithName("LogWorkout")
.WithSummary("Registra ou sincroniza uma sessão de treino completa.")
.Produces(StatusCodes.Status201Created)
.ProducesValidationProblem();

// Endpoint de Consulta de Última Performance para Pré-Preenchimento Inteligente na UI Mobile
workoutsGroup.MapGet("/users/{userId:guid}/exercises/{exerciseId:guid}/last-performance", async (
    Guid userId, 
    Guid exerciseId, 
    IMediator mediator) =>
{
    var result = await mediator.Send(new GetLastPerformanceQuery(userId, exerciseId));
    return result is not null ? Results.Ok(result) : Results.NotFound();
})
.WithName("GetLastPerformance")
.WithSummary("Recupera as cargas e repetições da última execução do exercício para pré-preenchimento rápido.")
.Produces(StatusCodes.Status200OK)
.Produces(StatusCodes.Status404NotFound);

app.Run();
