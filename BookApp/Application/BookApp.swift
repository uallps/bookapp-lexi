import SwiftUI

@main
struct BookApp: App {
    /// Una sola configuración para toda la app: la comparten Libros y Ajustes.
    @State private var config = AppConfig()
    @State private var selection: String? = "libros"
#if Progreso
    @State private var progress: ProgressPlugin
#endif
#if FechasLectura
    @State private var readingDates: ReadingDatesPlugin
#endif

    /// Los plugins se crean y se registran una sola vez, al arrancar la app.
    init() {
#if Progreso
        let progress = ProgressPlugin()
        PluginRegistry.shared.register(progress)
        _progress = State(wrappedValue: progress)
#endif
#if FechasLectura
        let readingDates = ReadingDatesPlugin()
        PluginRegistry.shared.register(readingDates)
        _readingDates = State(wrappedValue: readingDates)
#endif
    }

    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                BookListView(storageProvider: config.storageType.makeProvider())
                    // Las pestañas conservan su estado: al cambiar de almacenamiento se rehace la lista.
                    .id(config.storageType)
                    .tabItem { Label("Libros", systemImage: "books.vertical") }
                SettingsView()
                    .tabItem { Label("Ajustes", systemImage: "gearshape") }
            }
            .environment(config)
#if Progreso
            .environment(progress)
#endif
#if FechasLectura
            .environment(readingDates)
#endif
#else
            NavigationSplitView {
                List(selection: $selection) {
                    NavigationLink(value: "libros") {
                        Label("Libros", systemImage: "books.vertical")
                    }
                    NavigationLink(value: "ajustes") {
                        Label("Ajustes", systemImage: "gearshape")
                    }
                }
            } detail: {
                switch selection {
                case "libros":
                    // La lista se crea al elegir Libros, con el almacenamiento elegido en Ajustes.
                    BookListView(storageProvider: config.storageType.makeProvider())
                case "ajustes":
                    SettingsView()
                default:
                    Text("Elige una opción")
                }
            }
            .environment(config)
#if Progreso
            .environment(progress)
#endif
#if FechasLectura
            .environment(readingDates)
#endif
#endif
        }
    }
}
