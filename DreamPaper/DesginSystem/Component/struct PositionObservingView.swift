import Combine
import SwiftUI

struct OffsetObservingScrollView<Content: View>: View {
    var axes: Axis.Set = [.vertical]
    var showsIndicators = true
    @Binding var offset: CGPoint
    @ViewBuilder var content: () -> Content

    private let coordinateSpaceName = UUID()

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            PositionObservingView(
                coordinateSpace: .named(coordinateSpaceName),
                position: Binding(
                    get: { offset },
                    set: { newOffset in
                        offset = CGPoint(x: -newOffset.x, y: -newOffset.y)
                    }
                ),
                content: content
            )
        }
        .coordinateSpace(name: coordinateSpaceName)
    }
}

struct PositionObservingView<Content: View>: View {
    var coordinateSpace: CoordinateSpace
    @Binding var position: CGPoint
    @ViewBuilder var content: () -> Content

    @StateObject private var debouncedPosition = DebouncedPosition()

    var body: some View {
        content()
            .background(GeometryReader { geometry in
                Color.clear.preference(
                    key: PreferenceKey.self,
                    value: geometry.frame(in: coordinateSpace).origin
                )
            })
            .onPreferenceChange(PreferenceKey.self) { newPosition in
                debouncedPosition.update(newPosition)
            }
            .onReceive(debouncedPosition.$debouncedPosition) { debouncedPosition in
                self.position = debouncedPosition
            }
    }
}

private extension PositionObservingView {
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGPoint { .zero }

        static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
            // No-op
        }
    }
}

class DebouncedPosition: ObservableObject {
    @Published var debouncedPosition: CGPoint = .zero
    private var cancellable: AnyCancellable?

    init() {
        cancellable = $debouncedPosition
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] value in
                self?.objectWillChange.send()
                if value.y > 20 {
                    self?.debouncedPosition = value
                }
            }
    }

    func update(_ newPosition: CGPoint) {
        debouncedPosition = newPosition
    }
}
