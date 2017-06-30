//
//  ASTDevSettingsVC.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 21/03/2017.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

import UIKit

struct Item {
    let name: String
    let scheme: ColorScheme
}

class ASTDevSettingsVC: UIViewController {

    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Developer Settings"
        items = buildItems()
    }

    func buildItems() -> [Item] {
        let black = Item(name: "Black", scheme: BlackColorScheme())
        let blue = Item(name: "Blue", scheme: BlueColorScheme())
        let purple = Item(name: "Purple", scheme: PurpleColorScheme())
        let custom = Item(name: "Custom", scheme: CustomColorScheme())

        return [black, blue, purple, custom]
    }

    func refreshTabBarVC() {
        if let delegate = UIApplication.shared.delegate as? JRAppDelegate, let tabBarVC = delegate.window.rootViewController as? TabMenuVC {
            UIApplication.shared.keyWindow?.tintColor = JRColorScheme.tintColor()
            tabBarVC.createItems()
        }
    }
}

extension ASTDevSettingsVC: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }
}

extension ASTDevSettingsVC: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        ColorSchemeConfigurator.shared.currentColorScheme = item.scheme
        refreshTabBarVC()
    }
}
