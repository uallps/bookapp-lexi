#if FechasLectura
import SwiftUI

/// O10 (Fechas de lectura): sección del detalle para ver las fechas de un libro.
struct BookDatesSection: View {
    let plugin: ReadingDatesPlugin
    let bookID: UUID

    var body: some View {
        Section(header: Text("Fechas")) {
            if let dates = plugin.dates(for: bookID) {
                Text(dates.summary)
            } else {
                Text("Sin fechas de lectura")
                    .bookCaption()
            }
        }
    }
}
#endif
