import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';
import '../services/workout_api_service.dart';

class ActiveWorkoutProvider with ChangeNotifier {
  final WorkoutApiService _apiService;
  final String currentUserId = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d'; // Mock ID de usuário

  WorkoutSessionModel? _activeSession;
  final Uuid _uuid = const Uuid();

  ActiveWorkoutProvider({WorkoutApiService? apiService}) 
      : _apiService = apiService ?? WorkoutApiService();

  WorkoutSessionModel? get activeSession => _activeSession;
  bool get hasActiveWorkout => _activeSession != null;

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

    // Consulta assíncrona da performance anterior para auto-preenchimento
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

    // Se não houver séries anteriores, inicializa com 1 série limpa
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
    notifyListeners();

    // Envio para o backend .NET 10 (com chave de idempotência clientSyncId)
    final success = await _apiService.syncWorkout(_activeSession!);
    _activeSession = null;
    notifyListeners();
    return success;
  }
}
