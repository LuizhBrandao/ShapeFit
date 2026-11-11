using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Infrastructure.Persistence;
using ShapeFit.Infrastructure.Persistence.Repositories;

namespace ShapeFit.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' não encontrada.");

        services.AddDbContext<ShapeFitDbContext>(options =>
            options.UseNpgsql(connectionString, b => b.MigrationsAssembly(typeof(ShapeFitDbContext).Assembly.FullName)));

        services.AddScoped<IWorkoutSessionRepository, WorkoutSessionRepository>();
        services.AddScoped<IWorkoutReadRepository, WorkoutReadRepository>();

        return services;
    }
}
