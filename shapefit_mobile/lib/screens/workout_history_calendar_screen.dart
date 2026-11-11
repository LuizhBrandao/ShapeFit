import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout_models.dart';
import '../providers/active_workout_provider.dart';

class WorkoutHistoryCalendarScreen extends StatefulWidget {
  const WorkoutHistoryCalendarScreen({super.key});

  @override
  State<WorkoutHistoryCalendarScreen> createState() => _WorkoutHistoryCalendarScreenState();
}

class _WorkoutHistoryCalendarScreenState extends State<WorkoutHistoryCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<ActiveWorkoutProvider>();
    final selectedWorkouts = workoutProvider.getWorkoutsForDate(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.blueAccent, size: 22),
            SizedBox(width: 8),
            Text('Histórico de Treinos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthHeader(),
            _buildDaysOfWeekHeader(),
            _buildCalendarGrid(workoutProvider),
            const Divider(color: Colors.white12, height: 28),
            _buildSelectedDateWorkouts(selectedWorkouts),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    final monthName = DateFormat('MMMM yyyy', 'pt_BR').format(_focusedMonth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            monthName.substring(0, 1).toUpperCase() + monthName.substring(1),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white70),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDaysOfWeekHeader() {
    const days = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((day) {
          return SizedBox(
            width: 38,
            child: Center(
              child: Text(
                day,
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(ActiveWorkoutProvider provider) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Domingo, 1 = Segunda, etc.

    final totalCells = ((startingWeekday + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCells,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final dayNumber = index - startingWeekday + 1;
          if (dayNumber < 1 || dayNumber > daysInMonth) {
            return const SizedBox();
          }

          final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
          final hasWorkout = provider.hasWorkoutOnDate(cellDate);
          final isSelected = cellDate.year == _selectedDate.year &&
                             cellDate.month == _selectedDate.month &&
                             cellDate.day == _selectedDate.day;
          final isToday = cellDate.year == DateTime.now().year &&
                          cellDate.month == DateTime.now().month &&
                          cellDate.day == DateTime.now().day;

          return InkWell(
            onTap: () {
              setState(() => _selectedDate = cellDate);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blueAccent.withValues(alpha: 0.3)
                    : (hasWorkout ? Colors.white.withValues(alpha: 0.05) : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Colors.blueAccent
                      : (isToday ? Colors.white38 : Colors.transparent),
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isToday ? Colors.blueAccent : Colors.white70),
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  if (hasWorkout) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateWorkouts(List<WorkoutSessionModel> workouts) {
    final formattedDate = DateFormat("d 'de' MMMM", 'pt_BR').format(_selectedDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Treinos em $formattedDate',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: workouts.isNotEmpty ? Colors.green.withValues(alpha: 0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${workouts.length} treino(s)',
                  style: TextStyle(
                    color: workouts.isNotEmpty ? Colors.greenAccent : Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 14),
          if (workouts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.event_busy, color: Colors.white24, size: 36),
                  SizedBox(height: 8),
                  Text('Nenhum treino registrado nesta data', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            )
          else
            ...workouts.map((w) => _buildWorkoutHistoryCard(w)),
        ],
      ),
    );
  }

  Widget _buildWorkoutHistoryCard(WorkoutSessionModel workout) {
    final startTime = DateFormat('HH:mm').format(workout.startedAt);
    final endTime = workout.finishedAt != null ? DateFormat('HH:mm').format(workout.finishedAt!) : '--:--';
    final totalSets = workout.exercises.fold<int>(0, (prev, e) => prev + e.sets.where((s) => s.isCompleted).length);

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
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
                  workout.name,
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$startTime às $endTime',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${workout.exercises.length} exercícios • $totalSets séries concluídas',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10),
            ...workout.exercises.map((e) {
              final completedSets = e.sets.where((s) => s.isCompleted).toList();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.exerciseName,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      '${completedSets.length} séries',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
