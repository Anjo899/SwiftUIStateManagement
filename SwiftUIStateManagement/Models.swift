import Foundation

nonisolated struct ProductResponse: Codable {
    let products: [Product]
}

nonisolated struct Product: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let brand: String?
    let rating: Double
    let stock: Int
    let thumbnail: String
    let images: [String]
    let dimensions: Dimensions
    let reviews: [Review]
}

nonisolated struct Dimensions: Codable, Hashable {
    let width: Double
    let height: Double
    let depth: Double
}

nonisolated struct Review: Codable, Hashable {
    let rating: Int
    let comment: String
    let reviewerName: String
}
