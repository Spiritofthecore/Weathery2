//
//  ViewController.swift
//  Weathery
//
//  Created by Macbook on 1/23/19.
//  Copyright © 2019 Spiritofthecore. All rights reserved.
//

import UIKit
import GoogleSignIn
import Google
import Firebase
//import PromiseKit




class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, SearchResultsHandler, GIDSignInUIDelegate, GIDSignInDelegate, EditWeatherCell{
    
    func DeleteTheCell(indexPath: IndexPath) {
        WeatherList.removeDuplicates()
        WeatherList.remove(at: indexPath.row)
        LocationList.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    

    //Outlet
    var theUser: User = User()
    let AccuWeatherAPIKey = "vEedMZKgfqHjY8tylOiBX8oQS6MjIcMj"
    var WeatherList: [Weather] = []
    var LocationList: [Location] = []
    var isEditting: Bool! = false
    var searchresultController: searchResultController!
    var ref: FIRDatabaseReference!
    var signInButton: GIDSignInButton!
    var celcius: Bool!
    var isSync: Bool!
    var currentWeather: Weather?
    let weatherLoop = DispatchGroup()
    let locationLoop = DispatchGroup()
    @IBOutlet var PopupView: UIView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var UserNameLabel: UILabel!
    @IBOutlet weak var ProfileImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    
    
    
    
    
    //Action
    @IBAction func Cancel(_ sender: Any) {
        dismissPopView()
    }
    @IBAction func Edit(_ sender: Any) {
        if (self.isEditting == false) {
            showPopView()
        }
        else {
            dismissPopView()
        }
    }
    @IBAction func searchLocation(_ sender: Any) {
        
        let searchController = UISearchController(searchResultsController: searchresultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }
    
    
    
    
    
    
    //Arrays handler
    func GetWeather(at location: Location) {
        self.LocationList.append(location)
//        isSync = false
//        SyncLocation(at: theUser.userName) {
//            self.reloadCityCollection()
//        }
        if (theUser.userName != "not yet sign in") {
            UploadLocations(at: theUser.userName, locations: [location])
        }
        
        reloadCityCollection()
    }
    func reloadCityCollection() {
        WeatherList.removeAll()
        CurrentConditionRequest(at: LocationList) { (CurrentWeatherList) in
            DispatchQueue.main.async {
                self.WeatherList = CurrentWeatherList
                self.collectionView.reloadData()
            }
        }
    }
    



    
    
    //functions
    func SignOut() {
        GIDSignIn.sharedInstance()?.signOut()
        UserNameLabel.text = "not yet sign in"
        ProfileImage.image = UIImage()
        let alert = UIAlertController(title: "Sign Out", message: "succeeded", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        GIDButtonHandler()
    }
    func GIDButtonHandler() {
        if((GIDSignIn.sharedInstance()?.hasAuthInKeychain())! == true){
            signInButton.isHidden = true
        }else{
            signInButton.isHidden = false
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.ProfileImage.image = UIImage(data: data)
            }
        }
    }
    func changeUserUI() {
        UserNameLabel.text = theUser.userName + "@gmail.com"
        downloadImage(from: theUser.userImageURL!)
    }
    
    
    
    
    
    
    
    //Animations
    func dismissPopView() {
        UIView.animate(withDuration: 0.5, animations: {
            self.dimView.alpha = 0
            self.PopupView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width / 1.5, y: 0)
        }) { (true) in
            self.PopupView.removeFromSuperview()
            self.navigationItem.leftBarButtonItem! = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.Edit(_:)))
            self.isEditting = false
        }
    }
    func showPopView() {
        PopupView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width / 1.5, y: 0)
        view.addSubview(PopupView)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.dimView.alpha = 0.85
            self.PopupView.transform = .identity
        }) { (true) in
            self.navigationItem.leftBarButtonItem! = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.Edit(_:)))
            self.isEditting = true
        }
    }
    
    
    
    
    
    
    
    //view handler
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeatherList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TheWeatherCell", for: indexPath) as! WeatherCell
        cell.CityLabel.text = self.WeatherList[indexPath.row].locationName
        if self.celcius {
            cell.TemperatureLabel.text = "\(String(WeatherList[indexPath.row].temperature.0))\u{BA}C"
        }else{
            cell.TemperatureLabel.text = "\(String(WeatherList[indexPath.row].temperature.1))\u{BA}F"
        }
        let imageName = "img\(WeatherList[indexPath.row].weatherImageKey).png"
        cell.WeatherImage.image = UIImage(named: "WeatherIcon/" + imageName)
        self.WeatherList.append(WeatherList[indexPath.row])
        cell.DeleteButton.setImage(UIImage(named: "X.png"), for: .normal)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentWeather = WeatherList[indexPath.row]
        tableView2.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        locationRequest(searchText: searchText) { (CityList) in
            DispatchQueue.main.async {
                self.searchresultController.reloadDataWithArray(CityList)
            }
        }
    }
 
    
    
    
    
    
    
    //Accuweather
