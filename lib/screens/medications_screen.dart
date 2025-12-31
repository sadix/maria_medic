import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final medications = await DatabaseHelper.instance.getAllMedications();
    setState(() {
      _medications = medications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Médicaments'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          final med = _medications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: med['photo_path'] != null
                  ? CircleAvatar(
                      backgroundImage: FileImage(File(med['photo_path'])),
                    )
                  : const CircleAvatar(
                      child: Icon(Icons.medication),
                    ),
              title: Text(med['name']),
              subtitle: Text(
                '${med['dosage']} - ${med['frequency']}\n${med['pills_per_dose']} cachet(s) par prise',
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteMedication(med['id']);
                  _loadMedications();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMedicationDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    final pillsController = TextEditingController(text: '1');
    String? photoPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nouveau médicament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (photoPath != null)
                  Image.file(File(photoPath!), height: 100),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setDialogState(() => photoPath = image.path);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Photo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du médicament',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Fréquence',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pillsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de cachets par prise',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertMedication({
                    'name': nameController.text,
                    'dosage': dosageController.text,
                    'frequency': frequencyController.text,
                    'photo_path': photoPath,
                    'pills_per_dose': int.parse(pillsController.text),
                  });
                  _loadMedications();
                  Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}