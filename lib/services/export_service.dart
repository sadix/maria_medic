import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';

class ExportService {
  static Future<void> exportAllData(BuildContext context) async {
    try {
      final excel = Excel.createExcel();

      // Export Glucose Records
      final glucoseRecords = await DatabaseHelper.instance.getAllGlucoseRecords();
      final glucoseSheet = excel['Glycémie'];
      glucoseSheet.appendRow([TextCellValue('Date'), TextCellValue('Heure'), TextCellValue('Taux (mg/dL)'), TextCellValue('Notes')]);
      for (var record in glucoseRecords) {
        glucoseSheet.appendRow([
          TextCellValue(record['date'] ?? ''),
          TextCellValue(record['time'] ?? ''),
          DoubleCellValue(record['level']),
          TextCellValue(record['notes'] ?? ''),
        ]);
      }

      // Export Temperature Records
      final tempRecords = await DatabaseHelper.instance.getAllTemperatureRecords();
      final tempSheet = excel['Température'];
      tempSheet.appendRow([TextCellValue('Date'), TextCellValue('Heure'), TextCellValue('Température (°C)'), TextCellValue('Notes')]);
      for (var record in tempRecords) {
        tempSheet.appendRow([
          TextCellValue(record['date'] ?? ''),
          TextCellValue(record['time'] ?? ''),
          DoubleCellValue(record['temperature']),
          TextCellValue(record['notes'] ?? ''),
        ]);
      }

      // Export Blood Pressure Records
      final bpRecords = await DatabaseHelper.instance.getAllBloodPressureRecords();
      final bpSheet = excel['Tension'];
      bpSheet.appendRow([TextCellValue('Date'), TextCellValue('Heure'), TextCellValue('Systolique'), TextCellValue('Diastolique'), TextCellValue('Pouls'), TextCellValue('Notes')]);
      for (var record in bpRecords) {
        bpSheet.appendRow([
          TextCellValue(record['date'] ?? ''),
          TextCellValue(record['time'] ?? ''),
          IntCellValue(record['systolic']),
          IntCellValue(record['diastolic']),
          IntCellValue(record['pulse']),
          TextCellValue(record['notes'] ?? ''),
        ]);
      }

      // Export Weight Records
      final weightRecords = await DatabaseHelper.instance.getAllWeightRecords();
      final weightSheet = excel['Poids'];
      weightSheet.appendRow([TextCellValue('Date'), TextCellValue('Heure'), TextCellValue('Poids (kg)'), TextCellValue('Notes')]);
      for (var record in weightRecords) {
        weightSheet.appendRow([
          TextCellValue(record['date'] ?? ''),
          TextCellValue(record['time'] ?? ''),
          DoubleCellValue(record['weight']),
          TextCellValue(record['notes'] ?? ''),
        ]);
      }

      // Export Medications
      final medications = await DatabaseHelper.instance.getAllMedications();
      final medSheet = excel['Médicaments'];
      medSheet.appendRow([TextCellValue('Nom'), TextCellValue('Dosage'), TextCellValue('Fréquence'), TextCellValue('Cachets/prise')]);
      for (var med in medications) {
        medSheet.appendRow([
          TextCellValue(med['name'] ?? ''),
          TextCellValue(med['dosage'] ?? ''),
          TextCellValue(med['frequency'] ?? ''),
          IntCellValue(med['pills_per_dose']),
        ]);
      }

      // Export Lab Results
      final labResults = await DatabaseHelper.instance.getAllLabResults();
      final labSheet = excel['Résultats Analyses'];
      labSheet.appendRow([TextCellValue('Date'), TextCellValue('Analyse'), TextCellValue('Résultat'), TextCellValue('Notes')]);
      for (var result in labResults) {
        labSheet.appendRow([
          TextCellValue(result['date'] ?? ''),
          TextCellValue(result['test_name'] ?? ''),
          TextCellValue(result['result_value'] ?? ''),
          TextCellValue(result['notes'] ?? ''),
        ]);
      }

      excel.delete('Sheet1');

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/donnees_sante_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final file = File(filePath);
      final fileBytes = excel.save();
      await file.writeAsBytes(fileBytes!);

      // Share file
      await Share.shareXFiles([XFile(filePath)], text: 'Données de santé exportées');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données exportées avec succès!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    }
  }

  static Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);

        // Import Glucose Records
        if (excel.tables.containsKey('Glycémie')) {
          final sheet = excel.tables['Glycémie']!;
          for (var i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];
            if (row.length >= 3) {
              await DatabaseHelper.instance.insertGlucoseRecord({
                'date': row[0]?.value.toString() ?? '',
                'time': row[1]?.value.toString() ?? '',
                'level': double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
                'notes': row.length > 3 ? row[3]?.value.toString() ?? '' : '',
              });
            }
          }
        }

        // Import Temperature Records
        if (excel.tables.containsKey('Température')) {
          final sheet = excel.tables['Température']!;
          for (var i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];
            if (row.length >= 3) {
              await DatabaseHelper.instance.insertTemperatureRecord({
                'date': row[0]?.value.toString() ?? '',
                'time': row[1]?.value.toString() ?? '',
                'temperature': double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
                'notes': row.length > 3 ? row[3]?.value.toString() ?? '' : '',
              });
            }
          }
        }

        // Import Blood Pressure Records
        if (excel.tables.containsKey('Tension')) {
          final sheet = excel.tables['Tension']!;
          for (var i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];
            if (row.length >= 5) {
              await DatabaseHelper.instance.insertBloodPressureRecord({
                'date': row[0]?.value.toString() ?? '',
                'time': row[1]?.value.toString() ?? '',
                'systolic': int.tryParse(row[2]?.value.toString() ?? '0') ?? 0,
                'diastolic': int.tryParse(row[3]?.value.toString() ?? '0') ?? 0,
                'pulse': int.tryParse(row[4]?.value.toString() ?? '0') ?? 0,
                'notes': row.length > 5 ? row[5]?.value.toString() ?? '' : '',
              });
            }
          }
        }

        // Import Weight Records
        if (excel.tables.containsKey('Poids')) {
          final sheet = excel.tables['Poids']!;
          for (var i = 1; i < sheet.rows.length; i++) {
            final row = sheet.rows[i];
            if (row.length >= 3) {
              await DatabaseHelper.instance.insertWeightRecord({
                'date': row[0]?.value.toString() ?? '',
                'time': row[1]?.value.toString() ?? '',
                'weight': double.tryParse(row[2]?.value.toString() ?? '0') ?? 0.0,
                'notes': row.length > 3 ? row[3]?.value.toString() ?? '' : '',
              });
            }
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données importées avec succès!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'import: $e')),
        );
      }
    }
  }

  /* @override
  void dispose() {
    _levelController.dispose();
    _notesController.dispose();
    super.dispose();
  } */
}