//    func oneDayRequest(at location: Location, completion: @escaping (Weather) -> ()) {
//        let urlString = "http://dataservice.accuweather.com/forecasts/v1/daily/1day/\(location.CityKey)?apikey=\(AccuWeatherAPIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        let url = URL(string: urlString!)
//        print(url!)
//        var weatherInfo: Weather!
//
//        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
//            do {
//                if data != nil {
//                    let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSDictionary
//                    let temperature = ((((dic.value(forKey: "DailyForecasts") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "Temperature") as! NSDictionary).value(forKey: "Maximum") as! NSDictionary).value(forKey: "Value") as! Int
//                    let imageKey = (((dic.value(forKey: "DailyForecasts") as! NSArray).object(at: 0) as! NSDictionary).value(forKey: "Day") as! NSDictionary).value(forKey: "Icon") as! Int
//                    //weatherInfo = Weather.init(temperature: temperature, weatherImageKey: imageKey)
//                }
//            } catch {
//                print("error")
//                weatherInfo = Weather.init()
//            }
//            completion(weatherInfo)
//        }).resume()
//    }
    
    func CurrentConditionRequest(at locations: [Location], completion: @escaping ([Weather]) -> ()) {
        var CurrentWeatherList: [Weather] = []
        for location in locations {
            weatherLoop.enter()
            let urlString = "http://dataservice.accuweather.com/currentconditions/v1/\(location.CityKey)?apikey=\(AccuWeatherAPIKey)&details=true".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let url = URL(string: urlString!)
            var weatherInfo: Weather!
            
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
                do {
                    if data != nil {
                        if let arr = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? NSArray {
                            let dic = arr.object(at: 0) as! NSDictionary
                            
                            let temp = dic.value(forKey: "Temperature") as! NSDictionary
                            let Temperature = ((temp.value(forKey: "Metric") as! NSDictionary).value(forKey: "Value") as! Double, (temp.value(forKey: "Imperial") as! NSDictionary).value(forKey: "Value") as! Double)
                            
                            let imageKey = dic.value(forKey: "WeatherIcon") as! Int
                            
                            let realTemp = dic.value(forKey: "RealFeelTemperature") as! NSDictionary
                            let realFeelTemperature = ((realTemp.value(forKey: "Metric") as! NSDictionary).value(forKey: "Value") as! Double, (realTemp.value(forKey: "Imperial") as! NSDictionary).value(forKey: "Value") as! Double)
                            
                            let relativeHumidity = dic.value(forKey: "RelativeHumidity") as! Double
                            
                            let wind = (dic.value(forKey: "Wind") as! NSDictionary).value(forKey: "Speed") as! NSDictionary
                            let windSpeed = (((wind.value(forKey: "Metric") as! NSDictionary).value(forKey: "Value")) as! Double, ((wind.value(forKey: "Imperial") as! NSDictionary).value(forKey: "Value")) as! Double)
                            
                            let UVIndex = dic.value(forKey: "UVIndex") as! Double
                            
                            let cloudCover = dic.value(forKey: "CloudCover") as! Double
                            
                            let pressure = dic.value(forKey: "Pressure") as! NSDictionary
                            let Pressure = ((pressure.value(forKey: "Metric") as! NSDictionary).value(forKey: "Value") as! Double, (pressure.value(forKey: "Imperial") as! NSDictionary).value(forKey: "Value") as! Double)
                            
                            weatherInfo = Weather.init(temperature: Temperature, weatherImageKey: imageKey, realFeelTemperature: realFeelTemperature, RelativeHumidity: relativeHumidity, WindSpeed: windSpeed, UVIndex: UVIndex, CloudCover: cloudCover, Pressure: Pressure, locationName: location.CityName, locationKey: location.CityKey)
                            CurrentWeatherList.append(weatherInfo)
                        } else {
                            let alert = UIAlertController(title: "Lỗi", message: "Dịch vụ tạm dừng", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } catch {
                    print("error")
                }
                self.weatherLoop.leave()
            }).resume()
        }
        
        weatherLoop.notify(queue: .main) {
            CurrentWeatherList.removeDuplicates()
            completion(CurrentWeatherList)
        }
        
        
    }
    func locationRequest(searchText: String, completion: @escaping ([Location]) -> ()) {
        var CityList: [Location] = []
        let urlString = "http://dataservice.accuweather.com/locations/v1/cities/autocomplete?apikey=\(AccuWeatherAPIKey)&q=\(searchText)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let url = URL(string: urlString!)
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            do {
                if let dic = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableLeaves) as? NSArray {
                    for city in dic {
                        let CityName = (city as! NSDictionary).value(forKey: "LocalizedName") as! String
                        let CityKey = (city as! NSDictionary).value(forKey: "Key") as! String
                        
                        CityList.append(Location(cityName: CityName, cityKey: CityKey))
                        
                        print(city)
                    }
                    completion(CityList)
                } else {
                    completion(CityList)
                    return
                }
            } catch {
                print("error")
            }
        } ).resume()
    }

    

    
    
    //Google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            var userName = user.profile.email!
            userName = userName.cutGmailTail()
            self.theUser = User(username: userName, userid: user.userID, userimageurl: user.profile.imageURL(withDimension: 100))
            // ...
