import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class LabResultsScreen extends StatefulWidget {
  const LabResultsScreen({super.key});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    final results = await DatabaseHelper.instance.getAllLabResults();
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats d\'Analyses'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final result = _results[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.analytics, size: 40),
              title: Text(result['test_name']),
              subtitle: Text(
                'Résultat: ${result['result_value']}\nDate: ${result['date']}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddResultDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddResultDialog() {
    final testNameController = TextEditingController();
    final resultValueController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau résultat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: testNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'analyse',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resultValueController,
                decoration: const InputDecoration(
                  labelText: 'Résultat',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (testNameController.text.isNotEmpty) {
                await DatabaseHelper.instance.insertLabResult({
                  'test_name': testNameController.text,
                  'result_value': resultValueController.text,
                  'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  'notes': notesController.text,
                });
                _loadResults();
                Navigator.pop(context);
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}