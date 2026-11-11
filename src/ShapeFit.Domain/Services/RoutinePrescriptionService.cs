using ShapeFit.Domain.Entities;
using ShapeFit.Domain.Enums;
using ShapeFit.Domain.ValueObjects;

namespace ShapeFit.Domain.Services;

/// <summary>
/// Serviço de Domínio para prescrição inteligente de Fichas de Treino (RoutineTemplate)
/// calibradas com precisão científica de acordo com a divisão escolhida e a duração da sessão.
/// </summary>
public static class RoutinePrescriptionService
{
    public static RoutineTemplate PrescribeRoutine(
        Guid userId,
        string routineName,
        WorkoutDivision division,
        int sessionDurationMinutes,
        string? customDescription = null)
    {
        var calibration = VolumeCalibrationService.Calibrate(sessionDurationMinutes);
        var targetExerciseCount = calibration.TargetExerciseCount;

        var description = customDescription ?? 
            $"Ficha prescrita cientificamente para sessões de {sessionDurationMinutes} minutos ({calibration.Rationale})";

        var template = new RoutineTemplate(
            Guid.NewGuid(),
            userId,
            routineName,
            description,
            division,
            isAiGenerated: true
        );

        switch (division)
        {
            case WorkoutDivision.UpperLower:
                BuildUpperLowerDays(template, targetExerciseCount);
                break;
            case WorkoutDivision.PushPullLegs:
                BuildPushPullLegsDays(template, targetExerciseCount);
                break;
            case WorkoutDivision.ABCD:
                BuildAbcdDays(template, targetExerciseCount);
                break;
            case WorkoutDivision.ABCDE:
                BuildAbcdeDays(template, targetExerciseCount);
                break;
            default:
                BuildPushPullLegsDays(template, targetExerciseCount);
                break;
        }

        return template;
    }

    private static void BuildUpperLowerDays(RoutineTemplate template, int count)
    {
        // Treino A: Upper
        var upper = new RoutineDay(Guid.NewGuid(), "Treino A • Membros Superiores (Upper)", 1, "Foco em peito, costas e deltoides");
        upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Inclinado com Halteres", MuscleGroup.Chest, 1, 3, new RepRange(8, 12), 2, 120, "Estiramento clavicular"));
        upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Puxada Frontal na Polia", MuscleGroup.Back, 2, 3, new RepRange(8, 12), 2, 90, "Puxada vertical para grande dorsal"));
        upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Reto com Barra", MuscleGroup.Chest, 3, 3, new RepRange(6, 10), 2, 120, "Sobrecarga mecânica central"));
        upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Baixa com Triângulo", MuscleGroup.Back, 4, 3, new RepRange(10, 12), 1, 90, "Espessura escapular"));

        if (count >= 5)
            upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Lateral com Halteres", MuscleGroup.Shoulders, 5, 3, new RepRange(12, 15), 1, 60, "Largura de ombros"));
        if (count >= 6)
            upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Corda na Polia", MuscleGroup.Triceps, 6, 3, new RepRange(10, 15), 1, 60, "Isolamento de tríceps"));
        if (count >= 7)
            upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Direta Barra W", MuscleGroup.Biceps, 7, 3, new RepRange(10, 12), 1, 60, "Isolamento de bíceps"));
        if (count >= 8)
            upper.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Face Pull na Polia", MuscleGroup.Shoulders, 8, 3, new RepRange(12, 15), 1, 60, "Deltoide posterior e manguito"));

        template.AddDay(upper);

        // Treino B: Lower
        var lower = new RoutineDay(Guid.NewGuid(), "Treino B • Membros Inferiores & Core (Lower)", 2, "Quadríceps, posteriores, panturrilha e core");
        lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Agachamento Hack (Máquina)", MuscleGroup.Quadriceps, 1, 3, new RepRange(8, 10), 2, 120, "Carga axial pesada de pernas"));
        lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Leg Press 45°", MuscleGroup.Quadriceps, 2, 3, new RepRange(10, 12), 2, 120, "Sobrecarga de membros inferiores"));
        lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Cadeira Extensora", MuscleGroup.Quadriceps, 3, 3, new RepRange(12, 15), 1, 60, "Isolamento de coxa"));
        lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Mesa Flexora", MuscleGroup.Hamstrings, 4, 3, new RepRange(10, 12), 1, 60, "Posterior de coxa"));

        if (count >= 5)
            lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Panturrilha Sentado (Gêmeos)", MuscleGroup.Calves, 5, 3, new RepRange(12, 15), 0, 60, "Foco no sóleo"));
        if (count >= 6)
            lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Abdominal na Polia / Crunch", MuscleGroup.Abs, 6, 3, new RepRange(15, 20), 1, 60, "Core e estabilidade"));
        if (count >= 7)
            lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Stiff com Halteres", MuscleGroup.Hamstrings, 7, 3, new RepRange(10, 12), 1, 90, "Alongamento sob carga"));
        if (count >= 8)
            lower.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação de Pernas Suspenso", MuscleGroup.Abs, 8, 3, new RepRange(12, 15), 1, 60, "Flexores e infra-abdominal"));

        template.AddDay(lower);
    }

