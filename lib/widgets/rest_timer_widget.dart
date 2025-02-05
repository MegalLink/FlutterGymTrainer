import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:get/get.dart';
import '../controllers/active_training_controller.dart';

class RestTimerWidget extends StatelessWidget {
  final int currentTime;
  final int totalTime;
  final VoidCallback? onStop;
  final bool isResting;

  const RestTimerWidget({
    super.key,
    required this.currentTime,
    required this.totalTime,
    this.onStop,
    required this.isResting,
  });

  @override
  Widget build(BuildContext context) {
    final isLastSeconds = currentTime <= 5 && currentTime > 0;
    final timerColor = isLastSeconds
        ? const Color(0xFFFF5252) // Rojo para últimos segundos
        : Theme.of(context).primaryColor;

    return Container(
      width: 180,
      height: 180,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<Color?>(
            duration: const Duration(seconds: 1),
            tween: ColorTween(
              begin: isLastSeconds ? Theme.of(context).primaryColor : const Color(0xFFFF5252),
              end: timerColor,
            ),
            builder: (context, color, child) {
              return CircularProgressIndicator(
                value: currentTime / totalTime,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isResting ? (color ?? Theme.of(context).primaryColor) : Colors.grey.shade400,
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: !isResting ? () => _showEditTimeDialog(context) : null,
                  child: TweenAnimationBuilder<Color?>(
                    duration: const Duration(seconds: 1),
                    tween: ColorTween(
                      begin: isLastSeconds ? Theme.of(context).primaryColor : const Color(0xFFFF5252),
                      end: timerColor,
                    ),
                    builder: (context, color, child) {
                      return Text(
                        formatTime(currentTime),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isResting ? (color ?? Theme.of(context).primaryColor) : Colors.grey.shade400,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: isResting ? onStop : () => Get.find<ActiveTrainingController>().startRest(),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    isResting ? 'Detener' : 'Iniciar',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditTimeDialog(BuildContext context) {
    final controller = Get.find<ActiveTrainingController>();
    final timeController = TextEditingController(
      text: controller.defaultRestTime.value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajustar tiempo de descanso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Segundos',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [30, 45, 60, 90, 120, 180].map((seconds) {
                return ActionChip(
                  label: Text('${seconds}s'),
                  onPressed: () {
                    timeController.text = seconds.toString();
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final seconds = int.tryParse(timeController.text);
              if (seconds != null && seconds > 0) {
                controller.setDefaultRestTime(seconds);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  TimerPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Dibuja el círculo de fondo
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Dibuja el progreso
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Comienza desde arriba
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(TimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
