import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/beginner_exercise_guide.dart';

class ExerciseVideoModal extends StatelessWidget {
  final String exerciseName;

  const ExerciseVideoModal({super.key, required this.exerciseName});

  static void show(BuildContext context, String exerciseName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseVideoModal(exerciseName: exerciseName),
    );
  }

  Future<void> _openRealVideo(String videoId) async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final guide = BeginnerExerciseGuideRepository.getGuide(exerciseName);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF161616),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de arraste superior
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Título e Cabeçalho Amigável
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                            ),
                            child: const Text(
                              'GUIA PASSO A PASSO PARA INICIANTES',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        guide.exerciseName,
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Músculo: ${guide.targetMuscle.displayName}',
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),

          // Card de Vídeo Real no YouTube (Curto e com treinador humano)
          InkWell(
            onTap: () => _openRealVideo(guide.youtubeVideoId),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6), width: 1.5),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://img.youtube.com/vi/${guide.youtubeVideoId}/hqdefault.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ASSISTIR EXECUÇÃO REAL EM VÍDEO (CURTO)',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Toque para abrir demonstração com personal humano',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.video_library, color: Colors.redAccent, size: 14),
                          SizedBox(width: 4),
                          Text('VÍDEO REAL', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Guia Prático para Quem Nunca Pisou na Academia
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                _buildGuideCard(
                  icon: Icons.search,
                  badge: 'PASSO 1: COMO ACHAR NA ACADEMIA',
                  title: guide.machineName,
                  content: guide.equipmentAppearance,
                  color: Colors.tealAccent,
                ),
                const SizedBox(height: 12),
                _buildGuideCard(
                  icon: Icons.tune,
                  badge: 'PASSO 2: REGULAGEM DO APARELHO',
                  title: 'Ajuste do Banco e Pino de Peso',
                  content: guide.pinAndWeightSetup,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 12),
                _buildGuideCard(
                  icon: Icons.airline_seat_recline_normal,
                  badge: 'PASSO 3: POSIÇÃO INICIAL',
                  title: 'Como Entrar e se Posicionar',
                  content: guide.startPosition,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 12),
                _buildGuideCard(
                  icon: Icons.play_circle_outline,
                  badge: 'PASSO 4: COMO FAZER O MOVIMENTO',
                  title: 'Execução Passo a Passo',
                  content: guide.movementStepByStep,
                  color: Colors.purpleAccent,
                ),
                const SizedBox(height: 12),
                _buildGuideCard(
                  icon: Icons.favorite,
                  badge: 'PASSO 5: O QUE VOCÊ DEVE SENTIR',
                  title: 'Teste de Sensação Muscular',
                  content: guide.feelingCheck,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String badge,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                badge,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }
}
