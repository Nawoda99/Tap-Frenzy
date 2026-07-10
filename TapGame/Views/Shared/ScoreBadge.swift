import SwiftUI

struct ScoreBadge: View {
    let label: String
    let value: String
    var icon: String? = nil

    var body: some View {
        VStack(spacing: 5) {
            if let icon { Image(systemName: icon).foregroundStyle(.purple) }
            Text(value).font(.title2.monospacedDigit().bold())
            Text(label.uppercased()).font(.caption2.bold()).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
