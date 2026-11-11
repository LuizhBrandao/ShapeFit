class RoutineRecommendation {
  final String routineName;
  final String divisionType; // ex: AB, ABC, ABCD, ABCDE, Full-body
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

  /// Gera a rotina personalizada estruturada conforme a divisão ESCOLHIDA pelo usuário:
  /// AB, ABC, ABCD, ABCDE ou Full-body.
  Future<RoutineRecommendation> generateRoutine({
    required String divisionChoice, // 'AB', 'ABC (PPL)', 'ABCD', 'ABCDE', 'Full-body'
    required int daysPerWeek,
    required String fitnessLevel,
    required String primaryGoal,
    required String equipmentAccess,
    required List<String> focusMuscles,
    required int sessionDurationMinutes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    switch (divisionChoice) {
      case 'AB (Superior / Inferior)':
        return _generateDivisionAB();
      case 'ABC (Push / Pull / Legs)':
        return _generateDivisionABC();
      case 'ABCD (Peito+Ombro / Costas+Trapézio / Pernas / Braços)':
        return _generateDivisionABCD();
      case 'ABCDE (Isolamento Máximo 5 Dias)':
        return _generateDivisionABCDE();
      default:
        return _generateDivisionABC();
    }
  }

  // Divisão AB (Upper / Lower)
  RoutineRecommendation _generateDivisionAB() {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão AB',
      divisionType: 'AB (Superior / Inferior)',
      description: 'Estrutura de 2 treinos alternados focando em alta frequência neuromuscular para todos os grupos musculares.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Membros Superiores (Upper)',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Composto principal de empurrar'),
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Grande Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Puxada vertical para costas'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Meio das Costas', sets: 3, repRange: '10-12', rirOrRpe: 'RIR 1-2', rationale: 'Espessura escapular'),
            RoutineExerciseItem(name: 'Elevação Lateral', targetMuscle: 'Deltoides', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Largura de ombros'),
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 3, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de tríceps'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 3, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Isolamento de bíceps'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Membros Inferiores & Core (Lower)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack / Livre', targetMuscle: 'Quadríceps & Glúteos', sets: 4, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial pesada de pernas'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 3, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de quadríceps'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1-2', rationale: 'Posterior de coxa'),
            RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Foco no músculo sóleo'),
            RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 3, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Fortalecimento do Core'),
          ],
        ),
      ],
    );
  }

  // Divisão ABC (Push / Pull / Legs)
  RoutineRecommendation _generateDivisionABC() {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABC (PPL)',
      divisionType: 'ABC (Push / Pull / Legs)',
      description: 'A divisão padrão-ouro de atletas globais: separa movimentos de empurrar, puxar e membros inferiores sem sobreposição indesejada.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Push (Peito, Ombro & Tríceps)',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1-2', rationale: 'Estiramento e sobrecarga clavicular'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 3, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Tensão constante em todo o arco'),
            RoutineExerciseItem(name: 'Elevação Lateral', targetMuscle: 'Deltoide Lateral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Largura escapular'),
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 3, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento sem dor articular'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Pull (Costas, Deltoide Post. & Bíceps)',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Grande Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Expansão da dorsal (V-Taper)'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Densidade paravertebral'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Postura e saúde dos ombros'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 3, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Pico de contração de bíceps'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Legs (Quadríceps, Isquiotibiais & Panturrilhas)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack / Livre', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Força bruta e massa de coxas'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 3, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de reto femoral'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Flexão direta de joelho'),
            RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilha', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Pausa excêntrica de 2s'),
          ],
        ),
      ],
    );
  }

  // Divisão ABCD
  RoutineRecommendation _generateDivisionABCD() {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABCD',
      divisionType: 'ABCD (4 Fichas Especializadas)',
      description: 'Ideal para quem treina 4 dias na semana: permite volume alto e foco localizado em cada grupo sem cansar demais em uma única sessão.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Peitoral & Deltoide Anterior',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Foco feixe clavicular'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 3, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Sobrecarga central'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 3, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Alongamento sob tensão'),
            RoutineExerciseItem(name: 'Desenvolvimento com Halteres', targetMuscle: 'Ombros', sets: 3, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Empurrar vertical'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Dorsal, Trapézio & Deltoide Posterior',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Dorsal', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Abertura de costas'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Densidade e espessura'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Manguito e deltoide posterior'),
            RoutineExerciseItem(name: 'Elevação Lateral', targetMuscle: 'Deltoide Lateral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Largura escapular'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Membros Inferiores Completos (Leg Day)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack / Livre', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial pesada'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 3, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento frontal'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Posteriores de coxa'),
            RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Alongamento total'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino D • Braços Completos (Bíceps, Tríceps & Core)',
          exercises: [
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Foco cabeça lateral'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Sobrecarga de bíceps'),
            RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Hipertrofia abdominal'),
          ],
        ),
      ],
    );
  }

  // Divisão ABCDE (5 Dias Clássico de Isolamento / Bodybuilding)
  RoutineRecommendation _generateDivisionABCDE() {
    return RoutineRecommendation(
      routineName: 'ShapeFit Hipertrofia • Divisão ABCDE (5 Fichas)',
      divisionType: 'ABCDE (Isolamento Máximo 5 Dias)',
      description: 'Estrutura tradicional do fisiculturismo: 1 grupo muscular grande por dia, permitindo destruir o músculo com volume brutal e descanso prolongado.',
      days: [
        RoutineWorkoutDay(
          dayName: 'Treino A • Peitoral',
          exercises: [
            RoutineExerciseItem(name: 'Supino Inclinado com Halteres', targetMuscle: 'Peitoral Superior', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Feixe clavicular'),
            RoutineExerciseItem(name: 'Supino Reto com Barra', targetMuscle: 'Peitoral Médio', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Força e massa peitoral'),
            RoutineExerciseItem(name: 'Crucifixo na Polia (Crossover)', targetMuscle: 'Peitoral', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Pump e adução total'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino B • Costas & Dorsais',
          exercises: [
            RoutineExerciseItem(name: 'Puxada Frontal na Polia', targetMuscle: 'Dorsais', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Largura dorsal em V'),
            RoutineExerciseItem(name: 'Remada Baixa com Triângulo', targetMuscle: 'Costas Média', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Densidade escapular'),
            RoutineExerciseItem(name: 'Remada Curvada com Barra', targetMuscle: 'Lombar & Dorsal', sets: 3, repRange: '8-10', rirOrRpe: 'RIR 2', rationale: 'Espessura bruta'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino C • Membros Inferiores (Leg Day Completo)',
          exercises: [
            RoutineExerciseItem(name: 'Agachamento Hack / Livre', targetMuscle: 'Quadríceps', sets: 4, repRange: '6-10', rirOrRpe: 'RIR 2', rationale: 'Carga axial'),
            RoutineExerciseItem(name: 'Cadeira Extensora', targetMuscle: 'Quadríceps', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Isolamento de coxa'),
            RoutineExerciseItem(name: 'Mesa Flexora', targetMuscle: 'Isquiotibiais', sets: 4, repRange: '10-12', rirOrRpe: 'RIR 1', rationale: 'Posterior'),
            RoutineExerciseItem(name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: 'Panturrilhas', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 0', rationale: 'Gêmeos e sóleo'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino D • Deltoides & Trapézio',
          exercises: [
            RoutineExerciseItem(name: 'Desenvolvimento com Halteres', targetMuscle: 'Deltoides', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 2', rationale: 'Empurrão vertical de ombro'),
            RoutineExerciseItem(name: 'Elevação Lateral', targetMuscle: 'Deltoide Lateral', sets: 5, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Construção dos ombros em cebola'),
            RoutineExerciseItem(name: 'Face Pull na Polia', targetMuscle: 'Deltoide Posterior', sets: 4, repRange: '12-15', rirOrRpe: 'RIR 1', rationale: 'Postura e deltoide posterior'),
          ],
        ),
        RoutineWorkoutDay(
          dayName: 'Treino E • Braços (Bíceps & Tríceps) & Abdômen',
          exercises: [
            RoutineExerciseItem(name: 'Tríceps Corda na Polia', targetMuscle: 'Tríceps', sets: 4, repRange: '10-15', rirOrRpe: 'RIR 1', rationale: 'Cabeça lateral'),
            RoutineExerciseItem(name: 'Rosca Direta Barra W', targetMuscle: 'Bíceps', sets: 4, repRange: '8-12', rirOrRpe: 'RIR 1', rationale: 'Braquial e bíceps'),
            RoutineExerciseItem(name: 'Abdominal na Polia / Crunch', targetMuscle: 'Abdômen', sets: 4, repRange: '15-20', rirOrRpe: 'RIR 1', rationale: 'Hipertrofia do Core'),
          ],
        ),
      ],
    );
  }
}
