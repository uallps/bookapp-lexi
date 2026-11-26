#if Sesiones && Progreso
import Foundation
import Observation

/// Plugin O5 (Sesiones de lectura). Registra las sesiones de cada libro en su propio fichero
/// y cada sesión hace avanzar el progreso de F1, de la que depende.
/// Como plugin de datos, borra las sesiones de un libro cuando se borra el libro.
@Observable
final class SessionsPlugin: DataPlugin {
    let name = "Sesiones de lectura"

    /// Las sesiones guardadas, de todos los libros. Cada cambio se guarda.
    private(set) var sessions: [ReadingSession] = [] {
        didSet { save() }
    }

    /// F1: las sesiones suman páginas a su progreso.
    @ObservationIgnored private let progress: ProgressPlugin
    @ObservationIgnored private let storage: JSONListStorage<ReadingSession>
    @ObservationIgnored private var loaded = false

    /// Por defecto guarda en sessions.json; en pruebas se le pasa otro fichero.
    init(progress: ProgressPlugin, storage: JSONListStorage<ReadingSession>? = nil) {
        self.progress = progress
        self.storage = storage ?? JSONListStorage(filename: "sessions.json")
        _Concurrency.Task { await loadSessions() }
    }

    /// Carga las sesiones guardadas, solo la primera vez.
    func loadSessions() async {
        guard !loaded else { return }
        loaded = true
        do {
            sessions = try await storage.load()
        } catch {
            print("\(name): no se han cargado las sesiones: \(error)")
        }
    }

    /// Registra una sesión y suma sus páginas al progreso del libro. Si el libro aún no
    /// tenía progreso, lo empieza (como el botón «Registrar progreso» de F1).
    func log(pages: Int, for bookID: UUID, on date: Date = .now) {
        guard pages > 0 else { return }
        sessions.append(ReadingSession(bookID: bookID, date: date, pages: pages))
        if progress.progress(for: bookID) == nil {
            progress.start(bookID: bookID)
        }
        progress.advance(bookID: bookID, by: pages)
    }

    /// Las sesiones de un libro, de la más antigua a la más reciente.
    func sessions(for bookID: UUID) -> [ReadingSession] {
        sessions.filter { $0.bookID == bookID }.sorted { $0.date < $1.date }
    }

    /// Días seguidos leyendo este libro hasta hoy.
    func streak(for bookID: UUID, today: Date = .now, calendar: Calendar = .current) -> Int {
        SessionStats.streak(of: sessions(for: bookID), today: today, calendar: calendar)
    }

    /// Páginas de este libro leídas esta semana.
    func pagesThisWeek(for bookID: UUID, today: Date = .now, calendar: Calendar = .current) -> Int {
        SessionStats.pagesThisWeek(of: sessions(for: bookID), today: today, calendar: calendar)
    }

    /// «Racha: 3 días · 85 págs esta semana».
    func summary(for bookID: UUID, today: Date = .now, calendar: Calendar = .current) -> String {
        SessionStats.summary(
            streak: streak(for: bookID, today: today, calendar: calendar),
            pagesThisWeek: pagesThisWeek(for: bookID, today: today, calendar: calendar))
    }

    // MARK: - DataPlugin: el registro nos avisa al borrar un libro

    func willDeleteBook(_ book: Book) {
        guard sessions.contains(where: { $0.bookID == book.id }) else { return }
        sessions.removeAll { $0.bookID == book.id }
        print("\(name): borradas las sesiones de «\(book.title)»")
    }

    func didDeleteBook(id: UUID) {}

    private func save() {
        let sessions = sessions
        _Concurrency.Task {
            do {
                try await storage.save(sessions)
            } catch {
                print("\(name): no se han guardado las sesiones: \(error)")
            }
        }
    }
}
#endif
