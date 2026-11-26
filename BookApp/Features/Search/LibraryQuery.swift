#if Busqueda
import Foundation
import Observation

/// Estado de pantalla para la búsqueda y el orden de la lista de libros.
/// No es un DataPlugin: no se guarda en disco ni tiene datos que borrar al eliminar un libro.
/// Se crea con @State en BookListView y vive mientras la vista está en memoria.
@Observable
final class LibraryQuery {
    var text: String = ""
    var order: SortOrder = .title

    /// Aplica el texto de búsqueda y el orden actual sobre una lista de libros.
    /// Se usa como un eslabón más dentro de la cadena de filtros de visibleBooks.
    func apply(to books: [Book]) -> [Book] {
        let filtered = filteredByText(books)
        return sorted(filtered)
    }

    private func filteredByText(_ books: [Book]) -> [Book] {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return books }

        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(query)
                || book.author.localizedCaseInsensitiveContains(query)
        }
    }

    private func sorted(_ books: [Book]) -> [Book] {
        switch order {
        case .title:
            return books.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        case .author:
            return books.sorted {
                $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending
            }
        case .status:
            // ReadingStatus es String enum: rawValue = "Pendiente", "Leyendo", "Leído"
            return books.sorted {
                $0.status.rawValue.localizedCaseInsensitiveCompare($1.status.rawValue) == .orderedAscending
            }
        }
    }
}
#endif
