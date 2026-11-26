#if Importar
import SwiftUI

/// O8 (Importar): botón de la lista. Lee books-import.csv de Documentos, añade los libros
/// válidos a la biblioteca y muestra «Importados N · Ignorados M».
struct ImportButton: View {
    let existingBooks: [Book]
    let addBooks: ([Book]) -> Void

    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading) {
            Button("Importar") { importFromDocuments() }
            if let message {
                Text(message)
                    .bookCaption()
            }
        }
    }

    private func importFromDocuments() {
        do {
            let result = try LibraryImporter.importFromDocuments(existing: existingBooks)
            addBooks(result.books)
            message = "Importados \(result.books.count) · Ignorados \(result.ignored)"
        } catch LibraryImporter.ImportError.fileNotFound {
            message = "No se ha encontrado books-import.csv en la carpeta Documentos"
        } catch {
            message = "No se ha podido importar: \(error.localizedDescription)"
        }
    }
}
#endif
