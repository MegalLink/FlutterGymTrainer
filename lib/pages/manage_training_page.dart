import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/exercise_controller.dart';
import '../controllers/training_controller.dart';
import '../models/exercise.dart';
import '../models/training.dart';

class ManageTrainingPage extends StatelessWidget {
  const ManageTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestionar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Entrenamientos'),
              Tab(text: 'Ejercicios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TrainingSection(),
            _ExerciseSection(),
          ],
        ),
      ),
    );
  }
}

class _TrainingSection extends StatelessWidget {
  final _trainingNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final trainingController = Get.put(TrainingController());
    final exerciseController = Get.find<ExerciseController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _trainingNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del entrenamiento',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  if (_trainingNameController.text.isNotEmpty) {
                    trainingController.addTraining(_trainingNameController.text);
                    _trainingNameController.clear();
                  }
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: trainingController.trainings.length,
              itemBuilder: (context, index) {
                final training = trainingController.trainings[index];
                return Card(
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              // Edit training name
                              final TextEditingController editController = TextEditingController(text: training.name);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Editar nombre'),
                                  content: TextField(
                                    controller: editController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre del entrenamiento',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (editController.text.isNotEmpty) {
                                          trainingController.updateTrainingName(training.id, editController.text);
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: const Text('Guardar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Text(training.name),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Show edit dialog for training name
                            final TextEditingController editController = TextEditingController(text: training.name);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Editar nombre'),
                                content: TextField(
                                  controller: editController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre del entrenamiento',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (editController.text.isNotEmpty) {
                                        trainingController.updateTrainingName(training.id, editController.text);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Guardar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    children: [
                      ListTile(
                        title: const Text('Agregar ejercicio'),
                        trailing: const Icon(Icons.add),
                        onTap: () {
                          _showExerciseSelectionDialog(
                            context,
                            training,
                            exerciseController,
                            trainingController,
                          );
                        },
                      ),
                      ...training.exerciseIds.map((exerciseId) {
                        final exercise = exerciseController.exercises
                            .firstWhere((e) => e.id == exerciseId);
                        return ListTile(
                          leading: exercise.imageUrl != null
                              ? Image.file(
                                  File(exercise.imageUrl!),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fitness_center),
                          title: Text(exercise.name),
                          subtitle: Text(exercise.category),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  trainingController.removeExerciseFromTraining(training.id, exerciseId);
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  void _showExerciseSelectionDialog(
    BuildContext context,
    Training training,
    ExerciseController exerciseController,
    TrainingController trainingController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar ejercicio'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
            shrinkWrap: true,
            itemCount: exerciseController.exercises.length,
            itemBuilder: (context, index) {
              final exercise = exerciseController.exercises[index];
              final isSelected = training.exerciseIds.contains(exercise.id);
              return ListTile(
                leading: exercise.imageUrl != null
                    ? Image.file(
                        File(exercise.imageUrl!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.fitness_center),
                title: Text(exercise.name),
                subtitle: Text(exercise.category),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  if (!isSelected) {
                    trainingController.addExerciseToTraining(
                      training.id,
                      exercise.id,
                    );
                  }
                  Navigator.pop(context);
                },
              );
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSection extends StatefulWidget {
  @override
  _ExerciseSectionState createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends State<_ExerciseSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _selectedImage;
  Exercise? _editingExercise;

  final List<String> _categories = [
    'Pecho',
    'Espalda',
    'Piernas',
    'Gluteos',
    'Brazos',
    'Hombros',
    'Abdominales',
    'Cardio'
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExerciseController>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del ejercicio',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _categoryController.text.isEmpty ? null : _categoryController.text,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      _categoryController.text = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Imagen'),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Imagen seleccionada: ${_selectedImage!.path.split('/').last}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final exercise = Exercise(
                            id: _editingExercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            name: _nameController.text,
                            category: _categoryController.text,
                            imageUrl: _selectedImage?.path,
                          );
                          
                          if (_editingExercise != null) {
                            controller.updateExercise(exercise);
                            _editingExercise = null;
                          } else {
                            controller.addExercise(exercise);
                          }
                          
                          _nameController.clear();
                          _categoryController.clear();
                          setState(() {
                            _selectedImage = null;
                          });
                        }
                      },
                      child: Text(_editingExercise == null ? 'Agregar ejercicio' : 'Editar ejercicio'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = controller.exercises[index];
                  return Card(
                    child: ListTile(
                      leading: exercise.imageUrl != null
                          ? Image.file(
                              File(exercise.imageUrl!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fitness_center),
                      title: Text(exercise.name),
                      subtitle: Text(exercise.category),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _nameController.text = exercise.name;
                              _categoryController.text = exercise.category;
                              if (exercise.imageUrl != null) {
                                _selectedImage = File(exercise.imageUrl!);
                              }
                              _editingExercise = exercise;
                              // Scroll to top to show the form
                              Scrollable.ensureVisible(
                                _formKey.currentContext!,
                                duration: const Duration(milliseconds: 500),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.deleteExercise(exercise.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
