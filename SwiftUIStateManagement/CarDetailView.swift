import SwiftUI

struct CarDetailView: View {
    let product: Product
    @Environment(NotesStore.self) private var notesStore
    @State private var showNoteSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TabView {
                    ForEach(product.images, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                // Commute denemesi için
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(height: 250)
                Text(product.title)
                    .font(.title)
                    .bold()
                Text("\(product.brand ?? "-") • $\(product.price, specifier: "%.2f")")
                    .font(.title3)
                    .foregroundStyle(.blue)
                Text("⭐️ \(product.rating, specifier: "%.2f")   •   Stok: \(product.stock)")
                    .foregroundStyle(.secondary)
                Text("Boyutlar: \(product.dimensions.width, specifier: "%.1f") × \(product.dimensions.height, specifier: "%.1f") × \(product.dimensions.depth, specifier: "%.1f")")
                    .foregroundStyle(.secondary)
                Text("Açıklama")
                    .font(.headline) // 
                Text(product.description)
                Text("Yorumlar")
                    .font(.headline)
                ForEach(product.reviews, id: \.self) { review in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(review.reviewerName) (\(review.rating)/5)")
                            .bold()
                        Text(review.comment)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNoteSheet = true
                } label: {
                    Image(systemName: notesStore.note(for: product.id).isEmpty
                          ? "square.and.pencil"
                          : "pencil.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showNoteSheet) {
            NoteEditorView(productID: product.id, title: product.title)
        }
    }
}
