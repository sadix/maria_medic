import 'package:flutter/material.dart';
import 'glucose_screen.dart';
import 'medications_screen.dart';
import 'prescriptions_screen.dart';
import 'lab_results_screen.dart';

import 'temperature_screen.dart';
import 'blood_pressure_screen.dart';
import 'weight_screen.dart';
import '../services/export_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Santé'),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export') {
                await ExportService.exportAllData(context);
              } else if (value == 'import') {
                await ExportService.importData(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload_file),
                    SizedBox(width: 8),
                    Text('Exporter (Excel)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Importer (Excel)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuItem(
              context,
              'Glycémie',
              Icons.water_drop,
              Colors.red,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GlucoseScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Température',
              Icons.thermostat,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TemperatureScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Tension',
              Icons.favorite,
              Colors.pink,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BloodPressureScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Poids',
              Icons.monitor_weight,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeightScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Médicaments',
              Icons.medication,
              Colors.green,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicationsScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Ordonnances',
              Icons.description,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrescriptionsScreen()),
              ),
            ),
            _buildMenuItem(
              context,
              'Résultats Analyses',
              Icons.analytics,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LabResultsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}