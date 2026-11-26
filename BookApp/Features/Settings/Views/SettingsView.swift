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
#if Importar
                Toggle("O8: Importar biblioteca", isOn: $config.enableImport)
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
