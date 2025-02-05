import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/index.dart';
import 'controllers/exercise_controller.dart';
import 'controllers/training_controller.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initDatabase();

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
