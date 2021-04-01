//
//  WeatherManager.swift
//  Clima
//
//  Created by Ali Elkoca on 14.03.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//


import CoreLocation

protocol WeatherManagerDelegate {
    func  didUpdateWeather(_ weatherManager: WeatherManager, _ weather:WeatherModel)
    func  didFailWithError(_ error : Error)
}

struct WeatherManager{
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=02ad8dd66fd8ee617c9bdac5c786989f&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(_ cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString)
    }
    
    
    
    func performRequest(_ urlString: String) {
        //1. Create URL
        if let url = URL(string: urlString){
            //2.Create URL Session
            let session = URLSession(configuration: .default)
            //3.Give the session a task
            let task = session.dataTask(with: url,completionHandler: handle(data: response: error:))
            //4. Start the task
            task.resume()
        }
    }
    
    func handle(data: Data? ,response:URLResponse?, error:Error?) {
        if error != nil {
            delegate?.didFailWithError(error!)
            return
        }
        if let safeData = data {
            if let weather = parseJSON(safeData) {
                //let weatherVC = WeatherViewController()
                self.delegate?.didUpdateWeather(self,weather)
            }
        }
    }
    
    func parseJSON(_ weatherData:Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do     {
            let decodedData = try  decoder.decode(WeatherData.self, from: weatherData)
            let weather = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temperature: decodedData.main.temp)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
    //    func getConditionName(weatherID : Int) -> String {
    //
    //        switch weatherID {
    //        case 200...232:
    //            return "cloud.bolt"
    //        case 300...321:
    //            return "cloud.drizzle"
    //        case 500...531:
    //            return "cloud.rain"
    //        case 600...622:
    //            return "cloud.snow"
    //        case 701...781:
    //            return "cloud.fog"
    //        case 800:
    //            return "sun.max"
    //        case 801...804:
    //            return "cloud.bolt"
    //
    //        default:
    //            return "cloud"
    //        }
}

