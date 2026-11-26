import SwiftUI

/// Pantalla de Ajustes: activa o desactiva las características en ejecución.
struct SettingsView: View {
    @Environment(AppConfig.self) private var config

    var body: some View {
        @Bindable var config = config
        Form {
            Section(header: Text("Características")) {
#if Progreso
                Toggle("F1: Mostrar progreso de lectura", isOn: $config.enableProgress)
#endif
                Toggle("F2: por definir", isOn: $config.enableF2)
                Toggle("F3: por definir", isOn: $config.enableF3)
                Toggle("F4: por definir", isOn: $config.enableF4)
                Toggle("F5: por definir", isOn: $config.enableF5)
#if Favoritos
                Toggle("O1: Favoritos", isOn: $config.enableFavorites)
#endif
#if Sesiones && Progreso
                // Requiere F1: sin el progreso activado, las sesiones no se muestran.
                Toggle("O5: Sesiones de lectura", isOn: $config.enableSessions)
#endif
            }
#if canImport(SwiftData)
            // Solo en Apple hay dónde elegir; en Linux y Windows los libros van siempre en JSON.
            Section(header: Text("Almacenamiento")) {
                Picker("Guardar los libros en", selection: $config.storageType) {
                    ForEach(StorageType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
#endif
        }
        .navigationTitle("Ajustes")
    }
}
