import SwiftUI

struct NoteEditorView: View {
    let productID: Int
    let title: String

    @Environment(NotesStore.self) private var notesStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            TextEditor(text: $draft)
                .focused($isFocused)
                .padding()
                .navigationTitle("\(title) Notu")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Vazgeç") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Kaydet") {
                            notesStore.setNote(draft, for: productID)
                            dismiss()
                        }
                    }
                }
        }
        .onAppear {
            draft = notesStore.note(for: productID)
            isFocused = true
        }
    }
}
