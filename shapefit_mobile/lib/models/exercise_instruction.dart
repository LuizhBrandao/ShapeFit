import 'workout_enums.dart';

class ExerciseInstruction {
  final String exerciseName;
  final MuscleGroup targetMuscle;
  final String gifLoopUrl; // GIF animado em loop contínuo de 4 a 8 segundos
  final String setup;
  final String execution;
  final String commonMistakes;

  const ExerciseInstruction({
    required this.exerciseName,
    required this.targetMuscle,
    required this.gifLoopUrl,
    required this.setup,
    required this.execution,
    required this.commonMistakes,
  });
}

class ExerciseInstructionRepository {
  // URLs diretas de animações em loop rápido (4-8s) mostrando a cadência e o movimento correto
  static final Map<String, ExerciseInstruction> _database = {
    'supino': const ExerciseInstruction(
      exerciseName: 'Supino Inclinado com Halteres',
      targetMuscle: MuscleGroup.chest,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Dumbbell-Press.gif',
      setup: 'Ajuste o banco em uma inclinação entre 30° e 45°. Pés firmes no chão e escápulas aduzidas contra o encosto.',
      execution: 'Desça os halteres de forma controlada (2-3 segundos) até o nível do peitoral superior. Empurre convergindo levemente no topo sem bater os halteres.',
      commonMistakes: 'Abrir excessivamente os cotovelos a 90° (mantenha a ~60° para poupar o manguito) ou tirar o glúteo do banco.',
    ),
    'crucifixo': const ExerciseInstruction(
      exerciseName: 'Crucifixo na Polia (Crossover)',
      targetMuscle: MuscleGroup.chest,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Cable-Crossover.gif',
      setup: 'Posicione as polias na altura do peito. Dê um passo à frente com tronco levemente inclinado.',
      execution: 'Mantenha os cotovelos com leve flexão fixa. Abra os braços sentindo o estiramento do peitoral e feche à frente apertando o peito no pico.',
      commonMistakes: 'Flexionar e estender os cotovelos transformando o isolamento em empurrão (supino).',
    ),
    'elevacao': const ExerciseInstruction(
      exerciseName: 'Elevação Lateral',
      targetMuscle: MuscleGroup.shoulders,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Dumbbell-Lateral-Raise.gif',
      setup: 'Tronco ereto com inclinação sutil à frente. Halteres ao lado das coxas.',
      execution: 'Eleve os braços lateralmente até a altura dos ombros pelo plano escapular (levemente à frente do corpo).',
      commonMistakes: 'Usar impulso do quadril e subir os halteres acima da linha dos ombros recrutando excesso de trapézio.',
    ),
    'triceps': const ExerciseInstruction(
      exerciseName: 'Tríceps Corda na Polia',
      targetMuscle: MuscleGroup.triceps,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Pushdown.gif',
      setup: 'Polia alta com corda. Cotovelos colados ao lado das costelas.',
      execution: 'Estenda os braços para baixo até o bloqueio articular completo, abrindo as pontas da corda na parte inferior.',
      commonMistakes: 'Deixar os cotovelos se moverem para frente e para trás durante o movimento.',
    ),
    'puxada': const ExerciseInstruction(
      exerciseName: 'Puxada Frontal na Polia',
      targetMuscle: MuscleGroup.back,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lat-Pulldown.gif',
      setup: 'Ajuste os roletes sobre as coxas para travar as pernas. Pegada um pouco mais larga que os ombros.',
      execution: 'Puxe a barra em direção ao topo do peitoral, puxando pelos cotovelos e contraindo as escápulas.',
      commonMistakes: 'Inclinar o tronco para trás excessivamente usando o peso do corpo para puxar a barra.',
    ),
    'remada': const ExerciseInstruction(
      exerciseName: 'Remada Curvada com Barra',
      targetMuscle: MuscleGroup.back,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Bent-Over-Row.gif',
      setup: 'Incline o quadril para trás a 45°, coluna neutra e joelhos sutilmente destravados. Barra alinhada sob os ombros.',
      execution: 'Puxe a barra em direção ao umbigo, puxando pelos cotovelos e espremendo a musculatura dorsal no topo.',
      commonMistakes: 'Arredondar a região lombar (risco de hérnia) ou usar impulso das pernas para levantar a barra.',
    ),
    'face pull': const ExerciseInstruction(
      exerciseName: 'Face Pull na Polia',
      targetMuscle: MuscleGroup.shoulders,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Face-Pull.gif',
      setup: 'Polia posicionada na altura dos olhos com acessório de corda dupla.',
      execution: 'Puxe a corda em direção aos olhos/testa enquanto roda externamente os ombros, afastando as mãos no final.',
      commonMistakes: 'Puxar para baixo em direção ao queixo perdendo a rotação externa do manguito rotador.',
    ),
    'rosca': const ExerciseInstruction(
      exerciseName: 'Rosca Direta Barra W',
      targetMuscle: MuscleGroup.biceps,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Barbell-Curl.gif',
      setup: 'Em pé, pés na largura do quadril, coluna alinhada e pegada nos ângulos da barra W.',
      execution: 'Flexione os cotovelos levantando a barra sem mover os braços para frente. Controle rigorosamente a descida (fase excêntrica).',
      commonMistakes: 'Balançar o tronco para trás criando inércia com a lombar.',
    ),
    'agachamento': const ExerciseInstruction(
      exerciseName: 'Agachamento Hack / Livre',
      targetMuscle: MuscleGroup.quadriceps,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/BARBELL-SQUAT.gif',
      setup: 'Pés na largura dos ombros com pontas sutilmente voltadas para fora. Core travado (manobra de Valsalva).',
      execution: 'Desça flexionando quadril e joelhos simultaneamente até passar da linha paralela. Suba empurrando o chão com o meio do pé.',
      commonMistakes: 'Valgo dinâmico (joelhos colapsando para dentro) ou perder a curvatura lombar.',
    ),
    'flexora': const ExerciseInstruction(
      exerciseName: 'Mesa Flexora',
      targetMuscle: MuscleGroup.hamstrings,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Lying-Leg-Curl.gif',
      setup: 'Deitado de bruços, ajuste o rolo logo abaixo das panturrilhas, perto do tendão de Aquiles.',
      execution: 'Flexione os joelhos trazendo os calcanhares em direção ao glúteo. Segure 1 segundo no pico e desça devagar.',
      commonMistakes: 'Tirar o quadril do banco durante a contração máxima.',
    ),
    'extensora': const ExerciseInstruction(
      exerciseName: 'Cadeira Extensora',
      targetMuscle: MuscleGroup.quadriceps,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/LEG-EXTENSION.gif',
      setup: 'Encosto ajustado para que o eixo da máquina coincida com a linha do joelho. Rolo sobre os tornozelos.',
      execution: 'Estenda as pernas totalmente até o bloqueio, contraindo o quadríceps no topo por 1 segundo antes de descer.',
      commonMistakes: 'Deixar o peso bater e despencar na fase negativa sem resistência.',
    ),
    'panturrilha': const ExerciseInstruction(
      exerciseName: 'Panturrilha em Pé na Máquina',
      targetMuscle: MuscleGroup.calves,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Standing-Calf-Raise.gif',
      setup: 'Almofadas sobre os ombros, ponta dos pés na borda da plataforma com calcanhares livres.',
      execution: 'Desça até o alongamento máximo do tendão, pause 2 segundos para anular a elasticidade reflexa, e empurre na ponta dos pés.',
      commonMistakes: 'Fazer repetições rápidas quicando sem pausar no fundo do movimento.',
    ),
  };

  static ExerciseInstruction getInstruction(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    for (var key in _database.keys) {
      if (lower.contains(key)) {
        return _database[key]!;
      }
    }

    return const ExerciseInstruction(
      exerciseName: 'Exercício de Força',
      targetMuscle: MuscleGroup.chest,
      gifLoopUrl: 'https://fitnessprogramer.com/wp-content/uploads/2021/02/Incline-Dumbbell-Press.gif',
      setup: 'Posicione-se confortavelmente garantindo postura alinhada e base firme antes de iniciar o movimento.',
      execution: 'Realize o movimento com cadência controlada: 2 a 3 segundos na descida excêntrica e 1 segundo concêntrico explosivo.',
      commonMistakes: 'Evite utilizar impulsos do corpo para mover a carga. Mantenha a tensão constante no músculo alvo.',
    );
  }
}
