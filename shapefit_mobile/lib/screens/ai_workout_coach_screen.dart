import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout_enums.dart';
import '../providers/active_workout_provider.dart';
import '../services/gemini_routine_service.dart';

class AiWorkoutCoachScreen extends StatefulWidget {
  const AiWorkoutCoachScreen({super.key});

  @override
  State<AiWorkoutCoachScreen> createState() => _AiWorkoutCoachScreenState();
}

class _AiWorkoutCoachScreenState extends State<AiWorkoutCoachScreen> {
  final GeminiRoutineService _coachService = GeminiRoutineService();

  int _currentStep = 0;
  bool _isLoading = false;
  RoutineRecommendation? _recommendation;

  // Respostas coletadas pela IA interativa
  int _daysPerWeek = 4;
  String _fitnessLevel = 'Intermediário (1-3 anos de treino)';
  String _primaryGoal = 'Hipertrofia Máxima (Estética)';
  String _equipment = 'Academia Completa';
  int _duration = 60;
  final Set<String> _focusMuscles = {'Peito', 'Costas', 'Braços'};

  final List<String> _muscleOptions = [
    'Peito',
    'Costas',
    'Ombros',
    'Braços (Bíceps/Tríceps)',
    'Quadríceps',
    'Posteriores e Glúteos',
    'Panturrilhas',
    'Abdômen'
  ];

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);
    final plan = await _coachService.generateRoutine(
      daysPerWeek: _daysPerWeek,
      fitnessLevel: _fitnessLevel,
      primaryGoal: _primaryGoal,
      equipmentAccess: _equipment,
      focusMuscles: _focusMuscles.toList(),
      sessionDurationMinutes: _duration,
    );
    setState(() {
      _isLoading = false;
      _recommendation = plan;
    });
  }

  void _importDayToActiveWorkout(BuildContext context, RoutineWorkoutDay day) {
    final workoutProvider = context.read<ActiveWorkoutProvider>();
    workoutProvider.startWorkout(day.dayName);

    for (var ex in day.exercises) {
      MuscleGroup muscle = MuscleGroup.chest;
      final target = ex.targetMuscle.toLowerCase();
      if (target.contains('costa') || target.contains('dorsal')) {
        muscle = MuscleGroup.back;
      } else if (target.contains('ombro') || target.contains('deltoide')) {
        muscle = MuscleGroup.shoulders;
      } else if (target.contains('bíceps') || target.contains('biceps')) {
        muscle = MuscleGroup.biceps;
      } else if (target.contains('tríceps') || target.contains('triceps')) {
        muscle = MuscleGroup.triceps;
      } else if (target.contains('quadríceps') || target.contains('perna')) {
        muscle = MuscleGroup.quadriceps;
      }

      workoutProvider.addExercise(
        'ai-${ex.name.hashCode.abs()}',
        ex.name,
        muscle,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rotina "${day.dayName}" carregada no seu treino ativo!'),
        backgroundColor: Colors.blueAccent,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 22),
            SizedBox(width: 8),
            Text('Coach IA • Montador de Ficha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _recommendation != null
              ? _buildRecommendationView()
              : _buildQuestionsFlow(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.amberAccent),
            const SizedBox(height: 24),
            const Text(
              'Avaliando princípios de hipertrofia...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Distribuindo o Volume Semanal Efetivo (MEV/MAV) para $_daysPerWeek dias com base no RP Periodization & Hevy/Boostcamp.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsFlow() {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(primary: Colors.amberAccent),
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep++);
          } else {
            _generatePlan();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  icon: Icon(isLast ? Icons.auto_awesome : Icons.arrow_forward),
                  label: Text(
                    isLast ? 'GERAR ROTINA CIENTÍFICA' : 'PRÓXIMO',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: details.onStepContinue,
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Voltar', style: TextStyle(color: Colors.white54)),
                  ),
                ]
              ],
            ),
          );
        },
        steps: [
          Step(
            isActive: _currentStep >= 0,
            title: const Text('Disponibilidade e Tempo', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$_daysPerWeek dias na semana • $_duration minutos por sessão'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quantos dias por semana você vai à academia?', style: TextStyle(color: Colors.white70)),
                Slider(
                  value: _daysPerWeek.toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  label: '$_daysPerWeek dias',
                  onChanged: (val) => setState(() => _daysPerWeek = val.round()),
                ),
                const SizedBox(height: 12),
                const Text('Tempo médio disponível por sessão:', style: TextStyle(color: Colors.white70)),
                Wrap(
                  spacing: 8,
                  children: [45, 60, 75, 90].map((mins) {
                    final isSel = _duration == mins;
                    return ChoiceChip(
                      label: Text('$mins min'),
                      selected: isSel,
                      selectedColor: Colors.amberAccent,
                      labelStyle: TextStyle(color: isSel ? Colors.black : Colors.white),
                      onSelected: (_) => setState(() => _duration = mins),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 1,
            title: const Text('Objetivo & Nível de Experiência', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Qual o seu objetivo principal?', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                ...['Hipertrofia Máxima (Estética)', 'Ganho de Força Bruta (Powerbuilding)', 'Recomposição Corporal / Perda de Gordura'].map((goal) {
                  final isSelected = _primaryGoal == goal;
                  return InkWell(
                    onTap: () => setState(() => _primaryGoal = goal),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.amberAccent : Colors.white38),
                          const SizedBox(width: 12),
                          Expanded(child: Text(goal, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14))),
                        ],
                      ),
                    ),
                  );
                }),
                const Divider(color: Colors.white12, height: 24),
                const Text('Tempo de treino constante:', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                ...['Iniciante (< 1 ano)', 'Intermediário (1-3 anos de treino)', 'Avançado (> 3 anos de treino sério)'].map((lvl) {
                  final isSelected = _fitnessLevel == lvl;
                  return InkWell(
                    onTap: () => setState(() => _fitnessLevel = lvl),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.amberAccent : Colors.white38),
                          const SizedBox(width: 12),
                          Expanded(child: Text(lvl, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14))),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Step(
            isActive: _currentStep >= 2,
            title: const Text('Grupos Musculares de Ênfase', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${_focusMuscles.length} músculos selecionados para prioridade'),
            content: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _muscleOptions.map((m) {
                final isSelected = _focusMuscles.contains(m);
                return FilterChip(
                  label: Text(m),
                  selected: isSelected,
                  selectedColor: Colors.amberAccent,
                  labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _focusMuscles.add(m);
                      } else {
                        _focusMuscles.remove(m);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Step(
            isActive: _currentStep >= 3,
            title: const Text('Local e Equipamentos', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              children: ['Academia Completa', 'Academia de Condomínio / Halteres Básicos', 'Calistenia / Barra Fixa / Paralelas'].map((eq) {
                final isSelected = _equipment == eq;
                return InkWell(
                  onTap: () => setState(() => _equipment = eq),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? Colors.amberAccent : Colors.white38),
                        const SizedBox(width: 12),
                        Expanded(child: Text(eq, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 14))),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationView() {
    final rec = _recommendation!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade900.withValues(alpha: 0.3), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.amberAccent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      rec.divisionType.toUpperCase(),
                      style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rec.routineName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  rec.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DIAS DA SUA ROTINA:',
            style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          ...rec.days.map((day) => _buildDayCard(day)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.white24),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Refazer Perguntas da IA'),
              onPressed: () => setState(() => _recommendation = null),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayCard(RoutineWorkoutDay day) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  day.dayName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('TREINAR HOJE'),
                  onPressed: () => _importDayToActiveWorkout(context, day),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            ...day.exercises.map((ex) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ex.sets}x ${ex.repRange}',
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ex.targetMuscle} • ${ex.rirOrRpe}',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
