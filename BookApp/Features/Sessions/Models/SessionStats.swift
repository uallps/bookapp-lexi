#if Sesiones && Progreso
import Foundation

/// O5 (Sesiones): cálculos sobre las sesiones. Es Swift puro, sin vistas ni ficheros,
/// y recibe el día de hoy y el calendario para poder probarlo con fechas fijas.
enum SessionStats {
    /// Días seguidos con alguna sesión hasta hoy.
    /// - Varias sesiones el mismo día cuentan como un solo día.
    /// - Un día entero sin sesión rompe la racha.
    /// - Hoy todavía no ha terminado: si la última sesión fue ayer, la racha sigue viva.
    static func streak(of sessions: [ReadingSession], today: Date, calendar: Calendar) -> Int {
        let days = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: today)
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }
        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    /// Páginas leídas en la semana de hoy (la semana empieza según el calendario).
    static func pagesThisWeek(of sessions: [ReadingSession], today: Date, calendar: Calendar) -> Int {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else { return 0 }
        return sessions
            .filter { week.contains($0.date) }
            .reduce(0) { $0 + $1.pages }
    }

    /// Ejemplo: «Racha: 3 días · 85 págs esta semana».
    static func summary(streak: Int, pagesThisWeek: Int) -> String {
        let days = streak == 1 ? "1 día" : "\(streak) días"
        return "Racha: \(days) · \(pagesThisWeek) págs esta semana"
    }
}
#endif
