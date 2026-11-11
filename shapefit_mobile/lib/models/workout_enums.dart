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
