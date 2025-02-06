import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/training.dart';
import '../models/exercise_set.dart';

class DatabaseService {
  static const String exercisesBoxName = 'exercises';
  static const String trainingsBoxName = 'trainings';
  static const String activeTrainingBoxName = 'active_training';
  
  Future<void> initDatabase() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TrainingAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ExerciseSetAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ExerciseSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ExerciseProgressAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Exercise>(exercisesBoxName);
    await Hive.openBox<Training>(trainingsBoxName);
    await Hive.openBox<ExerciseSession>(activeTrainingBoxName);
  }

  // Exercise methods
  Box<Exercise> getExercisesBox() {
    return Hive.box<Exercise>(exercisesBoxName);
  }

  Future<List<Exercise>> getExercises() async {
    final box = getExercisesBox();
    return box.values.toList();
  }

  Future<Exercise> getExerciseById(String id) async {
    final box = getExercisesBox();
    
    return box.values.toList().firstWhere((exercise) => exercise.id == id);
  }

  Future<void> insertExercise(Exercise exercise) async {
    final box = getExercisesBox();
    await box.put(exercise.id, exercise);
  }

  Future<void> updateExercise(Exercise exercise) async {
    final box = getExercisesBox();
    await box.put(exercise.id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    final box = getExercisesBox();
    await box.delete(id);
  }

  // Training methods
  Box<Training> getTrainingsBox() {
    return Hive.box<Training>(trainingsBoxName);
  }

  Future<List<Training>> getTrainings() async {
    final box = getTrainingsBox();
    return box.values.toList();
  }

  Future<void> insertTraining(Training training) async {
    final box = getTrainingsBox();
    await box.put(training.id, training);
  }

  Future<void> updateTraining(Training training) async {
    final box = getTrainingsBox();
    await box.put(training.id, training);
  }

  Future<void> deleteTraining(String id) async {
    final box = getTrainingsBox();
    await box.delete(id);
  }

  // Active Training methods
  Box<ExerciseSession> getActiveTrainingBox() {
    return Hive.box<ExerciseSession>(activeTrainingBoxName);
  }

  Future<void> saveActiveTrainingProgress(String trainingId, List<ExerciseProgress> progress) async {
    final box = getActiveTrainingBox();
    final session = ExerciseSession(
      trainingId: trainingId,
      exerciseProgress: progress,
    );
    await box.put(trainingId, session);
  }

  Future<ExerciseSession?> getActiveTrainingProgress(String trainingId) async {
    final box = getActiveTrainingBox();
    return box.get(trainingId);
  }

  Future<List<ExerciseSession>> getAllActiveTrainingSessions() async {
    final box = getActiveTrainingBox();
    return box.values.toList();
  }

  Future<void> deleteActiveTrainingSession(String trainingId) async {
    final box = getActiveTrainingBox();
    await box.delete(trainingId);
  }

  Future<void> deleteAllActiveTrainingSessions() async {
    final box = getActiveTrainingBox();
    await box.clear();
  }

  // Cleanup
  Future<void> closeBoxes() async {
    await Hive.close();
  }
}
