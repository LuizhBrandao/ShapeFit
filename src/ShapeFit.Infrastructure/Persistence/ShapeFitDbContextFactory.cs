using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace ShapeFit.Infrastructure.Persistence;

public class ShapeFitDbContextFactory : IDesignTimeDbContextFactory<ShapeFitDbContext>
{
    public ShapeFitDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<ShapeFitDbContext>();
        
        // String de conexão padrão de migração / design-time
        var connectionString = "Host=localhost;Port=5432;Database=shapefit_db;Username=shapefit_user;Password=shapefit_password";
        
        optionsBuilder.UseNpgsql(connectionString, b => b.MigrationsAssembly(typeof(ShapeFitDbContext).Assembly.FullName));

        return new ShapeFitDbContext(optionsBuilder.Options);
    }
}
