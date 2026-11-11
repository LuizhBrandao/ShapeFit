import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../models/workout_enums.dart';
import '../models/workout_models.dart';
import '../providers/active_workout_provider.dart';
import '../widgets/exercise_video_modal.dart';
import 'ai_workout_coach_screen.dart';
import 'create_custom_routine_screen.dart';
import 'workout_history_calendar_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<ActiveWorkoutProvider>();
    final hasActiveWorkout = workoutProvider.hasActiveWorkout;

    if (workoutProvider.cycleCompletedTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCycleCompletedDialog(context, workoutProvider);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _buildBody(context, workoutProvider),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF181818),
          indicatorColor: Colors.blueAccent.withValues(alpha: 0.2),
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center, color: Colors.blueAccent),
              label: 'Treino',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month, color: Colors.greenAccent),
              label: 'Histórico',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome, color: Colors.amberAccent),
              label: 'Coach IA',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: Colors.purpleAccent),
              label: 'Analytics',
            ),
          ],
        ),
      ),
      bottomSheet: hasActiveWorkout && _currentTabIndex != 0
          ? _buildActiveWorkoutMiniPlayer(context, workoutProvider)
          : null,
    );
  }

  void _showCycleCompletedDialog(BuildContext context, ActiveWorkoutProvider provider) {
    final completedName = provider.completedRoutineName;
    provider.acknowledgeCycleCompletion();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amberAccent, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ciclo de 30 Treinos Concluído!',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns! Você completou os 30 treinos de "$completedName"!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pela ciência do treinamento (RP Periodization), seu corpo esgotou a adaptação biológica dessa ficha específica e precisa de novos ângulos e estímulos.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('REAVALIAR COM IA', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(dialogCtx);
              setState(() => _currentTabIndex = 2);
            },
          )
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ActiveWorkoutProvider provider) {
    switch (_currentTabIndex) {
      case 0:
        return provider.hasActiveWorkout 
            ? _buildActiveWorkoutView(context, provider) 
            : _buildStartWorkoutHub(context, provider);
      case 1:
        return const WorkoutHistoryCalendarScreen();
      case 2:
        return const AiWorkoutCoachScreen();
      case 3:
        return _buildAnalyticsPreview();
      default:
        return Container();
    }
  }

  Widget _buildActiveWorkoutMiniPlayer(BuildContext context, ActiveWorkoutProvider provider) {
    final session = provider.activeSession!;
    return Container(
      color: Colors.blueAccent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TREINO EM ANDAMENTO', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              Text(session.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            onPressed: () => setState(() => _currentTabIndex = 0),
            child: const Text('VOLTAR AO LOG'),
          )
        ],
      ),
    );
  }

  Widget _buildStartWorkoutHub(BuildContext context, ActiveWorkoutProvider provider) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('ShapeFit Pro', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 24)),
                      if (AppConfig.current.environmentBadge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConfig.current.isDevelopment ? Colors.amber.withValues(alpha: 0.2) : Colors.cyan.withValues(alpha: 0.2),
                            border: Border.all(
                              color: AppConfig.current.isDevelopment ? Colors.amber : Colors.cyan,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            AppConfig.current.environmentBadge!,
                            style: TextStyle(
                              color: AppConfig.current.isDevelopment ? Colors.amber : Colors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Text('Alta Performance & Hipertrofia Científica', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.greenAccent),
                tooltip: 'Ver Calendário de Treinos',
                onPressed: () => setState(() => _currentTabIndex = 1),
              )
            ],
          ),
          const SizedBox(height: 18),

          // Painel de Mesociclo: 30 Treinos Independentes por Ficha
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.autorenew, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mesociclo: 30 Treinos por Ficha',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    Text('RP Periodizado', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 14),
                ...provider.userRoutines.map((routine) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                routine.name,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              '${routine.completedCount} / ${routine.targetCount}',
                              style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: routine.progressRatio,
                            minHeight: 8,
                            backgroundColor: Colors.white10,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Botões de Ação Rápida: Nova Ficha e IA Coach
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateCustomRoutineScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.add_circle, color: Colors.greenAccent, size: 26),
                        SizedBox(height: 8),
                        Text('Criar Minha Ficha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Personalize seus exercícios', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _currentTabIndex = 2),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 26),
                        SizedBox(height: 8),
                        Text('Ficha com IA Coach', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Divisão científica em 30 treinos', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('INICIAR TREINO VAZIO', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('INICIAR TREINO AVULSO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              onPressed: () {
                provider.startWorkout('Treino Rápido');
                provider.addExercise(
                  'e1111111-1111-1111-1111-111111111111',
                  'Supino Reto com Barra',
                  MuscleGroup.chest,
                );
              },
            ),
          ),

          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SUAS FICHAS E ROTINAS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCustomRoutineScreen()),
                  );
                },
                icon: const Icon(Icons.add, size: 16, color: Colors.greenAccent),
                label: const Text('Nova', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            ],
          ),
          const SizedBox(height: 8),

          ...provider.userRoutines.map((routine) {
            return Card(
              color: const Color(0xFF1E1E1E),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(routine.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${routine.completedCount}/30',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(routine.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
                    foregroundColor: Colors.blueAccent,
                    elevation: 0,
                  ),
                  onPressed: () => provider.startWorkoutFromRoutine(routine),
                  child: const Text('INICIAR'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutView(BuildContext context, ActiveWorkoutProvider provider) {
    final session = provider.activeSession!;
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF181818),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: Colors.greenAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Iniciado às ${session.startedAt.hour.toString().padLeft(2, '0')}:${session.startedAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () async {
                    final ok = await provider.finishWorkout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Treino concluído e salvo no Calendário!' : 'Treino concluído e salvo no Calendário (offline)!'),
                          backgroundColor: ok ? Colors.green : Colors.orange,
                          action: SnackBarAction(
                            label: 'VER NO HISTÓRICO',
                            textColor: Colors.white,
                            onPressed: () => setState(() => _currentTabIndex = 1),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('CONCLUIR', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: session.exercises.length,
              itemBuilder: (context, exIndex) {
                final exercise = session.exercises[exIndex];
                return _buildExerciseCard(context, provider, exercise);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, ActiveWorkoutProvider provider, ExerciseLogModel exercise) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_fill, color: Colors.amberAccent, size: 24),
                  tooltip: 'Ver Vídeo & Instruções de Execução',
                  onPressed: () => ExerciseVideoModal.show(context, exercise.exerciseName),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                SizedBox(width: 42, child: Center(child: Text('TIPO', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)))),
                SizedBox(width: 8),
                Expanded(flex: 3, child: Center(child: Text('ANTERIOR', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)))),
                SizedBox(width: 8),
                Expanded(flex: 3, child: Center(child: Text('KG', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)))),
                SizedBox(width: 8),
                Expanded(flex: 3, child: Center(child: Text('REPS', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)))),
                SizedBox(width: 40, child: Center(child: Icon(Icons.check, size: 16, color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 6),
            ...exercise.sets.map((set) => _buildSetRow(provider, set)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.04),
                  foregroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => provider.addSet(exercise),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar Série', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(ActiveWorkoutProvider provider, SetLogModel set) {
    Color typeColor = Colors.grey;
    if (set.type == SetType.warmUp) typeColor = Colors.orangeAccent;
    if (set.type == SetType.dropSet) typeColor = Colors.purpleAccent;
    if (set.type == SetType.failure) typeColor = Colors.redAccent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: set.isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
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
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                set.previousWeight != null ? '${set.previousWeight}kg × ${set.previousReps}' : '—',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: set.weight > 0 ? set.weight.toString() : (set.previousWeight?.toString() ?? ''),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  hintText: set.previousWeight?.toString() ?? '0',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
                onChanged: (val) => set.weight = double.tryParse(val) ?? 0.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: set.reps > 0 ? set.reps.toString() : (set.previousReps?.toString() ?? ''),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  hintText: set.previousReps?.toString() ?? '0',
                  hintStyle: const TextStyle(color: Colors.white24),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                ),
                onChanged: (val) => set.reps = int.tryParse(val) ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              set.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
              color: set.isCompleted ? Colors.greenAccent : Colors.white24,
            ),
            onPressed: () => provider.toggleSetCompletion(set),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsPreview() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Volume Semanal por Músculo', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Monitoramento de Séries Efetivas (RP Hypertrophy)', style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 20),
          _buildVolumeBar('Peitoral', 14, 18, Colors.blueAccent),
          _buildVolumeBar('Dorsal / Costas', 16, 20, Colors.tealAccent),
          _buildVolumeBar('Deltoides / Ombros', 12, 16, Colors.amberAccent),
          _buildVolumeBar('Quadríceps', 15, 18, Colors.purpleAccent),
          _buildVolumeBar('Braços (Bíceps/Tríceps)', 10, 14, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildVolumeBar(String muscle, int currentSets, int optimalSets, Color color) {
    final progress = (currentSets / optimalSets).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(muscle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              Text('$currentSets / $optimalSets séries', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
