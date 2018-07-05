import UIKit

class TabMenuVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createItems()
    }

    func createItems() {
        var results: [UIViewController] = []

        tabBar.tintColor = JRColorScheme.mainColor()
        if ConfigManager.shared.flightsEnabled {
            let flightsVC = createFlightsVC()
            flightsVC.tabBarItem = UITabBarItem(title: NSLS("JR_SEARCH_FORM_TITLE"), image: #imageLiteral(resourceName: "plane_icon"), tag: 0)
            results.append(flightsVC)
        }

        if ConfigManager.shared.hotelsEnabled && !isRTLDirectionByLocale() {
            let hotelsVC = createHotelsVC()
            hotelsVC.tabBarItem = UITabBarItem(title: NSLS("LOC_SEARCH_FORM_TITLE"), image: #imageLiteral(resourceName: "bed_icon"), tag: 0)
            results.append(hotelsVC)
        }

        let infoScreenViewController = createInfoScreenViewController()
        infoScreenViewController.tabBarItem = UITabBarItem(title:  NSLS("LOC_INFO"), image: #imageLiteral(resourceName: "info_icon"), tag: 0)
        results.append(infoScreenViewController)

        viewControllers = results
    }

    private func createFlightsVC() -> UIViewController {
        let rootViewController = iPhone() ? ASTContainerSearchFormViewController() : ASTSearchFormSceneViewController()
        return JRNavigationController(rootViewController: rootViewController)
    }

    private func createHotelsVC() -> UIViewController {
        let searchVC = iPad() ? HLIpadSearchVC() : HLSearchVC()
        return JRNavigationController(rootViewController: searchVC)
    }

    private func createInfoScreenViewController() -> UIViewController {
        let infoScreenViewController = InfoScreenViewController()
        return JRNavigationController(rootViewController: infoScreenViewController)
    }
}
