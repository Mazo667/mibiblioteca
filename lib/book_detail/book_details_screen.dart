import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mibiblioteca/model/book.dart';
import 'package:mibiblioteca/state.dart';

import '../utils.dart';

class BookDetailScreen extends StatelessWidget {
  final Book _book;
  const BookDetailScreen(this._book, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle Libro"),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          BookCoverWidget(_book.coverUrl),
          BookInfoWidget(_book.title,_book.author,_book.description),
          BookActionsWidget(_book.id)
        ],
        ),
      ),
    );
  }
}

class BookActionsWidget extends StatelessWidget {
  final String bookId;
  const BookActionsWidget(this.bookId, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //BlocBuilder se ocupa de los widget que van a usar el state
    return BlocBuilder<BookshelfBloc,BookshelfState>(
        builder: (context, bookshelfState){
          var action = () => _addToBookshelf(context, bookId);
          var label = "Agregar a mi cuenta";
          var color = Colors.greenAccent;
          //Si la cuenta contiene mi libro Id cambio el action y el label
          if(bookshelfState.bookIds.contains(bookId)) {
            action = () => _removeToBookshelf(context, bookId);
            label = "Quitar de mi cuenta";
            color = Colors.pinkAccent;
          }
          return ElevatedButton(
            style: ElevatedButton.styleFrom(primary: color),
            onPressed: action,
            child: Text(label),
          );
        });
  }
  void _addToBookshelf(BuildContext context,String bookId){
    //obtenemos el bloc atravez del context y especificamos con read() que queremos leer
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(AddBookToBookshelf(bookId));
  }

  void _removeToBookshelf(BuildContext context,String bookId){
    //obtenemos el bloc atravez del context y especificamos con read() que queremos leer
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(RemoveBookFromBookshelf(bookId));
  }
}


class BookCoverWidget extends StatelessWidget {
  final String coverUrl;

  const BookCoverWidget(this.coverUrl, {Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: 230,
          margin: const EdgeInsets.only(top: 20, bottom: 20),
          decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5),spreadRadius: 5,blurRadius: 10)]),
          child: Image(image: getImageWidget(coverUrl)),
    )
    );
  }
}

class BookInfoWidget extends StatelessWidget {
  final String title;
  final String author;
  final String description;

  const BookInfoWidget(this.title,this.author,this.description, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: Column(children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium,),
        const SizedBox(height: 5),
        Text(author, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 15),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
      ],),
    );
  }
}