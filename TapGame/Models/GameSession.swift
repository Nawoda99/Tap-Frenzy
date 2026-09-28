import Foundation
import CoreLocation

struct GameSession: Identifiable, Codable, Hashable {
    let id: UUID
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double

    init(
        id: UUID = UUID(),
        mode: GameMode,
        score: Int,
        timestamp: Date = Date(),
        coordinate: CLLocationCoordinate2D?
    ) {
        self.id = id
        self.mode = mode
        self.score = score
        self.timestamp = timestamp
        latitude = coordinate?.latitude ?? 0
        longitude = coordinate?.longitude ?? 0
    }

    var hasLocation: Bool { latitude != 0 || longitude != 0 }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
