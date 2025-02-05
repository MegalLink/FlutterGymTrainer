import 'package:hive/hive.dart';

part 'training.g.dart';

@HiveType(typeId: 1)
class Training extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> exerciseIds;

  Training({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'exerciseIds': exerciseIds,
    };
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'],
      name: json['name'],
      exerciseIds: List<String>.from(json['exerciseIds']),
    );
  }
}
