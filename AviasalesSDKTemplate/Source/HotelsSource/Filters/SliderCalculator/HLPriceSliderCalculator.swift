import UIKit

struct SliderPoint {
    let priceValue: Double
    let sliderValue: Double
}

struct SliderRange {
    let minPoint: SliderPoint
    let maxPoint: SliderPoint
}

@objcMembers
class HLPriceSliderCalculator: NSObject {

    fileprivate (set) var pivots: [Double] = []

    init(prices: [Double], maxPivotCount: Int) {
        let sortedPrices = prices.sorted()

        let pricesArrayCount = sortedPrices.count
        let pivotsCount = min(pricesArrayCount, maxPivotCount)

        var valuesLeft = pricesArrayCount
        var currentIndex = 0
        var totalCount = pivotsCount

        for _ in 0..<pivotsCount + 1 {
            currentIndex = min(currentIndex, pricesArrayCount - 1)
            pivots.append(sortedPrices[currentIndex])

            guard currentIndex < pricesArrayCount - 1 && totalCount > 0 else { break }

            let divider = max(1, valuesLeft / totalCount)
            valuesLeft -= divider
            totalCount -= 1
            currentIndex += divider
        }
    }

    func sliderValue(_ priceValue: Double) -> Double {
        let normalizedPriceValue = max(pivots.first!, min(priceValue, pivots.last!))
        let range = sliderRange(normalizedPriceValue, isSliderValue: false)
        let nextSliderPoint = range.maxPoint
        let prevSliderPoint = range.minPoint
        let sliderDelta = nextSliderPoint.sliderValue - prevSliderPoint.sliderValue
        let priceDelta = nextSliderPoint.priceValue - prevSliderPoint.priceValue

        return prevSliderPoint.sliderValue + sliderDelta * (normalizedPriceValue - prevSliderPoint.priceValue) / priceDelta
    }

    func priceValue(_ sliderValue: Double) -> Double {
        let normalizedSliderValue: Double = max(0, min(sliderValue, 1))
        let range = sliderRange(normalizedSliderValue, isSliderValue: true)
        let nextSliderPoint = range.maxPoint
        let prevSliderPoint = range.minPoint
        let sliderDelta = nextSliderPoint.sliderValue - prevSliderPoint.sliderValue
        let priceDelta = nextSliderPoint.priceValue - prevSliderPoint.priceValue

        return prevSliderPoint.priceValue + priceDelta * (normalizedSliderValue - prevSliderPoint.sliderValue) / sliderDelta
    }

    func priceValue(_ sliderValue: Double, roundingRule: HLSliderCalculatorRoundingRule) -> Double {
        let price = priceValue(sliderValue)

        let roundedPrice = HLSliderCalculator.roundValue(price, roundingRule: roundingRule)

        return max(pivots.first!, min(roundedPrice, pivots.last!))
    }

    fileprivate func sliderRange(_ value: Double, isSliderValue: Bool) -> SliderRange {
        let sliderMin: CGFloat = 0
        let sliderMax: CGFloat = 1
        let priceMin = pivots.first!
        let priceMax = pivots.last!

        let segment = 1.0 / Double(pivots.count - 1)

        var currentIndex = 0
        var nextSliderPoint = SliderPoint(priceValue: priceMin, sliderValue: Double(sliderMin))
        var prevSliderPoint = SliderPoint(priceValue: priceMax, sliderValue: Double(sliderMax))

        while currentIndex < pivots.count && (isSliderValue ? nextSliderPoint.sliderValue : nextSliderPoint.priceValue) < value {
            let newPriceValue = pivots[currentIndex]
            let newSliderValue = Double(currentIndex) * segment
            if nextSliderPoint.sliderValue < newSliderValue {
                prevSliderPoint = nextSliderPoint
                nextSliderPoint = SliderPoint(priceValue: newPriceValue, sliderValue: newSliderValue)
            }

            currentIndex += 1
        }

        return SliderRange(minPoint: prevSliderPoint, maxPoint: nextSliderPoint)
    }
}
