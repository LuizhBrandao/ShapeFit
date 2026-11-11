import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/custom_routine_model.dart';
import '../models/routine_dto_models.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';
import '../services/workout_api_service.dart';

class ActiveWorkoutProvider with ChangeNotifier {
  final WorkoutApiService _apiService;
  final String currentUserId = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

  WorkoutSessionModel? _activeSession;
  final List<WorkoutSessionModel> _completedHistory = [];
  final Uuid _uuid = const Uuid();

  RoutineTemplateDto? _activeRoutine;
  MesocycleProgressDto? _activeMesocycle;

  // Fichas padrão e criadas pelo usuário
  final List<CustomRoutineTemplate> _userRoutines = [
    CustomRoutineTemplate(
      id: 'default-push',
      name: 'Push A (Peitoral, Ombros & Tríceps)',
      description: 'Peito • Deltoide • Tríceps',
      completedCount: 1,
      targetCount: 30,
      exercises: [
        CustomRoutineExerciseTemplate(exerciseId: 'ex-1', name: 'Supino Inclinado com Halteres', targetMuscle: MuscleGroup.chest),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-2', name: 'Crucifixo na Polia (Crossover)', targetMuscle: MuscleGroup.chest),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-3', name: 'Elevação Lateral', targetMuscle: MuscleGroup.shoulders),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-4', name: 'Tríceps Corda na Polia', targetMuscle: MuscleGroup.triceps),
      ],
    ),
    CustomRoutineTemplate(
      id: 'default-pull',
      name: 'Pull A (Costas, Deltoide Posterior & Bíceps)',
      description: 'Dorsal • Posterior de Ombro • Bíceps',
      completedCount: 1,
      targetCount: 30,
      exercises: [
        CustomRoutineExerciseTemplate(exerciseId: 'ex-5', name: 'Puxada Frontal na Polia', targetMuscle: MuscleGroup.back),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-6', name: 'Remada Baixa com Triângulo', targetMuscle: MuscleGroup.back),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-7', name: 'Face Pull na Polia', targetMuscle: MuscleGroup.shoulders),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-8', name: 'Rosca Direta Barra W', targetMuscle: MuscleGroup.biceps),
      ],
    ),
    CustomRoutineTemplate(
      id: 'default-legs',
      name: 'Legs A (Quadríceps & Isquiotibiais)',
      description: 'Quadríceps • Posteriores • Panturrilha',
      completedCount: 0,
      targetCount: 30,
      exercises: [
        CustomRoutineExerciseTemplate(exerciseId: 'ex-9', name: 'Agachamento Hack / Livre', targetMuscle: MuscleGroup.quadriceps),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-10', name: 'Mesa Flexora', targetMuscle: MuscleGroup.hamstrings),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-11', name: 'Cadeira Extensora', targetMuscle: MuscleGroup.quadriceps),
        CustomRoutineExerciseTemplate(exerciseId: 'ex-12', name: 'Panturrilha Sentado (Gêmeos)', targetMuscle: MuscleGroup.calves),
      ],
    ),
  ];

  bool _cycleCompletedTrigger = false;
  String _completedRoutineName = '';

  ActiveWorkoutProvider({WorkoutApiService? apiService}) 
      : _apiService = apiService ?? WorkoutApiService() {
    _loadSampleHistoryIfEmpty();
    loadActiveBackendData();
  }

  WorkoutSessionModel? get activeSession => _activeSession;
  bool get hasActiveWorkout => _activeSession != null;
  List<WorkoutSessionModel> get completedHistory => List.unmodifiable(_completedHistory);
  List<CustomRoutineTemplate> get userRoutines => List.unmodifiable(_userRoutines);
  RoutineTemplateDto? get activeRoutine => _activeRoutine;
  MesocycleProgressDto? get activeMesocycle => _activeMesocycle;

  bool get cycleCompletedTrigger => _cycleCompletedTrigger;
  String get completedRoutineName => _completedRoutineName;

  void addCustomRoutine(CustomRoutineTemplate routine) {
    _userRoutines.add(routine);
    notifyListeners();
  }

  Future<void> loadActiveBackendData() async {
    try {
      final routine = await _apiService.fetchActiveRoutine(currentUserId);
      final mesocycle = await _apiService.fetchMesocycleProgress(currentUserId);
      if (routine != null) {
        _activeRoutine = routine;
      }
      if (mesocycle != null) {
        _activeMesocycle = mesocycle;
        for (var r in _userRoutines) {
          if (r.routineTemplateId == mesocycle.routineTemplateId || r.mesocycleId == mesocycle.id) {
            r.completedCount = mesocycle.completedSessionsCount;
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  void setActivePrescription(PrescribeRoutineResponse prescription) {
    _activeMesocycle = MesocycleProgressDto(
      id: prescription.mesocycleId,
      userId: currentUserId,
      routineTemplateId: prescription.routineTemplateId,
      cycleNumber: 1,
      targetSessionsCount: 30,
      completedSessionsCount: 0,
      progressRatio: 0.0,
      status: 1,
      startedAt: DateTime.now(),
      goal: 'Hipertrofia e Volume Científico',
    );

    // Remove eventuais fichas anteriores com o mesmo template
    _userRoutines.removeWhere((r) => r.routineTemplateId == prescription.routineTemplateId);

    // Mapeia os dias prescritos pelo backend em fichas disponíveis no app
    final newRoutines = prescription.days.map((day) {
      return CustomRoutineTemplate(
        id: day.id,
        routineTemplateId: prescription.routineTemplateId,
        mesocycleId: prescription.mesocycleId,
        name: day.name,
        description: day.description ?? '${day.exercises.length} exercícios fisiológicos • ${day.totalTargetSets} séries',
        completedCount: 0,
        targetCount: 30,
        exercises: day.exercises.map((ex) {
          return CustomRoutineExerciseTemplate(
            exerciseId: ex.exerciseId,
            name: ex.customExerciseName,
            targetMuscle: ex.targetMuscle,
            defaultSets: ex.targetSets,
            repRange: ex.repRange,
          );
        }).toList(),
      );
    }).toList();

    _userRoutines.insertAll(0, newRoutines);
    notifyListeners();
  }

  void startWorkout(String name, {String? routineTemplateId, String? routineDayId, String? mesocycleId}) {
    _activeSession = WorkoutSessionModel(
      id: _uuid.v4(),
      userId: currentUserId,
      name: name,
      startedAt: DateTime.now(),
      clientSyncId: _uuid.v4(),
      routineTemplateId: routineTemplateId,
      routineDayId: routineDayId,
      mesocycleId: mesocycleId ?? _activeMesocycle?.id,
      exercises: [],
    );
    notifyListeners();
  }

  void startWorkoutFromRoutine(CustomRoutineTemplate routine) {
    startWorkout(
      routine.name,
      routineTemplateId: routine.routineTemplateId,
      routineDayId: routine.routineTemplateId != null ? routine.id : null,
      mesocycleId: routine.mesocycleId ?? _activeMesocycle?.id,
    );
    for (var ex in routine.exercises) {
      addExercise(ex.exerciseId, ex.name, ex.targetMuscle);
    }
  }

  void startWorkoutFromPrescribedDay({
    required PrescribeRoutineResponse prescription,
    required RoutineDayDto day,
  }) {
    startWorkout(
      day.name,
      routineTemplateId: prescription.routineTemplateId,
      routineDayId: day.id,
      mesocycleId: prescription.mesocycleId,
    );
    for (var ex in day.exercises) {
      addExercise(ex.exerciseId, ex.customExerciseName, ex.targetMuscle);
    }
  }

  void acknowledgeCycleCompletion() {
    _cycleCompletedTrigger = false;
    _completedRoutineName = '';
    notifyListeners();
  }

  void _loadSampleHistoryIfEmpty() {
    if (_completedHistory.isEmpty) {
      final now = DateTime.now();
      _completedHistory.add(
        WorkoutSessionModel(
          id: _uuid.v4(),
          userId: currentUserId,
          name: 'Pull A (Costas & Bíceps)',
          startedAt: now.subtract(const Duration(days: 2, hours: 2)),
          finishedAt: now.subtract(const Duration(days: 2, hours: 1)),
          exercises: [
            ExerciseLogModel(
              id: _uuid.v4(),
              exerciseId: 'ex-pull',
              exerciseName: 'Puxada Frontal na Polia',
              primaryMuscle: MuscleGroup.back,
              order: 1,
              sets: [
                SetLogModel(id: _uuid.v4(), setOrder: 1, weight: 65, reps: 10, isCompleted: true),
                SetLogModel(id: _uuid.v4(), setOrder: 2, weight: 65, reps: 10, isCompleted: true),
                SetLogModel(id: _uuid.v4(), setOrder: 3, weight: 70, reps: 8, isCompleted: true),
              ],
            )
          ],
        ),
      );
    }
  }

  Future<void> addExercise(String exerciseId, String name, MuscleGroup muscle) async {
    if (_activeSession == null) return;

    final exerciseLog = ExerciseLogModel(
      id: _uuid.v4(),
      exerciseId: exerciseId,
      exerciseName: name,
      primaryMuscle: muscle,
      order: _activeSession!.exercises.length + 1,
      sets: [],
    );

    final previousPerf = await _apiService.fetchLastPerformance(currentUserId, exerciseId);
    
    if (previousPerf != null && previousPerf['sets'] != null) {
      final List prevSets = previousPerf['sets'];
      for (int i = 0; i < prevSets.length; i++) {
        final p = prevSets[i];
        exerciseLog.sets.add(SetLogModel(
          id: _uuid.v4(),
          setOrder: i + 1,
          type: SetType.fromValue(p['type'] ?? 1),
          weight: (p['weight'] as num).toDouble(),
          reps: p['repetitions'] as int,
          previousWeight: (p['weight'] as num).toDouble(),
          previousReps: p['repetitions'] as int,
        ));
      }
    }

    if (exerciseLog.sets.isEmpty) {
      exerciseLog.sets.add(SetLogModel(
        id: _uuid.v4(),
        setOrder: 1,
        type: SetType.normal,
        weight: 0,
        reps: 0,
      ));
    }

    _activeSession!.exercises.add(exerciseLog);
    notifyListeners();
  }

  void addSet(ExerciseLogModel exercise) {
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
    final newSet = SetLogModel(
      id: _uuid.v4(),
      setOrder: exercise.sets.length + 1,
      type: lastSet?.type ?? SetType.normal,
      weight: lastSet?.weight ?? 0,
      reps: lastSet?.reps ?? 0,
      previousWeight: lastSet?.previousWeight,
      previousReps: lastSet?.previousReps,
    );
    exercise.sets.add(newSet);
    notifyListeners();
  }

  void toggleSetType(SetLogModel set) {
    final types = SetType.values;
    final nextIndex = (types.indexOf(set.type) + 1) % types.length;
    set.type = types[nextIndex];
    notifyListeners();
  }

  void toggleSetCompletion(SetLogModel set) {
    set.isCompleted = !set.isCompleted;
    notifyListeners();
  }

  Future<bool> finishWorkout() async {
    if (_activeSession == null) return false;

    _activeSession!.finishedAt = DateTime.now();
    final finishedToSync = _activeSession!;
    _completedHistory.insert(0, finishedToSync);

    // Busca a ficha correspondente na lista do usuário por ID estruturado
    CustomRoutineTemplate? matchedRoutine;
    if (finishedToSync.routineDayId != null) {
      matchedRoutine = _userRoutines.where((r) => r.id == finishedToSync.routineDayId).firstOrNull;
    }
    if (matchedRoutine == null && finishedToSync.routineTemplateId != null) {
      matchedRoutine = _userRoutines.where((r) => r.routineTemplateId == finishedToSync.routineTemplateId).firstOrNull;
    }
    matchedRoutine ??= _userRoutines.where((r) => r.name.toLowerCase() == finishedToSync.name.toLowerCase()).firstOrNull;

    _activeSession = null;
    notifyListeners();

    // Sincroniza com a API C# .NET 10
    final syncSuccess = await _apiService.syncWorkout(finishedToSync);

    if (syncSuccess) {
      // Quando sincronizado, atualiza o progresso real do mesociclo a partir do PostgreSQL
      final updatedMesocycle = await _apiService.fetchMesocycleProgress(currentUserId);
      if (updatedMesocycle != null) {
        _activeMesocycle = updatedMesocycle;
        for (var r in _userRoutines) {
          if (r.routineTemplateId == updatedMesocycle.routineTemplateId || r.mesocycleId == updatedMesocycle.id) {
            r.completedCount = updatedMesocycle.completedSessionsCount;
          }
        }
        if (updatedMesocycle.isCompleted) {
          _cycleCompletedTrigger = true;
          _completedRoutineName = _activeRoutine?.name ?? matchedRoutine?.name ?? 'Mesociclo de 30 Treinos';
        }
        notifyListeners();
      }
    } else {
      // Fallback offline caso a rede esteja temporariamente indisponível
      if (matchedRoutine != null && matchedRoutine.completedCount < matchedRoutine.targetCount) {
        matchedRoutine.completedCount++;
        if (matchedRoutine.completedCount >= matchedRoutine.targetCount) {
          _cycleCompletedTrigger = true;
          _completedRoutineName = matchedRoutine.name;
        }
        notifyListeners();
      }
    }

    return syncSuccess;
  }

  List<WorkoutSessionModel> getWorkoutsForDate(DateTime date) {
    return _completedHistory.where((s) {
      return s.startedAt.year == date.year &&
             s.startedAt.month == date.month &&
             s.startedAt.day == date.day;
    }).toList();
  }

  bool hasWorkoutOnDate(DateTime date) {
    return _completedHistory.any((s) {
      return s.startedAt.year == date.year &&
             s.startedAt.month == date.month &&
             s.startedAt.day == date.day;
    });
  }
}
