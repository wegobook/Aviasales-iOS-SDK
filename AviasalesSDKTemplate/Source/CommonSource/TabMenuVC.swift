import UIKit

class TabMenuVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        createItems()
    }

    func createItems() {
        var results: [UIViewController] = []

        tabBar.tintColor = JRColorScheme.navigationBarBackgroundColor()
        if ticketsEnabled() {
            let ticketsBarItem = UITabBarItem(title: NSLS("JR_SEARCH_FORM_TITLE"), image: #imageLiteral(resourceName: "plane_icon"), tag: 0)
            let ticketsVC = createTicketsVC()
            ticketsVC.tabBarItem = ticketsBarItem
            results.append(ticketsVC)
        }

        if hotelsEnabled() {
            let hotelsBarItem = UITabBarItem(title: NSLS("LOC_SEARCH_FORM_TITLE"), image: #imageLiteral(resourceName: "bed_icon"), tag: 0)
            let hotelsVC = createHotelsVC()
            hotelsVC.tabBarItem = hotelsBarItem
            results.append(hotelsVC)
        }

        let settingsBarItem = UITabBarItem(title: NSLS("LOC_SETTINGS_TITLE"), image: #imageLiteral(resourceName: "gear_icon"), tag: 0)
        let settingsVC = createSettingsVC()
        settingsVC.tabBarItem = settingsBarItem
        results.append(settingsVC)

        viewControllers = results
    }

    private func createTicketsVC() -> UIViewController {
        let rootViewController = iPhone() ? ASTContainerSearchFormViewController() : ASTSearchFormSceneViewController()
        return JRNavigationController(rootViewController: rootViewController)
    }

    private func createHotelsVC() -> UIViewController {
        let searchVC = iPad() ? HLIpadSearchVC() : HLSearchVC()
        let navVC = JRNavigationController(rootViewController: searchVC)

        return navVC
    }

    private func createSettingsVC() -> UIViewController {
        let settingsVC = HLProfileVC()
        let navVC = JRNavigationController(rootViewController: settingsVC)

        return navVC
    }
}
