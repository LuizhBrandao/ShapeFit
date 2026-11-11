using System.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Npgsql;
using ShapeFit.Application.Common.Interfaces;
using ShapeFit.Infrastructure.Caching;
using ShapeFit.Infrastructure.Persistence;
using ShapeFit.Infrastructure.Persistence.Repositories;
using StackExchange.Redis;

namespace ShapeFit.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' não encontrada.");

        // Centralização do pool de conexões com NpgsqlDataSource
        var dataSource = NpgsqlDataSource.Create(connectionString);
        services.AddSingleton(dataSource);
        services.AddScoped<IDbConnection>(sp => sp.GetRequiredService<NpgsqlDataSource>().CreateConnection());

        services.AddDbContext<ShapeFitDbContext>(options =>
            options.UseNpgsql(dataSource, b => b.MigrationsAssembly(typeof(ShapeFitDbContext).Assembly.FullName)));

        services.AddScoped<IWorkoutSessionRepository, WorkoutSessionRepository>();
        services.AddScoped<IWorkoutReadRepository, WorkoutReadRepository>();
        services.AddScoped<IRoutineTemplateRepository, RoutineTemplateRepository>();
        services.AddScoped<IMesocycleRepository, MesocycleRepository>();

        // Hot Cache Resiliente via Redis e MessagePack
        var redisConnectionString = configuration.GetConnectionString("Redis") ?? "localhost:6379";
        services.AddSingleton<IConnectionMultiplexer>(_ =>
        {
            var options = ConfigurationOptions.Parse(redisConnectionString);
            options.AbortOnConnectFail = false;
            return ConnectionMultiplexer.Connect(options);
        });
        services.AddSingleton<ICacheService, RedisCacheService>();

        return services;
    }
}