//            print(theUser.userName)
//            for item in WeatherList {
//                print(item.temperature)
//            }
//            if isSync == false {
//                SyncLocation(at: userName, completion: {
//                    self.reloadCityCollection()
//                })
//            }
            findUser(acc: theUser.userName) { (isFound) in
                if isFound {
                    self.downloadLocations(acc: self.theUser.userName) { (isFound) in
                        if isFound {
                            self.LocationList.removeDuplicates()
                            self.reloadCityCollection()
                        }
                    }
                }
            }

            self.RenewLocations()
            GIDButtonHandler()
            changeUserUI()
        }
    }
    
    
    
    
    
    
    
    //Firebase
//    func SyncLocation(at acc: String, completion: @escaping () -> ()) {
//        downloadLocations(acc: acc) { (isFound) in
//            if isFound {
//                //remove duplicate location
//                self.RemoveDuplicate()
//            }
//            self.Delete(at: acc, completion: {
//                self.UploadLocations(at: acc, completion: {
//                    DispatchQueue.main.async {
//                        self.isSync = true
//                    }
//                    completion()
//                })
//            })
//        }
//    }

    func Delete(at acc: String, completion: @escaping ()->()) {
        ref?.child(acc).removeValue()
        completion()
    }
    func UploadLocations(at acc: String, locations: [Location]) {
            // do things
        for location in locations {
            locationLoop.enter()
            ref?.child(acc).child("Metric").setValue(celcius)
            let autoID = ref?.child(acc).child("Locations").childByAutoId()
            autoID?.child("Key").setValue(location.CityKey)
            autoID?.child("LocalizedName").setValue(location.CityName)
            ref?.child(acc).child("Count").setValue(LocationList.count)
            locationLoop.leave()
        }
        
        locationLoop.notify(queue: .main) {
            print("upload succeeded")
        }
    }
    func findUser(acc: String, completion: @escaping (Bool) -> ()) {
        ref.observe(.value) { (snapshot) in
            let theValue = snapshot.value as? NSDictionary
            if theValue == nil {
                completion(false)
            } else {
                if (theValue?.value(forKey: acc) as? NSDictionary) != nil {
                    print("there is a user")
                    completion(true)
                    return
                }
                completion(false)
            }
        }
    }
    func RenewLocations() {
        LocationList.removeAll()
    }
    func downloadLocations(acc: String, completion: @escaping (Bool) -> ()) {
        ref.observe(.value) { (snapshot) in
            let theValue = snapshot.value as? NSDictionary
            if theValue == nil {
                completion(false)
            } else {
                if let info = theValue?.value(forKey: acc) as? NSDictionary {
                    guard let locations = info.value(forKey: "Locations") as? NSDictionary else {
                        completion(false)
                        return
                    }
                    for location in locations {
                        let city = location.value as! NSDictionary
                        guard city.value(forKey: "LocalizedName") != nil else {
                            completion(false)
                            return
                        }
                        guard city.value(forKey: "Key") != nil else {
                            completion(false)
                            return
                        }
                        self.LocationList.append(Location(cityName: city.value(forKey: "LocalizedName") as! String, cityKey: city.value(forKey: "Key") as! String))
                    }
                    print("there is a location")
                    completion(true)
                    return
                }
                completion(false)
            }
        }
    }
    
    
    
    

    
    //ViewDidload
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView2.delegate = self
        tableView2.dataSource = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EditCell")
        tableView2.register(UITableViewCell.self, forCellReuseIdentifier: "InfoCell")


        
        celcius = false // celsius is default
        //isSync = false
        
        ref = FIRDatabase.database().reference()
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        PopupView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.height)
        signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        signInButton.center = PopupView.center
        PopupView.addSubview(signInButton)
        //GIDButtonHandler()
