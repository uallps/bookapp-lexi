#if Deseos
import Foundation

struct WishItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var author: String
    var note: String
}
#endif
