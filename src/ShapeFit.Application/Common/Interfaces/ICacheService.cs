namespace ShapeFit.Application.Common.Interfaces;

public interface ICacheService
{
    /// <summary>
    /// Consulta o Hot Cache pela chave especificada. Se não encontrado (Cache MISS), 
    /// executa a fábrica assíncrona, persiste o resultado no cache com o TTL informado e retorna o valor.
    /// </summary>
    Task<T?> GetOrSetAsync<T>(
        string key, 
        Func<Task<T?>> factory, 
        TimeSpan? expiration = null, 
        CancellationToken cancellationToken = default);

    /// <summary>
    /// Invalida reativamente a chave informada do cache.
    /// </summary>
    Task RemoveAsync(string key, CancellationToken cancellationToken = default);
}
