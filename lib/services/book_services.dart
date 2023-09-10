import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mibiblioteca/model/book.dart';

class BooksService {
  //Creamos la referencia que es el path donde esta la coleccion y el documento
  final bookRef = FirebaseFirestore.instance.collection('books')
  //convertimos el snapshot data a nuestras clases tambien podemos usar el parametro options
      .withConverter(fromFirestore: (snapshot, _) =>
  //en el json recibimos el id que esta fuera del snapshot y la data del snapshot
  Book.fromJason(snapshot.id, snapshot.data()!),
      toFirestore: (book, _) => book.toJson());

  //Snapshot es el objeto que nos devuelve Firebase

  Future<List<Book>> getLastBooks() async {
    //guardamos el resultado de la API de firestore, la respuesta va a hacer un querySnapshot que contiene un book
    var result = await bookRef.limit(3).get().then((value) => value);
    List<Book> books = [];

    for (var doc in result.docs) {
      books.add(doc.data());
    }
    return Future.value(books);
  }

  Future<Book> getBook(String bookId) async {
    var result = await bookRef.doc(bookId).get().then((value) => value);
    if (result.exists) {
      return Future.value(result.data());
    }
    throw const HttpException("Book not found");
  }
//Este metodo recibe los parametros y lo guarda en una referencia que añade al servidor de firebase en la coleccion books
  Future<String> saveBook(String title, String author, String summary) async {
    var reference = FirebaseFirestore.instance.collection("books");
    var result = await reference.add({
      'name': title,
      'author': author,
      'summary': summary
    });
    return Future.value(result.id);
  }
}