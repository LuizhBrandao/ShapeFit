import 'package:flutter/material.dart';

class BiomechanicalAnimationViewer extends StatefulWidget {
  final String exerciseName;

  const BiomechanicalAnimationViewer({super.key, required this.exerciseName});

  @override
  State<BiomechanicalAnimationViewer> createState() => _BiomechanicalAnimationViewerState();
}

class _BiomechanicalAnimationViewerState extends State<BiomechanicalAnimationViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Ciclo completo de 4 segundos: 2.5s na fase excêntrica (descida) e 1.5s na concêntrica (subida)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final isGoingDown = _controller.status == AnimationStatus.forward;
        final phaseText = isGoingDown ? 'DESCIDA EXCÊNTRICA (2-3s)' : 'SUBIDA CONCÊNTRICA (1s)';
        final phaseColor = isGoingDown ? Colors.orangeAccent : Colors.greenAccent;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Fundo escuro com grade biomecânica sutil
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 230),
                painter: _BiomechanicsPainter(
                  exerciseName: widget.exerciseName,
                  progress: progress,
                ),
              ),
            ),
            // Indicador de fase e cadência da repetição
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: phaseColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: phaseColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      phaseText,
                      style: TextStyle(color: phaseColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Selo de Repetição em Loop
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat, color: Colors.blueAccent, size: 14),
                    SizedBox(width: 4),
                    Text('CADÊNCIA 3-1-1 (LOOP)', style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BiomechanicsPainter extends CustomPainter {
  final String exerciseName;
  final double progress; // 0.0 (extensão total) a 1.0 (flexão/descida máxima)

  _BiomechanicsPainter({required this.exerciseName, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final lower = exerciseName.toLowerCase();

    if (lower.contains('agachamento') || lower.contains('hack') || lower.contains('leg')) {
      _drawSquat(canvas, size, progress);
    } else if (lower.contains('remada') || lower.contains('puxada') || lower.contains('pull')) {
      _drawRowOrPull(canvas, size, progress);
    } else {
      _drawBenchOrPress(canvas, size, progress);
    }
  }

  void _drawSquat(Canvas canvas, Size size, double p) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintBody = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintMuscle = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintBar = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Movimento do quadril e joelho descendo e subindo
    final hipY = center.dy - 10 + (p * 45);
    final kneeY = center.dy + 35 + (p * 15);
    final kneeX = center.dx + 25 - (p * 5);
    final hipX = center.dx - 20 - (p * 15);
    final foot = Offset(center.dx + 10, center.dy + 80);

    // Coxa / Quadríceps (Músculo Alvo)
    canvas.drawLine(Offset(hipX, hipY), Offset(kneeX, kneeY), paintMuscle);
    // Canela
    canvas.drawLine(Offset(kneeX, kneeY), foot, paintBody);
    // Tronco
    final torsoTop = Offset(hipX + 15, hipY - 60);
    canvas.drawLine(Offset(hipX, hipY), torsoTop, paintBody);
    // Cabeça
    canvas.drawCircle(Offset(torsoTop.dx + 5, torsoTop.dy - 16), 12, paintBody..style = PaintingStyle.fill);

    // Barra de Peso sobre as costas
    paintBody.style = PaintingStyle.stroke;
    canvas.drawLine(Offset(torsoTop.dx - 35, torsoTop.dy), Offset(torsoTop.dx + 45, torsoTop.dy), paintBar);
    canvas.drawCircle(Offset(torsoTop.dx - 35, torsoTop.dy), 14, Paint()..color = Colors.amber.shade700);
    canvas.drawCircle(Offset(torsoTop.dx + 45, torsoTop.dy), 14, Paint()..color = Colors.amber.shade700);
  }

  void _drawRowOrPull(Canvas canvas, Size size, double p) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintBody = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintMuscle = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintBar = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 6;

    // Tronco inclinado a 45°
    final hip = Offset(center.dx - 40, center.dy + 20);
    final shoulder = Offset(center.dx + 20, center.dy - 40);

    // Costas / Dorsal (Músculo Alvo)
    canvas.drawLine(hip, shoulder, paintMuscle);
    // Cabeça
    canvas.drawCircle(Offset(shoulder.dx + 12, shoulder.dy - 10), 12, paintBody..style = PaintingStyle.fill);
    paintBody.style = PaintingStyle.stroke;

    // Braços puxando a barra em direção ao abdômen
    final barY = (center.dy + 50) - (p * 45);
    final barX = (center.dx + 10) - (p * 15);
    final elbow = Offset(center.dx - 10 - (p * 20), center.dy - (p * 10));

    canvas.drawLine(shoulder, elbow, paintBody);
    canvas.drawLine(elbow, Offset(barX, barY), paintBody);

    // Barra com anilhas
    canvas.drawLine(Offset(barX - 40, barY), Offset(barX + 40, barY), paintBar);
    canvas.drawCircle(Offset(barX - 40, barY), 14, Paint()..color = Colors.amber.shade700);
    canvas.drawCircle(Offset(barX + 40, barY), 14, Paint()..color = Colors.amber.shade700);

    // Pernas
    canvas.drawLine(hip, Offset(center.dx - 30, center.dy + 80), paintBody);
  }

  void _drawBenchOrPress(Canvas canvas, Size size, double p) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintBody = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintMuscle = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintBar = Paint()
      ..color = Colors.amberAccent
      ..strokeWidth = 6;

    // Banco inclinado
    canvas.drawLine(Offset(center.dx - 60, center.dy + 40), Offset(center.dx + 50, center.dy - 20), Paint()..color = Colors.white24..strokeWidth = 6);

    // Tronco deitado
    final shoulder = Offset(center.dx + 25, center.dy - 10);
    canvas.drawLine(Offset(center.dx - 40, center.dy + 25), shoulder, paintMuscle);
    canvas.drawCircle(Offset(shoulder.dx + 15, shoulder.dy - 8), 12, paintBody..style = PaintingStyle.fill);
    paintBody.style = PaintingStyle.stroke;

    // Braços empurrando halteres/barra
    final handY = (center.dy - 10) - (p * 50);
    final handX = shoulder.dx - (p * 10);
    final elbow = Offset(shoulder.dx - 25 + (p * 10), center.dy + 15 - (p * 20));

    canvas.drawLine(shoulder, elbow, paintBody);
    canvas.drawLine(elbow, Offset(handX, handY), paintBody);

    // Carga / Halteres
    canvas.drawLine(Offset(handX - 25, handY), Offset(handX + 25, handY), paintBar);
    canvas.drawCircle(Offset(handX - 25, handY), 12, Paint()..color = Colors.amber.shade700);
    canvas.drawCircle(Offset(handX + 25, handY), 12, Paint()..color = Colors.amber.shade700);
  }

  @override
  bool shouldRepaint(covariant _BiomechanicsPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.exerciseName != exerciseName;
}
