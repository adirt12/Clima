//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    // setting UI buttons
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var weatherManger = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self // set location manager delegate
        
        locationManager.requestWhenInUseAuthorization() // request auth for location
        locationManager.requestLocation() //get the current location data
        
        weatherManger.delegate = self // set weather manager delegate
        searchTextField.delegate = self // set search text field delegate
    }

    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}


// MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    
    // wait for search button icon pressed
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    // wait for search keyboard button pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    // wait the user to enter some city name
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else{
            textField.placeholder = "Type something"
            return false
        }
    }
    
    // reset the search text field and fetch the city data that insert by user
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let city = searchTextField.text{
            weatherManger.fetchWeather(cityName: city)
        }
        
        searchTextField.text = ""
    }
    
}


// MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate{
    
    // update the data that present when the user enter new city
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async{
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate{
    
    // update the currnet location user data 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManger.fetchWeather(latitude: lat , longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
