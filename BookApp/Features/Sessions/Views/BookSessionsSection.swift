#if Sesiones && Progreso
import SwiftUI

/// O5 (Sesiones): sección del detalle para registrar sesiones de hoy y ver la racha.
struct BookSessionsSection: View {
    let plugin: SessionsPlugin
    let bookID: UUID

    var body: some View {
        Section(header: Text("Sesiones")) {
            Text(plugin.summary(for: bookID))
                .monospacedDigit()
            HStack {
                Button("+10 págs") { plugin.log(pages: 10, for: bookID) }
                Button("+25 págs") { plugin.log(pages: 25, for: bookID) }
            }
            if let last = plugin.sessions(for: bookID).last {
                Text("Última sesión: \(last.date.formatted(date: .abbreviated, time: .omitted)) · \(last.pages) págs")
                    .bookCaption()
            }
        }
    }
}
#endif
