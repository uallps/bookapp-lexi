#if Exportar
import SwiftUI

/// O7 (Exportar): botón de la barra de herramientas. Al pulsarlo escribe books-export.csv
/// en Documentos y muestra un mensaje con el número de libros y la ruta.
struct ExportButton: View {
    let books: [Book]
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading) {
            Button("Exportar") { export() }
            if let message {
                Text(message)
                    .bookCaption()
            }
        }
    }

    private func export() {
        do {
            let url = try LibraryExporter.export(books)
            message = "Exportados \(books.count) libros a \(url.path)"
        } catch {
            message = "No se ha podido exportar: \(error.localizedDescription)"
        }
    }
}
#endif
