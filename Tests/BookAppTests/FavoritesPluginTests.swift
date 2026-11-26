#if Favoritos
import Foundation
import Testing
@testable import BookApp

@MainActor
@Suite("O1 · Favoritos")
struct FavoritesPluginTests {
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent("favorites-\(UUID().uuidString).json")

    private func makePlugin() async -> FavoritesPlugin {
        let plugin = FavoritesPlugin(storage: JSONListStorage(fileURL: fileURL))
        await plugin.loadFavorites()
        return plugin
    }

    @Test("Marcar y desmarcar un libro")
    func toggle() async {
        let plugin = await makePlugin()
        let book = Book(title: "Rayuela")

        plugin.toggle(book.id)
        #expect(plugin.isFavorite(book.id))
        plugin.toggle(book.id)
        #expect(!plugin.isFavorite(book.id))
    }

    @Test("Marcar dos veces no duplica el favorito")
    func noDuplicates() async {
        let plugin = await makePlugin()
        let id = UUID()

        plugin.setFavorite(true, for: id)
        plugin.setFavorite(true, for: id)
        #expect(plugin.items.count == 1)
    }

    @Test("El filtro deja pasar todo hasta que se activa «Solo favoritos»")
    func filter() async {
        let plugin = await makePlugin()
        let favorite = Book(title: "Ficciones")
        let other = Book(title: "Pedro Páramo")
        plugin.toggle(favorite.id)

        #expect([favorite, other].filter(plugin.matches).count == 2)
        plugin.onlyFavorites = true
        #expect([favorite, other].filter(plugin.matches).map(\.id) == [favorite.id])
        #expect(plugin.count(in: [favorite, other]) == 1)
    }

    @Test("Al borrar un libro se quita de favoritos")
    func deleteBook() async {
        let plugin = await makePlugin()
        let book = Book(title: "La Regenta")
        plugin.toggle(book.id)

        plugin.willDeleteBook(book)
        #expect(!plugin.isFavorite(book.id))
    }

    @Test("Los favoritos se conservan al volver a abrir")
    func persistence() async throws {
        let id = UUID()
        let storage = JSONListStorage<FavoriteBook>(fileURL: fileURL)
        try await storage.save([FavoriteBook(bookID: id)])

        let reopened = await makePlugin()
        #expect(reopened.isFavorite(id))
        #expect(!reopened.onlyFavorites)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
#endif
