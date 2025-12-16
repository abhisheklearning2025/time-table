import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for local storage
/// Handles timetables, activities, and settings
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timetable.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Enable foreign key constraints
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Timetables table
    await db.execute('''
      CREATE TABLE timetables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        emoji TEXT,
        type TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        alerts_enabled INTEGER NOT NULL DEFAULT 0,
        owner_id TEXT,
        share_code TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_public INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Activities table
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        timetable_id TEXT NOT NULL,
        time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        start_minutes INTEGER NOT NULL,
        end_minutes INTEGER NOT NULL,
        duration TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category_id TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_next_day INTEGER NOT NULL DEFAULT 0,
        custom_audio_path TEXT,
        FOREIGN KEY (timetable_id) REFERENCES timetables (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_activities_timetable
      ON activities(timetable_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_timetables_type
      ON timetables(type)
    ''');

    await db.execute('''
      CREATE INDEX idx_timetables_active
      ON timetables(is_active)
    ''');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (for testing/debugging)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('activities');
    await db.delete('timetables');
    await db.delete('settings');
  }

  /// Delete database (for testing/debugging)
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timetable.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
