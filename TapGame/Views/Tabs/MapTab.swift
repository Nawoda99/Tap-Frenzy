import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject private var store: SessionStore
    @State private var selectedID: UUID?
    @State private var position: MapCameraPosition = .automatic

    private var locatedSessions: [GameSession] { store.sessions.filter(\.hasLocation) }
    private var selectedSession: GameSession? { store.sessions.first { $0.id == selectedID } }

    var body: some View {
        Group {
            if locatedSessions.isEmpty {
                ContentUnavailableView(
                    "No Mapped Games",
                    systemImage: "map",
                    description: Text("Play a game with location access enabled to add a pin.")
                )
            } else {
                Map(position: $position, selection: $selectedID) {
                    ForEach(locatedSessions) { session in
                        Marker("\(session.mode.title): \(session.score)", systemImage: session.mode.icon, coordinate: session.coordinate)
                            .tint(.purple)
                            .tag(session.id)
                    }
                }
                .mapControls { MapCompass(); MapScale(); MapUserLocationButton() }
                .safeAreaInset(edge: .bottom) {
                    if let session = selectedSession {
                        HStack {
                            Label(session.mode.title, systemImage: session.mode.icon)
                            Spacer()
                            Text("Score \(session.score)").bold()
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Game Map")
    }
}
