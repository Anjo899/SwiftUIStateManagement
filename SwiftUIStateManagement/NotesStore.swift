import Foundation
import Observation

@Observable
class NotesStore {
    private(set) var notes: [String: String] = [:]

    private let url = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("Notes.plist")

    init() { load() }

    func note(for id: Int) -> String {
        notes[String(id)] ?? ""
    }

    func setNote(_ text: String, for id: Int) {
        let temiz = text.trimmingCharacters(in: .whitespacesAndNewlines)
        notes[String(id)] = temiz.isEmpty ? nil : temiz
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url),
              let saved = try? PropertyListDecoder().decode([String: String].self, from: data)
        else { return }
        notes = saved
    }

    private func save() {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            try encoder.encode(notes).write(to: url)
            print("Not kaydedildi:", url.path)
        } catch {
            print("Not kayıt hatası:", error)
        }
    }
}
