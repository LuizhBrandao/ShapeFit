import 'workout_enums.dart';

class BeginnerExerciseGuide {
  final String exerciseName;
  final MuscleGroup targetMuscle;
  final String machineName;
  final String equipmentAppearance;
  final String youtubeVideoId; // Vídeo real de alta qualidade em português (curto/direto)
  final String pinAndWeightSetup; // Como regular o pino de peso e o banco
  final String startPosition; // Como sentar/entrar na máquina
  final String movementStepByStep; // Movimento mastigado
  final String feelingCheck; // O que você tem que sentir no corpo

  const BeginnerExerciseGuide({
    required this.exerciseName,
    required this.targetMuscle,
    required this.machineName,
    required this.equipmentAppearance,
    required this.youtubeVideoId,
    required this.pinAndWeightSetup,
    required this.startPosition,
    required this.movementStepByStep,
    required this.feelingCheck,
  });
}

class BeginnerExerciseGuideRepository {
  static final Map<String, BeginnerExerciseGuide> _database = {
    'agachamento': const BeginnerExerciseGuide(
      exerciseName: 'Agachamento Hack (Máquina)',
      targetMuscle: MuscleGroup.quadriceps,
      machineName: 'Máquina Hack Squat (Trilho Inclinado a 45°)',
      equipmentAppearance: 'Estrutura metálica com encosto inclinado, duas almofadas de apoio para os ombros e uma plataforma grande de metal para apoiar os pés.',
      youtubeVideoId: '0tn5K9NlCfo',
      pinAndWeightSetup: 'Comece APENAS com o peso da própria máquina (sem anilhas). Destrave a alavanca lateral girando-a para fora somente após apoiar os ombros.',
      startPosition: 'Encoste as costas e o glúteo totalmente no apoio. Coloque os ombros sob as almofadas. Apoie os pés na metade da plataforma, separados na largura dos seus ombros, pontas levemente para fora.',
      movementStepByStep: '1. Segure as alavancas com as mãos e gire para destravar a máquina.\n2. Dobre os joelhos devagar descendo até suas coxas formarem um ângulo de 90° (como se fosse sentar numa cadeira baixa).\n3. Empurre a plataforma com a sola inteira dos pés para subir. Pare um milímetro antes de esticar tudo (não trave os joelhos no topo).',
      feelingCheck: 'Você deve sentir a parte da frente das coxas queimando. Não deve sentir dor nos joelhos ou na lombar.',
    ),
    'extensora': const BeginnerExerciseGuide(
      exerciseName: 'Cadeira Extensora',
      targetMuscle: MuscleGroup.quadriceps,
      machineName: 'Cadeira Extensora (Leg Extension)',
      equipmentAppearance: 'Banco com encosto vertical e um rolete acolchoado cilíndrico na frente onde você encaixa as canelas.',
      youtubeVideoId: 'YyvSfVcxQ30',
      pinAndWeightSetup: 'Puxe o pino amarelo do encosto: ajuste para que suas costas fiquem apoiadas e a dobra de trás dos joelhos encoste exatamente na borda do assento. Coloque a carga no primeiro ou segundo tijolinho leve (10-15kg).',
      startPosition: 'Sente-se bem encaixado, apoie a canela atrás do rolo almofadado (o rolete deve ficar bem acima do seu peito do pé). Segure firme nas duas alavancas laterais ao lado do banco.',
      movementStepByStep: '1. Levante as pernas esticando os joelhos até ficarem retas.\n2. Segure por 1 segundo no alto sentindo a coxa apertar.\n3. Desça devagar em 3 segundos sem deixar o peso de placas bater embaixo.',
      feelingCheck: 'Queimação concentrada isoladamente na parte frontal da coxa.',
    ),
    'flexora': const BeginnerExerciseGuide(
      exerciseName: 'Mesa Flexora (Deitado)',
      targetMuscle: MuscleGroup.hamstrings,
      machineName: 'Mesa Flexora Horizontal (Leg Curl)',
      equipmentAppearance: 'Mesa acolchoada horizontal ou com leve quebra angular, com um rolete cilíndrico móvel para os tornozelos e pegadores frontais.',
      youtubeVideoId: 'ELOCsoDSmrg',
      pinAndWeightSetup: 'Ajuste o pino do rolete para que ele fique posicionado logo atrás dos seus tornozelos (no tendão de Aquiles), nunca na panturrilha nem no calcanhar.',
      startPosition: 'Deite-se de barriga para baixo. Segure firme nos dois pegadores de ferro da frente para manter seu quadril colado na mesa.',
      movementStepByStep: '1. Dobre os joelhos puxando os calcanhares em direção ao bumbum.\n2. Segure 1 segundo na contração máxima.\n3. Volte esticando devagar sem deixar o quadril levantar da mesa.',
      feelingCheck: 'Tensão e contração na parte de trás da coxa.',
    ),
    'puxada': const BeginnerExerciseGuide(
      exerciseName: 'Puxada Frontal na Polia',
      targetMuscle: MuscleGroup.back,
      machineName: 'Puxador Alto / Lat Pulldown',
      equipmentAppearance: 'Torre de cabo com uma barra longa curva pendurada no teto da máquina e um banco com dois roletes estofados para prender as coxas.',
      youtubeVideoId: 'CAwf7n6Luuc',
      pinAndWeightSetup: 'Ajuste a altura do rolete estofado para prender suas coxas com firmeza. Coloque carga leve no pino da torre.',
      startPosition: 'Fique de pé, segure na barra nos cantos onde ela faz a curva (pegada um palmo mais larga que seus ombros). Sente-se no banco travando as coxas sob as almofadas e mantenha o peito estufado.',
      movementStepByStep: '1. Puxe a barra para baixo em direção ao alto do seu peitoral (osso do peito).\n2. Pense em puxar com os cotovelos apontando para o chão, e não com as mãos.\n3. Deixe a barra subir controlando até os braços quase esticarem por completo.',
      feelingCheck: 'Sensação de aperto embaixo das axilas e nas costas, sem dor no pescoço.',
    ),
    'remada': const BeginnerExerciseGuide(
      exerciseName: 'Remada Baixa com Triângulo',
      targetMuscle: MuscleGroup.back,
      machineName: 'Remada Sentada na Polia / Seated Cable Row',
      equipmentAppearance: 'Banco comprido com apoio metálico inclinado para os pés na frente e uma polia baixa onde se prende um puxador em formato de V (triângulo).',
      youtubeVideoId: 'GZbfZ033f74',
      pinAndWeightSetup: 'Engate o triângulo no mosquetão da polia baixa. Ajuste a carga no pino.',
      startPosition: 'Sente-se, apoie os pés nas plataformas de metal com os joelhos um pouco destravados (nunca 100% esticados). Segure no triângulo e mantenha a coluna totalmente reta.',
      movementStepByStep: '1. Estufe o peito e puxe o triângulo em direção ao seu umbigo.\n2. Mantenha os cotovelos raspando perto das costelas.\n3. No final da puxada, aperte as escápulas das costas como se quisesse segurar uma caneta entre elas.\n4. Volte os braços para frente devagar sem deixar a coluna encurvar.',
      feelingCheck: 'Firmeza no meio das costas e sensação de postura ereta.',
    ),
    'supino': const BeginnerExerciseGuide(
      exerciseName: 'Supino Máquina Sentado',
      targetMuscle: MuscleGroup.chest,
      machineName: 'Chest Press / Máquina de Supino Horizontal',
      equipmentAppearance: 'Cadeira com encosto vertical reto ou levemente inclinado e duas manoplas na altura do peitoral conectadas a placas de peso.',
      youtubeVideoId: 'xUm0BiZCWlQ',
      pinAndWeightSetup: 'Puxe o pino embaixo do assento para regular a altura: as manoplas devem ficar exatamente na linha média do seu mamilo/peito.',
      startPosition: 'Sente com as costas e a cabeça coladas no encosto. Pés apoiados firmes no chão. Segure nas manoplas com os pulsos retos.',
      movementStepByStep: '1. Empurre as alavancas para frente até esticar quase tudo (deixe o cotovelo ligeiramente solto no final).\n2. Traga as manoplas de volta devagar até as mãos chegarem perto da linha do peito.\n3. Respire puxando o ar na descida e soltando ao empurrar.',
      feelingCheck: 'Sensação de estiramento e aperto no peitoral.',
    ),
    'triceps': const BeginnerExerciseGuide(
      exerciseName: 'Tríceps na Polia com Corda',
      targetMuscle: MuscleGroup.triceps,
      machineName: 'Polia Alta (Cross Over ou Torre de Cabo)',
      equipmentAppearance: 'Torre de cabo vertical com mosquetão no alto, onde se engata uma corda preta com nós/bolas nas pontas.',
      youtubeVideoId: 'vB5OHsJ3EME',
      pinAndWeightSetup: 'Ajuste a roldana no ponto mais alto da barra guia. Coloque o pino numa carga leve (5 a 10kg).',
      startPosition: 'Segure a corda com as palmas das mãos voltadas uma para a outra. Dê meio passo para trás, incline o tronco 10° para frente e trave os cotovelos colados nas suas costelas.',
      movementStepByStep: '1. Empurre a corda para baixo esticando apenas o antebraço.\n2. Quando chegar lá embaixo, afaste as duas pontas da corda para os lados.\n3. Volte dobrando os cotovelos até a altura do peito, mantendo o cotovelo parado no mesmo lugar.',
      feelingCheck: 'Queimação intensa na parte de trás dos braços (músculo do tchauzinho).',
    ),
    'panturrilha': const BeginnerExerciseGuide(
      exerciseName: 'Panturrilha Sentado (Gêmeos)',
      targetMuscle: MuscleGroup.calves,
      machineName: 'Máquina de Panturrilha Sentado (Banco Sóleo)',
      equipmentAppearance: 'Banco com duas almofadas redondas que se apoiam sobre os joelhos e uma barra de ferro no chão onde se apoia a ponta dos pés.',
      youtubeVideoId: 'JbyjNymZOt0',
      pinAndWeightSetup: 'Coloque as almofadas acolchoadas em cima dos joelhos. Coloque peso leve (5-10kg).',
      startPosition: 'Apoie apenas a ponta/bola dos pés na barra de apoio, deixando os calcanhares soltos para fora. Encaixe a almofada em cima das coxas/joelhos.',
      movementStepByStep: '1. Suba na ponta dos pés empurrando a almofada e destrave a alavanca lateral.\n2. Desça os calcanhares o máximo que puder para alongar o tendão e espere 2 segundos parado embaixo.\n3. Empurre forte subindo na ponta dos pés o mais alto possível.',
      feelingCheck: 'Alongamento profundo no tendão e queimação no meio da batata da perna.',
    ),
  };

  static BeginnerExerciseGuide getGuide(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    for (var key in _database.keys) {
      if (lower.contains(key)) {
        return _database[key]!;
      }
    }

    return BeginnerExerciseGuide(
      exerciseName: exerciseName,
      targetMuscle: MuscleGroup.chest,
      machineName: 'Equipamento Guiado de Musculação',
      equipmentAppearance: 'Procure o equipamento com a placa/adesivo que ilustra o músculo $exerciseName ou peça auxílio ao professor do salão.',
      youtubeVideoId: '0tn5K9NlCfo',
      pinAndWeightSetup: 'Inicie com a carga mínima da máquina (primeiro pino) para aprender o trajeto mecânico do aparelho.',
      startPosition: 'Sente-se com as costas apoiadas, coluna ereta e pés firmes no chão.',
      movementStepByStep: '1. Segure nos pegadores com firmeza.\n2. Execute o movimento de forma suave sem trancos.\n3. Controle a volta em 2 a 3 segundos.',
      feelingCheck: 'Tensão muscular constante sem dor nas articulações.',
    );
  }
}
