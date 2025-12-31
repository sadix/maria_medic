import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class GlucoseScreen extends StatefulWidget {
  const GlucoseScreen({super.key});

  @override
  State<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends State<GlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await DatabaseHelper.instance.getAllGlucoseRecords();
    setState(() {
      _records = records;
    });
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      await DatabaseHelper.instance.insertGlucoseRecord({
        'level': double.parse(_levelController.text),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'notes': _notesController.text,
      });

      _levelController.clear();
      _notesController.clear();
      _loadRecords();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taux de Glycémie'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getGlucoseColor(record['level']),
                child: Text(
                  '${record['level']}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              title: Text('${record['level']} mg/dL'),
              subtitle: Text('${record['date']} à ${record['time']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await DatabaseHelper.instance.deleteGlucoseRecord(record['id']);
                  _loadRecords();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getGlucoseColor(double level) {
    if (level < 70) return Colors.blue;
    if (level < 140) return Colors.green;
    return Colors.red;
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau relevé'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _levelController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Taux (mg/dL)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un taux';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Heure'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() => _selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _saveRecord,
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _levelController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}