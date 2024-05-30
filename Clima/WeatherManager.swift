//
//  WeatherManager.swift
//  Clima
//
//  Created by Iliya on 29/05/2024.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

// create weather manger delegate protocol
protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager{
    // api URL from open weather site
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=c20d2e7c12e4b52848760175a777abcf&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    // fetch weather data when the user enter city
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    // fetch weather data when the user want is current location data
    func fetchWeather(latitude: CLLocationDegrees , longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // send request for the weather data from the api
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self ,weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    // parse the JSON file the we got from our api with the relevant data
    func parseJSON(_ weatherData:Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
            
        }catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}

