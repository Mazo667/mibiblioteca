import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mibiblioteca/model/book.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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

  Future<String> uploadBookCover(String imagePath, String newBookId) async {
    try{
      //guardo el path en una variable
      var newBookRef = 'books/$newBookId';
      //Guardo el imagePath en un archivo
      File image = File(imagePath);
      //subo esa imagen firebase storage
      var task = await firebase_storage.FirebaseStorage.instance.
      ref(newBookRef).putFile(image);

      debugPrint("Upload finalizado, path: ${task.ref}");

      //Retorno la url de la imagen subida al firebaseStorage
      return firebase_storage.FirebaseStorage.instance
          .ref(newBookRef)
          .getDownloadURL();
    } on FirebaseException catch(e){
      debugPrint(e.message);
      rethrow;
    }

  }

  Future<void> updateCoverBook(String newBookId, String imageUrl) async {
    //obtengo la referencia del libro que quiero actualizar
    var reference = FirebaseFirestore.instance.collection("books").doc(newBookId);
    //con la referencia actualizo el campo
    await reference.update({
      'coverUrl': imageUrl,
    });
  }
}