import 'package:hive/hive.dart';

part 'exercise_set.g.dart';

@HiveType(typeId: 4)
class ExerciseSet {
  @HiveField(0)
  final int setNumber;
  
  @HiveField(1)
  final int repetitions;
  
  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final double? weight;

  @HiveField(4)
  final String? weightUnit; // 'kg' or 'lbs'

  ExerciseSet({
    required this.setNumber,
    required this.repetitions,
    required this.timestamp,
    this.weight,
    this.weightUnit,
  });

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'repetitions': repetitions,
    'timestamp': timestamp.toIso8601String(),
    'weight': weight,
    'weightUnit': weightUnit,
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    setNumber: json['setNumber'],
    repetitions: json['repetitions'],
    timestamp: DateTime.parse(json['timestamp']),
    weight: json['weight'],
    weightUnit: json['weightUnit'],
  );
}

@HiveType(typeId: 5)
class ExerciseProgress {
  @HiveField(0)
  final String exerciseName;
  
  @HiveField(1)
  final List<ExerciseSet> sets;
  
  @HiveField(2)
  bool isCompleted;
  
  @HiveField(3)
  int targetSets;

  ExerciseProgress({
    required this.exerciseName,
    List<ExerciseSet>? sets,
    this.isCompleted = false,
    this.targetSets = 3,
  }) : sets = sets ?? [];

  void addSet(int repetitions, {double? weight, String? weightUnit}) {
    sets.add(ExerciseSet(
      setNumber: sets.length + 1,
      repetitions: repetitions,
      timestamp: DateTime.now(),
      weight: weight,
      weightUnit: weightUnit,
    ));
    isCompleted = sets.length >= targetSets;
  }

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'sets': sets.map((set) => set.toJson()).toList(),
    'isCompleted': isCompleted,
    'targetSets': targetSets,
  };

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) => ExerciseProgress(
    exerciseName: json['exerciseName'],
    sets: (json['sets'] as List<dynamic>)
        .map((set) => ExerciseSet.fromJson(set))
        .toList(),
    isCompleted: json['isCompleted'],
    targetSets: json['targetSets'],
  );
}

@HiveType(typeId: 5)
class ExerciseSession {
  @HiveField(0)
  final String trainingId;
  
  @HiveField(1)
  final List<ExerciseProgress> exerciseProgress;
  
  ExerciseSession({
    required this.trainingId,
    List<ExerciseProgress>? exerciseProgress,
  }) : exerciseProgress = exerciseProgress ?? [];

  Map<String, dynamic> toJson() => {
    'trainingId': trainingId,
    'exerciseProgress': exerciseProgress.map((progress) => progress.toJson()).toList(),
  };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) => ExerciseSession(
    trainingId: json['trainingId'],
    exerciseProgress: (json['exerciseProgress'] as List<dynamic>)
        .map((progress) => ExerciseProgress.fromJson(progress))
        .toList(),
  );
} 