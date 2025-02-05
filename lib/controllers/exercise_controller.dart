import 'package:get/get.dart';
import '../models/exercise.dart';
import '../services/database_service.dart';

class ExerciseController extends GetxController {
  final DatabaseService _databaseService = DatabaseService();
  final RxList<Exercise> exercises = <Exercise>[].obs;
  final RxString selectedCategory = 'Todos'.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExercises();
  }

  Future<void> loadExercises() async {
    try {
      isLoading.value = true;
      final loadedExercises = await _databaseService.getExercises();
      exercises.assignAll(loadedExercises);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cargar los ejercicios: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExercise(Exercise exercise) async {
    try {
      await _databaseService.insertExercise(exercise);
      await loadExercises();
      Get.snackbar(
        'Éxito',
        'Ejercicio agregado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al agregar el ejercicio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await _databaseService.deleteExercise(id);
      await loadExercises();
      Get.snackbar(
        'Éxito',
        'Ejercicio eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar el ejercicio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Exercise? getExerciseById(String id) {
    try {
      return exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Exercise> get filteredExercises {
    if (selectedCategory.value == 'Todos') {
      return exercises;
    }
    return exercises.where((exercise) => exercise.category == selectedCategory.value).toList();
  }

  List<String> get categories {
    final categorySet = exercises.map((e) => e.category).toSet();
    return ['Todos', ...categorySet];
  }

  Future<void> updateExercise(Exercise exercise) async {
    try {
      await _databaseService.updateExercise(exercise);
      await loadExercises();
      Get.snackbar(
        'Éxito',
        'Ejercicio actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar el ejercicio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
