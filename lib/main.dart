import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mibiblioteca/book_shelf/book_shelf.dart';
import 'package:mibiblioteca/categories/categories.dart';
import 'package:mibiblioteca/home/home_screen.dart';
import 'package:mibiblioteca/notifications/notifications.dart';
import 'package:mibiblioteca/state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async{
  //metodo de firebase que asegura que todas las cosas se inicialicen
  WidgetsFlutterBinding.ensureInitialized();
  //Incializacion de firebase
  await Firebase.initializeApp();
  //Inicio la app
  runApp(const MiBiblioteca());
}

class MiBiblioteca extends StatelessWidget {
  const MiBiblioteca({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Los provides siempre tienen que estar sobre lo widgets que lo van a ocupar
    return BlocProvider(
      //en create indicamos el bloc y el state que tienen que crear
      create: (_) => BookshelfBloc(
        //y al state le pasamos un estado inicial
          BookshelfState([])), //En esta caso la lista esta vacia
      //colocamos el widget que esta debajo del provider
      child: MaterialApp(
          title: 'Mi biblioteca',
          theme: ThemeData(
            primaryColor: Colors.greenAccent,
            useMaterial3: true,
          ),
          home:  const BottomNavigationWidget()),
    );
  }
}



class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({Key? key}) : super(key: key);

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _sections = [
    HomeScreen(),
    CategoriesScreen(),
    BookShelfScreen(),
  ];

  @override
  void initState() {
    super.initState();
    print("se ejecuto el init");
    initNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Biblioteca"),),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.library_books),label: "Biblioteca"),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded),label: "Mi Cuenta")
        ],
        currentIndex: _selectedIndex,
        //Cuando hago click en algunos de los botones cambio el indice
        onTap: _onItemTapped,
      ),
      body: _sections[_selectedIndex],
    );
  }
  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }
}

