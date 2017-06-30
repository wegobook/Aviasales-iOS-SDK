//
//  ASTPassengersPickerSliderView.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit
import GCXSteppedSlider

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

        let slider = GCXSteppedSlider.init(frame: bounds, stepValues: steps, initialStep: step)

        slider.tintColor = JRColorScheme.navigationBarBackgroundColor()
        slider.signatureColor = JRColorScheme.sliderBackgroundColor()
        slider.delegate = self
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliderView .addSubview(slider)

        let views = ["slider" : slider]
        sliderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[slider]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        let horizontalMetrics = ["left" : 15, "right" : 15]
        sliderView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[slider]-(right)-|", options: NSLayoutFormatOptions(), metrics: horizontalMetrics, views: views))
    }
}

extension ASTPassengersPickerSliderView: GCXSteppedSliderDelegate {

    func steppedSlider(_ slider: GCXSteppedSlider, valueChanged selectedValue: Any?) {

        guard let selectedValue = selectedValue else {
            return
        }

        if let intValue = selectedValue as? Int {
            valueChanged?(intValue)
        }
    }

    func steppedSlider(_ slider: GCXSteppedSlider, stepImageForValue stepValue: Any?) -> UIImage? {
        return UIImage(named: "slider_step_icon")
    }

    func steppedSlider(_ slider: GCXSteppedSlider, sizeForStepImageOfValue stepValue: Any?) -> CGSize {
        return CGSize(width: 10, height: 10)
    }
}
