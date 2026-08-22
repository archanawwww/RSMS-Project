import SwiftUI
import Combine

@MainActor
class InventoryAppState: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var selectedInventorySegment: Int = 0
    @Published var activeCycleCountSession: CycleCountSession? = nil
}


