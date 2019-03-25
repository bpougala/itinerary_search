//
//  AddressesAutoCompleteController.swift
//  gocab_mapbox
//
//  Created by Biko Pougala on 20/02/2019.
//  Copyright © 2019 Tomahawk. All rights reserved.
//

import UIKit
import CoreLocation

class AddressesAutoCompleteController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var inputSearchTextView: UITextField!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var foursquareCreditsLogo: UIImageView!
    @IBOutlet weak var bingCreditsLogo: UIImageView!
    let locationManager = CLLocationManager()
    
    let localeRegion = Locale.current.regionCode!
    let localeLanguage = Locale.current.languageCode!
    var culture = ""    
    var coordinates = CLLocationCoordinate2DMake(43.6976763, 7.27038570000002) // Marseilles centre 
    
    var addresses = [String]()
    
    var addressLocations = [Int:CLLocationCoordinate2D]()
    var addressNames = [Int:String]()
    
    var locations = [CLLocationCoordinate2D]()
    
    var iterator = 0 // iterator to assign values in the addressesLocations dictionary
    
    var selectedLocation: CLLocationCoordinate2D?
    var selectedAddress: String? 
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self 
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization() 
        locationManager.startMonitoringSignificantLocationChanges()
        
        inputSearchTextView.delegate = self 
        inputSearchTextView.font = UIFont(name: "Rubik-Regular.ttf", size: 15)
        
        searchResultsTableView.delegate = self 
        searchResultsTableView.dataSource = self 
        
        culture = "\(localeLanguage)_\(localeRegion)"
        
        bingCreditsLogo.isHidden = true 
        foursquareCreditsLogo.isHidden = true
        
        
        
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let txtAfterUpdate = text.replacingCharacters(in: range, with: string)
            self.getAddresses(text: txtAfterUpdate)
        }
        
        self.searchResultsTableView.reloadData()
        
        return true 
    }
    
    func getAddresses(text: String?) {
        //        activityIndicator.center = self.view.center
        //        activityIndicator.hidesWhenStopped = true 
        //        activityIndicator.style = UIActivityIndicatorView.Style.gray
        //        view.addSubview(activityIndicator)
        self.iterator = 0 // every time a new input is entered, reinitialise the dictionary
        addresses.removeAll(keepingCapacity: false) // remove all the contents of the tableView at each new input
        addressLocations.removeAll(keepingCapacity: false)
        locations.removeAll(keepingCapacity: false)
        
        let key = "e^kf8uxP{9z$1Z" // my own API key
        let query = text ?? ""
        let longitude = coordinates.longitude
        let latitude = coordinates.latitude
        let address = "https://gocab-taxis.eu/address_autocomplete.php?pass=\(key)&longitude=\(longitude)&latitude=\(latitude)&query=\(query)&culture=\(culture)"
        let escapedAddress = address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        
        guard let url = URL(string: escapedAddress) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in 
            if error != nil {
                print(error!.localizedDescription)
            }
            
            guard let data = data else { return }
            do {
                guard let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? NSDictionary else { 
                    print("data doesn't contain any JSON")
                    return 
                }
                if json.count > 0 {
                    let value = json["value"] as? NSArray ?? []
                    if json["serviceProvider"] as? String == "Bing" {
                        self.populateBing(value)
                        DispatchQueue.main.async {
                            self.foursquareCreditsLogo.isHidden = true 
                            self.bingCreditsLogo.isHidden = false 
                            self.searchResultsTableView.reloadData()
                        }
                    } else {
                        self.populateFoursquare(json)
                        DispatchQueue.main.async {
                            self.bingCreditsLogo.isHidden = true 
                            self.foursquareCreditsLogo.isHidden = false 
                            self.searchResultsTableView.reloadData()
                            self.iterator+=1
                        }
                    }
                    
                    
                }
            }
            }.resume()
        
    }
    
    func populateFoursquare(_ array: NSDictionary) {
        addresses.removeAll(keepingCapacity: false)
        locations.removeAll(keepingCapacity: false)
        if array.count > 0 {
            for (_, value) in array {
                let info = value as? NSDictionary
                if let info = info { // last element of the dictionary has key "serviceProvider" and value "Foursquare"
                    let placeName = info["name"]
                    let address = info["location"] 
                    if let placeName = placeName as? String, let address = address as? NSDictionary {
                        let city = address["city"] as? String 
                        let longitude = address["lng"] as? Double 
                        let latitude = address["lat"] as? Double 
                        let addressName = address["address"] as? String 
                        if let city = city, let addressName = addressName, let longitude = longitude, let latitude = latitude {
                            let fullNameCell = "\(placeName), \(addressName), \(city)"
                            self.addresses.append(fullNameCell)
                            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                            let i = self.iterator
                            self.addressNames[1] = addressName
                            self.addressLocations[i] = coordinate
                            self.addressNames[i] = addressName
                            self.iterator+=1
                            
                        }
                    }
                }
                
            }
        }
    }
    
    func populateBing(_ array: NSArray) {
        addresses.removeAll(keepingCapacity: false)
        locations.removeAll(keepingCapacity: false)
        if array.count>0 {
            
            for index in 0...array.count-1 {
                
                let address = array[index] as! NSDictionary
                let secondAddress = address["address"] as? NSDictionary
                self.iterator+=1 
                if let secondAddress = secondAddress {
                    
                    let thirdAddress = secondAddress["formattedAddress"] as? String 
                    let adminDistrict = secondAddress["adminDistrict"] as? String 
                    let countryRegion = secondAddress["countryRegion"] as? String 
                    
                    if let thirdAddress = thirdAddress, let adminDistrict = adminDistrict, let  countryRegion = countryRegion {
                        
                        let placeName = address["name"] as? String 
                        if let placeName = placeName {
                            
                            let formattedAddress = "\(placeName), \(thirdAddress), \(adminDistrict), \(countryRegion)"
                            self.addresses.append(formattedAddress)
                            geocodeAddress(formattedAddress)
                            
                        } else {
                            let formattedAddress = "\(thirdAddress), \(adminDistrict), \(countryRegion)"
                            self.addresses.append(formattedAddress)
                            geocodeAddress(formattedAddress)
                        }
                        
                    }
                    
                }
            } 
        }
    }
    
    func geocodeAddress(_ address: String) {
        let key = "e^kf8uxP{9z$1Z"
        let urlString = "https://gocab-taxis.eu/geocode.php?address=\(address)&key=\(key)"
        
        let escapedAddress = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        if let url = URL(string: escapedAddress) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in 
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let data = data else { return }
                do {
                    guard let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? NSDictionary else { 
                        print("data doesn't contain any JSON")
                        return 
                    }
                    if json.count > 0 {
                        let longitude = json["longitude"] as? Double 
                        let latitude = json["latitude"] as? Double 
                        
                        if let longitude = longitude, let latitude = latitude {
                            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                            self.addressLocations[self.iterator] = coordinate
                            self.addresses.append(address)
                            self.locations.append(coordinate)
                        }
                        
                        
                    }
                }
                }.resume()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as UITableViewCell 
        let index = indexPath.row as Int 
        
        cell.textLabel!.font = UIFont(name: "Rubik-Regular", size: 15)
        
        cell.textLabel!.text = addresses[index]
        
        return cell 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let index = indexPath.row as Int
        
        let location = self.locations[index]
        let locationName = self.addresses[index]
        
        self.selectedAddress = locationName
        self.selectedLocation = location
        
        let newController = NewViewController()
        
        newController.addressLocation = location 
        newController.addressName = locationName
        
        let destVC = storyboard?.instantiateViewController(withIdentifier: "NewViewController") as! NewViewController
        destVC.addressLocation = location 
        destVC.currentCoordinates = self.coordinates
        destVC.addressName = locationName
        
        navigationController?.pushViewController(destVC, animated: true)
        
        /// performSegue(withIdentifier: "mySegue", sender: self)
        
        
        //    print(locationName)
        
        
        
    }
    
            
            
            
        }
    

