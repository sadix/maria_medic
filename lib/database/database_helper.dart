import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE glucose_records (
        id $idType,
        level $realType,
        date $textType,
        time $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE medications (
        id $idType,
        name $textType,
        dosage $textType,
        frequency $textType,
        photo_path TEXT,
        pills_per_dose $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE medication_intakes (
        id $idType,
        medication_id $intType,
        date $textType,
        time $textType,
        taken INTEGER NOT NULL,
        FOREIGN KEY (medication_id) REFERENCES medications (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE prescriptions (
        id $idType,
        scan_path $textType,
        date $textType,
        doctor_name TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE lab_results (
        id $idType,
        test_name $textType,
        result_value TEXT,
        date $textType,
        scan_path TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE temperature_records (
        id $idType,
        temperature $realType,
        date $textType,
        time $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE blood_pressure_records (
        id $idType,
        systolic $intType,
        diastolic $intType,
        pulse $intType,
        date $textType,
        time $textType,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE weight_records (
        id $idType,
        weight $realType,
        date $textType,
        time $textType,
        notes TEXT
      )
    ''');
  }

  // Glucose Records
  Future<int> insertGlucoseRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('glucose_records', row);
  }

  Future<List<Map<String, dynamic>>> getAllGlucoseRecords() async {
    final db = await instance.database;
    return await db.query('glucose_records', orderBy: 'date DESC, time DESC');
  }

  // Medications
  Future<int> insertMedication(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('medications', row);
  }

  Future<List<Map<String, dynamic>>> getAllMedications() async {
    final db = await instance.database;
    return await db.query('medications');
  }

  // Medication Intakes
  Future<int> insertMedicationIntake(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('medication_intakes', row);
  }

  Future<List<Map<String, dynamic>>> getMedicationIntakes(int medicationId) async {
    final db = await instance.database;
    return await db.query(
      'medication_intakes',
      where: 'medication_id = ?',
      whereArgs: [medicationId],
      orderBy: 'date DESC, time DESC',
    );
  }

  // Prescriptions
  Future<int> insertPrescription(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('prescriptions', row);
  }

  Future<List<Map<String, dynamic>>> getAllPrescriptions() async {
    final db = await instance.database;
    return await db.query('prescriptions', orderBy: 'date DESC');
  }

  // Lab Results
  Future<int> insertLabResult(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('lab_results', row);
  }

  Future<List<Map<String, dynamic>>> getAllLabResults() async {
    final db = await instance.database;
    return await db.query('lab_results', orderBy: 'date DESC');
  }

  Future<void> deleteGlucoseRecord(int id) async {
    final db = await instance.database;
    await db.delete('glucose_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMedication(int id) async {
    final db = await instance.database;
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }



  // Temperature Records
  Future<int> insertTemperatureRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('temperature_records', row);
  }

  Future<List<Map<String, dynamic>>> getAllTemperatureRecords() async {
    final db = await instance.database;
    return await db.query('temperature_records', orderBy: 'date DESC, time DESC');
  }

  Future<void> deleteTemperatureRecord(int id) async {
    final db = await instance.database;
    await db.delete('temperature_records', where: 'id = ?', whereArgs: [id]);
  }

  // Blood Pressure Records
  Future<int> insertBloodPressureRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('blood_pressure_records', row);
  }

  Future<List<Map<String, dynamic>>> getAllBloodPressureRecords() async {
    final db = await instance.database;
    return await db.query('blood_pressure_records', orderBy: 'date DESC, time DESC');
  }

  Future<void> deleteBloodPressureRecord(int id) async {
    final db = await instance.database;
    await db.delete('blood_pressure_records', where: 'id = ?', whereArgs: [id]);
  }

  // Weight Records
  Future<int> insertWeightRecord(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('weight_records', row);
  }

  Future<List<Map<String, dynamic>>> getAllWeightRecords() async {
    final db = await instance.database;
    return await db.query('weight_records', orderBy: 'date DESC, time DESC');
  }

  Future<void> deleteWeightRecord(int id) async {
    final db = await instance.database;
    await db.delete('weight_records', where: 'id = ?', whereArgs: [id]);
  }
}
