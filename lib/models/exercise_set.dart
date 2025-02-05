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

  ExerciseSet({
    required this.setNumber,
    required this.repetitions,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'setNumber': setNumber,
    'repetitions': repetitions,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => ExerciseSet(
    setNumber: json['setNumber'],
    repetitions: json['repetitions'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

@HiveType(typeId: 5)
class ExerciseProgress {
  @HiveField(0)
  final String exerciseId;
  
  @HiveField(1)
  final List<ExerciseSet> sets;
  
  @HiveField(2)
  bool isCompleted;
  
  @HiveField(3)
  int targetSets;

  ExerciseProgress({
    required this.exerciseId,
    List<ExerciseSet>? sets,
    this.isCompleted = false,
    this.targetSets = 3, 
  }) : sets = sets ?? [];

  void addSet(int repetitions) {
    sets.add(
      ExerciseSet(
        setNumber: sets.length + 1,
        repetitions: repetitions,
        timestamp: DateTime.now(),
      ),
    );
    if (sets.length >= targetSets) {
      isCompleted = true;
    }
  }

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'sets': sets.map((set) => set.toJson()).toList(),
    'isCompleted': isCompleted,
    'targetSets': targetSets,
  };

  factory ExerciseProgress.fromJson(Map<String, dynamic> json) => ExerciseProgress(
    exerciseId: json['exerciseId'],
    sets: (json['sets'] as List).map((set) => ExerciseSet.fromJson(set)).toList(),
    isCompleted: json['isCompleted'],
    targetSets: json['targetSets'],
  );
}
