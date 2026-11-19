#if Progreso
import SwiftUI

/// F1 (Progreso): sección del detalle para ver y avanzar el progreso de un libro.
struct BookProgressSection: View {
    let plugin: ProgressPlugin
    let bookID: UUID

    var body: some View {
        Section(header: Text("Progreso")) {
            if let progress = plugin.progress(for: bookID) {
                Text(progress.summary)
                HStack {
                    Button("-10 págs") { plugin.advance(bookID: bookID, by: -10) }
                    Button("+10 págs") { plugin.advance(bookID: bookID, by: 10) }
                }
            } else {
                Button("Registrar progreso (300 págs)") { plugin.start(bookID: bookID) }
            }
        }
    }
}
#endif
