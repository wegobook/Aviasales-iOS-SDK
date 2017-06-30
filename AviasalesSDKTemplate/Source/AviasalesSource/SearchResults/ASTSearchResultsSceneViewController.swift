//
//  ASTSearchResultsSceneViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTSearchResultsSceneViewController: UIViewController {

    @IBOutlet weak var ticketsContainerView: UIView!
    @IBOutlet weak var ticketContainerView: UIView!

    let searchResultsViewController: JRSearchResultsVC
    let ticketViewController: JRTicketVC

    init(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo) {
        searchResultsViewController = JRSearchResultsVC(searchInfo: searchInfo, response: searchResult)
        ticketViewController = JRTicketVC(searchInfo: searchInfo, searchID: searchResult.searchResultInfo.searchID)
        super.init(nibName: nil, bundle: nil)
        title = JRSearchInfoUtils.formattedIatasAndDates(for: searchInfo)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

    // MARK: - Setup

    func setupViewController() {
        setupNavigationItems()
        setupChildViewControllers()
    }

    func setupNavigationItems() {
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem()
    }

    func setupChildViewControllers() {
        searchResultsViewController.filterChangedBlock = { [weak self] (isEmptyResults) in
            self?.ticketsContainerView.isHidden = isEmptyResults
            self?.ticketContainerView.isHidden = isEmptyResults
        }
        searchResultsViewController.selectionBlock = { [weak self] (ticket) in
            self?.ticketViewController.setTicket(ticket)
        }
        addChild(viewController: searchResultsViewController, toContainer: ticketsContainerView)
        addChild(viewController: ticketViewController, toContainer: ticketContainerView)
    }

    func addChild(viewController: UIViewController, toContainer container: UIView) {
        self.addChildViewController(viewController)
        container.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        container.addConstraints(JRConstraintsMakeScaleToFill(viewController.view, container))
        viewController.didMove(toParentViewController: self)
    }
}
