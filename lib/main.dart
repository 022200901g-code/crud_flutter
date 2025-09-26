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
    return const MaterialApp(
      title: 'Flutter demo Crud',
      theme: ThemeData{
        ColorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget{
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  final DatabaseHelper _dbhelper = DatabaseHelper();
  final TextEditingController _editTituloLibro=TextEditingController();
  List<Libro> _items = [];

  @override
  void initState(){
    super.initState();
    _cargarListaLibros();
  } 
  Future<void> _cargarListaLibros() async{
    final items = await _dbhelper.getItems();
    setState(() {
      _items = items;
    });
  }
  void 

}