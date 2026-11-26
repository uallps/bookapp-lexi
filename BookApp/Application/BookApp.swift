import SwiftUI

@main
struct BookApp: App {
    /// Una sola configuración para toda la app: la comparten Libros y Ajustes.
    @State private var config: AppConfig
    @State private var bookViewModel: BookListViewModel
    @State private var selection: String? = "libros"
#if Deseos
    @State private var wishlist: WishlistPlugin
#endif
#if Progreso
    @State private var progress: ProgressPlugin
#endif

    /// Los plugins se crean y se registran una sola vez, al arrancar la app.
    init() {
        let config = AppConfig()
        _config = State(wrappedValue: config)
        _bookViewModel = State(wrappedValue: BookListViewModel(storageProvider: config.storageType.makeProvider()))
#if Deseos
        _wishlist = State(wrappedValue: WishlistPlugin())
#endif
#if Progreso
        let progress = ProgressPlugin()
        PluginRegistry.shared.register(progress)
        _progress = State(wrappedValue: progress)
#endif
    }

    var body: some Scene {
        WindowGroup {
#if os(iOS)
            TabView {
                BookListView(viewModel: bookViewModel)
                    .tabItem { Label("Libros", systemImage: "books.vertical") }
#if Deseos
                if config.enableWishlist {
                    WishlistView(addBook: { bookViewModel.addBook(title: $0, author: $1) })
                        .tabItem { Label("Deseos", systemImage: "heart") }
                        .environment(wishlist)
                }
#endif
                SettingsView()
                    .tabItem { Label("Ajustes", systemImage: "gearshape") }
            }
            .environment(config)
#if Progreso
            .environment(progress)
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
#if Deseos
                    if config.enableWishlist {
                        NavigationLink(value: "deseos") {
                            Label("Deseos", systemImage: "heart")
                        }
                    }
#endif
                }
            } detail: {
                switch selection {
                case "libros":
                    // La lista se crea al elegir Libros, con el almacenamiento elegido en Ajustes.
                    BookListView(viewModel: bookViewModel)
#if Deseos
                case "deseos":
                    if config.enableWishlist {
                        WishlistView(addBook: { bookViewModel.addBook(title: $0, author: $1) })
                            .environment(wishlist)
                    } else {
                        Text("Activa la lista de deseos en Ajustes")
                    }
#endif
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
#endif
            .onChange(of: config.storageType) { _, storageType in
                bookViewModel = BookListViewModel(storageProvider: storageType.makeProvider())
            }
        }
    }
}
