#if Sesiones && Progreso
import Foundation
import Testing
@testable import BookApp

/// Progreso en memoria, para que las pruebas no escriban en la carpeta Documentos.
private final class InMemoryProgressStorage: ProgressStorageProvider {
    var stored: [BookProgress] = []
    func loadProgress() async throws -> [BookProgress] { stored }
    func saveProgress(_ progress: [BookProgress]) async throws { stored = progress }
}

@MainActor
@Suite("O5 · Sesiones de lectura")
struct SessionsPluginTests {
    /// Calendario fijo: UTC y semanas que empiezan en lunes.
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.firstWeekday = 2
        return calendar
    }()
    /// «Hoy» en las pruebas: jueves 26 de noviembre de 2026, a las 18:00.
    let today = Date(timeIntervalSince1970: 1_795_716_000)
    let bookID = UUID()
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("sessions-\(UUID().uuidString).json")

    private func daysAgo(_ days: Int, hour: Int = 0) -> Date {
        let start = calendar.startOfDay(for: today)
        let day = calendar.date(byAdding: .day, value: -days, to: start)!
        return calendar.date(byAdding: .hour, value: hour, to: day)!
    }

    private func session(_ days: Int, pages: Int = 10, hour: Int = 9) -> ReadingSession {
        ReadingSession(bookID: bookID, date: daysAgo(days, hour: hour), pages: pages)
    }

    private func streak(_ sessions: [ReadingSession]) -> Int {
        SessionStats.streak(of: sessions, today: today, calendar: calendar)
    }

    private func makePlugins() async -> (ProgressPlugin, SessionsPlugin) {
        let progress = ProgressPlugin(storageProvider: InMemoryProgressStorage())
        await progress.loadProgress()
        let sessions = SessionsPlugin(progress: progress, storage: JSONListStorage(fileURL: fileURL))
        await sessions.loadSessions()
        return (progress, sessions)
    }

    // MARK: - Racha

    @Test("Sin sesiones no hay racha")
    func streakEmpty() {
        #expect(streak([]) == 0)
    }

    @Test("Una sesión hoy es una racha de 1 día")
    func streakToday() {
        #expect(streak([session(0)]) == 1)
    }

    @Test("Si la última sesión fue ayer, la racha sigue viva")
    func streakYesterday() {
        #expect(streak([session(1)]) == 1)
    }

    @Test("Una sesión de hace tres días ya no cuenta")
    func streakThreeDaysAgo() {
        #expect(streak([session(3)]) == 0)
    }

    @Test("Días seguidos hasta hoy suman racha")
    func streakConsecutive() {
        #expect(streak([session(0), session(1), session(2)]) == 3)
        #expect(streak([session(1), session(2), session(3)]) == 3)
    }

    @Test("Dos sesiones el mismo día cuentan como un día")
    func streakSameDay() {
        #expect(streak([session(0, hour: 8), session(0, hour: 22), session(1)]) == 2)
    }

    @Test("Un día sin sesión rompe la racha")
    func streakGap() {
        #expect(streak([session(0), session(1), session(3), session(4)]) == 2)
    }

    // MARK: - Páginas de la semana

    @Test("Solo cuentan las páginas de esta semana (de lunes a hoy)")
    func pagesThisWeek() {
        // Hoy es jueves: lunes (hace 3 días) entra; el domingo anterior (hace 4) no.
        let sessions = [session(0, pages: 25), session(3, pages: 10), session(4, pages: 50)]
        #expect(SessionStats.pagesThisWeek(of: sessions, today: today, calendar: calendar) == 35)
    }

    @Test("Resumen con singular y plural")
    func summary() {
        #expect(SessionStats.summary(streak: 1, pagesThisWeek: 10) == "Racha: 1 día · 10 págs esta semana")
        #expect(SessionStats.summary(streak: 3, pagesThisWeek: 85) == "Racha: 3 días · 85 págs esta semana")
    }

    // MARK: - Plugin

    @Test("Registrar una sesión hace avanzar el progreso de F1")
    func logAdvancesProgress() async {
        let (progress, sessions) = await makePlugins()

        sessions.log(pages: 25, for: bookID, on: today)
        sessions.log(pages: 10, for: bookID, on: today)

        #expect(sessions.sessions(for: bookID).count == 2)
        #expect(progress.progress(for: bookID)?.currentPage == 35)
        #expect(sessions.summary(for: bookID, today: today, calendar: calendar) == "Racha: 1 día · 35 págs esta semana")
    }

    @Test("Una sesión sin páginas no se registra")
    func ignoresEmptySession() async {
        let (progress, sessions) = await makePlugins()

        sessions.log(pages: 0, for: bookID, on: today)
        #expect(sessions.sessions(for: bookID).isEmpty)
        #expect(progress.progress(for: bookID) == nil)
    }

    @Test("Al borrar un libro se borran sus sesiones y no las de otros")
    func deleteBook() async {
        let (_, sessions) = await makePlugins()
        let book = Book(id: bookID, title: "Fortunata y Jacinta")
        let other = UUID()
        sessions.log(pages: 10, for: book.id, on: today)
        sessions.log(pages: 10, for: other, on: today)

        sessions.willDeleteBook(book)
        #expect(sessions.sessions(for: book.id).isEmpty)
        #expect(sessions.sessions(for: other).count == 1)
    }

    @Test("Las sesiones se conservan al volver a abrir")
    func persistence() async throws {
        try await JSONListStorage<ReadingSession>(fileURL: fileURL).save([session(0, pages: 25)])

        let (_, reopened) = await makePlugins()
        #expect(reopened.sessions(for: bookID).map(\.pages) == [25])
        try? FileManager.default.removeItem(at: fileURL)
    }
}
#endif
