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
  final RxBool autoStartTimer = false.obs;
  
  // Map to store weight controllers for each exercise
  final Map<String, TextEditingController> weightControllers = {};
  // Map to store weight units for each exercise
  final Map<String, String> weightUnits = {};

  ActiveTrainingController(this.training) : databaseService = Get.find<DatabaseService>() {
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    // Inicializar el progreso para cada ejercicio
    for (var exerciseId in training.exerciseIds) {
      final exercise = await databaseService.getExerciseById(exerciseId);
   
        exerciseProgress.add(ExerciseProgress(exerciseName: exercise.name));
      
    }
  }

  TextEditingController getWeightController(ExerciseProgress progress) {
    if (!weightControllers.containsKey(progress.exerciseName)) {
      weightControllers[progress.exerciseName] = TextEditingController();
    }
    return weightControllers[progress.exerciseName]!;
  }

  String getWeightUnit(ExerciseProgress progress) {
    final exerciseName = progress.exerciseName;
    if (!weightUnits.containsKey(exerciseName)) {
      weightUnits[exerciseName] = 'kg';
    }
    return weightUnits[exerciseName]!;
  }

  void setWeightUnit(ExerciseProgress progress, String unit) {
    final exerciseName = progress.exerciseName;
    weightUnits[exerciseName] = unit;
    update();
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

  void addSetToExercise(String exerciseName, int repetitions) {
    final progress = exerciseProgress.firstWhere(
      (p) => p.exerciseName == exerciseName,
    );
    
    double? weight;
    String? weightUnit;
    
    final weightText = weightControllers[exerciseName]?.text;
    if (weightText != null && weightText.isNotEmpty) {
      weight = double.tryParse(weightText);
      weightUnit = weightUnits[exerciseName];
    }
    
    progress.addSet(
      repetitions,
      weight: weight,
      weightUnit: weightUnit,
    );
    
    exerciseProgress.refresh();
    
    // Start rest timer automatically if enabled
    if (autoStartTimer.value) {
      startRest();
    }
  }

  void markExerciseAsCompleted(String exerciseName) {
    final progress = exerciseProgress.firstWhere(
      (p) => p.exerciseName == exerciseName,
    );
    progress.isCompleted = true;
    exerciseProgress.refresh();
  }

  void updateTargetSets(String exerciseName, int change) {
    final progress = exerciseProgress.firstWhere((p) => p.exerciseName == exerciseName);
    final newTarget = progress.targetSets + change;
    if (newTarget >= 1) {  // Asegurar que no sea menor a 1
      progress.targetSets = newTarget;
      exerciseProgress.refresh();
    }
  }

  void removeSet(String exerciseName, int setNumber) {
    final progress = exerciseProgress.firstWhere((p) => p.exerciseName == exerciseName);
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
      
      // Convertir el progreso actual a formato JSON
      final progressJson = exerciseProgress.map((progress) => progress.toJson()).toList();
      final uniqueId =  DateTime.now().millisecondsSinceEpoch.toString();
      // Guardar en la base de datos
      await databaseService.saveActiveTrainingProgress(
        uniqueId,
        { 'progress': progressJson},
      );

      // Reiniciar el estado del entrenamiento
      await _resetTrainingState();

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

  Future<void> _resetTrainingState() async {
    // Limpiar el progreso actual
    exerciseProgress.clear();
    
    // Reiniciar los controladores de peso y unidades
    weightControllers.forEach((_, controller) => controller.clear());
    weightUnits.clear();
    
    // Reiniciar el temporizador y estados
    stopRest();
    isExpanded.value = false;
    
    // Inicializar nuevo progreso
    await _initializeProgress();
  }

  @override
  void onClose() {
    restTimer?.cancel();
    super.onClose();
  }
}
