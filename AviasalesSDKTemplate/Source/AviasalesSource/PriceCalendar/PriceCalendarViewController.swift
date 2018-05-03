//
//  PriceCalendarViewController.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 12.02.2018.
//  Copyright © 2018 Go Travel Un Limited. All rights reserved.
//

import UIKit

@objcMembers
class PriceCalendarViewController: UIViewController {

    fileprivate let presenter: PriceCalendarPresenter

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: LoadingView!

    var dismissCallback: ((JRSDKSearchInfo) -> Void)?

    fileprivate var cellModels = [PriceCalendarCellModelProtocol]()

    init(searchInfo: JRSDKSearchInfo) {
        presenter = PriceCalendarPresenter(searchInfo: searchInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.attach(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 235)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData() // this fixes tableHeaderView height issue
    }

    private func setup() {
        navigationItem.backBarButtonItem = UIBarButtonItem.backBarButtonItem()
        tableView.tableHeaderView = PriceCalendarChartHeader.loadFromNib()
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
    }
}

private extension PriceCalendarViewController {

    func buildAverageCell(from cellModel: PriceCalendarAverageCellModel) -> PriceCalendarAverageCell {
        guard let cell = PriceCalendarAverageCell.loadFromNib() else {
            fatalError()
        }
        cell.setup(cellModel)
        return cell
    }

    func buildDirectCell(from cellModel: PriceCalendarDirectCellModel) -> PriceCalendarDirectCell {
        guard let cell = PriceCalendarDirectCell.loadFromNib() else {
            fatalError()
        }
        cell.setup(cellModel) { [weak self] (sender) in
            self?.presenter.directSwitch()
        }
        return cell
    }

    func buildResultCell(from cellModel: PriceCalendarResultCellModel) -> PriceCalendarResultCell {
        guard let cell = PriceCalendarResultCell.loadFromNib() else {
            fatalError()
        }
        cell.setup(cellModel)
        return cell
    }

    func buildCardCell(from cellModel: PriceCalendarCardCellModel) -> PriceCalendarCardCell {
        guard let cell = PriceCalendarCardCell.loadFromNib(), let view = ActionCardView.loadFromNib() else {
            fatalError()
        }
        view.setup(cellModel.viewModel)
        view.action = { [weak self] (_) in
            self?.presenter.returnDate()
        }
        cell.setup(view)
        return cell
    }
}

extension PriceCalendarViewController: PriceCalendarViewProtocol {

    func set(title: String) {
        navigationItem.title = title
    }

    func showLoading() {
        tableView.isUserInteractionEnabled = false
        loadingView.isHidden = false

    }

    func hideLoading() {
        loadingView.isHidden = true
        tableView.isUserInteractionEnabled = true
    }

    func set(cellModels: [PriceCalendarCellModelProtocol]) {
        self.cellModels = cellModels
        tableView.reloadData()
    }

    func showWaiting(with searchInfo: JRSDKSearchInfo) {
        if iPhone() {
            let waitingScreenViewController = ASTWaitingScreenViewController(searchInfo: searchInfo)
            navigationController?.setViewControllersWithRootAndView(waitingScreenViewController)
        } else {
            dismiss(animated: true) { [weak self] in
                self?.dismissCallback?(searchInfo)
            }
        }
    }

    func showDatePicker(with departureDate: Date) {
        let datePickerViewController = JRDatePickerVC(mode: .return, borderDate: departureDate, firstDate: departureDate, secondDate: nil) { [weak self] (returnDate) in
            self?.presenter.search(departureDate: departureDate, returnDate: returnDate)
        }
        navigationController?.pushViewController(datePickerViewController!, animated: true)
    }
}

extension PriceCalendarViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = cellModels[indexPath.row]
        switch cellModel.type {
        case .average:
            return buildAverageCell(from: cellModel as! PriceCalendarAverageCellModel)
        case .direct:
            return buildDirectCell(from: cellModel as! PriceCalendarDirectCellModel)
        case .result:
            return buildResultCell(from: cellModel as! PriceCalendarResultCellModel)
        case .card:
            return buildCardCell(from: cellModel as! PriceCalendarCardCellModel)
        }
    }
}

extension PriceCalendarViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellModel = cellModels[indexPath.row]
        presenter.select(cellModel)
    }
}
