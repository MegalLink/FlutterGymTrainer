import 'package:get/get.dart';
import '../models/exercise_set.dart';

class ExerciseProgressController extends GetxController {
  static ExerciseProgressController get to => Get.find();
  
  // Estado observable para el progreso del ejercicio
  final exerciseProgress = <ExerciseProgress>[].obs;
  
  // Agregar progreso
  void setProgress(List<ExerciseProgress> progress) {
    exerciseProgress.value = progress;
  }
  
  // Agregar un nuevo ejercicio al progreso
  void addExerciseProgress(ExerciseProgress progress) {
    exerciseProgress.add(progress);
  }
  
  // Limpiar todo el progreso
  void clearProgress() {
    exerciseProgress.clear();
  }
  
  // Obtener el progreso actual
  List<ExerciseProgress> getProgress() {
    return exerciseProgress.toList();
  }
  
  // Verificar si hay progreso
  bool hasProgress() {
    return exerciseProgress.isNotEmpty;
  }
}