    private static void BuildPushPullLegsDays(RoutineTemplate template, int count)
    {
        // Treino A: Push
        var push = new RoutineDay(Guid.NewGuid(), "Treino A • Push (Peito, Ombro & Tríceps)", 1, "Padrão de empurrar");
        push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Inclinado com Halteres", MuscleGroup.Chest, 1, 3, new RepRange(8, 12), 2, 120, "Feixe clavicular"));
        push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Reto com Barra", MuscleGroup.Chest, 2, 3, new RepRange(6, 10), 2, 120, "Sobrecarga mecânica central"));
        push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Crucifixo na Polia (Crossover)", MuscleGroup.Chest, 3, 3, new RepRange(12, 15), 1, 60, "Adução sob tensão contínua"));
        push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Desenvolvimento com Halteres", MuscleGroup.Shoulders, 4, 3, new RepRange(8, 12), 2, 90, "Empurrão vertical de ombros"));

        if (count >= 5)
            push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Lateral com Halteres", MuscleGroup.Shoulders, 5, 3, new RepRange(12, 15), 1, 60, "Largura de ombros"));
        if (count >= 6)
            push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Corda na Polia", MuscleGroup.Triceps, 6, 3, new RepRange(10, 15), 1, 60, "Cabeça lateral do tríceps"));
        if (count >= 7)
            push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Francês com Halter", MuscleGroup.Triceps, 7, 3, new RepRange(10, 12), 1, 60, "Cabeça longa em estiramento"));
        if (count >= 8)
            push.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Peck Deck / Voador", MuscleGroup.Chest, 8, 3, new RepRange(12, 15), 1, 60, "Isolamento de peitoral"));

        template.AddDay(push);

        // Treino B: Pull
        var pull = new RoutineDay(Guid.NewGuid(), "Treino B • Pull (Costas, Deltoide Post. & Bíceps)", 2, "Padrão de puxar");
        pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Puxada Frontal na Polia", MuscleGroup.Back, 1, 3, new RepRange(8, 12), 2, 90, "V-Taper e dorsal"));
        pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Baixa com Triângulo", MuscleGroup.Back, 2, 3, new RepRange(8, 12), 2, 90, "Espessura de costas"));
        pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Curvada com Barra", MuscleGroup.Back, 3, 3, new RepRange(8, 10), 2, 120, "Espessura bruta dorsal"));
        pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Face Pull na Polia", MuscleGroup.Shoulders, 4, 3, new RepRange(12, 15), 1, 60, "Deltoide posterior e manguito"));

        if (count >= 5)
            pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Direta Barra W", MuscleGroup.Biceps, 5, 3, new RepRange(8, 12), 1, 60, "Pico de bíceps"));
        if (count >= 6)
            pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Martelo com Halteres", MuscleGroup.Biceps, 6, 3, new RepRange(10, 12), 1, 60, "Braquial e antebraço"));
        if (count >= 7)
            pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Encolhimento com Halteres", MuscleGroup.Traps, 7, 3, new RepRange(12, 15), 1, 60, "Trapézio superior"));
        if (count >= 8)
            pull.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Scott na Máquina", MuscleGroup.Biceps, 8, 3, new RepRange(10, 12), 1, 60, "Isolamento encurtado de bíceps"));

        template.AddDay(pull);

        // Treino C: Legs
        var legs = new RoutineDay(Guid.NewGuid(), "Treino C • Legs (Membros Inferiores & Panturrilha)", 3, "Pernas completas");
        legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Agachamento Hack (Máquina)", MuscleGroup.Quadriceps, 1, 3, new RepRange(6, 10), 2, 120, "Sobrecarga axial"));
        legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Leg Press 45°", MuscleGroup.Quadriceps, 2, 3, new RepRange(10, 12), 2, 120, "Volume de coxas e glúteos"));
        legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Cadeira Extensora", MuscleGroup.Quadriceps, 3, 3, new RepRange(12, 15), 1, 60, "Isolamento de quadríceps"));
        legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Mesa Flexora", MuscleGroup.Hamstrings, 4, 3, new RepRange(10, 12), 1, 60, "Flexão de joelhos"));

        if (count >= 5)
            legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Pélvica / Hip Thrust", MuscleGroup.Glutes, 5, 3, new RepRange(10, 12), 1, 90, "Glúteo máximo"));
        if (count >= 6)
            legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Panturrilha Sentado (Gêmeos)", MuscleGroup.Calves, 6, 3, new RepRange(12, 15), 0, 60, "Gêmeos e sóleo"));
        if (count >= 7)
            legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Cadeira Abdutora", MuscleGroup.Glutes, 7, 3, new RepRange(12, 15), 1, 60, "Glúteo médio"));
        if (count >= 8)
            legs.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Panturrilha em Pé no Degrau", MuscleGroup.Calves, 8, 3, new RepRange(15, 20), 0, 60, "Gastrocnêmio estirado"));

        template.AddDay(legs);
    }

