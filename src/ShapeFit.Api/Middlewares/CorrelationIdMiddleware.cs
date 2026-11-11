namespace ShapeFit.Api.Middlewares;

public class CorrelationIdMiddleware(RequestDelegate next, ILogger<CorrelationIdMiddleware> logger)
{
    public const string CorrelationIdHeader = "X-Correlation-ID";

    public async Task InvokeAsync(HttpContext context)
    {
        if (!context.Request.Headers.TryGetValue(CorrelationIdHeader, out var correlationId) || string.IsNullOrWhiteSpace(correlationId))
        {
            correlationId = Guid.NewGuid().ToString();
        }

        context.TraceIdentifier = correlationId!;
        context.Response.Headers.Append(CorrelationIdHeader, correlationId);

        using (logger.BeginScope(new Dictionary<string, object> { ["CorrelationId"] = correlationId! }))
        {
            logger.LogInformation("Iniciando requisição {Method} {Path} com CorrelationId: {CorrelationId}",
                context.Request.Method, context.Request.Path, correlationId);

            await next(context);

            logger.LogInformation("Requisição {Method} {Path} finalizada com status: {StatusCode}",
                context.Request.Method, context.Request.Path, context.Response.StatusCode);
        }
    }
}

public static class CorrelationIdMiddlewareExtensions
{
    public static IApplicationBuilder UseCorrelationId(this IApplicationBuilder app)
        => app.UseMiddleware<CorrelationIdMiddleware>();
}
