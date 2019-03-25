//
//  ViewController.swift
//  gocab_mapbox
//
//  Created by Biko Pougala on 15/12/2018.
//  Copyright © 2018 Tomahawk. All rights reserved.
//

import UIKit
import Mapbox 
import CoreLocation 

class ViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    private var currentLocation: CLLocationCoordinate2D?
    private var mapView: MGLMapView?
    private var locationManager: CLLocationManager? 
    private var enterAddressView: UITextField? 
    private var shouldSetUpConstraints = false // this is used for AutoLayout 
    private var centerButton: UIButton? 
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        let styleUrl = URL(string: "mapbox://styles/bpougala/cjjhafo2oagmo2rnijkzezju3")
        
        mapView = MGLMapView(frame: view.bounds,
                                 styleURL: styleUrl)   
        
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView?.delegate = self 
        if (mapView != nil) {
            view.addSubview(mapView!)
        }
        
        mapView?.showsUserLocation = true 
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self 
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
        locationManager?.startUpdatingHeading()
        
       // enterAddressView = UITextView(frame: CGRect(x: 40, y: 100, width: 340, height: 50))
        enterAddressView = UITextField()
        
        if (enterAddressView != nil) {
            self.view.addSubview(enterAddressView!)
            view.bringSubviewToFront(enterAddressView!)
            
        }
        
        
        enterAddressView?.translatesAutoresizingMaskIntoConstraints = false 
        
        enterAddressView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true 
        enterAddressView?.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        enterAddressView?.widthAnchor.constraint(equalToConstant: 340).isActive = true 
        enterAddressView?.heightAnchor.constraint(equalToConstant: 50).isActive = true         
        enterAddressView?.backgroundColor = UIColor(red: 0.90, green: 0.49, blue: 0.13, alpha: 1)
        enterAddressView?.text = "Where are we going?"
        enterAddressView?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        enterAddressView?.font = UIFont(name: "Rubik-Regular", size: 18)
        enterAddressView?.delegate = self 
        
        let magnifyingGlassImage = UIImage(named: "magnifying_glass")
        let magnifyingGlass = UIImageView()
        magnifyingGlass.image = magnifyingGlassImage
        magnifyingGlass.setImageColor(color: UIColor.white)
        magnifyingGlass.frame = CGRect(x: 40, y: 100, width: 45, height: 20)
        magnifyingGlass.contentMode = .scaleAspectFit
        enterAddressView?.leftViewMode = .always 
        enterAddressView?.leftView = magnifyingGlass
      
      //  enterAddressView?.layer.cornerRadius = (enterAddressView?.frame.size.height ?? 0)/2
        enterAddressView?.clipsToBounds = false
        enterAddressView?.layer.shadowOpacity = 0.4
        enterAddressView?.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        centerButton = UIButton()
     
        if (centerButton != nil) {
            self.view.addSubview(centerButton!)
            view.bringSubviewToFront(centerButton!)
        }
        
        centerButton?.backgroundColor = UIColor.white
        centerButton?.translatesAutoresizingMaskIntoConstraints = false 
        centerButton?.topAnchor.constraint(equalTo: view.topAnchor, constant: 190).isActive = true 
        centerButton?.trailingAnchor.constraint(equalTo: enterAddressView!.trailingAnchor, constant: 0).isActive = true 
        centerButton?.heightAnchor.constraint(equalToConstant: 45).isActive = true 
        centerButton?.widthAnchor.constraint(equalToConstant: 45).isActive = true 
        centerButton?.layer.cornerRadius = 15
        
        let centerIconImage = UIImage(named: "center_icon")
        let centerIcon = UIImageView()
        centerIcon.image = centerIconImage
        //centerIcon.setImageColor(color: UIColor(red: 1, green: 1, blue: 1, alpha: 1))
        centerButton?.setImage(centerIcon.image, for: .normal)
        
        
        // set 3D effect
        centerButton?.clipsToBounds = false 
        centerButton?.layer.shadowOpacity = 0.4
        centerButton?.layer.shadowOffset = CGSize(width: 3, height: 3)

       
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.performSegue(withIdentifier: "mySegue", sender: nil)
    }

   
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == .authorizedWhenInUse) {
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        } else if(status == .authorizedAlways) {
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            mapView?.setCenter(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), zoomLevel: 13.5, animated: true)
            
        }
    }
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        locationManager?.stopUpdatingLocation()
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        style.localizeLabels(into: nil)
    }


}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

