import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';
import '../services/workout_api_service.dart';

class ActiveWorkoutProvider with ChangeNotifier {
  final WorkoutApiService _apiService;
  final String currentUserId = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

  WorkoutSessionModel? _activeSession;
  final List<WorkoutSessionModel> _completedHistory = [];
  final Uuid _uuid = const Uuid();

  // Controle do Ciclo de 30 Treinos (Mesociclo RP)
  static const int maxCycleWorkouts = 30;
  int _currentCycleProgress = 1; // Inicia no treino 1
  String _activeCycleRoutineName = 'Push / Pull / Legs Hipertrofia';
  bool _cycleCompletedTrigger = false;

  ActiveWorkoutProvider({WorkoutApiService? apiService}) 
      : _apiService = apiService ?? WorkoutApiService() {
    _loadSampleHistoryIfEmpty();
  }

  WorkoutSessionModel? get activeSession => _activeSession;
  bool get hasActiveWorkout => _activeSession != null;
  List<WorkoutSessionModel> get completedHistory => List.unmodifiable(_completedHistory);

  int get currentCycleProgress => _currentCycleProgress;
  int get maxCycleTarget => maxCycleWorkouts;
  String get activeCycleRoutineName => _activeCycleRoutineName;
  bool get cycleCompletedTrigger => _cycleCompletedTrigger;

  void acknowledgeCycleCompletion() {
    _cycleCompletedTrigger = false;
    notifyListeners();
  }

  void startNewCycle(String routineName) {
    _currentCycleProgress = 1;
    _activeCycleRoutineName = routineName;
    _cycleCompletedTrigger = false;
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

  void startWorkout(String name) {
    _activeSession = WorkoutSessionModel(
      id: _uuid.v4(),
      userId: currentUserId,
      name: name,
      startedAt: DateTime.now(),
      clientSyncId: _uuid.v4(),
      exercises: [],
    );
    notifyListeners();
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
    _completedHistory.insert(0, _activeSession!);

    // Incrementa o contador do ciclo de 30 treinos
    if (_currentCycleProgress < maxCycleWorkouts) {
      _currentCycleProgress++;
    } else {
      // 30º treino concluído! Dispara o gatilho de reavaliação pela IA
      _cycleCompletedTrigger = true;
    }

    final finishedToSync = _activeSession!;
    _activeSession = null;
    notifyListeners();

    return await _apiService.syncWorkout(finishedToSync);
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
