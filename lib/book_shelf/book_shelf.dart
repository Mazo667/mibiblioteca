import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mibiblioteca/add_book/add_book_screen.dart';
import 'package:mibiblioteca/book_detail/book_details_screen.dart';
import 'package:mibiblioteca/model/book.dart';
import 'package:mibiblioteca/services/book_services.dart';
import 'package:mibiblioteca/state.dart';
import 'package:mibiblioteca/utils.dart';

class BookShelfScreen extends StatelessWidget {

  InterstitialAd? _ad;

  BookShelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712", //id de prueba
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad){
              print("Ad esta cargado");
              _ad = ad;
              _ad!.fullScreenContentCallback = FullScreenContentCallback(
                //si el ad se cierra, seguimos nuestra navegacion a la siguiente pantalla
                onAdDismissedFullScreenContent: (ad){
                  _navigateToAddNewBookScreen(context);
                  //si el ad ya se mostro, seguimos con la navegacion
                }, onAdFailedToShowFullScreenContent: (ad,error){
                print(error);
                _navigateToAddNewBookScreen(context);
              }
              );},
            //si surgio un error con el ad seguimos con la navegacion
            onAdFailedToLoad: (error){
              print(error);
              _navigateToAddNewBookScreen(context);
            })
    );
    return BlocBuilder<BookshelfBloc,BookshelfState>(
        builder: (context, bookshelfState){
          //Declaro un widget que contenga si la lista esta vacia
          var emptyListWidget = Center(child: Text("Aun no tienes ningun libro en tu cuenta",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,));

        //aca pregunto si la lista esta vacia muestro el widget emptyListWidget si no mostramos la grilla
          var mainWidget = bookshelfState.bookIds.isEmpty ? emptyListWidget : MyBookGrid(bookshelfState.bookIds);
          return Column(
            children: [
              Expanded(child: mainWidget),
              ElevatedButton(onPressed: () {
                //pregunto si el ad cargo o no, si es nulo no cargo
                if(_ad != null){
                  _ad!.show();
                }else{
                  _navigateToAddNewBookScreen(context);
                }
              }, child: const Text("Agregar nuevos libros")),
            ],
          );
        }
    );
  }

  void _navigateToAddNewBookScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBookScreen()));
  }
}

class MyBookGrid extends StatelessWidget {
  final List<String> bookIds;

  const MyBookGrid(this.bookIds, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          //La longitud de los items va a ser la longitud en el state
          itemCount: bookIds.length,
          itemBuilder: (context, index){
            return BookCoverItem(bookIds[index]);
          }),
    );
  }
}


class BookCoverItem extends StatefulWidget {
  final String _bookId;

  const BookCoverItem(this._bookId, {Key? key}) : super(key: key);

  @override
  State<BookCoverItem> createState() => _BookCoverItemState();
}

class _BookCoverItemState extends State<BookCoverItem> {
  Book? _book;

  @override
  void initState() {
    super.initState();
    _getBook(widget._bookId);
  }

  void _getBook(String bookId) async{
    var book = await BooksService().getBook(bookId);
    setState(() {
      _book = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_book==null){
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return InkWell(
        onTap: () {
          _openBookDetails(_book!, context);
        },
        child: Ink.image(
            fit: BoxFit.cover,
            image: getImageWidget(_book!.coverUrl))
    );
  }

  void _openBookDetails(Book book, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => BookDetailScreen(book)
    )
    );
  }

}
