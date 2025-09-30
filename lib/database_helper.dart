import 'package:crud_flutter/libros.dart'; // Importa el modelo Libro
import 'package:sqflite/sqflite.dart';     // Librería para manejar SQLite
import 'package:path/path.dart';           // Librería para unir rutas

class DatabaseHelper {
  // Singleton → solo una instancia de DatabaseHelper en toda la app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance; // Devuelve siempre la misma instancia

  static Database? _database; // Aquí se guarda la referencia a la BD

  DatabaseHelper._internal(); // Constructor privado para Singleton

  // Getter de la base de datos (abre la BD si no está abierta)
  Future<Database> get database async {
    if (_database != null) return _database!; // Si ya existe, la retorna
    _database = await _initDatabase();        // Si no, la crea/inicializa
    return _database!;
  }

  // Inicializa la BD: crea la ruta y la tabla si no existe
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bdlibros.db'); // Ruta BD
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Se ejecuta solo al crear la BD por primera vez
        await db.execute(
          "CREATE TABLE libros (id INTEGER PRIMARY KEY AUTOINCREMENT, tituloLibro TEXT)", 
        );
      },
    );
  }

  // Insertar un libro en la tabla "libros"
  Future<void> insertLibro(Libro item) async {
    final db = await database; // Obtiene la BD
    await db.insert(
      'libros',            // Nombre de la tabla
      item.toMap(),        // Convierte el objeto Libro a mapa
      conflictAlgorithm: ConflictAlgorithm.replace, // Si existe, lo reemplaza
    );
  }

  // Obtener todos los libros de la tabla
  Future<List<Libro>> getItems() async {
    final db = await database; // Obtiene la BD
    final List<Map<String, dynamic>> maps = await db.query('libros'); // SELECT
    return List.generate(maps.length, (i) {
      return Libro(  // Convierte cada fila en un objeto Libro
        id: maps[i]['id'], 
        tituloLibro: maps[i]['tituloLibro'],
      );
    });
  }

  // Eliminar registros de cualquier tabla
  Future<int> eliminar(
    String table, {
    String? where,          // Condición WHERE (ejemplo: "id = ?")
    List<Object?>? whereArgs, // Argumentos para el WHERE
  }) async {
    final db = await database; // Usa la BD ya abierta (no reinicia)
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // Actualizar registros en cualquier tabla
  Future<int> actualizar(
    String table,
    Map<String, dynamic> values, { // Campos a actualizar en formato mapa
    String? where, 
    List<Object?>? whereArgs,
  }) async {
    final db = await database; // Usa la BD ya abierta
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }
}
