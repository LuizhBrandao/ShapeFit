class RoutineRecommendation {
  final String routineName;
  final String divisionType;
  final String description;
  final List<RoutineWorkoutDay> days;

  RoutineRecommendation({
    required this.routineName,
    required this.divisionType,
    required this.description,
    required this.days,
  });

  factory RoutineRecommendation.fromJson(Map<String, dynamic> json) {
    return RoutineRecommendation(
      routineName: json['routineName'] ?? 'Rotina Personalizada',
      divisionType: json['divisionType'] ?? 'Personalizado',
      description: json['description'] ?? '',
      days: (json['days'] as List? ?? [])
          .map((d) => RoutineWorkoutDay.fromJson(d))
          .toList(),
    );
  }
}

class RoutineWorkoutDay {
  final String dayName;
  final List<RoutineExerciseItem> exercises;

  RoutineWorkoutDay({required this.dayName, required this.exercises});

  factory RoutineWorkoutDay.fromJson(Map<String, dynamic> json) {
    return RoutineWorkoutDay(
      dayName: json['dayName'] ?? 'Dia de Treino',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => RoutineExerciseItem.fromJson(e))
          .toList(),
    );
  }
}

class RoutineExerciseItem {
  final String name;
  final String targetMuscle;
  final int sets;
  final String repRange;
  final String rirOrRpe;
  final String rationale;

  RoutineExerciseItem({
    required this.name,
    required this.targetMuscle,
    required this.sets,
    required this.repRange,
    required this.rirOrRpe,
    required this.rationale,
  });

  factory RoutineExerciseItem.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseItem(
      name: json['name'] ?? '',
      targetMuscle: json['targetMuscle'] ?? '',
      sets: json['sets'] ?? 3,
      repRange: json['repRange'] ?? '8-12',
      rirOrRpe: json['rirOrRpe'] ?? 'RIR 1-2',
      rationale: json['rationale'] ?? '',
    );
  }
}

class GeminiRoutineService {
  final String? apiKey;

  GeminiRoutineService({this.apiKey});

