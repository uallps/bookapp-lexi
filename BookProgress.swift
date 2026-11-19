import SwiftUI

/// Fila de un libro. No conoce el ViewModel: recibe los flags, el texto de F1 y la acción.
struct BookRowView: View {
    let book: Book
    let showProgress: Bool
    let progressText: String?
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
                // Punto de variación en ejecución (F1): solo se muestra si el flag está activo.
                if showProgress, let progressText {
                    Text(progressText)
                        .bookCaption()
                }
            }
        }
    }
}
