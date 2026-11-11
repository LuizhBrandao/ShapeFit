import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_models.dart';

class WorkoutApiService {
  // Para Android Emulator use: 10.0.2.2:5000 / para dispositivo físico, o IP da máquina local ou DNS da OCI
  final String baseUrl;

  WorkoutApiService({this.baseUrl = 'http://10.0.2.2:5000'});

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
}
