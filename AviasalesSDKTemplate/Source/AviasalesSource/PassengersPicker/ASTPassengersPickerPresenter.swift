//
//  ASTPassengersPickerPresenter.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import Foundation

protocol ASTPassengersPickerViewProtocol: NSObjectProtocol {

    func update(viewModel: ASTPassengersPickerViewModel)
    func setupSlider(step: Int)
    func dismiss(passengersInfo: ASTPassengersInfo)
}

class ASTPassengersPickerPresenter {

    weak var view: ASTPassengersPickerViewProtocol?

    private let maxPassengersConut = 9

    fileprivate var adults: Int {
        didSet {
            if infants > adults {
                infants = adults
            }
        }
    }
    fileprivate var children: Int
    fileprivate var infants: Int
    fileprivate var travelClass: JRSDKTravelClass

    var shouldAllowAddPassengers: Bool {
        return (maxPassengersConut - adults - children - infants) > 0
    }

    init(passengersInfo: ASTPassengersInfo) {
        adults = passengersInfo.adults
        children = passengersInfo.children
        infants = passengersInfo.infants
        travelClass = passengersInfo.travelClass
    }

    func handleViewDidLoad(view: ASTPassengersPickerViewProtocol) {
        self.view = view
        view.update(viewModel: buildViewModel())
        view.setupSlider(step: travelClass.rawValue)
    }

    func handleDecrement(cellModel: ASTPassengersPickerCellModelProtocol) {
        applyDelta(delta: -1, type: cellModel.type)
    }

    func handleIncrement(cellModel: ASTPassengersPickerCellModelProtocol) {
        applyDelta(delta: 1, type: cellModel.type)
    }

    private func applyDelta(delta: Int, type: ASTPassengersPickerCellModelType) {

        switch type {
        case .adults:
            adults += delta
        case .children:
            children += delta
        case .infants:
            infants += delta
        }

        view?.update(viewModel: buildViewModel())
    }

    func handleChangeTravelClass(value: Int) {
        travelClass = JRSDKTravelClass(rawValue: value)!
    }

    func handleDone() {
        let passengersInfo = ASTPassengersInfo(adults: adults, children: children, infants: infants, travelClass: travelClass)
        view?.dismiss(passengersInfo: passengersInfo)
    }
}

private extension ASTPassengersPickerPresenter {

    func buildViewModel() -> ASTPassengersPickerViewModel {
        return ASTPassengersPickerViewModel(cellModels: buildCellModels())
    }

    func buildCellModels() -> [ASTPassengersPickerCellModelProtocol] {
        return [buildAdultsCellModel(), buildChildrenCellModel(), buildInfantsCellModel()]
    }

    func buildAdultsCellModel() -> ASTPassengersPickerCellModel {

        let title = NSLS("JR_PASSENGERS_PICKER_ADULTS_TITLE")
        let subtitle = NSLS("JR_PASSENGERS_PICKER_ADULTS_DESCRIPTION")
        let count = String(adults)
        let plusEnabled = shouldAllowAddPassengers
        let minusEnabled = adults > 1

        return ASTPassengersPickerCellModel(type: .adults, title: title, subtitle: subtitle, count: count, plusEnabled: plusEnabled, minusEnabled: minusEnabled)
    }

    func buildChildrenCellModel() -> ASTPassengersPickerCellModel {

        let title = NSLS("JR_PASSENGERS_PICKER_CHILDREN_TITLE")
        let subtitle = NSLS("JR_PASSENGERS_PICKER_CHILDREN_DESCRIPTION")
        let count = String(children)
        let plusEnabled = shouldAllowAddPassengers
        let minusEnabled = children > 0

        return ASTPassengersPickerCellModel(type: .children, title: title, subtitle: subtitle, count: count, plusEnabled: plusEnabled, minusEnabled: minusEnabled)
    }

    func buildInfantsCellModel() -> ASTPassengersPickerCellModel {

        let title = NSLS("JR_PASSENGERS_PICKER_INFANTS_TITLE")
        let subtitle = NSLS("JR_PASSENGERS_PICKER_INFANTS_DESCRIPTION")
        let count = String(infants)
        let plusEnabled = shouldAllowAddPassengers && adults > infants
        let minusEnabled = infants > 0

        return ASTPassengersPickerCellModel(type: .infants, title: title, subtitle: subtitle, count: count, plusEnabled: plusEnabled, minusEnabled: minusEnabled)
    }
}
