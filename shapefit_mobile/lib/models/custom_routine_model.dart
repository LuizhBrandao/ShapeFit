import 'package:uuid/uuid.dart';
import 'workout_enums.dart';

class CustomRoutineExerciseTemplate {
  final String exerciseId;
  final String name;
  final MuscleGroup targetMuscle;
  int defaultSets;
  String repRange;

  CustomRoutineExerciseTemplate({
    required this.exerciseId,
    required this.name,
    required this.targetMuscle,
    this.defaultSets = 3,
    this.repRange = '8-12',
  });
}

class CustomRoutineTemplate {
  final String id;
  String name;
  String description;
  final List<CustomRoutineExerciseTemplate> exercises;
  int completedCount;
  final int targetCount;

  CustomRoutineTemplate({
    String? id,
    required this.name,
    this.description = '',
    List<CustomRoutineExerciseTemplate>? exercises,
    this.completedCount = 0,
    this.targetCount = 30,
  })  : id = id ?? const Uuid().v4(),
        exercises = exercises ?? [];

  double get progressRatio => (completedCount / targetCount).clamp(0.0, 1.0);
}
