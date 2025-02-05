import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/training.dart';

class DatabaseService {
  static const String exercisesBoxName = 'exercises';
  static const String trainingsBoxName = 'trainings';
  
  Future<void> initDatabase() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExerciseAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TrainingAdapter());
    }
    
    // Open boxes
    await Hive.openBox<Exercise>(exercisesBoxName);
    await Hive.openBox<Training>(trainingsBoxName);
  }

  // Exercise methods
  Future<List<Exercise>> getExercises() async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    return box.values.toList();
  }

  Future<void> insertExercise(Exercise exercise) async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    await box.put(exercise.id, exercise);
  }

  Future<void> updateExercise(Exercise exercise) async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    await box.put(exercise.id, exercise);
  }

  Future<void> deleteExercise(String id) async {
    final box = Hive.box<Exercise>(exercisesBoxName);
    await box.delete(id);
  }

  // Training methods
  Future<List<Training>> getTrainings() async {
    final box = Hive.box<Training>(trainingsBoxName);
    return box.values.toList();
  }

  Future<void> insertTraining(Training training) async {
    final box = Hive.box<Training>(trainingsBoxName);
    await box.put(training.id, training);
  }

  Future<void> updateTraining(Training training) async {
    final box = Hive.box<Training>(trainingsBoxName);
    await box.put(training.id, training);
  }

  Future<void> deleteTraining(String id) async {
    final box = Hive.box<Training>(trainingsBoxName);
    await box.delete(id);
  }

  // Cleanup
  Future<void> closeBoxes() async {
    await Hive.close();
  }
}
