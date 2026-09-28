import SwiftUI
import MapKit

struct MapTab: View {
    @EnvironmentObject private var store: SessionStore
    @State private var selectedSession: GameSession?
    @State private var position: MapCameraPosition = .automatic

    private var locatedSessions: [GameSession] { store.sessions.filter(\.hasLocation) }

    var body: some View {
        VStack {
            if locatedSessions.isEmpty {
                Spacer()
                Image(systemName: "map")
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)
                Text("No Mapped Games")
                    .font(.title2.bold())
                Text("Play a game with location access enabled to add a pin.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            } else {
                Map(position: $position) {
                    ForEach(locatedSessions) { session in
                        Annotation(session.mode.title, coordinate: session.coordinate) {
                            Button {
                                selectedSession = session
                            } label: {
                                Image(systemName: session.mode.icon)
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.purple, in: Circle())
                                    .shadow(radius: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .mapControls { MapCompass(); MapScaleView(); MapUserLocationButton() }
            }
        }
        .navigationTitle("Game Map")
        .sheet(item: $selectedSession) { session in
            VStack(spacing: 18) {
                Image(systemName: session.mode.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(.purple)
                Text(session.mode.title).font(.title.bold())
                Text("Score: \(session.score)").font(.title2)
                Text(session.timestamp, style: .date).foregroundStyle(.secondary)
            }
            .padding(30)
            .presentationDetents([.medium])
        }
    }
}