    private static void BuildAbcdDays(RoutineTemplate template, int count)
    {
        // Treino A: Peitoral & Deltoide Anterior
        var dayA = new RoutineDay(Guid.NewGuid(), "Treino A • Peitoral & Deltoide Anterior", 1);
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Inclinado com Halteres", MuscleGroup.Chest, 1, 3, new RepRange(8, 12), 2, 120));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Reto com Barra", MuscleGroup.Chest, 2, 3, new RepRange(6, 10), 2, 120));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Crucifixo na Polia (Crossover)", MuscleGroup.Chest, 3, 3, new RepRange(12, 15), 1, 60));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Desenvolvimento com Halteres", MuscleGroup.Shoulders, 4, 3, new RepRange(8, 12), 2, 90));
        if (count >= 5) dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Peck Deck / Voador", MuscleGroup.Chest, 5, 3, new RepRange(12, 15), 1, 60));
        if (count >= 6) dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Frontal na Polia", MuscleGroup.Shoulders, 6, 3, new RepRange(12, 15), 1, 60));
        template.AddDay(dayA);

        // Treino B: Dorsal, Trapézio & Deltoide Post.
        var dayB = new RoutineDay(Guid.NewGuid(), "Treino B • Dorsal, Trapézio & Deltoide Posterior", 2);
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Puxada Frontal na Polia", MuscleGroup.Back, 1, 3, new RepRange(8, 12), 2, 90));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Baixa com Triângulo", MuscleGroup.Back, 2, 3, new RepRange(8, 12), 2, 90));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Curvada com Barra", MuscleGroup.Back, 3, 3, new RepRange(8, 10), 2, 120));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Face Pull na Polia", MuscleGroup.Shoulders, 4, 3, new RepRange(12, 15), 1, 60));
        if (count >= 5) dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Encolhimento com Barra", MuscleGroup.Traps, 5, 3, new RepRange(12, 15), 1, 60));
        if (count >= 6) dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Cavalinho (Barra T)", MuscleGroup.Back, 6, 3, new RepRange(10, 12), 1, 90));
        template.AddDay(dayB);

        // Treino C: Membros Inferiores
        var dayC = new RoutineDay(Guid.NewGuid(), "Treino C • Membros Inferiores Completos", 3);
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Agachamento Hack (Máquina)", MuscleGroup.Quadriceps, 1, 3, new RepRange(6, 10), 2, 120));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Leg Press 45°", MuscleGroup.Quadriceps, 2, 3, new RepRange(10, 12), 2, 120));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Cadeira Extensora", MuscleGroup.Quadriceps, 3, 3, new RepRange(12, 15), 1, 60));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Mesa Flexora", MuscleGroup.Hamstrings, 4, 3, new RepRange(10, 12), 1, 60));
        if (count >= 5) dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Pélvica / Hip Thrust", MuscleGroup.Glutes, 5, 3, new RepRange(10, 12), 1, 90));
        if (count >= 6) dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Panturrilha Sentado (Gêmeos)", MuscleGroup.Calves, 6, 3, new RepRange(12, 15), 0, 60));
        template.AddDay(dayC);

        // Treino D: Braços Completos
        var dayD = new RoutineDay(Guid.NewGuid(), "Treino D • Braços Completos (Bíceps, Tríceps & Core)", 4);
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Corda na Polia", MuscleGroup.Triceps, 1, 3, new RepRange(10, 15), 1, 60));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Francês com Halter", MuscleGroup.Triceps, 2, 3, new RepRange(10, 12), 1, 60));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Direta Barra W", MuscleGroup.Biceps, 3, 3, new RepRange(8, 12), 1, 60));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Martelo com Halteres", MuscleGroup.Biceps, 4, 3, new RepRange(10, 12), 1, 60));
        if (count >= 5) dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Abdominal na Polia / Crunch", MuscleGroup.Abs, 5, 3, new RepRange(15, 20), 1, 60));
        if (count >= 6) dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Lateral com Halteres", MuscleGroup.Shoulders, 6, 3, new RepRange(12, 15), 1, 60));
        template.AddDay(dayD);
    }

    private static void BuildAbcdeDays(RoutineTemplate template, int count)
    {
        // 5 Fichas de Isolamento Máximo
        var dayA = new RoutineDay(Guid.NewGuid(), "Treino A • Peitoral Completo", 1);
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Inclinado com Halteres", MuscleGroup.Chest, 1, 3, new RepRange(8, 12), 2, 120));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Supino Reto com Barra", MuscleGroup.Chest, 2, 3, new RepRange(6, 10), 2, 120));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Crucifixo na Polia (Crossover)", MuscleGroup.Chest, 3, 3, new RepRange(12, 15), 1, 60));
        dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Peck Deck / Voador", MuscleGroup.Chest, 4, 3, new RepRange(12, 15), 1, 60));
        if (count >= 5) dayA.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Flexão de Braço no Solo", MuscleGroup.Chest, 5, 3, new RepRange(15, 20), 0, 60));
        template.AddDay(dayA);

        var dayB = new RoutineDay(Guid.NewGuid(), "Treino B • Dorsal & Trapézio", 2);
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Puxada Frontal na Polia", MuscleGroup.Back, 1, 3, new RepRange(8, 12), 2, 90));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Baixa com Triângulo", MuscleGroup.Back, 2, 3, new RepRange(8, 12), 2, 90));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Remada Curvada com Barra", MuscleGroup.Back, 3, 3, new RepRange(8, 10), 2, 120));
        dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Encolhimento com Barra", MuscleGroup.Traps, 4, 3, new RepRange(12, 15), 1, 60));
        if (count >= 5) dayB.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Pulldown na Polia Alta", MuscleGroup.Back, 5, 3, new RepRange(12, 15), 1, 60));
        template.AddDay(dayB);

        var dayC = new RoutineDay(Guid.NewGuid(), "Treino C • Membros Inferiores (Leg Day)", 3);
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Agachamento Hack (Máquina)", MuscleGroup.Quadriceps, 1, 3, new RepRange(6, 10), 2, 120));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Leg Press 45°", MuscleGroup.Quadriceps, 2, 3, new RepRange(10, 12), 2, 120));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Cadeira Extensora", MuscleGroup.Quadriceps, 3, 3, new RepRange(12, 15), 1, 60));
        dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Mesa Flexora", MuscleGroup.Hamstrings, 4, 3, new RepRange(10, 12), 1, 60));
        if (count >= 5) dayC.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Panturrilha Sentado (Gêmeos)", MuscleGroup.Calves, 5, 3, new RepRange(12, 15), 0, 60));
        template.AddDay(dayC);

        var dayD = new RoutineDay(Guid.NewGuid(), "Treino D • Deltoides & Manguito", 4);
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Desenvolvimento com Halteres", MuscleGroup.Shoulders, 1, 3, new RepRange(8, 12), 2, 90));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Lateral com Halteres", MuscleGroup.Shoulders, 2, 3, new RepRange(12, 15), 1, 60));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Face Pull na Polia", MuscleGroup.Shoulders, 3, 3, new RepRange(12, 15), 1, 60));
        dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Elevação Frontal na Polia", MuscleGroup.Shoulders, 4, 3, new RepRange(12, 15), 1, 60));
        if (count >= 5) dayD.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Crucifixo Invertido com Halteres", MuscleGroup.Shoulders, 5, 3, new RepRange(12, 15), 1, 60));
        template.AddDay(dayD);

        var dayE = new RoutineDay(Guid.NewGuid(), "Treino E • Braços & Core", 5);
        dayE.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Corda na Polia", MuscleGroup.Triceps, 1, 3, new RepRange(10, 15), 1, 60));
        dayE.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Direta Barra W", MuscleGroup.Biceps, 2, 3, new RepRange(8, 12), 1, 60));
        dayE.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Tríceps Francês com Halter", MuscleGroup.Triceps, 3, 3, new RepRange(10, 12), 1, 60));
        dayE.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Rosca Martelo com Halteres", MuscleGroup.Biceps, 4, 3, new RepRange(10, 12), 1, 60));
        if (count >= 5) dayE.AddExercise(new RoutineExercise(Guid.NewGuid(), Guid.NewGuid(), "Abdominal na Polia / Crunch", MuscleGroup.Abs, 5, 3, new RepRange(15, 20), 1, 60));
        template.AddDay(dayE);
    }
}