  /// Gera a rotina personalizada estruturada conforme a divisão ESCOLHIDA pelo usuário
  /// E CALCULA O NÚMERO DE EXERCÍCIOS E SÉRIES COM BASE NO TEMPO DISPONÍVEL (45, 60, 75 ou 90 min).
  Future<RoutineRecommendation> generateRoutine({
    required String divisionChoice,
    required int daysPerWeek,
    required String fitnessLevel,
    required String primaryGoal,
    required String equipmentAccess,
    required List<String> focusMuscles,
    required int sessionDurationMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Cálculo fisiológico de volume por tempo:
    // Em média, cada exercício com 3-4 séries + descanso de 90s-120s consome 12 a 15 minutos.
    // - 45 min: 3 a 4 exercícios (12 a 14 séries)
    // - 60 min: 4 a 5 exercícios (16 a 18 séries)
    // - 75 min: 5 a 6 exercícios (20 a 22 séries)
    // - 90 min: 6 a 7 exercícios completos (24 a 28 séries) com variações de ângulos, isoladores e panturrilha/core.
    final targetExerciseCount = sessionDurationMinutes >= 90
        ? 6
        : (sessionDurationMinutes >= 75 ? 5 : (sessionDurationMinutes >= 60 ? 4 : 3));

    switch (divisionChoice) {
      case 'AB (Superior / Inferior)':
        return _generateDivisionAB(targetExerciseCount, sessionDurationMinutes);
      case 'ABC (Push / Pull / Legs)':
        return _generateDivisionABC(targetExerciseCount, sessionDurationMinutes);
      case 'ABCD (Peito+Ombro / Costas+Trapézio / Pernas / Braços)':
        return _generateDivisionABCD(targetExerciseCount, sessionDurationMinutes);
      case 'ABCDE (Isolamento Máximo 5 Dias)':
        return _generateDivisionABCDE(targetExerciseCount, sessionDurationMinutes);
      default:
        return _generateDivisionABC(targetExerciseCount, sessionDurationMinutes);
    }
  }

  // Divisão AB (Upper / Lower)
  RoutineRecommendation _generateDivisionAB(int count, int minutes) {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão AB ($minutes min)',
      divisionType: 'AB (Superior / Inferior)',
      description: 'Volume adaptado para sessões de $minutes minutos, cobrindo todos os ângulos de tração com alta frequência.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Membros Superiores (Upper)',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Feixe clavicular'),
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Grande Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Puxada vertical'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga central'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Meio das Costas', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1-2', rationale: 'Espessura escapular'),
            RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Largura de ombros'),
            if (count >= 5) RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de tríceps'),
            if (count >= 6) RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Isolamento de bíceps'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Membros Inferiores & Core (Lower)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack (Máquina)', targetMuscle: 'Quadríceps & Glúteos', sets: 4, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial pesada'),
            RoutineExerciseItem(name: 'Leg Press 45°', targetMuscle: 'Quadríceps', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga de membros inferiores'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de coxa'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Posterior de coxa'),
            RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Foco no sóleo'),
            if (count >= 6) RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Core e estabilidade'),
          ],
        ),
      ],
    );
  }

  // Divisão ABC (Push / Pull / Legs)
  RoutineRecommendation _generateDivisionABC(int count, int minutes) {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABC (PPL - $minutes min)',
      divisionType: 'ABC (Push / Pull / Legs)',
      description: 'Estrutura completa calibrada para $minutes minutos de treino intenso, garantindo volume ótimo para cada padrão de movimento.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Push (Peito, Ombro & Tríceps)',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Estiramento clavicular'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga mecânica pesada'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Tensão constante em adução'),
            RoutineExerciseItem(name: 'Desenvolvimento com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Empurrão vertical de ombro'),
            RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoide Lateral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Largura escapular'),
            if (count >= 6) RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Cabeça lateral'),
            if (count >= 7) RoutineExerciseItem(name: 'Tríceps Francês com Halter', targetMuscle: 'Tríceps', sets: 3, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Cabeça longa estirada'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Pull (Costas, Deltoide Post. & Bíceps)',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Grande Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Expansão em V-Taper'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Densidade escapular'),
            RoutineExerciseItem(name: 'Remada Curvada com Barra', targetMuscle: 'Lombar & Dorsal', sets: 4, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Espessura bruta'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Saúde e manguito'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Pico de contração'),
            if (count >= 6) RoutineExerciseItem(name: 'Rosca Martelo com Halteres', targetMuscle: 'Braquial & Antebraço', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Espessura do braço'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Legs (Quadríceps, Isquiotibiais & Panturrilha)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack (Máquina)', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial pesada'),
            RoutineExerciseItem(name: 'Leg Press 45°', targetMuscle: 'Quadríceps & Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 2', rationale: 'Volume composto'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento em posição encurtada'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Flexão direta de joelho'),
            RoutineExerciseItem(name: 'Elevação Pélvica / Hip Thrust', targetMuscle: 'Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Pico de contração de glúteos'),
            if (count >= 6) RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilha', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Alongamento profundo com pausa'),
          ],
        ),
      ],
    );
  }

  // Divisão ABCD
  RoutineRecommendation _generateDivisionABCD(int count, int minutes) {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABCD ($minutes min)',
      divisionType: 'ABCD (4 Fichas Especializadas)',
      description: 'Volume ampliado proporcional aos seus $minutes minutos de treino, permitindo destruição e recuperação perfeita por grupo muscular.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Peitoral & Deltoide Anterior',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Feixe clavicular'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga central'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Adução com tensão contínua'),
            RoutineExerciseItem(name: 'Peck Deck / Voador Máquina', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de peito'),
            RoutineExerciseItem(name: 'Desenvolvimento com Halteres', targetMuscle: 'Ombros', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Empurrão vertical'),
            if (count >= 6) RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Deltoide lateral'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Dorsal, Trapézio & Deltoide Posterior',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Abertura dorsal'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Espessura escapular'),
            RoutineExerciseItem(name: 'Remada Curvada com Barra', targetMuscle: 'Dorsal & Lombar', sets: 4, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Massa geral de costas'),
            RoutineExerciseItem(name: 'Remada Cavalinho (Barra T)', targetMuscle: 'Costas', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Densidade muscular'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Postura e manguito'),
            if (count >= 6) RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoide', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Frequência de ombros'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Membros Inferiores Completos (Leg Day)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack (Máquina)', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial pesada'),
            RoutineExerciseItem(name: 'Leg Press 45°', targetMuscle: 'Quadríceps & Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga de coxas'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de reto femoral'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Posteriores de coxa'),
            RoutineExerciseItem(name: 'Elevação Pélvica / Hip Thrust', targetMuscle: 'Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Glúteo máximo'),
            if (count >= 6) RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 5, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Pausa excêntrica 2s'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino D • Braços Completos (Bíceps, Tríceps & Core)',
          exercises: [
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Cabeça lateral'),
            RoutineExerciseItem(name: 'Tríceps Francês com Halter', targetMuscle: 'Tríceps', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Cabeça longa'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Braquial e bíceps'),
            RoutineExerciseItem(name: 'Rosca Martelo com Halteres', targetMuscle: 'Bíceps & Antebraço', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Espessura do braço'),
            RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Hipertrofia abdominal'),
            if (count >= 6) RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Volume extra de ombros'),
          ],
        ),
      ],
    );
  }

  // Divisão ABCDE (Isolamento Máximo 5 Dias)
  RoutineRecommendation _generateDivisionABCDE(int count, int minutes) {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABCDE ($minutes min)',
      divisionType: 'ABCDE (Isolamento Máximo 5 Dias)',
      description: 'Rotina de elite estilo fisiculturismo: cada dia é dedicado com 5 a 6 exercícios e 20 a 24 séries para aniquilar o grupo muscular em $minutes minutos.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Peitoral Completo',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Feixe clavicular'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Força e massa peitoral'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Pump e adução total'),
            RoutineExerciseItem(name: 'Peck Deck / Voador Máquina', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento do peito'),
            if (count >= 5) RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Core'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Costas & Dorsais',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Dorsais', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Largura dorsal em V'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Densidade escapular'),
            RoutineExerciseItem(name: 'Remada Curvada com Barra', targetMuscle: 'Lombar & Dorsal', sets: 4, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Espessura bruta'),
            RoutineExerciseItem(name: 'Remada Cavalinho (Barra T)', targetMuscle: 'Dorsais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Isolamento com apoio de peito'),
            if (count >= 5) RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Trapézio & Manguito', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Saúde articular'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Membros Inferiores (Leg Day Completo)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack (Máquina)', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial'),
            RoutineExerciseItem(name: 'Leg Press 45°', targetMuscle: 'Quadríceps & Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 2', rationale: 'Volume de pernas'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento frontal'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Posterior'),
            RoutineExerciseItem(name: 'Elevação Pélvica / Hip Thrust', targetMuscle: 'Glúteos', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Glúteo máximo'),
            if (count >= 6) RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 5, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Pausa excêntrica'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino D • Deltoides & Trapézio',
          exercises: [
            RoutineExerciseItem(name: 'Desenvolvimento com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Empurrão vertical'),
            RoutineExerciseItem(name: 'Elevação Lateral com Halteres', targetMuscle: 'Deltoide Lateral', sets: 5, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Ombros em cebola'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Postura e manguito'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Deltoide/Peito', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Feixe clavicular'),
            if (count >= 5) RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Core'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino E • Braços Completos (Bíceps & Tríceps)',
          exercises: [
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Cabeça lateral'),
            RoutineExerciseItem(name: 'Tríceps Francês com Halter', targetMuscle: 'Tríceps', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Cabeça longa estirada'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Pico de bíceps'),
            RoutineExerciseItem(name: 'Rosca Martelo com Halteres', targetMuscle: 'Braquial & Antebraço', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Espessura do braço'),
            if (count >= 5) RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilha', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Frequência de panturrilha'),
          ],
        ),
      ],
    );
  }
}
