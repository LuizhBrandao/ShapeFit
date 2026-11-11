import 'workout_enums.dart';

class SetLogModel {
  final String id;
  int setOrder;
  SetType type;
  double weight;
  String unit;
  int reps;
  int? repsInReserve;
  bool isCompleted;
  // Campos de pré-preenchimento (vindos do último treino para facilitar a UX)
  double? previousWeight;
  int? previousReps;

  SetLogModel({
    required this.id,
    required this.setOrder,
    this.type = SetType.normal,
    this.weight = 0.0,
    this.unit = 'kg',
    this.reps = 0,
    this.repsInReserve,
    this.isCompleted = false,
    this.previousWeight,
    this.previousReps,
  });

  double calculateVolume() => weight * reps;

  /// Estimativa de 1RM com fórmula de Epley: Peso * (1 + Reps / 30)
  double calculateEstimated1RM() {
    if (reps <= 0) return weight;
    if (reps == 1) return weight;
    return weight * (1.0 + (reps / 30.0));
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'setOrder': setOrder,
    'type': type.value,
    'weight': weight,
    'unit': unit,
    'repetitions': reps,
    'repsInReserve': repsInReserve,
    'isCompleted': isCompleted,
  };
}

class ExerciseLogModel {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final MuscleGroup primaryMuscle;
  int order;
  String? notes;
  final List<SetLogModel> sets;

  ExerciseLogModel({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    required this.order,
    this.notes,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'exerciseId': exerciseId,
    'order': order,
    'notes': notes,
    'sets': sets.map((s) => s.toJson()).toList(),
  };
}

class WorkoutSessionModel {
  final String id;
  final String userId;
  String name;
  DateTime startedAt;
  DateTime? finishedAt;
  String? clientSyncId;
  String? notes;
  final List<ExerciseLogModel> exercises;

  WorkoutSessionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.startedAt,
    this.finishedAt,
    this.clientSyncId,
    this.notes,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'startedAt': startedAt.toIso8601String(),
    'finishedAt': finishedAt?.toIso8601String(),
    'clientSyncId': clientSyncId,
    'notes': notes,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };
}
