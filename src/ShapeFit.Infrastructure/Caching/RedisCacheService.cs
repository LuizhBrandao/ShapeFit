using MessagePack;
using MessagePack.Resolvers;
using Microsoft.Extensions.Logging;
using ShapeFit.Application.Common.Interfaces;
using StackExchange.Redis;

namespace ShapeFit.Infrastructure.Caching;

public class RedisCacheService : ICacheService
{
    private readonly IConnectionMultiplexer _redis;
    private readonly ILogger<RedisCacheService> _logger;
    private readonly MessagePackSerializerOptions _options;

    public RedisCacheService(IConnectionMultiplexer redis, ILogger<RedisCacheService> logger)
    {
        _redis = redis;
        _logger = logger;
        _options = ContractlessStandardResolver.Options;
    }

    public async Task<T?> GetOrSetAsync<T>(
        string key, 
        Func<Task<T?>> factory, 
        TimeSpan? expiration = null, 
        CancellationToken cancellationToken = default)
    {
        var db = _redis.GetDatabase();

        try
        {
            var cachedBytes = await db.StringGetAsync(key);
            if (cachedBytes.HasValue)
            {
                _logger.LogInformation("Cache HIT para chave: {Key}", key);
                return MessagePackSerializer.Deserialize<T>((byte[])cachedBytes!, _options, cancellationToken);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Falha ao consultar cache Redis para chave: {Key}. Prosseguindo para fonte primária.", key);
        }

        _logger.LogInformation("Cache MISS para chave: {Key}. Carregando fonte primária...", key);
        var result = await factory();

        if (result is not null)
        {
            try
            {
                var bytes = MessagePackSerializer.Serialize(result, _options, cancellationToken);
                await db.StringSetAsync(key, bytes, expiration ?? TimeSpan.FromHours(12));
                _logger.LogInformation("Valor persistido no cache Redis para chave: {Key} com TTL de {Ttl}", key, expiration ?? TimeSpan.FromHours(12));
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Falha ao gravar no cache Redis para chave: {Key}", key);
            }
        }

        return result;
    }

    public async Task RemoveAsync(string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var db = _redis.GetDatabase();
            await db.KeyDeleteAsync(key);
            _logger.LogInformation("Chave invalidada do cache Redis: {Key}", key);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Falha ao invalidar chave do cache Redis: {Key}", key);
        }
    }
}
