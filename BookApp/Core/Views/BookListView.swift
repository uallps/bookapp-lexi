import SwiftUI

struct BookListView: View {
    @State private var viewModel: BookListViewModel
    /// La configuración la crea la app y llega por el entorno: es la misma que edita Ajustes.
    @Environment(AppConfig.self) private var config
#if Progreso
    /// F1: el plugin de progreso llega por el entorno. Sus datos viven aparte del libro
    /// y de este ViewModel.
    @Environment(ProgressPlugin.self) private var progress
#endif
#if Favoritos
    /// O1: favoritos y su filtro.
    @Environment(FavoritesPlugin.self) private var favorites
#endif
#if Sesiones && Progreso
    /// O5: sesiones de lectura (dependen de F1).
    @Environment(SessionsPlugin.self) private var sessions
#endif

    /// Quien crea la lista decide dónde se guardan los libros.
    init(storageProvider: BookStorageProvider = JSONStorageProvider()) {
        _viewModel = State(wrappedValue: BookListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        NavigationStack {
            List {
                // Filas de las características (controles y resúmenes), antes de los libros.
#if Favoritos
                if config.enableFavorites {
                    FavoritesFilterRow(plugin: favorites, favoriteCount: favorites.count(in: viewModel.books))
                }
#endif
                ForEach(visibleBooks) { book in
                    bookRow(book: book)
                }
            }
            .toolbar {
                Button("Añadir libro") {
                    viewModel.addBook()
                }
            }
            .navigationTitle("Libros")
        }
    }

    /// Una fila: enlace al detalle del libro, con menú contextual para borrarlo.
    private func bookRow(book: Book) -> some View {
        NavigationLink(destination: BookDetailView(book: binding(for: book)) { detailSections(for: book) }) {
            BookRowView(
                book: book,
                extraInfo: extraInfo(for: book),
                changeStatus: { viewModel.changeStatus(id: book.id) }
            )
            .contextMenu {
                Button("Eliminar libro") {
                    viewModel.removeBook(id: book.id)
                }
            }
        }
    }

    /// Un enlace (Binding) para que el detalle edite el libro. No toca los datos:
    /// leer y escribir se traducen a métodos del ViewModel.
    private func binding(for book: Book) -> Binding<Book> {
        Binding(
            get: { viewModel.book(id: book.id) ?? book },
            set: { viewModel.updateBook($0) }
        )
    }

    // MARK: - Puntos de variación de las características
    // Cada característica se engancha aquí con su `#if` (compilación) y su flag (ejecución).

    /// Los libros que se muestran: los de la biblioteca que pasan todos los filtros activos.
    /// Los filtros se encadenan: un libro se ve solo si pasa cada uno de ellos.
    private var visibleBooks: [Book] {
        var books = viewModel.books
#if Favoritos
        if config.enableFavorites {
            books = books.filter(favorites.matches)
        }
#endif
        return books
    }

    /// Líneas extra de la fila de un libro, en el orden de las características.
    private func extraInfo(for book: Book) -> [String] {
        var info: [String] = []
#if Progreso
        if config.enableProgress, let summary = progress.progress(for: book.id)?.summary {
            info.append(summary)
        }
#endif
#if Favoritos
        if config.enableFavorites, favorites.isFavorite(book.id) {
            info.append("★ Favorito")
        }
#endif
        return info
    }

    /// Secciones extra del detalle de un libro.
    @ViewBuilder
    private func detailSections(for book: Book) -> some View {
#if Progreso
        if config.enableProgress {
            BookProgressSection(plugin: progress, bookID: book.id)
        }
#endif
#if Favoritos
        if config.enableFavorites {
            BookFavoriteSection(plugin: favorites, bookID: book.id)
        }
#endif
#if Sesiones && Progreso
        // O5 requiere F1: con el progreso apagado, tampoco se ven las sesiones.
        if config.enableSessions && config.enableProgress {
            BookSessionsSection(plugin: sessions, bookID: book.id)
        }
#endif
    }
}
