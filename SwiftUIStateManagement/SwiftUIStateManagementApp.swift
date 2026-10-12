import SwiftUI

@main
struct SwiftUIStateManagementApp: App {
    @State private var notesStore = NotesStore()
    @State private var favoritesStore = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(notesStore)
                .environment(favoritesStore)
        }
    }
}
