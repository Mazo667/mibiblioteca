import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mibiblioteca/model/book.dart';
import 'package:mibiblioteca/state.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils.dart';

class BookDetailScreen extends StatelessWidget {
  final Book _book;
  BookDetailScreen(this._book, {Key? key}) : super(key: key);
  /* bannerAd recibe el tamaño, unitId para obtenerlo en la dashboard de AdMob,
   listener para escuchar los ciclos de vida del ad y el request que le hace a los servidores de google */
  final BannerAd bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) => print('ad Loaded'),
        onAdFailedToLoad: (Ad ad,LoadAdError error){
          ad.dispose();
          print('Ad failed to load $error');
        }
      ),
      request: AdRequest());

  @override
  Widget build(BuildContext context) {
    //Llamamos a los servidores de google para cargar el Ad
    bannerAd.load(); //en un statefull lo cargariamos en initState
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle Libro"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              BookCoverWidget(_book.coverUrl),
              BookInfoWidget(_book.title,_book.author,_book.description),
              BookActionsWidget(_book.id),
            ],
            ),
          ),
          Container(
              width: bannerAd.size.width.toDouble(),
              height: bannerAd.size.height.toDouble(),
              child: AdWidget(ad: bannerAd)),
        ],
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