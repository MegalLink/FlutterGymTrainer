import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/active_training_controller.dart';
import '../controllers/exercise_controller.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/training.dart';
import '../widgets/rest_timer_widget.dart';

class ActiveTrainingPage extends StatelessWidget {
  final Training training;

  const ActiveTrainingPage({
    super.key,
    required this.training,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActiveTrainingController(training));
    final exerciseController = Get.find<ExerciseController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(training.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Obx(() => FloatingActionButton(
              mini: true,
              onPressed: controller.isSaving.value 
                ? null 
                : () {
                    controller.saveTrainingSession();
                    Get.back();
                  },
              child: controller.isSaving.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
            )),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Automatic timer checkbox
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Obx(() => Checkbox(
                      value: controller.autoStartTimer.value,
                      onChanged: (value) => controller.autoStartTimer.value = value ?? false,
                    )),
                    const Text('Temporizador automático'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: training.exerciseIds.length,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 80,
                  ),
                  itemBuilder: (context, index) {
                    final exerciseId = training.exerciseIds[index];
                    final exercise = exerciseController.getExerciseById(exerciseId);
                    if (exercise == null) return const SizedBox.shrink();

                    return Obx(() {
                      final progress = controller.exerciseProgress
                          .firstWhere((p) => p.exerciseName == exercise.name);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: [
                            ListTile(
                              leading: SizedBox(
                                width: 60,
                                height: 60,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: exercise.imageUrl != null
                                      ? Image.file(
                                          File(exercise.imageUrl!),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.fitness_center,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                              title: Text(
                                exercise.name,
                                style: TextStyle(
                                  decoration: progress.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exercise.category),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // Selector de series
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => controller.updateTargetSets(progress.exerciseName, -1),
                                      ),
                                      Text('${progress.sets.length}/${progress.targetSets} series'),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => controller.updateTargetSets(progress.exerciseName, 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  progress.sets.length >= progress.targetSets
                                      ? Icons.check_circle
                                      : Icons.check_circle_outline,
                                  color: progress.sets.length >= progress.targetSets
                                      ? Colors.green
                                      : null,
                                ),
                                onPressed: () => _showAddSetDialog(
                                  context,
                                  controller,
                                  exercise,
                                  progress.sets.length + 1,
                                ),
                              ),
                            ),
                            if (progress.sets.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Series realizadas:',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: progress.sets
                                          .map((set) => Chip(
                                                label: Text(
                                                  'Serie ${set.setNumber}: ${set.repetitions} reps',
                                                ),
                                                deleteIcon: const Icon(
                                                  Icons.close,
                                                  size: 18,
                                                ),
                                                onDeleted: () => controller.removeSet(
                                                  progress.exerciseName,
                                                  set.setNumber,
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          // Temporizador expandible en la parte inferior
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setExpansionState) {
                  return ExpansionTile(
                    onExpansionChanged: (expanded) {
                      setExpansionState(() {
                        controller.isExpanded.value = expanded;
                      });
                    },
                    initiallyExpanded: false,
                    trailing: Obx(() => AnimatedRotation(
                      turns: controller.isExpanded.value ? 0.5 : 0,
                      duration: const Duration(milliseconds: 0),
                      child: Icon(
                        Icons.expand_more,
                        color: controller.isResting.value
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    )),
                    title: Row(
                      children: [
                        const Icon(Icons.timer),
                        const SizedBox(width: 8),
                        const Text('Temporizador'),
                        const Spacer(),
                        Obx(() => Text(
                              formatTime(
                                controller.isResting.value
                                    ? controller.currentRestTime.value
                                    : controller.defaultRestTime.value,
                              ),
                              style: TextStyle(
                                color: controller.isResting.value
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Obx(() => RestTimerWidget(
                              currentTime: controller.isResting.value
                                  ? controller.currentRestTime.value
                                  : controller.defaultRestTime.value,
                              totalTime: controller.defaultRestTime.value,
                              onStop: controller.isResting.value ? controller.stopRest : null,
                              isResting: controller.isResting.value,
                            )),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSetDialog(
    BuildContext context,
    ActiveTrainingController controller,
    Exercise exercise,
    int setNumber,
  ) {
    final repetitionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar serie $setNumber - ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repetitionsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de repeticiones',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.getWeightController(ExerciseProgress(exerciseName: exercise.name)),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GetBuilder<ActiveTrainingController>(
                  builder: (controller) {
                    final currentUnit = controller.getWeightUnit(
                      ExerciseProgress(exerciseName: exercise.name)
                    );
                    return DropdownButton<String>(
                      value: currentUnit,
                      items: const [
                        DropdownMenuItem(value: 'kg', child: Text('kg')),
                        DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setWeightUnit(
                            ExerciseProgress(exerciseName: exercise.name),
                            value,
                          );
                        }
                      },
                    );
                  },
                ),
              ],
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
              final repetitions = int.tryParse(repetitionsController.text);
              if (repetitions != null && repetitions > 0) {
                controller.addSetToExercise(exercise.name, repetitions);
                Navigator.pop(context);
                if (controller.exerciseProgress
                    .firstWhere((p) => p.exerciseName == exercise.name)
                    .sets
                    .length >= controller.exerciseProgress
                    .firstWhere((p) => p.exerciseName == exercise.name)
                    .targetSets) {
                  controller.startRest(); // Iniciar descanso automáticamente si completamos las series objetivo
                }
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
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
