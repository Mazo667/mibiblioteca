import 'package:flutter/material.dart';
import 'package:mibiblioteca/model/book_categorie.dart';
import 'package:mibiblioteca/utils.dart';


class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BookCategoriesGrid();
  }
}


class BookCategoriesGrid extends StatelessWidget {
  BookCategoriesGrid({Key? key}): super(key: key);

  final List<BookCategory> _categories = [
    BookCategory(1, "Programacion","#fb8500"),
    BookCategory(2, "Hacking Etico","#ffb703"),
    BookCategory(3, "Bases de Datos","#8ecae6"),
  ];
  @override
  Widget build(BuildContext context) {
    //Aunque las categorias son fijas, hacemos un builder por si hay que agregar mas
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: GridView.builder(
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index){
            return TitleCategory(_categories[index]);
          }),
    );
  }
}

class TitleCategory extends StatelessWidget {
  final BookCategory _category;

  const TitleCategory(this._category, {Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            borderRadius: BorderRadius.circular(5.0),
            onTap: () {
              _navigateToBookWithCategorie();
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0),
                  color: hexToColor(_category.colorBg, Colors.black)),
              alignment: AlignmentDirectional.center,
              child: Text(_category.name, style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,),
            )
        )
    );
  }

  void _navigateToBookWithCategorie() {}
}
