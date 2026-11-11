import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/beginner_exercise_guide.dart';
import '../models/custom_routine_model.dart';
import '../models/workout_enums.dart';
import '../providers/active_workout_provider.dart';

class CreateCustomRoutineScreen extends StatefulWidget {
  const CreateCustomRoutineScreen({super.key});

  @override
  State<CreateCustomRoutineScreen> createState() => _CreateCustomRoutineScreenState();
}

class _CreateCustomRoutineScreenState extends State<CreateCustomRoutineScreen> {
  final _nameController = TextEditingController(text: 'Minha Nova Ficha');
  final _descController = TextEditingController();
  final List<CustomRoutineExerciseTemplate> _selectedExercises = [];
  MuscleGroup? _filterMuscle;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showAddExerciseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final guides = BeginnerExerciseGuideRepository.allGuides.where((g) {
              if (_filterMuscle == null) return true;
              return g.targetMuscle == _filterMuscle;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const Text('Catálogo de Exercícios', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Filtro por Músculo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Todos'),
                          selected: _filterMuscle == null,
                          selectedColor: Colors.blueAccent,
                          labelStyle: TextStyle(color: _filterMuscle == null ? Colors.white : Colors.white70),
                          onSelected: (_) {
                            setModalState(() => _filterMuscle = null);
                          },
                        ),
                        const SizedBox(width: 6),
                        ...[
                          MuscleGroup.chest,
                          MuscleGroup.back,
                          MuscleGroup.shoulders,
                          MuscleGroup.biceps,
                          MuscleGroup.triceps,
                          MuscleGroup.quadriceps,
                          MuscleGroup.hamstrings,
                          MuscleGroup.glutes,
                          MuscleGroup.calves,
                          MuscleGroup.abs,
                        ].map((m) {
                          final isSel = _filterMuscle == m;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(m.displayName),
                              selected: isSel,
                              selectedColor: Colors.blueAccent,
                              labelStyle: TextStyle(color: isSel ? Colors.white : Colors.white70),
                              onSelected: (_) {
                                setModalState(() => _filterMuscle = m);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: guides.length,
                      itemBuilder: (context, index) {
                        final guide = guides[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          title: Text(guide.exerciseName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          subtitle: Text('${guide.targetMuscle.displayName} • ${guide.machineName}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 28),
                          onTap: () {
                            setState(() {
                              _selectedExercises.add(
                                CustomRoutineExerciseTemplate(
                                  exerciseId: 'custom-ex-${const Uuid().v4()}',
                                  name: guide.exerciseName,
                                  targetMuscle: guide.targetMuscle,
                                ),
                              );
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveRoutine() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dê um nome para a sua ficha!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos 1 exercício à sua ficha!'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    final newRoutine = CustomRoutineTemplate(
      name: name,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : '${_selectedExercises.length} exercícios personalizados',
      exercises: _selectedExercises,
      completedCount: 0,
      targetCount: 30,
    );

    context.read<ActiveWorkoutProvider>().addCustomRoutine(newRoutine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ficha "$name" criada com sucesso e válida por 30 treinos!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Text('Criar Nova Ficha de Treino', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text('SALVAR', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('NOME DA ROTINA', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              hintText: 'Ex: Foco Peitoral & Deltoide',
              hintStyle: const TextStyle(color: Colors.white24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          const Text('DESCRIÇÃO OU OBSERVAÇÃO (OPCIONAL)', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          TextField(
            controller: _descController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              hintText: 'Ex: Ficha de hipertrofia para segundas e quintas',
              hintStyle: const TextStyle(color: Colors.white24),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXERCÍCIOS DA FICHA (${_selectedExercises.length})',
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              TextButton.icon(
                onPressed: _showAddExerciseDialog,
                icon: const Icon(Icons.add, size: 18, color: Colors.blueAccent),
                label: const Text('Adicionar Exercício', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),

          if (_selectedExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white24, size: 40),
                  SizedBox(height: 12),
                  Text('Nenhum exercício adicionado ainda.', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Toque em "Adicionar Exercício" acima para escolher da lista ampliada.', style: TextStyle(color: Colors.white30, fontSize: 12)),
                ],
              ),
            )
          else
            ..._selectedExercises.asMap().entries.map((entry) {
              final index = entry.key;
              final ex = entry.value;
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.15),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  subtitle: Text(ex.targetMuscle.displayName, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _selectedExercises.removeAt(index);
                      });
                    },
                  ),
                ),
              );
            }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check),
              label: const Text('CRIAR FICHA E INICIAR CICLO DE 30 TREINOS', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: _saveRoutine,
            ),
          )
        ],
      ),
    );
  }
}
