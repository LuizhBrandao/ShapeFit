import 'workout_enums.dart';

class ExerciseInstruction {
  final String exerciseName;
  final MuscleGroup targetMuscle;
  final String videoUrl;
  final String setup;
  final String execution;
  final String commonMistakes;

  const ExerciseInstruction({
    required this.exerciseName,
    required this.targetMuscle,
    required this.videoUrl,
    required this.setup,
    required this.execution,
    required this.commonMistakes,
  });
}

class ExerciseInstructionRepository {
  static final Map<String, ExerciseInstruction> _database = {
    'supino': const ExerciseInstruction(
      exerciseName: 'Supino Inclinado com Halteres',
      targetMuscle: MuscleGroup.chest,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-athlete-working-out-with-dumbbells-44161-large.mp4',
      setup: 'Ajuste o banco em uma inclinação entre 30° e 45°. Pés firmes no chão e escápulas aduzidas contra o encosto.',
      execution: 'Desça os halteres de forma controlada (2-3 segundos) até o nível do peitoral superior. Empurre para cima convergindo levemente no topo sem bater os halteres.',
      commonMistakes: 'Abrir excessivamente os cotovelos a 90° (mantenha a ~60° para poupar o manguito) ou tirar o glúteo do banco.',
    ),
    'crucifixo': const ExerciseInstruction(
      exerciseName: 'Crucifixo na Polia (Crossover)',
      targetMuscle: MuscleGroup.chest,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-doing-cable-cross-exercise-at-gym-44163-large.mp4',
      setup: 'Posicione as polias na altura do peito ou superior. Dê um passo à frente com tronco levemente inclinado.',
      execution: 'Mantenha os cotovelos com leve flexão fixa. Abra os braços sentindo o estiramento do peitoral e feche à frente apertando o peito no pico.',
      commonMistakes: 'Flexionar e estender os braços como se fosse um supino, transformando isolamento em composto.',
    ),
    'elevacao': const ExerciseInstruction(
      exerciseName: 'Elevação Lateral',
      targetMuscle: MuscleGroup.shoulders,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-athletic-man-lifting-dumbbells-in-gym-44155-large.mp4',
      setup: 'Tronco ereto com inclinação sutil à frente. Halteres ao lado das coxas.',
      execution: 'Eleve os braços lateralmente até a altura dos ombros pelo plano escapular (levemente à frente do corpo).',
      commonMistakes: 'Usar impulso do quadril e subir os halteres acima da linha dos ombros recrutando excesso de trapézio.',
    ),
    'triceps': const ExerciseInstruction(
      exerciseName: 'Tríceps Corda na Polia',
      targetMuscle: MuscleGroup.triceps,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-exercising-triceps-with-cable-rope-at-the-gym-44168-large.mp4',
      setup: 'Polia alta com corda. Cotovelos colados ao lado das costelas.',
      execution: 'Estenda os braços para baixo até o bloqueio articular completo, abrindo as pontas da corda na parte inferior.',
      commonMistakes: 'Deixar os cotovelos se moverem para frente e para trás durante o movimento.',
    ),
    'puxada': const ExerciseInstruction(
      exerciseName: 'Puxada Frontal na Polia',
      targetMuscle: MuscleGroup.back,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-training-his-back-on-a-pulldown-machine-44164-large.mp4',
      setup: 'Ajuste os roletes sobre as coxas para travar as pernas. Pegada um pouco mais larga que os ombros.',
      execution: 'Puxe a barra em direção ao topo do peitoral, puxando pelos cotovelos e contraindo as escápulas.',
      commonMistakes: 'Inclinar o tronco para trás excessivamente usando o peso do corpo para puxar a barra.',
    ),
    'agachamento': const ExerciseInstruction(
      exerciseName: 'Agachamento Hack / Livre',
      targetMuscle: MuscleGroup.quadriceps,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-man-doing-squats-with-barbell-in-gym-44166-large.mp4',
      setup: 'Pés na largura dos ombros com pontas sutilmente voltadas para fora. Core travado (manobra de Valsalva).',
      execution: 'Desça flexionando quadril e joelhos simultaneamente até passar da linha paralela (se a mobilidade permitir). Suba empurrando o chão com o meio do pé.',
      commonMistakes: 'Valgo dinâmico (joelhos colapsando para dentro) ou perder a curvatura lombar.',
    ),
  };

  static ExerciseInstruction getInstruction(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    for (var key in _database.keys) {
      if (lower.contains(key)) {
        return _database[key]!;
      }
    }

    // Default caso o exercício não tenha vídeo específico mapeado
    return ExerciseInstruction(
      exerciseName: exerciseName,
      targetMuscle: MuscleGroup.chest,
      videoUrl: 'https://assets.mixkit.co/videos/preview/mixkit-athlete-working-out-with-dumbbells-44161-large.mp4',
      setup: 'Posicione-se confortavelmente garantindo postura alinhada e base firme antes de iniciar o movimento.',
      execution: 'Realize o movimento com cadência controlada: 2 a 3 segundos na descida excêntrica e 1 segundo concêntrico explosivo.',
      commonMistakes: 'Evite utilizar impulsos do corpo para mover a carga. Mantenha a tensão constante no músculo alvo.',
    );
  }
}
