import SwiftUI

// YENİ: üstteki iki sekme
enum ListTab: String, CaseIterable {
    case all = "Ana Menü"
    case favorites = "Favoriler"
}
enum SortOption: String, CaseIterable {
    case none = "Varsayılan"
    case priceAscending = "Fiyat (artan)"
    case priceDescending = "Fiyat (azalan)"
    case rating = "Puan"
    case name = "İsim"
}

struct ContentView: View {
    @Environment(FavoritesStore.self) private var favoritesStore
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTab: ListTab = .all
    @State private var searchText = ""
    @State private var sortOption: SortOption = .none
    private var displayedProducts: [Product] {
        var result: [Product]
        switch selectedTab {
        case .all:
            result = products
        case .favorites:
            var seen = Set<Int>()
            result = products.filter { favoritesStore.isFavorite($0.id) && seen.insert($0.id).inserted }
        }

        let query = searchText.trimmingCharacters(in: .whitespaces)
        if !query.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.brand ?? "").localizedCaseInsensitiveContains(query)
            }
        }

        switch sortOption {
        case .none:
            break
        case .priceAscending:
            result.sort { $0.price < $1.price }
        case .priceDescending:
            result.sort { $0.price > $1.price }
        case .rating:
            result.sort { $0.rating > $1.rating }
        case .name:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Liste", selection: $selectedTab) {
                    ForEach(ListTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                Group {
                    if isLoading {
                        ProgressView("Araçlar yükleniyor...")
                            .frame(maxHeight: .infinity)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .frame(maxHeight: .infinity)
                    } else if !searchText.isEmpty && displayedProducts.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else if selectedTab == .favorites && displayedProducts.isEmpty {
                        ContentUnavailableView(
                            "Favori yok",
                            systemImage: "star",
                            description: Text("Bir aracı favorilere eklemek için yanındaki yıldıza bas.")
                        )
                    } else {
                        List(Array(displayedProducts.enumerated()), id: \.offset) { _, product in
                            NavigationLink(value: product) {
                                CarRow(product: product)
                            }
                        }
                        .refreshable {
                            await loadProducts(showLoading: false)
                        }
                    }
                }
            }
            .navigationTitle("Ana Sayfa")
            .searchable(text: $searchText, prompt: "Araç veya marka ara")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sırala", selection: $sortOption) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .navigationDestination(for: Product.self) { product in
                CarDetailView(product: product)
            }
        }
        .task {
            await loadProducts()
        }
    }

    private func loadProducts(showLoading: Bool = true) async {
        if showLoading { isLoading = true }
        defer { isLoading = false }
        errorMessage = nil
        do {
            let url = URL(string: "https://dummyjson.com/products/category/vehicle")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let fetched = try JSONDecoder().decode(ProductResponse.self, from: data).products
            products = Array(repeating: fetched, count: 16).flatMap { $0 }
        } catch {
            errorMessage = "Araçlar yüklenemedi"
        }
    }
}

struct CarRow: View {
    let product: Product
    @Environment(FavoritesStore.self) private var favoritesStore
    var body: some View {
        HStack(spacing: 12) {
            Button {
                favoritesStore.toggle(product.id)
            } label: {
                Image(systemName: favoritesStore.isFavorite(product.id) ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(.yellow)
            }
            .buttonStyle(.borderless)

            AsyncImage(url: URL(string: product.thumbnail)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Image(systemName: "car.fill")
                    .foregroundStyle(.gray)
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                Text("\(product.brand ?? "-") • $\(product.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(NotesStore())
        .environment(FavoritesStore())
}
