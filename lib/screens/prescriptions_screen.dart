import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../database/database_helper.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  List<Map<String, dynamic>> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    final prescriptions = await DatabaseHelper.instance.getAllPrescriptions();
    setState(() {
      _prescriptions = prescriptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordonnances'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = _prescriptions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.description, size: 40),
              title: Text(prescription['doctor_name'] ?? 'Ordonnance'),
              subtitle: Text(prescription['date']),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                if (prescription['scan_path'] != null) {
                  _showScanDialog(prescription['scan_path']);
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPrescription(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addPrescription() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      final doctorController = TextEditingController();
      final notesController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nouvelle ordonnance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: doctorController,
                decoration: const InputDecoration(
                  labelText: 'Nom du médecin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.insertPrescription({
                  'scan_path': result.files.single.path,
                  'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'doctor_name': doctorController.text,
                  'notes': notesController.text,
                });
                _loadPrescriptions();
                Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      );
    }
  }

  void _showScanDialog(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (path.endsWith('.pdf'))
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Icon(Icons.picture_as_pdf, size: 100),
              )
            else
              Image.file(File(path)),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}