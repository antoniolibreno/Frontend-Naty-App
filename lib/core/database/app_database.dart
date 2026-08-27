import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Banco SQLite compartilhado pelos repositórios da aplicação.
///
/// O banco é aberto sob demanda e a mesma conexão é reutilizada durante todo
/// o ciclo de vida do app. Novas tabelas e migrações devem ser adicionadas em
/// [_createSchema] e [_onUpgrade], respectivamente.
@lazySingleton
class AppDatabase {
  static const String databaseName = 'naty_app.db';
  static const int schemaVersion = 1;

  Database? _instance;
  Future<Database>? _opening;

  /// Retorna a conexão aberta, criando e configurando o banco no primeiro uso.
  Future<Database> get database async {
    final currentInstance = _instance;
    if (currentInstance != null && currentInstance.isOpen) {
      return currentInstance;
    }

    final pendingOpening = _opening;
    if (pendingOpening != null) {
      return pendingOpening;
    }

    final opening = _open();
    _opening = opening;
    try {
      final instance = await opening;
      _instance = instance;
      return instance;
    } finally {
      _opening = null;
    }
  }

  Future<Database> _open() async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      path.join(databasePath, databaseName),
      version: schemaVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Permite inicializar o banco explicitamente no bootstrap, quando preciso.
  Future<void> initialize() async {
    await database;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSchema(db);
  }

  Future<void> _createSchema(Database db) async {
    final batch = db.batch();

    // Tabela interna que identifica a versão lógica do schema. As tabelas das
    // features podem ser incluídas neste mesmo batch em suas próximas etapas.
    batch.execute('''
      CREATE TABLE app_metadata (
        key TEXT PRIMARY KEY NOT NULL,
        value TEXT NOT NULL
      )
    ''');
    batch.insert('app_metadata', <String, Object?>{
      'key': 'schema_version',
      'value': schemaVersion.toString(),
    });

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final batch = db.batch();

    // As próximas migrações devem ser incrementais, por exemplo:
    // if (oldVersion < 2) batch.execute('CREATE TABLE ...');

    batch.update(
      'app_metadata',
      <String, Object?>{'value': newVersion.toString()},
      where: 'key = ?',
      whereArgs: <Object?>['schema_version'],
    );
    await batch.commit(noResult: true);
  }

  /// Executa várias operações atomicamente.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<void> close() async {
    final currentInstance = _instance ?? await _opening;
    _instance = null;
    _opening = null;
    await currentInstance?.close();
  }
}
