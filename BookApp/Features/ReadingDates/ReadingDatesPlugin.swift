#if FechasLectura
import Foundation
import Observation

/// Plugin O10 (Fechas de lectura). Guarda las fechas de inicio y fin de lectura
/// de cada libro y reacciona a los cambios de estado.
/// Cumple DataPlugin (para limpiar al borrar) y StatusPlugin (para registrar fechas).
@Observable
final class ReadingDatesPlugin: DataPlugin, StatusPlugin {
    let name = "Fechas de lectura"

    /// Las fechas guardadas. Cada cambio se guarda.
    private(set) var items: [ReadingDates] = [] {
        didSet { save() }
    }

    @ObservationIgnored private let storageProvider: ReadingDatesStorageProvider
    @ObservationIgnored private var loaded = false

    init(storageProvider: ReadingDatesStorageProvider = JSONReadingDatesStorageProvider()) {
        self.storageProvider = storageProvider
        _Concurrency.Task { await loadDates() }
    }

    /// Carga las fechas guardadas, solo la primera vez.
    func loadDates() async {
        guard !loaded else { return }
        loaded = true
        do {
            items = try await storageProvider.loadDates()
        } catch {
            print("No se han cargado las fechas de lectura: \(error)")
        }
    }

    /// Las fechas de un libro, si tiene.
    func dates(for bookID: UUID) -> ReadingDates? {
        items.first { $0.bookID == bookID }
    }

    // MARK: - StatusPlugin: reacción al cambio de estado

    func didChangeStatus(of book: Book, to status: ReadingStatus) {
        let now = Date()

        switch status {
        case .reading:
            // Al pasar a Leyendo: guardar startedAt (si no tenía ya).
            if let index = items.firstIndex(where: { $0.bookID == book.id }) {
                if items[index].startedAt == nil {
                    items[index].startedAt = now
                }
                // Limpiar finishedAt por si volvió de Leído a Leyendo.
                items[index].finishedAt = nil
            } else {
                items.append(ReadingDates(bookID: book.id, startedAt: now, finishedAt: nil))
            }

        case .finished:
            // Al pasar a Leído: guardar finishedAt (y startedAt si faltaba).
            if let index = items.firstIndex(where: { $0.bookID == book.id }) {
                if items[index].startedAt == nil {
                    items[index].startedAt = now
                }
                items[index].finishedAt = now
            } else {
                items.append(ReadingDates(bookID: book.id, startedAt: now, finishedAt: now))
            }

        case .pending:
            // Al volver a Pendiente: limpiar las fechas.
            items.removeAll { $0.bookID == book.id }
        }
    }

    // MARK: - DataPlugin: borrar datos al borrar un libro

    func willDeleteBook(_ book: Book) {
        guard dates(for: book.id) != nil else { return }
        items.removeAll { $0.bookID == book.id }
        print("\(name): borradas las fechas de «\(book.title)»")
    }

    func didDeleteBook(id: UUID) {
        print("\(name): el libro \(id) ya no existe")
    }

    // MARK: - Persistencia

    private func save() {
        let items = items
        _Concurrency.Task {
            do {
                try await storageProvider.saveDates(items)
            } catch {
                print("No se han guardado las fechas de lectura: \(error)")
            }
        }
    }
}
#endif
