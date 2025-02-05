import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/exercise_set.dart';
import '../models/training.dart';
import '../services/database_service.dart';

class ActiveTrainingController extends GetxController {
  final Training training;
  final DatabaseService databaseService;
  final RxList<ExerciseProgress> exerciseProgress = <ExerciseProgress>[].obs;
  final RxInt currentRestTime = 0.obs;
  final RxBool isResting = false.obs;
  final RxBool isExpanded = false.obs;
  Timer? restTimer;
  final RxInt defaultRestTime = 60.obs; // Tiempo de descanso por defecto en segundos
  final RxBool isSaving = false.obs;

  ActiveTrainingController(this.training) : databaseService = Get.find<DatabaseService>() {
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final savedProgress = await databaseService.getActiveTrainingProgress(training.id);
    
    if (savedProgress != null) {
      exerciseProgress.clear();
      final List<dynamic> progressList = savedProgress['progress'];
      exerciseProgress.addAll(
        progressList.map((json) => ExerciseProgress.fromJson(json)).toList()
      );
    } else {
      // Inicializar el progreso para cada ejercicio si no hay datos guardados
      for (var exerciseId in training.exerciseIds) {
        exerciseProgress.add(ExerciseProgress(exerciseId: exerciseId));
      }
    }
  }

  void startRest([int? customTime]) {
    isResting.value = true;
    currentRestTime.value = customTime ?? defaultRestTime.value;
    _startTimer();
  }

  void stopRest() {
    isResting.value = false;
    currentRestTime.value = 0;
  }

  void setDefaultRestTime(int seconds) {
    if (seconds > 0) {
      defaultRestTime.value = seconds;
    }
  }

  void addSetToExercise(String exerciseId, int repetitions) {
    final progress = exerciseProgress.firstWhere(
      (p) => p.exerciseId == exerciseId,
    );
    progress.addSet(repetitions);
    exerciseProgress.refresh();
  }

  void markExerciseAsCompleted(String exerciseId) {
    final progress = exerciseProgress.firstWhere(
      (p) => p.exerciseId == exerciseId,
    );
    progress.isCompleted = true;
    exerciseProgress.refresh();
  }

  void updateTargetSets(String exerciseId, int change) {
    final progress = exerciseProgress.firstWhere((p) => p.exerciseId == exerciseId);
    final newTarget = progress.targetSets + change;
    if (newTarget >= 1) {  // Asegurar que no sea menor a 1
      progress.targetSets = newTarget;
      exerciseProgress.refresh();
    }
  }

  void removeSet(String exerciseId, int setNumber) {
    final progress = exerciseProgress.firstWhere((p) => p.exerciseId == exerciseId);
    progress.sets.removeWhere((set) => set.setNumber == setNumber);
    // Reordenar los números de serie
    for (var i = 0; i < progress.sets.length; i++) {
      progress.sets[i] = ExerciseSet(
        setNumber: i + 1,
        repetitions: progress.sets[i].repetitions,
        timestamp: progress.sets[i].timestamp,
      );
    }
    // Actualizar el estado de completado
    progress.isCompleted = progress.sets.length >= progress.targetSets;
    exerciseProgress.refresh();
  }

  bool isTrainingCompleted() {
    return exerciseProgress.every((p) => p.isCompleted);
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!isResting.value || currentRestTime.value <= 0) {
        if (currentRestTime.value <= 0) {
          isResting.value = false;
        }
        return false;
      }
      await Future.delayed(const Duration(seconds: 1));
      currentRestTime.value--;
      return true;
    });
  }

  Future<void> saveTrainingSession() async {
    try {
      isSaving.value = true;
      
      await databaseService.saveActiveTrainingProgress(training.id, {
        'progress': exerciseProgress.map((progress) => progress.toJson()).toList(),
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        'Éxito',
        'Sesión de entrenamiento guardada correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la sesión de entrenamiento: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    restTimer?.cancel();
    super.onClose();
  }
}
