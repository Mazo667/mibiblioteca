import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

class BookActionsWidget extends StatefulWidget {
  final String bookId;

  const BookActionsWidget(this.bookId, {super.key});


  @override
  State<BookActionsWidget> createState() => _BookActionsWidgetState();
}

class _BookActionsWidgetState extends State<BookActionsWidget> {
  bool _canPurchase = false;
  ProductDetails? _productDetails;
  bool _purchased = false;

  @override
  void initState() {
   getIAProducts();
   listenForPurchases();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //BlocBuilder se ocupa de los widget que van a usar el state
    return BlocBuilder<BookshelfBloc,BookshelfState>(
        builder: (context, bookshelfState){
          var action = () => _addToBookshelf(context, widget.bookId);
          var label = "Agregar a mi cuenta";
          var color = Colors.greenAccent;
          //Si la cuenta contiene mi libro Id cambio el action y el label
          if(bookshelfState.bookIds.contains(widget.bookId)) {
            action = () => _removeToBookshelf(context, widget.bookId);
            label = "Quitar de mi cuenta";
            color = Colors.pinkAccent;
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(primary: color),
                onPressed: action,
                child: Text(label),
              ),
              ElevatedButton(
                  onPressed: _canPurchaseBook(),
                  child: Text(_purchased ? "Ya compraste este libro" : "Comprar Ebook"),
              style: ElevatedButton.styleFrom(primary: color),
              )
            ],
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

  void buyEbook(String bookId){
    var details = _productDetails;
    if(details != null){
      print("ESTA POR COMPRAR EL EBOOK ${details.id}");
      PurchaseParam purchaseParam = PurchaseParam(productDetails: details);
      InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
    }else{
      print("DENTRO DEL METODO BUYEBOOK, EL PRODUCTO ES NULO");
    }
  }

  void getIAProducts() async {
  final bool available = await InAppPurchase.instance.isAvailable();
  if(!available){
    //TODO MOSTRAR ERROR
    return;
  }
  //Obtenemos los detalles del producto
  Set<String> prodructIds = <String>{"ebook_tier_1"};
  var productDetailsResponse = await InAppPurchase.instance.queryProductDetails(prodructIds);
  //si no encontro ningun producto
  if(productDetailsResponse.notFoundIDs.isNotEmpty){
    //TODO mostrar error y devolver
    print("NO ENCONTRO EL ID DEL PRODUCTO");
  } else {
    //obtenemos todos los productos del response
      for(ProductDetails productDetails in productDetailsResponse.productDetails){
        //encontramos el producto tier 1
        print("ENCONTRO EL PRODUCTO ${productDetails.id}");
        if(productDetails.id == "ebook_tier_1"){
          setState(() {
            _canPurchase = true;
            _productDetails = productDetails;
          });
        }
      }
  }
  }

  void listenForPurchases() {
    Stream purchasesStream = InAppPurchase.instance.purchaseStream;
    purchasesStream.listen((purchaseDetailsList) {
      _handlePurchases(purchaseDetailsList);
    });
  }

  VoidCallback? _canPurchaseBook() {
    if (!_purchased && _canPurchase) {
      return () {
        buyEbook(widget.bookId);
      };
    }
    return null;
  }

  void _handlePurchases(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      //Cuando el usuario hizo una compra y se esta esperando la respuesta
      if(purchaseDetails.status == PurchaseStatus.pending){
        //TODO
      } else {
        //Surgio un error
        if(purchaseDetails.status == PurchaseStatus.error){
          //TODO error
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          //TODO validar la compra
          setState(() {
            _purchased = true;
          });
        }
      }
    }
  }

  void _showError(IAPError? error) {
    String errorText = error != null ? error.message : "Error desconocido";
    _showDialog(
        "Error", "Ocurrió un error al realizar tu compra. Error:" + errorText);
  }

  void _showDialog(String title, String body) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancelar'),
              child: const Text('Ok'),
            ),
          ],
        ));
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