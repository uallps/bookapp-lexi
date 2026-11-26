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
    /// Dónde se guardan los libros. En UserDefaults se guarda su nombre ("JSON", "SwiftData").
    var storageType: StorageType {
        didSet { store(storageType.rawValue, forKey: "storageType") }
    }
#if Busqueda
    var enableBusqueda: Bool {   // O6: Búsqueda y ordenación
        didSet { store(enableBusqueda, forKey: "enableBusqueda") }
    }
#endif

    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        enableProgress = defaults.object(forKey: "enableProgress") as? Bool ?? false
        enableF2 = defaults.object(forKey: "enableF2") as? Bool ?? false
        enableF3 = defaults.object(forKey: "enableF3") as? Bool ?? false
        enableF4 = defaults.object(forKey: "enableF4") as? Bool ?? false
        enableF5 = defaults.object(forKey: "enableF5") as? Bool ?? false
        storageType = StorageType(rawValue: defaults.string(forKey: "storageType") ?? "") ?? .json
#if Busqueda
        enableBusqueda = defaults.object(forKey: "enableBusqueda") as? Bool ?? false
#endif
    }

    private func store(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: key)
        // En Linux y Windows, UserDefaults escribe en disco más tarde: lo forzamos ya.
        defaults.synchronize()
    }
}
