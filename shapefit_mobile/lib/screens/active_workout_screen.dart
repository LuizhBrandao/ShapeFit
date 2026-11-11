import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';
import '../providers/active_workout_provider.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<ActiveWorkoutProvider>();
    final session = workoutProvider.activeSession;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ShapeFit')),
        body: Center(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.fitness_center),
            label: const Text('INICIAR NOVO TREINO', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              workoutProvider.startWorkout('Treino de Hipertrofia (Push)');
              // Adiciona um exercício de exemplo imediatamente
              workoutProvider.addExercise(
                'e1111111-1111-1111-1111-111111111111',
                'Supino Reto com Barra',
                MuscleGroup.chest,
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () async {
              final ok = await workoutProvider.finishWorkout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Treino sincronizado com sucesso!' : 'Treino salvo localmente (offline)'),
                    backgroundColor: ok ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            child: const Text('CONCLUIR', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: session.exercises.length,
        itemBuilder: (context, exIndex) {
          final exercise = session.exercises[exIndex];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Header da tabela de séries
                  const Row(
                    children: [
                      SizedBox(width: 44, child: Text('SÉRIE', style: TextStyle(color: Colors.grey, fontSize: 12))),
                      Expanded(child: Center(child: Text('ANTERIOR', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                      Expanded(child: Center(child: Text('KG', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                      Expanded(child: Center(child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 12)))),
                      SizedBox(width: 40, child: Icon(Icons.check, size: 16, color: Colors.grey)),
                    ],
                  ),
                  const Divider(color: Colors.white12),
                  ...exercise.sets.map((set) => _buildSetRow(context, workoutProvider, set)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => workoutProvider.addSet(exercise),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Adicionar Série'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, ActiveWorkoutProvider provider, SetLogModel set) {
    Color typeColor = Colors.grey;
    if (set.type == SetType.warmUp) typeColor = Colors.orangeAccent;
    if (set.type == SetType.dropSet) typeColor = Colors.purpleAccent;
    if (set.type == SetType.failure) typeColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: set.isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Botão de 1 toque para alterar o Tipo de Série (Normal, Aquecimento, Drop, Falha)
          InkWell(
            onTap: () => provider.toggleSetType(set),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 36,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: typeColor, width: 1.2),
              ),
              child: Text(
                set.type.shortCode,
                style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Exibição do peso/reps anterior para pré-preenchimento
          Expanded(
            child: Center(
              child: Text(
                set.previousWeight != null ? '${set.previousWeight} kg × ${set.previousReps}' : '—',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
            ),
          ),
          // Input do Peso atual
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: set.weight > 0 ? set.weight.toString() : (set.previousWeight?.toString() ?? ''),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  hintText: set.previousWeight?.toString() ?? '0',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
                onChanged: (val) => set.weight = double.tryParse(val) ?? 0.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Input das Repetições atuais
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: set.reps > 0 ? set.reps.toString() : (set.previousReps?.toString() ?? ''),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  hintText: set.previousReps?.toString() ?? '0',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
                onChanged: (val) => set.reps = int.tryParse(val) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botão de Conclusão da Série com feedback tátil/visual
          IconButton(
            icon: Icon(
              set.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: set.isCompleted ? Colors.greenAccent : Colors.white30,
            ),
            onPressed: () => provider.toggleSetCompletion(set),
          ),
        ],
      ),
    );
  }
}
