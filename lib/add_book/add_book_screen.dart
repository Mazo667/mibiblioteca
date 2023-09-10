import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mibiblioteca/services/book_services.dart';
import 'package:mibiblioteca/state.dart';


class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar nuevo libro"),
      ),
      body: const AddBookForm()
    );
  }
}

class AddBookForm extends StatefulWidget {
  const AddBookForm({super.key});

  @override
  State<AddBookForm> createState() => _AddBookFormState();
}

class _AddBookFormState extends State<AddBookForm> {
  final tittleFieldController = TextEditingController();
  final authorFieldController = TextEditingController();
  final summaryFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _savingBook = false;

  @override
  Widget build(BuildContext context) {
    if(_savingBook){
      return const Center(child: CircularProgressIndicator());
    }
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: tittleFieldController,
                validator: (value){
                if(value == null || value.isEmpty){
                  return "Por favor ingresa el titulo";
                  }
                return null;
                },
                decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Titulo',)
            ),
            TextFormField(
              controller: authorFieldController,
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "Por favor ingresa el autor";
                  }
                  return null;
                },
                decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Autor',)
            ),
            TextFormField(
              controller: summaryFieldController,
                decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Resumen',)
            ),
            ElevatedButton(onPressed: () {
              //accedemos al estado actual del formulario y ejecutar su funcion de validacion
              if(_formKey.currentState!.validate()){
                _saveBook(context);
              }
            }, child: const Text("Guardar"))
          ],
        ),
      ),
    );
  }

  void _saveBook(BuildContext context) async {
    var title = tittleFieldController.text;
    var author = authorFieldController.text;
    var summary = summaryFieldController.text;

    setState(() {
      _savingBook = true;
    });

   var newBookId = await BooksService().saveBook(title,author,summary);

   var bookshelfBloc = context.read<BookshelfBloc>();
   bookshelfBloc.add(AddBookToBookshelf(newBookId));

   Navigator.pop(context);
  }
}
