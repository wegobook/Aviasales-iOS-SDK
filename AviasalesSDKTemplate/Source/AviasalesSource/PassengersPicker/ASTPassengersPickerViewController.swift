//
//  ASTPassengersPickerViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

@objcMembers
class ASTPassengersPickerViewController: UIViewController {

    fileprivate let presenter: ASTPassengersPickerPresenter
    fileprivate var viewModel: ASTPassengersPickerViewModel?

    fileprivate let selection: (ASTPassengersInfo) -> Void

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var sliderView: ASTPassengersPickerSliderView!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var separatorViewHeightConstraint: NSLayoutConstraint!

    init(passengersInfo: ASTPassengersInfo, selection: @escaping (ASTPassengersInfo) -> Void ) {
        self.presenter = ASTPassengersPickerPresenter(passengersInfo: passengersInfo)
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.handleViewDidLoad(view: self)
    }

    // MARK: - Setup

    func setupViewController() {
        setupConstraints()
        setupTableView()
        setupDoneButton()
    }

    func setupConstraints() {
        separatorViewHeightConstraint.constant = JRPixel()
    }

    func setupTableView() {
        tableView.backgroundColor = .white
    }

    func setupDoneButton() {
        doneButton.tintColor = JRColorScheme.mainColor()
    }

    // MARK: - Cells

    func buildCell(cellModel: ASTPassengersPickerCellModel?) -> ASTPassengersPickerTableViewCell {

        guard let cellModel = cellModel else {
            return ASTPassengersPickerTableViewCell()
        }

        guard let cell = ASTPassengersPickerTableViewCell.loadFromNib() else {
            return ASTPassengersPickerTableViewCell()
        }

        cell.passengersTitleLabel.text = cellModel.title
        cell.passengersSubtitleLabel.text = cellModel.subtitle
        cell.minusButton.isEnabled = cellModel.minusEnabled
        cell.plusButton.isEnabled = cellModel.plusEnabled
        cell.countLabel.text = cellModel.count

        cell.minusAction = { [weak self] (sender) in
            self?.presenter.handleDecrement(cellModel: cellModel)
        }

        cell.plusAction = { [weak self] (sender) in
            self?.presenter.handleIncrement(cellModel: cellModel)
        }

        return cell
    }

    // MARK: - Actions

    @IBAction func doneButtonTapped(_ sender: UIButton) {
        presenter.handleDone()
    }
}

extension ASTPassengersPickerViewController: ASTPassengersPickerViewProtocol {

    func update(viewModel: ASTPassengersPickerViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }

    func setupSlider(step: Int) {
        sliderView.setup(step: step)
        sliderView.valueChanged = { [weak self] (value) in
            self?.presenter.handleChangeTravelClass(value: value)
        }
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    func dismiss(passengersInfo: ASTPassengersInfo) {
        selection(passengersInfo)
        dismiss(animated: true, completion: nil)
    }
}

extension ASTPassengersPickerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cellModels.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel?.cellModels[indexPath.row] as? ASTPassengersPickerCellModel
        return buildCell(cellModel: cellModel)
    }
}
