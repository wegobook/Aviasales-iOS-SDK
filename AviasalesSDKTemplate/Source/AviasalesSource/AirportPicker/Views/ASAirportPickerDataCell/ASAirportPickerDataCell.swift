//
//  ASAirportPickerDataCell.swift
//  AviasalesSDKTemplate
//
//  Created by Dim on 03.07.17.
//  Copyright © 2017 Go Travel Un Limited. All rights reserved.
//

import UIKit

protocol ASAirportPickerDataCellProtocol {
    var city: String? { get }
    var airport: String? { get }
    var iata: String { get }
}

class ASAirportPickerDataCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var iataLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        cityLabel.textColor = JRColorScheme.darkTextColor()
        airportLabel.textColor = JRColorScheme.lightTextColor()
        iataLabel.textColor = JRColorScheme.darkTextColor()
    }

    func setup(cellModel: ASAirportPickerDataCellProtocol) {
        cityLabel.text = cellModel.city
        airportLabel.text = cellModel.airport
        iataLabel.text = cellModel.iata
    }
}
