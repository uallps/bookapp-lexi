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

    /// Quien crea la lista decide dónde se guardan los libros.
    init(storageProvider: BookStorageProvider = JSONStorageProvider()) {
        _viewModel = State(wrappedValue: BookListViewModel(storageProvider: storageProvider))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.books) { book in
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
        NavigationLink(destination: BookDetailView(book: binding(for: book)) { progressSection(for: book) }) {
            BookRowView(
                book: book,
                showProgress: config.enableProgress,
                progressText: progressText(for: book),
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

    // MARK: - F1: Progreso (punto de variación en compilación)

    /// Texto de progreso de un libro; nil si F1 no está compilada o el libro no tiene datos.
    private func progressText(for book: Book) -> String? {
#if Progreso
        return progress.progress(for: book.id)?.summary
#else
        return nil
#endif
    }

    /// Sección de progreso del detalle; vacía si F1 no está compilada o su flag está apagado.
    @ViewBuilder
    private func progressSection(for book: Book) -> some View {
#if Progreso
        if config.enableProgress {
            BookProgressSection(plugin: progress, bookID: book.id)
        }
#else
        EmptyView()
#endif
    }
}
