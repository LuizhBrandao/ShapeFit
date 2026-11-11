enum SetType {
  normal(1, 'Normal', 'N'),
  warmUp(2, 'Aquecimento', 'W'),
  dropSet(3, 'Drop-set', 'D'),
  failure(4, 'Falha', 'F');

  final int value;
  final String label;
  final String shortCode;

  const SetType(this.value, this.label, this.shortCode);

  static SetType fromValue(int val) {
    return SetType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => SetType.normal,
    );
  }
}

enum MuscleGroup {
  chest(1, 'Peito'),
  back(2, 'Costas'),
  shoulders(3, 'Ombros'),
  biceps(4, 'Bíceps'),
  triceps(5, 'Tríceps'),
  quadriceps(6, 'Quadríceps'),
  hamstrings(7, 'Posteriores'),
  glutes(8, 'Glúteos'),
  calves(9, 'Panturrilhas'),
  abs(10, 'Abdômen'),
  forearms(11, 'Antebraços'),
  traps(12, 'Trapézio');

  final int value;
  final String displayName;

  const MuscleGroup(this.value, this.displayName);

  static MuscleGroup fromValue(int val) {
    return MuscleGroup.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MuscleGroup.chest,
    );
  }
}

enum WorkoutDivision {
  fullBody(1, 'Full Body'),
  upperLower(2, 'AB (Superior / Inferior)'),
  pushPullLegs(3, 'ABC (Push / Pull / Legs)'),
  abcd(4, 'ABCD (Peito+Ombro / Costas+Trapézio / Pernas / Braços)'),
  abcde(5, 'ABCDE (Isolamento Máximo 5 Dias)'),
  custom(99, 'Personalizado');

  final int value;
  final String label;

  const WorkoutDivision(this.value, this.label);

  static WorkoutDivision fromValue(int val) {
    return WorkoutDivision.values.firstWhere(
      (e) => e.value == val,
      orElse: () => WorkoutDivision.custom,
    );
  }
}
