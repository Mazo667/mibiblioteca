import 'package:flutter/material.dart';
import 'package:mibiblioteca/book_detail/book_details_screen.dart';
import 'package:mibiblioteca/model/book.dart';
import 'package:mibiblioteca/services/book_services.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _getLastBook();
  }
  //metodo asincrono, que se va encargar de obtener los libros de nuestro service
  void _getLastBook() async {
    var lastBooks = await BooksService().getLastBooks();
    setState(() {
      _books = lastBooks;
    });
  }
  @override
  Widget build(BuildContext context) {
    var showProgres = _books.isEmpty; //Si la lista esta vacia showProgres es true
    //si showProgres es true listLenght va a hacer 3 sino va a ser el largo de la lista + 2
    var listLenght = showProgres ? 3 : _books.length + 2;
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView.builder(
          itemCount: listLenght,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const HeaderWidget();
            }
            if (index == 1) {
              return const ListItemHeader();
            }
            if (showProgres){
              return const Padding(
                padding: EdgeInsets.only(top: 50),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return ListItemBook(_books[index - 2]);
          }),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset("assets/images/libros.jpg"));
  }
}

class ListItemHeader extends StatelessWidget {
  const ListItemHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 10, left: 5),
      child: const Text(
        "Ultimos Libros",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

class ListItemBook extends StatelessWidget {
  final Book _book;

  const ListItemBook(this._book, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 170,
        child: InkWell(
          borderRadius: BorderRadius.circular(5.0),
          onTap: () {
            _openBookDetails(context, _book);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 10),
                  child: Image.asset(_book.coverUrl,width: 150,),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: Text(
                            _book.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontSize: 18),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Flexible(
                          child: Text(
                            _book.author,
                            style: Theme.of(context).textTheme.titleSmall,
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      Flexible(
                          child: Text(
                            _book.description,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
//
  void _openBookDetails(BuildContext context, Book book) {
    //El navigator mete la pantalla BookDetailScreen
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BookDetailScreen(_book)));
  }
}
