import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Hive Data'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Entrenamiento Activo'),
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
    return FutureBuilder(
      future: _databaseService.getActiveTrainingData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final activeTrainingData = snapshot.data as Map<dynamic, dynamic>;
        
        if (activeTrainingData.isEmpty) {
          return const Center(child: Text('No hay entrenamiento activo guardado'));
        }

        return ListView.builder(
          itemCount: activeTrainingData.length,
          itemBuilder: (context, index) {
            final key = activeTrainingData.keys.elementAt(index);
            final value = activeTrainingData[key];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text('Training ID: $key'),
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
                                  await _databaseService.deleteActiveTrainingProgress(key.toString());
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
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      value.toString(),
                      style: const TextStyle(fontFamily: 'monospace'),
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
