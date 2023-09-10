import 'package:flutter_bloc/flutter_bloc.dart';

//Guardo una lista de Ids
class BookshelfState {
  List<String> bookIds;
  BookshelfState(this.bookIds);
}
//Creo una clase abstracta con los eventos, para hacer mas facil usar
abstract class BookshelfEvent {
  const BookshelfEvent();
}
//Agrego los eventos para modificar el state
class AddBookToBookshelf extends BookshelfEvent {
  final String bookId;
  const AddBookToBookshelf(this.bookId);
}

class RemoveBookFromBookshelf extends BookshelfEvent {
  final String bookId;
  const RemoveBookFromBookshelf(this.bookId);
}
//Agregamos el Bloc quien estara escuchando por los eventos y el manejo correspondiente
class BookshelfBloc extends Bloc<BookshelfEvent, BookshelfState> {
  BookshelfBloc(BookshelfState initialState) : super(initialState) {
    on<AddBookToBookshelf>((event, emit) {
      //Del state obtenemos la lista de ids, el metodo add lo que hace es agregar este
      //nuevo add a la lista, modificandola
      state.bookIds.add(event.bookId);
      //Emitimos otro estado para que bloc entienda que el estado fue modificado y todos los
      //que esten escuchando este provider, reaccionen y reconstruyan sus widgets
      emit(BookshelfState(state.bookIds));
    });
    on<RemoveBookFromBookshelf>((event, emit) {
      state.bookIds.remove(event.bookId);
      emit(BookshelfState(state.bookIds));
    });
  }
}