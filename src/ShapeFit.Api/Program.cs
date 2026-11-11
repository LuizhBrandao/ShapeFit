using Scalar.AspNetCore;
using ShapeFit.Api.Endpoints;
using ShapeFit.Api.Middlewares;
using ShapeFit.Application;
using ShapeFit.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Configuração das camadas Clean Architecture
builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

// Configuração de CORS por Ambiente
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(options =>
{
    options.AddPolicy("ShapeFitCorsPolicy", policy =>
    {
        if (builder.Environment.IsDevelopment())
        {
            policy.AllowAnyOrigin()
                  .AllowAnyHeader()
                  .AllowAnyMethod();
        }
        else if (allowedOrigins.Length > 0)
        {
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        }
        else
        {
            policy.AllowAnyHeader()
                  .AllowAnyMethod();
        }
    });
});

builder.Services.AddOpenApi();

var app = builder.Build();

// Middleware de Observabilidade Resiliente (CorrelationId & Structured Logging)
app.UseCorrelationId();
app.UseCors("ShapeFitCorsPolicy");

// Documentação Interativa via OpenAPI / Scalar disponível em Development e Staging
if (app.Environment.IsDevelopment() || app.Environment.IsEnvironment("Staging"))
{
    app.MapOpenApi();
    app.MapScalarApiReference(options =>
    {
        var title = app.Environment.IsDevelopment()
            ? "ShapeFit API - Dev"
            : "ShapeFit API - Staging (Homologação)";

        options.WithTitle(title)
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

// Endpoint de Health Check e Diagnóstico de Ambiente
app.MapGet("/api/health", () => TypedResults.Ok(new
{
    Status = "Healthy",
    Environment = app.Environment.EnvironmentName,
    Timestamp = DateTime.UtcNow
})).WithTags("Health");

app.Run();
