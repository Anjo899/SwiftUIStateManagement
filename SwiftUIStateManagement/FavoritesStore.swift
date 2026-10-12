import Foundation
import Observation

@Observable
class FavoritesStore {
    private(set) var favorites: [String: Bool] = [:]

    private let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Favorites.plist")

    init() { load() }

    func isFavorite(_ id: Int) -> Bool {
        favorites[String(id)] ?? false
    }

    func toggle(_ id: Int) {
        let key = String(id)
        favorites[key] = (favorites[key] == true) ? nil : true
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let saved = try? PropertyListDecoder().decode([String: Bool].self, from: data)
        else { return }
        favorites = saved
    }

    private func save() {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            try encoder.encode(favorites).write(to: url)
            print("Favoriler kaydedildi:", url.path)
        } catch {
            print("Favori kayıt hatası:", error)
        }
    }
}
