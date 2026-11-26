#if Favoritos
import Foundation

/// O1 (Favoritos): un libro marcado como favorito. Va aparte del libro y se une por su id:
/// el libro no sabe que existe.
struct FavoriteBook: Codable, Equatable {
    var bookID: UUID
}
#endif
