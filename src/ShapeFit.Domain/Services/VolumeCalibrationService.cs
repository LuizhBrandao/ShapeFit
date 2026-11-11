using ShapeFit.Domain.Entities;
using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Domain.Services;

/// <summary>
/// Status de conformidade do volume de treino em relação à capacidade fisiológica e recuperação.
/// </summary>
public enum VolumeCompliance
{
    Optimal = 1,              // Volume ótimo dentro da faixa fisiológica ideal
    Suboptimal = 2,           // Estímulo insuficiente para o tempo de sessão
    ExcessiveJunkVolume = 3   // Volume excessivo ('junk volume') com fadiga desproporcional
}

/// <summary>
/// Resultado da auditoria fisiológica de volume de um dia de treino.
/// </summary>
public sealed record VolumeAuditResult(
    VolumeCompliance Compliance,
    int ActualExerciseCount,
    int ActualTotalSets,
    SessionVolumeCalibration ExpectedCalibration,
    string Feedback
);

/// <summary>
/// Serviço de Domínio para calibração fisiológica de volume (exercícios e séries)
/// estritamente proporcional à duração disponível para a sessão de treino.
/// </summary>
public static class VolumeCalibrationService
{
    /// <summary>
    /// Retorna os limites fisiológicos recomendados para uma dada duração em minutos:
    /// - 45 min: 4 a 5 exercícios (13 a 15 séries)
    /// - 60 min: 6 a 7 exercícios (16 a 20 séries)
    /// - 75 min: 7 a 8 exercícios (20 a 24 séries)
    /// - 90 min: 9 a 10 exercícios (24 a 30 séries com variações de ângulos e isoladores)
    /// </summary>
    public static SessionVolumeCalibration Calibrate(int durationMinutes)
    {
        if (durationMinutes <= 0)
            throw new ArgumentOutOfRangeException(nameof(durationMinutes), "A duração da sessão deve ser maior que zero.");

        if (durationMinutes <= 45)
        {
            return new SessionVolumeCalibration(
                DurationMinutes: durationMinutes,
                MinExercises: 4,
                MaxExercises: 5,
                TargetExerciseCount: 4,
                MinSets: 13,
                MaxSets: 15,
                TargetSets: 14,
                Rationale: "Sessões dinâmicas de 45 minutos demandam foco estrito em compostos primários com descanso de 60 a 90 segundos para maximizar densidade."
            );
        }

        if (durationMinutes <= 60)
        {
            return new SessionVolumeCalibration(
                DurationMinutes: durationMinutes,
                MinExercises: 6,
                MaxExercises: 7,
                TargetExerciseCount: 6,
                MinSets: 16,
                MaxSets: 20,
                TargetSets: 18,
                Rationale: "Sessões padrão de 60 minutos viabilizam cobertura de ângulos primários e inclusão de exercícios isoladores com descanso de 90 a 120 segundos."
            );
        }

        if (durationMinutes <= 75)
        {
            return new SessionVolumeCalibration(
                DurationMinutes: durationMinutes,
                MinExercises: 7,
                MaxExercises: 8,
                TargetExerciseCount: 7,
                MinSets: 20,
                MaxSets: 24,
                TargetSets: 22,
                Rationale: "Sessões de 75 minutos permitem sobrecarga mecânica pesada nos primeiros compostos e volume extra nos grupos sinergistas."
            );
        }

        return new SessionVolumeCalibration(
            DurationMinutes: durationMinutes,
            MinExercises: 9,
            MaxExercises: 10,
            TargetExerciseCount: 9,
            MinSets: 24,
            MaxSets: 30,
            TargetSets: 26,
            Rationale: "Sessões completas de 90 minutos cobrem todos os feixes anatômicos, variações de pico de contração, alongamento sob carga, panturrilha e core."
        );
    }

    /// <summary>
    /// Audita o volume planejado de um dia de rotina em relação à duração esperada.
    /// </summary>
    public static VolumeAuditResult AuditDayVolume(RoutineDay day, int durationMinutes)
    {
        ArgumentNullException.ThrowIfNull(day);
        var calibration = Calibrate(durationMinutes);

        var actualExerciseCount = day.Exercises.Count;
        var actualTotalSets = day.TotalTargetSets;

        if (actualTotalSets < calibration.MinSets || actualExerciseCount < calibration.MinExercises)
        {
            return new VolumeAuditResult(
                VolumeCompliance.Suboptimal,
                actualExerciseCount,
                actualTotalSets,
                calibration,
                $"O volume atual ({actualTotalSets} séries em {actualExerciseCount} exercícios) está abaixo do estímulo ótimo para {durationMinutes} min (mínimo recomendado: {calibration.MinSets} séries em {calibration.MinExercises} exercícios)."
            );
        }

        if (actualTotalSets > calibration.MaxSets || actualExerciseCount > calibration.MaxExercises)
        {
            return new VolumeAuditResult(
                VolumeCompliance.ExcessiveJunkVolume,
                actualExerciseCount,
                actualTotalSets,
                calibration,
                $"O volume atual ({actualTotalSets} séries em {actualExerciseCount} exercícios) excede a capacidade de recuperação ótima para {durationMinutes} min, gerando 'junk volume' acumulado (máximo recomendado: {calibration.MaxSets} séries em {calibration.MaxExercises} exercícios)."
            );
        }

        return new VolumeAuditResult(
            VolumeCompliance.Optimal,
            actualExerciseCount,
            actualTotalSets,
            calibration,
            $"Volume calibrado perfeitamente para {durationMinutes} minutos: {actualTotalSets} séries distribuídas em {actualExerciseCount} exercícios."
        );
    }
}