//        if(GIDSignIn.sharedInstance()?.hasAuthInKeychain() == true) {
//            var theEmail = GIDSignIn.sharedInstance()?.currentUser.profile.email
//            SyncLocation(at: theEmail!.cutGmailTail(), completion: {
//                self.reloadCityCollection()
//            })
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchresultController = searchResultController()
        searchresultController.delegate = self
    }
}







extension ViewController: UITableViewDelegate, UITableViewDataSource {
    //tableView handler
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
        return 3
        }
        if tableView == self.tableView2 {
            return 6
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            var cell = tableView.dequeueReusableCell(withIdentifier: "EditCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "EditCell")
        }
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = "Sign Out"
        case 1:
            let switchView = UISwitch(frame: CGRect.zero)
            switchView.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
            cell?.accessoryView = switchView
            cell?.textLabel?.text = "Celsius"
        case 2:
            cell?.textLabel?.text = "Provider"
        default:
            print("how you got here")
        }
        return cell!
        }
        if tableView == self.tableView2 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell")
            cell?.backgroundColor = UIColor.clear
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: "InfoCell")
            }
            cell?.textLabel?.numberOfLines = 0
            cell?.textLabel?.lineBreakMode = .byWordWrapping
            switch indexPath.row {
            case 0:
                if celcius {
                    cell?.textLabel?.text = "Real feel temperature: \(self.currentWeather?.realFeelTemperature.0 ?? 0)\u{BA}C"
                } else {
                    cell?.textLabel?.text = "Real feel temperature: \(self.currentWeather?.realFeelTemperature.1 ?? 0)\u{BA}F"
                }
            case 1:
                cell?.textLabel?.text = "Relative humidity: \(self.currentWeather?.RelativeHumidity ?? 0)\u{25}"
            case 2:
                if celcius {
                    cell?.textLabel?.text = "Wind Speed: \(self.currentWeather?.WindSpeed.0 ?? 0) km/h"
                } else {
                    cell?.textLabel?.text = "Wind Speed: \(self.currentWeather?.WindSpeed.1 ?? 0) mi/h"
                }
            case 3:
                cell?.textLabel?.text = "UV Index: \(self.currentWeather?.UVIndex ?? 0)"
            case 4:
                cell?.textLabel?.text = "Cloud cover: \(self.currentWeather?.CloudCover ?? 0)\u{25}"
            case 5:
                if celcius {
                    cell?.textLabel?.text = "Pressure: \(self.currentWeather?.Pressure.0 ?? 0) mb"
                } else {
                    cell?.textLabel?.text = "Pressure: \(self.currentWeather?.Pressure.1 ?? 0) inHg"
                }
            default:
                print("how you got here")
            }
            return cell!
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
        switch indexPath.row {
        case 0:
            self.SignOut()
        case 1:
            print("2")
        case 2:
            if let url = URL(string: "https://www.accuweather.com/en/vn/vietnam-weather") {
                UIApplication.shared.open(url, options: [:])
            }
        default:
             print("how you got here")
        }
        }
        if tableView == self.tableView2 {
            
        }
    }
    
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        WeatherList.removeDuplicates()
        if (sender.isOn == true) {
            // change to celsiuls, km/h, ...
            celcius = true
        } else {
            //change to farenheig, miles/h, ...
            celcius = false
        }
        collectionView.reloadData()
        tableView2.reloadData()
    }
}





extension String {
    mutating func cutGmailTail() -> String {
        for _ in 1...10 {
            self.remove(at: Index(encodedOffset: self.count - 1))
        }
        return self
    }
}

extension Int {
    mutating func CtoF() -> Int {
        return Int(round(Double(self*9/5 + 32)))
    }
    mutating func FtoC() -> Int {
        return Int(round(Double((self - 32)*5/9)))
    }
}

extension Array where Element: Hashable {
    func removingDuplicate() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    mutating func removeDuplicates() {
        self = self.removingDuplicate()
    }
}
