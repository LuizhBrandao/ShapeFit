import 'workout_enums.dart';

class RoutineExerciseDto {
  final String id;
  final String exerciseId;
  final String customExerciseName;
  final MuscleGroup targetMuscle;
  final int order;
  final int targetSets;
  final String repRange;
  final int? targetRir;
  final int restIntervalSeconds;
  final String? notes;

  RoutineExerciseDto({
    required this.id,
    required this.exerciseId,
    required this.customExerciseName,
    required this.targetMuscle,
    required this.order,
    required this.targetSets,
    required this.repRange,
    this.targetRir,
    required this.restIntervalSeconds,
    this.notes,
  });

  factory RoutineExerciseDto.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseDto(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      customExerciseName: json['customExerciseName'] as String? ?? '',
      targetMuscle: MuscleGroup.fromValue(json['targetMuscle'] as int? ?? 1),
      order: json['order'] as int? ?? 1,
      targetSets: json['targetSets'] as int? ?? 3,
      repRange: json['repRange'] as String? ?? '8-12',
      targetRir: json['targetRir'] as int?,
      restIntervalSeconds: json['restIntervalSeconds'] as int? ?? 90,
      notes: json['notes'] as String?,
    );
  }
}

class RoutineDayDto {
  final String id;
  final String name;
  final int order;
  final String? description;
  final int totalTargetSets;
  final List<RoutineExerciseDto> exercises;

  RoutineDayDto({
    required this.id,
    required this.name,
    required this.order,
    this.description,
    required this.totalTargetSets,
    required this.exercises,
  });

  factory RoutineDayDto.fromJson(Map<String, dynamic> json) {
    return RoutineDayDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Dia de Treino',
      order: json['order'] as int? ?? 1,
      description: json['description'] as String?,
      totalTargetSets: json['totalTargetSets'] as int? ?? 0,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => RoutineExerciseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RoutineTemplateDto {
  final String id;
  final String userId;
  final String name;
  final String description;
  final WorkoutDivision division;
  final bool isActive;
  final bool isAiGenerated;
  final DateTime createdAt;
  final int totalExercisesCount;
  final int totalTargetSets;
  final List<RoutineDayDto> days;

  RoutineTemplateDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.division,
    required this.isActive,
    required this.isAiGenerated,
    required this.createdAt,
    required this.totalExercisesCount,
    required this.totalTargetSets,
    required this.days,
  });

  factory RoutineTemplateDto.fromJson(Map<String, dynamic> json) {
    return RoutineTemplateDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      division: WorkoutDivision.fromValue(json['division'] as int? ?? 99),
      isActive: json['isActive'] as bool? ?? true,
      isAiGenerated: json['isAiGenerated'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      totalExercisesCount: json['totalExercisesCount'] as int? ?? 0,
      totalTargetSets: json['totalTargetSets'] as int? ?? 0,
      days: (json['days'] as List? ?? [])
          .map((d) => RoutineDayDto.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MesocycleProgressDto {
  final String id;
  final String userId;
  final String routineTemplateId;
  final int cycleNumber;
  final int targetSessionsCount;
  final int completedSessionsCount;
  final double progressRatio;
  final int status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final String? goal;

  MesocycleProgressDto({
    required this.id,
    required this.userId,
    required this.routineTemplateId,
    required this.cycleNumber,
    required this.targetSessionsCount,
    required this.completedSessionsCount,
    required this.progressRatio,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.goal,
  });

  bool get isCompleted => completedSessionsCount >= targetSessionsCount || status == 2;
  int get remainingSessions => (targetSessionsCount - completedSessionsCount).clamp(0, targetSessionsCount);

  factory MesocycleProgressDto.fromJson(Map<String, dynamic> json) {
    return MesocycleProgressDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      routineTemplateId: json['routineTemplateId'] as String,
      cycleNumber: json['cycleNumber'] as int? ?? 1,
      targetSessionsCount: json['targetSessionsCount'] as int? ?? 30,
      completedSessionsCount: json['completedSessionsCount'] as int? ?? 0,
      progressRatio: (json['progressRatio'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as int? ?? 1,
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ?? DateTime.now(),
      finishedAt: json['finishedAt'] != null ? DateTime.tryParse(json['finishedAt'] as String) : null,
      goal: json['goal'] as String?,
    );
  }
}

class PrescribeRoutineResponse {
  final String routineTemplateId;
  final String mesocycleId;
  final String routineName;
  final WorkoutDivision division;
  final int totalDays;
  final int totalExercises;
  final int totalSets;
  final List<RoutineDayDto> days;

  PrescribeRoutineResponse({
    required this.routineTemplateId,
    required this.mesocycleId,
    required this.routineName,
    required this.division,
    required this.totalDays,
    required this.totalExercises,
    required this.totalSets,
    required this.days,
  });

  factory PrescribeRoutineResponse.fromJson(Map<String, dynamic> json) {
    return PrescribeRoutineResponse(
      routineTemplateId: json['routineTemplateId'] as String,
      mesocycleId: json['mesocycleId'] as String,
      routineName: json['routineName'] as String? ?? '',
      division: WorkoutDivision.fromValue(json['division'] as int? ?? 99),
      totalDays: json['totalDays'] as int? ?? 0,
      totalExercises: json['totalExercises'] as int? ?? 0,
      totalSets: json['totalSets'] as int? ?? 0,
      days: (json['days'] as List? ?? [])
          .map((d) => RoutineDayDto.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
