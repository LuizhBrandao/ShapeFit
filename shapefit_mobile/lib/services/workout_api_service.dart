import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/routine_dto_models.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';

class WorkoutApiService {
  final String baseUrl;

  WorkoutApiService({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.current.apiBaseUrl;

  /// Busca as séries e cargas do último treino desse exercício para auto-preenchimento
  Future<Map<String, dynamic>?> fetchLastPerformance(String userId, String exerciseId) async {
    try {
      final url = Uri.parse('$baseUrl/api/workouts/users/$userId/exercises/$exerciseId/last-performance');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Falha silenciosa em caso de ausência de rede (comportamento offline-first)
    }
    return null;
  }

  /// Sincroniza a sessão de treino com a API .NET 10
  Future<bool> syncWorkout(WorkoutSessionModel session) async {
    try {
      final url = Uri.parse('$baseUrl/api/workouts');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(session.toJson()),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false; // Salvo localmente para sincronização posterior
    }
  }

  /// Prescreve cientificamente uma rotina no backend C# e inicia seu Mesociclo de 30 treinos
  Future<PrescribeRoutineResponse?> prescribeRoutine({
    required String userId,
    required String routineName,
    required WorkoutDivision division,
    required int sessionDurationMinutes,
    String? customDescription,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/routines/prescribe');
      final body = {
        'userId': userId,
        'routineName': routineName,
        'division': division.value,
        'sessionDurationMinutes': sessionDurationMinutes,
        if (customDescription != null) 'customDescription': customDescription,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PrescribeRoutineResponse.fromJson(data);
      }
    } catch (_) {
      // Offline fallback ou erro de rede tratado pela UI
    }
    return null;
  }

  /// Busca a rotina ativa planejada do usuário no backend
  Future<RoutineTemplateDto?> fetchActiveRoutine(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/routines/users/$userId/active');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return RoutineTemplateDto.fromJson(data);
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }

  /// Consulta o progresso do Mesociclo ativo de 30 treinos
  Future<MesocycleProgressDto?> fetchMesocycleProgress(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/routines/users/$userId/mesocycle');
      final response = await http.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return MesocycleProgressDto.fromJson(data);
      }
    } catch (_) {
      // Offline fallback
    }
    return null;
  }
}
