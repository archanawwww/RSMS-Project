import UIKit

struct NavigationUtil {
    static func popToRootView() {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
        
        let rootViewController = keyWindow?.rootViewController
        findNavigationController(viewController: rootViewController)?
            .popToRootViewController(animated: true)
    }

    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }

        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }

        for childViewController in viewController.children {
            if let found = findNavigationController(viewController: childViewController) {
                return found
            }
        }

        return nil
    }
}
