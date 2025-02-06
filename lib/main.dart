import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/exercise_set.dart';
import 'pages/index.dart';
import 'controllers/exercise_controller.dart';
import 'controllers/training_controller.dart';
import 'services/database_service.dart';
import 'controllers/exercise_progress_controller.dart'; // Updated import statement

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service
  final databaseService = DatabaseService();
  await databaseService.initDatabase();
  
  // Register database service with GetX
  Get.put<DatabaseService>(databaseService);
  Get.put(ExerciseProgressController()); // Updated ExerciseProgressController initialization

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters for active training
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ExerciseSetAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ExerciseProgressAdapter());
  }
  
  // Initialize controllers
  Get.put(ExerciseController());
  Get.put(TrainingController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gym Trainer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 7, 41, 233)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: [
            TrainPage(),
            ManageTrainingPage(),
            StatisticsPage(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.changeIndex(index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.fitness_center),
              label: 'Entrenar',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note),
              label: 'Gestionar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart),
              label: 'Estadísticas',
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
