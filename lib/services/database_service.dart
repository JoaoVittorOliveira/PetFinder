import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/pet.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    // Inicializa o FFI apenas em ambientes desktop (não-web, não-mobile)
    if (kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'petfinder.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS pets');
          await db.execute('DROP TABLE IF EXISTS session');
          await _createTables(db, newVersion);
        }
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Tabela de Pets com a nova coluna userId
    await db.execute('''
      CREATE TABLE pets (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        contact TEXT NOT NULL,
        dummyImageUrl TEXT,
        datePosted TEXT NOT NULL,
        isFound INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Tabela para guardar quem está logado
    await db.execute('''
      CREATE TABLE session (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // --- MÉTODOS DE PETS ---
  Future<void> savePets(List<Pet> pets) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('pets');
      for (final pet in pets) {
        await txn.insert(
          'pets',
          pet.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<Pet>> loadPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('pets');
    return maps.map((map) => Pet.fromMap(map)).toList();
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('pets');
  }

  // --- MÉTODOS DE SESSÃO (LOGIN) ---
  Future<void> saveSession(String id, String name) async {
    final db = await database;
    await db.delete('session'); // Garante que só teremos 1 usuário logado
    await db.insert('session', {'id': id, 'name': name});
  }

  Future<Map<String, dynamic>?> getSession() async {
    final db = await database;
    final result = await db.query('session', limit: 1);
    if (result.isNotEmpty) return result.first;
    return null;
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('session');
  }
}
