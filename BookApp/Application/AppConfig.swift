import Foundation
import Observation

/// Feature flags en ejecución: qué características comunes (F1–F5) muestra la app y dónde guarda los libros.
/// Es configuración de la aplicación, no datos de los libros. Todas empiezan desactivadas y
/// cada valor se guarda en UserDefaults al cambiar, así que se conserva al cerrar y volver a abrir.
@Observable
final class AppConfig {
    var enableProgress: Bool {   // F1: Progreso
        didSet { store(enableProgress, forKey: "enableProgress") }
    }
    var enableF2: Bool {
        didSet { store(enableF2, forKey: "enableF2") }
    }
    var enableF3: Bool {
        didSet { store(enableF3, forKey: "enableF3") }
    }
    var enableF4: Bool {
        didSet { store(enableF4, forKey: "enableF4") }
    }
    var enableF5: Bool {
        didSet { store(enableF5, forKey: "enableF5") }
    }
#if FechasLectura
    var enableReadingDates: Bool {   // O10: Fechas de lectura
        didSet { store(enableReadingDates, forKey: "enableReadingDates") }
    }
#endif
    /// Dónde se guardan los libros. En UserDefaults se guarda su nombre ("JSON", "SwiftData").
    var storageType: StorageType {
        didSet { store(storageType.rawValue, forKey: "storageType") }
    }

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        enableProgress = defaults.object(forKey: "enableProgress") as? Bool ?? false
        enableF2 = defaults.object(forKey: "enableF2") as? Bool ?? false
        enableF3 = defaults.object(forKey: "enableF3") as? Bool ?? false
        enableF4 = defaults.object(forKey: "enableF4") as? Bool ?? false
        enableF5 = defaults.object(forKey: "enableF5") as? Bool ?? false
#if FechasLectura
        enableReadingDates = defaults.object(forKey: "enableReadingDates") as? Bool ?? false
#endif
        storageType = StorageType(rawValue: defaults.string(forKey: "storageType") ?? "") ?? .json
    }

    private func store(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: key)
        // En Linux y Windows, UserDefaults escribe en disco más tarde: lo forzamos ya.
        defaults.synchronize()
    }
}
