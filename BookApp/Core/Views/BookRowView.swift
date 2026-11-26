import SwiftUI

/// Fila de un libro. No conoce el ViewModel ni las características: recibe las líneas
/// extra que aportan los plugins activos y la acción de cambiar el estado.
struct BookRowView: View {
    let book: Book
    let extraInfo: [String]
    let changeStatus: () -> Void

    var body: some View {
        HStack {
            Button(action: changeStatus) {
                Image(systemName: book.status == .finished ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.bookAccent)
            }
            .buttonStyle(.plain)
            VStack(alignment: .leading) {
                Text(book.title)
                if !book.author.isEmpty {
                    Text(book.author)
                        .bookCaption()
                }
                Text(book.status.rawValue)
                    .bookCaption(color: book.status.color)
                // Puntos de variación en ejecución: solo llegan las líneas de las características activas.
                ForEach(extraInfo, id: \.self) { line in
                    Text(line)
                        .bookCaption()
                }
            }
        }
    }
}
