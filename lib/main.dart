import 'package:flutter/material.dart';
import 'package:crud_flutter/database_helper.dart';
import 'libros.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter demo Crud',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbhelper = DatabaseHelper();
  final TextEditingController _EditTituloLibro = TextEditingController();
  List<Libro> _items = [];

  @override
  void initState() {
    super.initState();
    _cargarListaLibros();
  }

  Future<void> _cargarListaLibros() async {
    final items = await _dbhelper.getItems();
    setState(() {
      _items = items;
    });
  }

  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro);
    await _dbhelper.insertLibro(nuevoLibro);
    print("SE AGREGO EL NUEVO LIBRO");
    _cargarListaLibros();
  }

  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar titulo"),
          content: TextField(
            controller: _EditTituloLibro,
            decoration: const InputDecoration(hintText: "Ingresa el titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  _agregarNuevoLibro(_EditTituloLibro.text.toString());
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Agregar"),
            ),
          ],
        );
      },
    );
  }

  void _eliminarLibro(int id) async {
    await _dbhelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros();
  }

  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminacion"),
          content: const Text(
            "¿Estas seguro de que quieres eliminar este libro?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id);
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _actualizarLibro(int id, String nuevoTitulo) async {
    await _dbhelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }

  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController tituloController = TextEditingController(
      text: tituloActual,
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
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, tituloController.text.toString());
                }
                Navigator.of(context).pop();
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final libro = _items[index];
          return ListTile(
            title: Text(libro.tituloLibro),
            subtitle: Text('Id: ${libro.id}'),
            trailing: IconButton(
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
        onPressed: _mostrarVentanaAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
