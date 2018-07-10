//
//  ASTPassengersPickerSliderView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTPassengersPickerSliderView: UIView {

    @IBOutlet private var view: UIView!
    @IBOutlet private weak var sliderView: UIView!

    var valueChanged: ((Int) -> Void)?

    private let steps = [JRSDKTravelClass.economy.rawValue, JRSDKTravelClass.premiumEconomy.rawValue, JRSDKTravelClass.business.rawValue, JRSDKTravelClass.first.rawValue]

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

    func loadViewFromNib() {
        view = Bundle.main.loadNibNamed("ASTPassengersPickerSliderView", owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }

    func setup(step: Int) {
        create(steps: steps, step: step)
    }

    private func create(steps: [Int], step: Int) {

        let slider = GCXSteppedSlider(frame: bounds, stepValues: steps, initialStep: step)

        slider.tintColor = JRColorScheme.mainColor()
        slider.signatureColor = JRColorScheme.sliderBackgroundColor()
        slider.delegate = self

        sliderView.addSubview(slider)

        slider.translatesAutoresizingMaskIntoConstraints = false

        slider.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor, constant: 15).isActive = true
        slider.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: 0).isActive = true
        slider.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor, constant: -15).isActive = true
        slider.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: 0).isActive = true
    }
}

extension ASTPassengersPickerSliderView: GCXSteppedSliderDelegate {

    func steppedSlider(_ slider: GCXSteppedSlider, valueChanged selectedValue: Any?) {
        guard let intValue = selectedValue as? Int else {
            return
        }
        valueChanged?(intValue)
    }

    func steppedSlider(_ slider: GCXSteppedSlider, stepImageForValue stepValue: Any?) -> UIImage? {
        return UIImage(named: "slider_step_icon")
    }

    func steppedSlider(_ slider: GCXSteppedSlider, sizeForStepImageOfValue stepValue: Any?) -> CGSize {
        return CGSize(width: 10, height: 10)
    }
}
