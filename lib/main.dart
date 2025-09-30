// Importaciones necesarias
import 'package:flutter/material.dart';            // Librería principal de Flutter para la UI
import 'package:crud_flutter/database_helper.dart'; // Clase para manejar la base de datos SQLite
import 'libros.dart';                              // Clase modelo Libro

// Punto de entrada de la aplicación
void main() {
  runApp(const MainApp()); // Inicia la app y carga el widget MainApp
}

// Widget principal de la app
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter demo Crud', // Título de la app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Colores de la app
        useMaterial3: true,
      ),
      home: const MyHomePage(), // Página inicial
    );
  }
}

// Página inicial con estado
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Estado de la página principal
class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbhelper = DatabaseHelper();     // Instancia del helper de base de datos
  final TextEditingController _EditTituloLibro = TextEditingController(); // Controlador del campo de texto
  List<Libro> _items = []; // Lista de libros que se mostrarán en pantalla

  @override
  void initState() {
    super.initState();
    _cargarListaLibros(); // Al iniciar, carga los libros de la BD
  }

  // Obtiene todos los libros de la BD
  Future<void> _cargarListaLibros() async {
    final items = await _dbhelper.getItems();
    setState(() {
      _items = items; // Refresca la lista en pantalla
    });
  }

  // Agregar un nuevo libro a la BD
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);
    await _dbhelper.insertLibro(nuevoLibro); // Inserta en SQLite
    print("SE AGREGO EL NUEVO LIBRO");
    _cargarListaLibros(); // Recarga lista
  }

  // Ventana emergente para agregar un libro
  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar titulo"),
          content: TextField(
            controller: _EditTituloLibro, // Donde el usuario escribe el título
            decoration: const InputDecoration(hintText: "Ingresa el titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  _agregarNuevoLibro(_EditTituloLibro.text.toString());
                  // _EditTituloLibro.clear(); // Puedes limpiar después de usarlo
                  Navigator.of(context).pop(); // Cierra la ventana
                }
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  // Eliminar un libro de la BD
  void _eliminarLibro(int id) async {
    await _dbhelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();
  }

  // Confirmar antes de eliminar un libro
  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminacion"),
          content: const Text("¿Estas seguro de que quieres eliminar este libro?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id); // Ejecuta la eliminación
                Navigator.of(context).pop(); // Cierra el cuadro
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  // Actualizar título de un libro en la BD
  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbhelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo}, // Nuevo valor
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  // Ventana para editar un libro existente
  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController tituloController = TextEditingController(
      text: tituloActual, // Valor inicial del texto
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Codificar Titulo del Libro"),
          content: TextField(
            controller: tituloController,
            decoration: const InputDecoration(
              hintText: "Escribe el nuevo titulo",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancelar
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, tituloController.text.toString());
                }
                Navigator.of(context).pop(); // Cierra la ventana
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // Construcción de la interfaz principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqlLite Flutter"), // Título en la barra superior
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: _items.length, // Cantidad de libros
        separatorBuilder: (context, index) => const Divider(), // Línea separadora
        itemBuilder: (context, index) {
          final libro = _items[index]; // Libro actual
          return ListTile(
            title: Text(libro.tituloLibro),   // Título del libro
            subtitle: Text('Id: ${libro.id}'), // Muestra el ID
            trailing: IconButton(             // Botón de borrar
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () {
                _mostrarMensajeModificar(int.parse(libro.id.toString()));
              },
            ),
            onTap: () {
              _ventanaEditar(int.parse(libro.id.toString()), libro.tituloLibro);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarVentanaAgregar, // Agregar nuevo libro
        child: const Icon(Icons.add),
      ),
    );
  }
}
