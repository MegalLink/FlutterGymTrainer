import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../controllers/exercise_controller.dart';
import '../controllers/training_controller.dart';

class TrainPage extends StatelessWidget {
  const TrainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trainingController = Get.find<TrainingController>();
    final exerciseController = Get.find<ExerciseController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrenar'),
      ),
      body: Obx(() {
        if (trainingController.trainings.isEmpty) {
          return const Center(
            child: Text(
              'No hay entrenamientos disponibles.\nCrea uno en la sección de gestión.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: trainingController.trainings.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final training = trainingController.trainings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ExpansionTile(
                    title: Text(
                      training.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${training.exerciseIds.length} ejercicios',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    children: [
                      if (training.exerciseIds.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No hay ejercicios en este entrenamiento',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: training.exerciseIds.length,
                          itemBuilder: (context, exerciseIndex) {
                            final exerciseId = training.exerciseIds[exerciseIndex];
                            final exercise = exerciseController.getExerciseById(exerciseId);
                            
                            if (exercise == null) return const SizedBox.shrink();

                            return ListTile(
                              leading: exercise.imageUrl != null
                                  ? Image.file(
                                      File(exercise.imageUrl!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.fitness_center),
                              title: Text(exercise.name),
                              subtitle: Text(exercise.category),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_arrow),
                                onPressed: () {
                                  Get.snackbar(
                                    'Ejercicio iniciado',
                                    'Iniciando ${exercise.name}',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Get.snackbar(
                                  'Entrenamiento iniciado',
                                  'Iniciando entrenamiento: ${training.name}',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Iniciar entrenamiento'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
