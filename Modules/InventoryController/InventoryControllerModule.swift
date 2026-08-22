import SwiftUI

struct InventoryLogoutActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var inventoryLogoutAction: () -> Void {
        get { self[InventoryLogoutActionKey.self] }
        set { self[InventoryLogoutActionKey.self] = newValue }
    }
}

public struct InventoryControllerModuleRootView: View {
    @StateObject private var appState = InventoryAppState()
    @StateObject private var shipmentsViewModel = ShipmentsViewModel()
    private let onLogout: () -> Void

    public init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
    }

    public var body: some View {
        MainTabView()
            .environmentObject(appState)
            .environmentObject(shipmentsViewModel)
            .environment(\.inventoryLogoutAction, onLogout)
    }
}
