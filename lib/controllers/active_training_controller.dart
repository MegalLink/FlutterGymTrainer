import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/training.dart';
import '../models/exercise_set.dart';
import '../services/database_service.dart';
import './exercise_progress_controller.dart';

class ActiveTrainingController extends GetxController {
  final Training training;
  final DatabaseService databaseService;
  
  // Variables observables
  final RxInt currentRestTime = 0.obs;
  final RxBool isResting = false.obs;
  final RxBool isExpanded = false.obs;
  Timer? restTimer;
  final RxInt defaultRestTime = 60.obs;
  final RxBool isSaving = false.obs;
  final RxBool autoStartTimer = false.obs;
  
  // Map to store weight controllers for each exercise
  final Map<String, TextEditingController> weightControllers = {};
  // Map to store weight units for each exercise
  final Map<String, String> weightUnits = {};

  // Controlador para el progreso del ejercicio
  late final ExerciseProgressController _progressController;

  ActiveTrainingController(this.training) : databaseService = Get.find<DatabaseService>() {
    _progressController = Get.find<ExerciseProgressController>();
    if (!_progressController.hasProgress()) {
      _initializeProgress();
    }
  }

  Future<void> _initializeProgress() async {
    // Inicializar el progreso para cada ejercicio
    for (var exerciseId in training.exerciseIds) {
      final exercise = await databaseService.getExerciseById(exerciseId);
      _progressController.addExerciseProgress(
        ExerciseProgress(exerciseName: exercise.name)
      );
    }
  }

  List<ExerciseProgress> get exerciseProgress => _progressController.getProgress();

  TextEditingController getWeightController(ExerciseProgress progress) {
    if (!weightControllers.containsKey(progress.exerciseName)) {
      weightControllers[progress.exerciseName] = TextEditingController();
    }
    return weightControllers[progress.exerciseName]!;
  }

  String getWeightUnit(ExerciseProgress progress) {
    return weightUnits[progress.exerciseName] ?? 'kg';
  }

  void setWeightUnit(ExerciseProgress progress, String unit) {
    weightUnits[progress.exerciseName] = unit;
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
    final progress = _progressController.getProgress().firstWhere(
      (p) => p.exerciseName == exerciseName,
    );

    final setNumber = progress.sets.length + 1;
    final weightController = weightControllers[exerciseName];
    final weightUnit = weightUnits[exerciseName] ?? 'kg';

    double? weight;
    if (weightController != null && weightController.text.isNotEmpty) {
      weight = double.tryParse(weightController.text);
      // Clear the weight controller after adding the set
      weightController.clear();
    }

    final newSet = ExerciseSet(
      setNumber: setNumber,
      repetitions: repetitions,
      timestamp: DateTime.now(),
      weight: weight,
      weightUnit: weightUnit,
    );

    progress.sets.add(newSet);
    _progressController.setProgress(_progressController.getProgress());
    
    // Start rest timer automatically if enabled
    if (autoStartTimer.value) {
      startRest();
    }
  }

  void markExerciseAsCompleted(String exerciseName) {
    final progress = _progressController.getProgress().firstWhere(
      (p) => p.exerciseName == exerciseName,
    );
    progress.isCompleted = true;
    _progressController.setProgress(_progressController.getProgress());
  }

  void updateTargetSets(String exerciseName, int change) {
    final progress = _progressController.getProgress().firstWhere((p) => p.exerciseName == exerciseName);
    final newTarget = progress.targetSets + change;
    if (newTarget >= 1) {  // Asegurar que no sea menor a 1
      progress.targetSets = newTarget;
      _progressController.setProgress(_progressController.getProgress());
    }
  }

  void removeSet(String exerciseName, int setNumber) {
    final progress = _progressController.getProgress().firstWhere((p) => p.exerciseName == exerciseName);
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
    _progressController.setProgress(_progressController.getProgress());
  }

  bool isTrainingCompleted() {
    return _progressController.getProgress().every((p) => p.isCompleted);
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
      
      final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Guardar en la base de datos
      await databaseService.saveActiveTrainingProgress(
        uniqueId,
        _progressController.getProgress(),
      );

      // Reiniciar el estado
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
    _progressController.clearProgress();
    
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
    weightControllers.forEach((_, controller) => controller.dispose());
    restTimer?.cancel();
    super.onClose();
  }
}
