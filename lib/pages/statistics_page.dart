import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/exercise_set.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key
    
    });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Hive Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Historial de entrenamientos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveTrainingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrainingTab() {
    return FutureBuilder<List<ExerciseSession>>(
      future: _databaseService.getAllActiveTrainingSessions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final sessions = snapshot.data ?? [];
        
        if (sessions.isEmpty) {
          return const Center(child: Text('No hay entrenamientos guardados'));
        }

        return ListView.builder(
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text('Entrenamiento: ${session.trainingId}'),
                subtitle: Text('Ejercicios: ${session.exerciseProgress.length}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que quieres eliminar este progreso de entrenamiento?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _databaseService.deleteActiveTrainingSession(session.trainingId);
                                  Navigator.pop(context);
                                  setState(() {}); // Forzar la reconstrucción del widget
                                },
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: session.exerciseProgress.map((progress) {
                        // Calculate max weight for this exercise in this session
                        double? maxWeight;
                        String? maxWeightUnit;
                        for (var set in progress.sets) {
                          if (set.weight != null) {
                            if (maxWeight == null || set.weight! > maxWeight) {
                              maxWeight = set.weight;
                              maxWeightUnit = set.weightUnit;
                            }
                          }
                        }
                        if (progress.sets.isEmpty) {
                          return const Row();
                        }
                            
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    progress.exerciseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                if (maxWeight != null)
                                  Text(
                                    'Peso máximo: $maxWeight $maxWeightUnit',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                           
                            const SizedBox(height: 8),
                            ...progress.sets.map((set) => Padding(
                              padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                              child: Text(
                                'Serie #${set.setNumber}: Repeticiónes ${set.repetitions}, Peso ${set.weight} ${set.weightUnit}',
                                style: TextStyle(
                                  color: set.weight != null && maxWeight != null && set.weight == maxWeight 
                                    ? Colors.blue 
                                    : null,
                                ),
                              ),
                            )),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
