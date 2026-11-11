import 'workout_enums.dart';

class BeginnerExerciseGuide {
  final String exerciseName;
  final MuscleGroup targetMuscle;
  final String machineName;
  final String equipmentAppearance;
  final String youtubeVideoId; // ID de demonstração em vídeo curto
  final String pinAndWeightSetup; // Como regular o pino de peso e banco
  final String startPosition; // Posição do corpo
  final String movementStepByStep; // Passo a passo
  final String feelingCheck; // O que sentir

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
  static final List<BeginnerExerciseGuide> allGuides = [
    // --- PEITORAL ---
    const BeginnerExerciseGuide(
      exerciseName: 'Supino Reto com Barra',
      targetMuscle: MuscleGroup.chest,
      machineName: 'Banco de Supino Reto com Suporte de Barra',
      equipmentAppearance: 'Banco horizontal acolchoado com cavalete de metal para apoiar uma barra olímpica de 20kg.',
      youtubeVideoId: 'rT7DgCr-3pg',
      pinAndWeightSetup: 'Coloque as travas de segurança na altura do peito. Comece com anilhas leves de 5kg ou apenas a barra vazia.',
      startPosition: 'Deite-se com os olhos alinhados embaixo da barra. Pés bem firmes no chão, glúteos apoiados e peito estufado.',
      movementStepByStep: '1. Segure a barra na largura de um palmo além dos ombros.\n2. Tire a barra do suporte e desça controladamente até encostar de leve no meio do peitoral.\n3. Empurre a barra para cima até esticar quase tudo sem trancar o cotovelo.',
      feelingCheck: 'Pressão e trabalho no centro do peitoral e tríceps.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Supino Inclinado com Halteres',
      targetMuscle: MuscleGroup.chest,
      machineName: 'Banco Inclinado (30° a 45°)',
      equipmentAppearance: 'Banco estofado com encosto inclinado regulável e suporte de halteres manuais.',
      youtubeVideoId: '8iPEnn-ltC8',
      pinAndWeightSetup: 'Puxe o pino do banco e trave no terceiro furo (cerca de 30°). Escolha dois halteres leves de mesmo peso.',
      startPosition: 'Sente com os halteres apoiados sobre os joelhos. Deite impulsionando os joelhos para levar os pesos aos ombros.',
      movementStepByStep: '1. Com as escápulas coladas no encosto, desça os halteres devagar ao lado do peito superior.\n2. Empurre os halteres para cima convergindo no topo sem bater os pesos.',
      feelingCheck: 'Ativação forte na parte de cima do peitoral (perto da clavícula).',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Crucifixo na Polia (Crossover)',
      targetMuscle: MuscleGroup.chest,
      machineName: 'Crossover / Torre de Polias Duplas',
      equipmentAppearance: 'Duas torres altas de cabo unidas por uma barra superior. Duas manoplas estofadas nos mosquetões.',
      youtubeVideoId: 'taI4XduLpBe',
      pinAndWeightSetup: 'Ajuste a altura da roldana na altura dos ombros ou peito. Ajuste os dois pinos com a mesma carga leve.',
      startPosition: 'Segure uma manopla em cada mão, dê um passo à frente no centro do aparelho com tronco levemente inclinado.',
      movementStepByStep: '1. Com cotovelos levemente flexionados e firmes, abra os braços sentindo o peito esticar.\n2. Feche os braços à frente como se estivesse abraçando uma árvore larga, apertando o peito no meio.',
      feelingCheck: 'Alongamento profundo nas pontas do peitoral e aperto máximo no centro.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Peck Deck / Voador Máquina',
      targetMuscle: MuscleGroup.chest,
      machineName: 'Máquina Voador / Pec Deck',
      equipmentAppearance: 'Banco com encosto vertical reto e dois braços móveis com almofadas ou manoplas verticais.',
      youtubeVideoId: 'eGjt4lkGeZ4',
      pinAndWeightSetup: 'Ajuste a altura do banco para que as manoplas fiquem no meio do seu peitoral. Carga leve no pino.',
      startPosition: 'Costas bem apoiadas, pés plantados no chão. Segure as manoplas com cotovelos levemente destravados.',
      movementStepByStep: '1. Junte os braços à frente até quase se tocarem, apertando o peito por 1 segundo.\n2. Volte devagar controlando o peso sem deixar as placas baterem.',
      feelingCheck: 'Isolamento completo do peitoral sem sobrecarga nos cotovelos.',
    ),

    // --- COSTAS & DORSAIS ---
    const BeginnerExerciseGuide(
      exerciseName: 'Puxada Frontal na Polia',
      targetMuscle: MuscleGroup.back,
      machineName: 'Puxador Alto / Lat Pulldown',
      equipmentAppearance: 'Torre de cabo com uma barra longa curva pendurada no alto e dois roletes acolchoados para travar as coxas.',
      youtubeVideoId: 'CAwf7n6Luuc',
      pinAndWeightSetup: 'Puxe o pino para travar as coxas com firmeza. Comece com carga moderada (20 a 30kg).',
      startPosition: 'Segure a barra nos cantos curvos. Sente travando as pernas, peito estufado e olhar ligeiramente para cima.',
      movementStepByStep: '1. Puxe a barra para baixo em direção à parte de cima do peito.\n2. Pense em puxar com os cotovelos apontando para o chão.\n3. Deixe a barra subir controlando até os braços quase esticarem por completo.',
      feelingCheck: 'Sensação de abertura e contração nas costas, embaixo das axilas.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Remada Baixa com Triângulo',
      targetMuscle: MuscleGroup.back,
      machineName: 'Remada Baixa Sentada (Seated Cable Row)',
      equipmentAppearance: 'Banco horizontal comprido com apoios inclinados de ferro para os pés e polia baixa com pegador em V.',
      youtubeVideoId: 'GZbfZ033f74',
      pinAndWeightSetup: 'Engate o triângulo no mosquetão da polia. Coloque carga moderada.',
      startPosition: 'Sente-se, apoie os pés nas plataformas com os joelhos um pouco flexionados. Coluna ereta.',
      movementStepByStep: '1. Estufe o peito e puxe o triângulo até encostar perto do umbigo.\n2. Aperte as costas atrás como se segurasse uma moeda entre as escápulas.\n3. Estique os braços para frente devagar mantendo a coluna ereta.',
      feelingCheck: 'Firmeza e densidade no meio das costas.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Remada Curvada com Barra',
      targetMuscle: MuscleGroup.back,
      machineName: 'Barra com Anilhas (Livre)',
      equipmentAppearance: 'Barra média ou longa no chão com anilhas redondas.',
      youtubeVideoId: '9efgc2WvF80',
      pinAndWeightSetup: 'Use anilhas leves de 5kg ou 10kg para manter a técnica perfeita.',
      startPosition: 'Dobre o quadril para trás a 45°, joelhos levemente soltos e coluna totalmente retificada. Barra alinhada nos ombros.',
      movementStepByStep: '1. Puxe a barra em direção à linha do umbigo raspando perto das coxas.\n2. Esprema a musculatura dorsal no topo.\n3. Desça a barra de forma controlada.',
      feelingCheck: 'Força na coluna dorsal e trapézio.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Remada Cavalinho (Barra T)',
      targetMuscle: MuscleGroup.back,
      machineName: 'T-Bar Row Machine / Cavalinho',
      equipmentAppearance: 'Máquina inclinada com apoio de peito almofadado ou barra longa fixa no chão por articulação giratória.',
      youtubeVideoId: 'j3Igk5nyZE4',
      pinAndWeightSetup: 'Apoie o peito na almofada. Coloque as anilhas na ponta da barra.',
      startPosition: 'Segure nas duas alavancas paralelas com pegada neutra. Pés firmes na base metálica.',
      movementStepByStep: '1. Puxe as alavancas em direção ao corpo com foco em contrair as costas.\n2. Desça devagar até o alongamento completo dos braços.',
      feelingCheck: 'Isolamento de costas sem sobrecarga na lombar graças ao apoio de peito.',
    ),

    // --- OMBROS / DELTOIDES ---
    const BeginnerExerciseGuide(
      exerciseName: 'Desenvolvimento com Halteres',
      targetMuscle: MuscleGroup.shoulders,
      machineName: 'Banco com Encosto a 90°',
      equipmentAppearance: 'Banco reto na vertical com encosto alto apoiando as costas por inteiro.',
      youtubeVideoId: 'qEwKCR5JCog',
      pinAndWeightSetup: 'Ajuste o encosto a 80°-90°. Escolha dois halteres leves.',
      startPosition: 'Sente com as costas coladas. Levante os halteres na altura das orelhas, com cotovelos a 90°.',
      movementStepByStep: '1. Empurre os halteres para o alto até quase se tocarem acima da cabeça.\n2. Desça devagar até a altura das orelhas novamente.',
      feelingCheck: 'Queimação nos ombros por inteiro.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Elevação Lateral com Halteres',
      targetMuscle: MuscleGroup.shoulders,
      machineName: 'Espaço de Pesos Livres (Halteres)',
      equipmentAppearance: 'Halteres de borracha ou ferro na área de peso livre.',
      youtubeVideoId: '3VcKaXpzqRo',
      pinAndWeightSetup: 'Escolha halteres bem leves (2kg a 5kg para iniciantes).',
      startPosition: 'Fique de pé, pés na largura do quadril, coluna ereta. Halteres ao lado das coxas.',
      movementStepByStep: '1. Levante os dois braços para os lados até ficarem na altura dos ombros.\n2. Cotovelos levemente flexionados apontando para fora.\n3. Desça controlando em 3 segundos sem bater os halteres nas pernas.',
      feelingCheck: 'Foco exclusivo na lateral do ombro (efeito ombro largo).',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Face Pull na Polia',
      targetMuscle: MuscleGroup.shoulders,
      machineName: 'Polia Alta com Corda',
      equipmentAppearance: 'Torre de cabo ajustável com acessório de corda dupla.',
      youtubeVideoId: 'rep-qVOkqgk',
      pinAndWeightSetup: 'Suba a polia na altura dos olhos. Carga bem leve no pino.',
      startPosition: 'Segure a corda com os polegares voltados para trás. Dê um passo para trás.',
      movementStepByStep: '1. Puxe a corda em direção ao seu nariz/testa.\n2. No final, abra as mãos para os lados rodando os ombros para trás.\n3. Volte devagar.',
      feelingCheck: 'Alívio postural e contração na parte de trás dos ombros.',
    ),

    // --- BRAÇOS (BÍCEPS & TRÍCEPS) ---
    const BeginnerExerciseGuide(
      exerciseName: 'Tríceps Corda na Polia',
      targetMuscle: MuscleGroup.triceps,
      machineName: 'Torre de Polia Alta',
      equipmentAppearance: 'Cabo vertical alto com corda de duas pontas e nós de borracha.',
      youtubeVideoId: 'vB5OHsJ3EME',
      pinAndWeightSetup: 'Roldana no topo. Carga leve no pino (5 a 10kg).',
      startPosition: 'Segure a corda, cotovelos grudados nas costelas, corpo ligeiramente inclinado para frente.',
      movementStepByStep: '1. Empurre as mãos para baixo esticando os braços.\n2. No final, afaste as duas pontas da corda para fora.\n3. Volte até a altura do peito mantendo os cotovelos colados no corpo.',
      feelingCheck: 'Queimação forte na parte de trás do braço.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Tríceps Francês com Halter',
      targetMuscle: MuscleGroup.triceps,
      machineName: 'Banco com Halter Unilateral / Bilateral',
      equipmentAppearance: 'Banco reto e um halter seguro pelas duas mãos atrás da cabeça.',
      youtubeVideoId: '-Vyt2QdS847',
      pinAndWeightSetup: 'Escolha um halter leve que consiga segurar confortavelmente com as duas mãos.',
      startPosition: 'Sente-se, segure o halter verticalmente atrás da cabeça com os cotovelos apontados para o teto.',
      movementStepByStep: '1. Estenda os braços empurrando o halter para cima.\n2. Desça o peso devagar flexionando os cotovelos atrás da cabeça.',
      feelingCheck: 'Alongamento extremo e contração da cabeça longa do tríceps.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Rosca Direta Barra W',
      targetMuscle: MuscleGroup.biceps,
      machineName: 'Barra W (Livre ou Pré-Montada)',
      equipmentAppearance: 'Barra de ferro ondulada que poupa a rotação desconfortável dos punhos.',
      youtubeVideoId: 'kwG2ipFRgfo',
      pinAndWeightSetup: 'Use barra montada leve (ex: 10kg no total) para aprender o trajeto.',
      startPosition: 'Em pé, coluna ereta, segure nas curvas da barra W com as palmas voltadas para cima.',
      movementStepByStep: '1. Levante a barra dobrando os cotovelos sem jogar o corpo para trás.\n2. Pare quando a barra chegar na altura do peito superior e aperte o bíceps.\n3. Desça a barra devagar até esticar o braço.',
      feelingCheck: 'Contração concentrada na frente do braço.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Rosca Martelo com Halteres',
      targetMuscle: MuscleGroup.biceps,
      machineName: 'Área de Halteres Livres',
      equipmentAppearance: 'Dois halteres manuais segurados como se fossem martelos.',
      youtubeVideoId: 'zC3nLlEvin4',
      pinAndWeightSetup: 'Dois halteres de mesmo peso leve.',
      startPosition: 'Em pé ou sentado, segure os halteres com as palmas voltadas uma para a outra (pegada neutra).',
      movementStepByStep: '1. Suba os halteres mantendo as palmas sempre viradas uma para a outra.\n2. Desça com calma até a lateral das coxas.',
      feelingCheck: 'Trabalho no bíceps e no antebraço (espessura do braço).',
    ),

    // --- MEMBROS INFERIORES (PERNAS) ---
    const BeginnerExerciseGuide(
      exerciseName: 'Agachamento Hack (Máquina)',
      targetMuscle: MuscleGroup.quadriceps,
      machineName: 'Máquina Hack Squat Inclinada',
      equipmentAppearance: 'Trilho com encosto a 45°, almofadas de ombros e plataforma de metal larga.',
      youtubeVideoId: '0tn5K9NlCfo',
      pinAndWeightSetup: 'Sem anilhas no começo. Destrave girando a alavanca lateral só depois de apoiar os ombros.',
      startPosition: 'Costas no apoio, ombros sob as almofadas. Pés na metade da plataforma, largura dos ombros.',
      movementStepByStep: '1. Destrave a máquina.\n2. Dobre os joelhos descendo até formar 90° nas coxas.\n3. Empurre a plataforma com a sola inteira para subir sem trancar o joelho no topo.',
      feelingCheck: 'Queimação forte na parte da frente das coxas.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Leg Press 45°',
      targetMuscle: MuscleGroup.quadriceps,
      machineName: 'Leg Press Inclinado a 45 Graus',
      equipmentAppearance: 'Banco inclinado deitado com um carrinho pesado sobre trilho e uma plataforma gigante de ferro.',
      youtubeVideoId: 'IZxyjW7MPJQ',
      pinAndWeightSetup: 'Comece com 1 ou 2 anilhas leves de cada lado. Sempre localize as travas de segurança laterais.',
      startPosition: 'Sente com lombar e glúteos 100% colados no banco. Pés no meio da plataforma, largura dos ombros.',
      movementStepByStep: '1. Empurre a plataforma, gire a alavanca para destravar.\n2. Dobre os joelhos trazendo a plataforma em direção ao peito sem descolar o bumbum do banco.\n3. Empurre de volta até esticar quase tudo.',
      feelingCheck: 'Trabalho massivo de quadríceps e glúteos.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Cadeira Extensora',
      targetMuscle: MuscleGroup.quadriceps,
      machineName: 'Cadeira Extensora de Coxas',
      equipmentAppearance: 'Banco com encosto vertical e rolete acolchoado móvel para as canelas.',
      youtubeVideoId: 'YyvSfVcxQ30',
      pinAndWeightSetup: 'Puxe o pino amarelo do encosto: apoie as costas, rolete na frente das canelas.',
      startPosition: 'Sente-se, segure firme nas alavancas laterais ao lado do banco.',
      movementStepByStep: '1. Levante as pernas esticando os joelhos.\n2. Segure 1 segundo no alto sentindo a coxa apertar.\n3. Desça devagar em 3 segundos sem deixar o peso bater.',
      feelingCheck: 'Queimação pura na frente da coxa.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Mesa Flexora',
      targetMuscle: MuscleGroup.hamstrings,
      machineName: 'Mesa Flexora Horizontal (Leg Curl)',
      equipmentAppearance: 'Mesa estofada com rolete móvel para os tornozelos e pegadores de mão na frente.',
      youtubeVideoId: 'ELOCsoDSmrg',
      pinAndWeightSetup: 'Regule o rolete para ficar atrás dos tornozelos (no tendão). Carga leve no pino.',
      startPosition: 'Deite de barriga para baixo, segure nas alavancas frontais e mantenha o quadril colado na mesa.',
      movementStepByStep: '1. Dobre os joelhos puxando os calcanhares em direção ao glúteo.\n2. Segure 1 segundo na contração.\n3. Desça devagar até esticar.',
      feelingCheck: 'Isolamento de posteriores de coxa.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Elevação Pélvica / Hip Thrust',
      targetMuscle: MuscleGroup.glutes,
      machineName: 'Máquina de Hip Thrust ou Banco Livre',
      equipmentAppearance: 'Banco baixo com cinto de segurança acolchoado ou barra sobre o quadril.',
      youtubeVideoId: 'SEdqd1n0cvg',
      pinAndWeightSetup: 'Ajuste o cinto acolchoado sobre a bacia. Coloque peso leve.',
      startPosition: 'Escápulas apoiadas no banco, pés na largura dos ombros firmes no chão.',
      movementStepByStep: '1. Empurre o quadril para cima até o tronco ficar em linha reta com as coxas.\n2. Aperte o glúteo no topo por 1 segundo.\n3. Desça o quadril devagar.',
      feelingCheck: 'Ativação máxima dos glúteos.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Panturrilha Sentado (Gêmeos)',
      targetMuscle: MuscleGroup.calves,
      machineName: 'Máquina de Panturrilha Sentado',
      equipmentAppearance: 'Banco com apoio almofadado sobre os joelhos e suporte de ponta de pé.',
      youtubeVideoId: 'JbyjNymZOt0',
      pinAndWeightSetup: 'Almofada encaixada sobre os joelhos. Peso leve nas anilhas.',
      startPosition: 'Ponta dos pés na borda da barra com calcanhares livres no ar.',
      movementStepByStep: '1. Suba na ponta dos pés e destrave a máquina.\n2. Desça os calcanhares o máximo que puder e segure 2 segundos.\n3. Empurre forte para o alto.',
      feelingCheck: 'Alongamento e queimação no meio da batata da perna.',
    ),
    const BeginnerExerciseGuide(
      exerciseName: 'Abdominal na Polia / Crunch',
      targetMuscle: MuscleGroup.abs,
      machineName: 'Polia Alta com Corda (Cable Crunch)',
      equipmentAppearance: 'Polia no alto com corda dupla, em frente a um colchonete no chão.',
      youtubeVideoId: '2fORO_PXGpo',
      pinAndWeightSetup: 'Polia no alto. Carga leve no pino da torre.',
      startPosition: 'Ajoelhe-se de frente para a máquina, segure a corda com as mãos ao lado das orelhas.',
      movementStepByStep: '1. Curve o tronco enrolando a coluna para baixo, levando os cotovelos em direção aos joelhos.\n2. Aperte o abdômen por 1 segundo.\n3. Volte desenrolando o tronco devagar.',
      feelingCheck: 'Queimação intensa no abdômen superior e médio.',
    ),
  ];

  static BeginnerExerciseGuide getGuide(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    for (var guide in allGuides) {
      if (lower.contains(guide.exerciseName.toLowerCase()) ||
          guide.exerciseName.toLowerCase().contains(lower)) {
        return guide;
      }
    }

    return BeginnerExerciseGuide(
      exerciseName: exerciseName,
      targetMuscle: MuscleGroup.chest,
      machineName: 'Equipamento Guiado de Academia',
      equipmentAppearance: 'Procure o equipamento com a placa/adesivo ilustrando $exerciseName ou peça orientação ao instrutor.',
      youtubeVideoId: '0tn5K9NlCfo',
      pinAndWeightSetup: 'Inicie com a carga mínima da máquina para aprender o trajeto.',
      startPosition: 'Sente-se com as costas apoiadas, coluna ereta e pés firmes no chão.',
      movementStepByStep: '1. Segure nos apoios com firmeza.\n2. Execute o movimento de forma suave sem trancos.\n3. Controle a descida em 2 a 3 segundos.',
      feelingCheck: 'Tensão muscular constante sem dor nas articulações.',
    );
  }
}
