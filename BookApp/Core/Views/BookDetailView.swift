import SwiftUI

/// Detalle de un libro. Recibe un enlace (@Binding) al libro de la lista:
/// lo que se edita aquí cambia el libro del ViewModel, sin copias.
/// `extra` es un hueco para el contenido de las características opcionales (por ejemplo F1):
/// el Core no sabe qué se le pone dentro.
struct BookDetailView<Extra: View>: View {
    @Binding var book: Book
    let extra: Extra

    init(book: Binding<Book>, @ViewBuilder extra: () -> Extra) {
        self._book = book
        self.extra = extra()
    }

    var body: some View {
        Form {
            TextField("Título del libro", text: $book.title)
            TextField("Autor", text: $book.author)
            Button("Estado de lectura: \(book.status.rawValue)") {
                book.status = book.status.next
            }
            extra
        }
        .navigationTitle(book.title)
    }
}
