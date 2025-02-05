import 'package:get/get.dart';
import '../models/training.dart';
import '../services/database_service.dart';

class TrainingController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Training> trainings = <Training>[].obs;
  final Rx<Training?> selectedTraining = Rx<Training?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainings();
  }

  Future<void> loadTrainings() async {
    try {
      isLoading.value = true;
      final loadedTrainings = await _databaseService.getTrainings();
      trainings.assignAll(loadedTrainings);
      // Seleccionar el primer entrenamiento por defecto si hay entrenamientos disponibles
      if (trainings.isNotEmpty && selectedTraining.value == null) {
        selectedTraining.value = trainings[0];
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar los entrenamientos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTraining(String name) async {
    try {
      final training = Training(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        exerciseIds: [],
      );
      await _databaseService.insertTraining(training);
      await loadTrainings();
      Get.snackbar(
        'Éxito',
        'Entrenamiento creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al crear el entrenamiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteTraining(String id) async {
    try {
      await _databaseService.deleteTraining(id);
      await loadTrainings();
      Get.snackbar(
        'Éxito',
        'Entrenamiento eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar el entrenamiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addExerciseToTraining(String trainingId, String exerciseId) async {
    try {
      final trainingIndex = trainings.indexWhere((t) => t.id == trainingId);
      if (trainingIndex != -1) {
        final training = trainings[trainingIndex];
        if (!training.exerciseIds.contains(exerciseId)) {
          final updatedTraining = Training(
            id: training.id,
            name: training.name,
            exerciseIds: [...training.exerciseIds, exerciseId],
          );
          await _databaseService.updateTraining(updatedTraining);
          await loadTrainings();
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al agregar ejercicio al entrenamiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> removeExerciseFromTraining(String trainingId, String exerciseId) async {
    try {
      final trainingIndex = trainings.indexWhere((t) => t.id == trainingId);
      if (trainingIndex != -1) {
        final training = trainings[trainingIndex];
        final updatedTraining = Training(
          id: training.id,
          name: training.name,
          exerciseIds: training.exerciseIds.where((id) => id != exerciseId).toList(),
        );
        await _databaseService.updateTraining(updatedTraining);
        await loadTrainings();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar ejercicio del entrenamiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateTrainingName(String id, String newName) async {
    try {
      final trainingIndex = trainings.indexWhere((t) => t.id == id);
      if (trainingIndex != -1) {
        final training = trainings[trainingIndex];
        final updatedTraining = Training(
          id: training.id,
          name: newName,
          exerciseIds: training.exerciseIds,
        );
        await _databaseService.updateTraining(updatedTraining);
        await loadTrainings();
        Get.snackbar(
          'Éxito',
          'Nombre del entrenamiento actualizado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar el nombre del entrenamiento: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
