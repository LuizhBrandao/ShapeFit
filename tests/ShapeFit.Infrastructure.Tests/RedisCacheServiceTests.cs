using MessagePack;
using MessagePack.Resolvers;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using NSubstitute.ExceptionExtensions;
using ShapeFit.Application.Workouts.DTOs;
using ShapeFit.Domain.Enums;
using ShapeFit.Infrastructure.Caching;
using StackExchange.Redis;
using Xunit;

namespace ShapeFit.Infrastructure.Tests;

public class RedisCacheServiceTests
{
    private readonly IConnectionMultiplexer _redis;
    private readonly IDatabase _database;
    private readonly RedisCacheService _sut;

    public RedisCacheServiceTests()
    {
        _redis = Substitute.For<IConnectionMultiplexer>();
        _database = Substitute.For<IDatabase>();
        _redis.GetDatabase(Arg.Any<int>(), Arg.Any<object>()).Returns(_database);

        _sut = new RedisCacheService(_redis, NullLogger<RedisCacheService>.Instance);
    }

    [Fact]
    public void MessagePack_ShouldSerializeAndDeserialize_LastExercisePerformanceDto_Accurately()
    {
        // Arrange
        var exerciseId = Guid.NewGuid();
        var performedAt = new DateTime(2026, 11, 11, 14, 0, 0, DateTimeKind.Utc);
        var originalDto = new LastExercisePerformanceDto(
            exerciseId,
            "Supino Reto com Barra",
            performedAt,
            new List<PreviousSetDto>
            {
                new(1, SetType.WarmUp, 40.0m, "kg", 15, null),
                new(2, SetType.Normal, 80.0m, "kg", 10, 2),
                new(3, SetType.Failure, 85.5m, "kg", 7, 0)
            }
        );

        // Act
        var options = ContractlessStandardResolver.Options;
        var bytes = MessagePackSerializer.Serialize(originalDto, options);
        var deserialized = MessagePackSerializer.Deserialize<LastExercisePerformanceDto>(bytes, options);

        // Assert
        Assert.NotNull(deserialized);
        Assert.Equal(originalDto.ExerciseId, deserialized.ExerciseId);
        Assert.Equal(originalDto.ExerciseName, deserialized.ExerciseName);
        Assert.Equal(originalDto.PerformedAt, deserialized.PerformedAt);
        Assert.Equal(3, deserialized.Sets.Count);

        Assert.Equal(SetType.WarmUp, deserialized.Sets[0].Type);
        Assert.Equal(40.0m, deserialized.Sets[0].Weight);

        Assert.Equal(SetType.Normal, deserialized.Sets[1].Type);
        Assert.Equal(80.0m, deserialized.Sets[1].Weight);
        Assert.Equal(2, deserialized.Sets[1].RepsInReserve);

        Assert.Equal(SetType.Failure, deserialized.Sets[2].Type);
        Assert.Equal(85.5m, deserialized.Sets[2].Weight);
        Assert.Equal(0, deserialized.Sets[2].RepsInReserve);
    }

    [Fact]
    public async Task GetOrSetAsync_OnCacheMiss_ShouldExecuteFactoryAndStoreInRedis()
    {
        // Arrange
        const string key = "users:user1:exercises:ex1:last-performance";
        _database.StringGetAsync(key).Returns(RedisValue.Null);

        var expectedDto = new LastExercisePerformanceDto(
            Guid.NewGuid(),
            "Agachamento Livre",
            DateTime.UtcNow,
            new List<PreviousSetDto> { new(1, SetType.Normal, 100m, "kg", 8, 1) }
        );

        var factoryExecuted = false;
        Task<LastExercisePerformanceDto?> Factory()
        {
            factoryExecuted = true;
            return Task.FromResult<LastExercisePerformanceDto?>(expectedDto);
        }

        // Act
        var result = await _sut.GetOrSetAsync(key, Factory, TimeSpan.FromHours(12));

        // Assert
        Assert.True(factoryExecuted);
        Assert.NotNull(result);
        Assert.Equal(expectedDto.ExerciseName, result.ExerciseName);
        await _database.Received(1).StringSetAsync(
            key, 
            Arg.Any<RedisValue>(), 
            TimeSpan.FromHours(12)
        );
    }

    [Fact]
    public async Task GetOrSetAsync_OnCacheHit_ShouldReturnCachedValueWithoutCallingFactory()
    {
        // Arrange
        const string key = "users:user1:exercises:ex1:last-performance";
        var cachedDto = new LastExercisePerformanceDto(
            Guid.NewGuid(),
            "Desenvolvimento com Halteres",
            DateTime.UtcNow,
            new List<PreviousSetDto> { new(1, SetType.Normal, 24m, "kg", 12, 1) }
        );

        var bytes = MessagePackSerializer.Serialize(cachedDto, ContractlessStandardResolver.Options);
        _database.StringGetAsync(key).Returns((RedisValue)bytes);

        var factoryExecuted = false;
        Task<LastExercisePerformanceDto?> Factory()
        {
            factoryExecuted = true;
            return Task.FromResult<LastExercisePerformanceDto?>(null);
        }

        // Act
        var result = await _sut.GetOrSetAsync(key, Factory);

        // Assert
        Assert.False(factoryExecuted);
        Assert.NotNull(result);
        Assert.Equal("Desenvolvimento com Halteres", result.ExerciseName);
    }

    [Fact]
    public async Task GetOrSetAsync_WhenRedisThrows_ShouldGracefullyFallbackToFactory()
    {
        // Arrange
        const string key = "users:user1:exercises:ex1:last-performance";
        _database.StringGetAsync(key).Throws(new RedisException("Redis offline"));

        var expectedDto = new LastExercisePerformanceDto(
            Guid.NewGuid(),
            "Remada Curvada",
            DateTime.UtcNow,
            new List<PreviousSetDto>()
        );

        // Act
        var result = await _sut.GetOrSetAsync(key, () => Task.FromResult<LastExercisePerformanceDto?>(expectedDto));

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Remada Curvada", result.ExerciseName);
    }

    [Fact]
    public async Task RemoveAsync_ShouldCallKeyDelete()
    {
        // Arrange
        const string key = "users:user1:exercises:ex1:last-performance";

        // Act
        await _sut.RemoveAsync(key);

        // Assert
        await _database.Received(1).KeyDeleteAsync(key);
    }
}
