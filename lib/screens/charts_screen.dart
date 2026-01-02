// lib/screens/charts_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  List<Map<String, dynamic>> _glucoseData = [];
  List<Map<String, dynamic>> _tempData = [];
  List<Map<String, dynamic>> _bpData = [];
  List<Map<String, dynamic>> _weightData = [];
  
  int _selectedDays = 30;
  final List<int> _dayOptions = [7, 14, 30, 60, 90];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final glucose = await DatabaseHelper.instance.getAllGlucoseRecords();
    final temp = await DatabaseHelper.instance.getAllTemperatureRecords();
    final bp = await DatabaseHelper.instance.getAllBloodPressureRecords();
    final weight = await DatabaseHelper.instance.getAllWeightRecords();

    setState(() {
      _glucoseData = _filterByDays(glucose);
      _tempData = _filterByDays(temp);
      _bpData = _filterByDays(bp);
      _weightData = _filterByDays(weight);
    });
  }

  List<Map<String, dynamic>> _filterByDays(List<Map<String, dynamic>> data) {
    final cutoffDate = DateTime.now().subtract(Duration(days: _selectedDays));
    return data.where((record) {
      try {
        final date = DateFormat('yyyy-MM-dd').parse(record['date']);
        return date.isAfter(cutoffDate);
      } catch (e) {
        return false;
      }
    }).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphiques'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            initialValue: _selectedDays,
            onSelected: (value) {
              setState(() {
                _selectedDays = value;
                _loadAllData();
              });
            },
            itemBuilder: (context) => _dayOptions.map((days) {
              return PopupMenuItem(
                value: days,
                child: Text('$days jours'),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Glycémie (mg/dL)', Colors.red),
            _buildGlucoseChart(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Température (°C)', Colors.orange),
            _buildTemperatureChart(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Tension Artérielle (mmHg)', Colors.pink),
            _buildBloodPressureChart(),
            const SizedBox(height: 32),
            
            _buildSectionTitle('Poids (kg)', Colors.purple),
            _buildWeightChart(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlucoseChart() {
    if (_glucoseData.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = _glucoseData.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      return FlSpot(index.toDouble(), record['level'].toDouble());
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < _glucoseData.length) {
                        final date = DateFormat('dd/MM').format(
                          DateFormat('yyyy-MM-dd').parse(_glucoseData[value.toInt()]['date'])
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(date, style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.red.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} mg/dL',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureChart() {
    if (_tempData.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = _tempData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['temperature'].toDouble());
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < _tempData.length) {
                        final date = DateFormat('dd/MM').format(
                          DateFormat('yyyy-MM-dd').parse(_tempData[value.toInt()]['date'])
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(date, style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.orange,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.orange.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} °C',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart() {
    if (_bpData.isEmpty) {
      return _buildEmptyChart();
    }

    final systolicSpots = _bpData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['systolic'].toDouble());
    }).toList();

    final diastolicSpots = _bpData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['diastolic'].toDouble());
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Systolique', Colors.pink),
                const SizedBox(width: 16),
                _buildLegendItem('Diastolique', Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _bpData.length) {
                            final date = DateFormat('dd/MM').format(
                              DateFormat('yyyy-MM-dd').parse(_bpData[value.toInt()]['date'])
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(date, style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: systolicSpots,
                      isCurved: true,
                      color: Colors.pink,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: diastolicSpots,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final color = spot.bar.color;
                          final label = color == Colors.pink ? 'Sys' : 'Dia';
                          return LineTooltipItem(
                            '$label: ${spot.y.toInt()} mmHg',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    if (_weightData.isEmpty) {
      return _buildEmptyChart();
    }

    final spots = _weightData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['weight'].toDouble());
    }).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < _weightData.length) {
                        final date = DateFormat('dd/MM').format(
                          DateFormat('yyyy-MM-dd').parse(_weightData[value.toInt()]['date'])
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(date, style: const TextStyle(fontSize: 10)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.purple,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.purple.withOpacity(0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)} kg',
                        const TextStyle(color: Colors.white),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Card(
      elevation: 4,
      child: Container(
        height: 250,
        alignment: Alignment.center,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Aucune donnée disponible',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}