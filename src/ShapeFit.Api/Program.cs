using Scalar.AspNetCore;
using ShapeFit.Api.Endpoints;
using ShapeFit.Api.Middlewares;
using ShapeFit.Application;
using ShapeFit.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Configuração das camadas Clean Architecture
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddOpenApi();

var app = builder.Build();

// Middleware de Observabilidade Resiliente (CorrelationId & Structured Logging)
app.UseCorrelationId();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("ShapeFit API - Documentação Interativa")
               .WithTheme(ScalarTheme.Moon);
    });
}

app.UseHttpsRedirection();

// Registro modularizado dos endpoints com TypedResults
app.MapGroup("/api/workouts")
   .WithTags("Workouts")
   .MapWorkoutEndpoints();

app.MapGroup("/api/routines")
   .WithTags("Routines")
   .MapRoutineEndpoints();

app.Run();
