//
//  ASNearestAirportsLoader.swift
//  AviasalesSDKTemplate
//
//  Created by Anton Chebotov on 30/05/2017.
//  Copyright © 2017 Go Travel Un LImited. All rights reserved.
//

import Foundation

class ASNearestAirportsLoader {

    private var completionBlock: ((String?) -> Void)?

    func loadNearbyAirportIATA(lat: CGFloat, lon: CGFloat, lang: String, completion: @escaping (String?) -> Void) {
        completionBlock = completion
        let req = request(lat: lat, lon: lon, lang: lang)
        let task = URLSession.shared.dataTask(with: req, completionHandler: { (data, response, error) in
            if let unwrappedData = data {
                self.parse(unwrappedData)
            } else {
                self.completionBlock?(nil)
            }
        })
        task.resume()

    }

    private func urlString(lat: CGFloat, lon: CGFloat, lang: String) -> String {
        return String(format: "http://places.aviasales.ru/coordinates_to_places.json?lat=%f&lon=%f&locale=%@", lat, lon, lang)
    }

    private func request(lat: CGFloat, lon: CGFloat, lang: String) -> URLRequest {
        let urlString = self.urlString(lat: lat, lon: lon, lang: lang)
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }

    func parse(_ data: Data) {
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: [])
            if let array = parsedData as? [[String : Any]] {
                if let city = array.first {
                    if let iata = city["city_iata"] as? String {
                        completionBlock?(iata)
                        return
                    }
                }
            }
            completionBlock?(nil)
        } catch { completionBlock?(nil) }
    }
}
