//
//  NewViewController.swift
//  gocab_mapbox
//
//  Created by Biko Pougala on 20/02/2019.
//  Copyright © 2019 Tomahawk. All rights reserved.
//

import UIKit
import CoreLocation
import Mapbox
import MapboxNavigation
import MapboxDirections
import MapboxCoreNavigation
import MapboxGeocoder 

class NewViewController: UIViewController, MGLMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {


    
    var addressLocation: CLLocationCoordinate2D?
    var addressName: String!
    private var mapView: NavigationMapView? 
    var currentCoordinates: CLLocationCoordinate2D?
    var directionsRoute: Route? 
    
    @IBOutlet weak var distanceTextView: UITextField!
    @IBOutlet weak var timeTextView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeTextView.delegate = self 
        distanceTextView.delegate = self 
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let styleUrl = URL(string: "mapbox://styles/bpougala/cjjhafo2oagmo2rnijkzezju3")
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2)
        mapView = NavigationMapView(frame: frame, styleURL: styleUrl)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.delegate = self 
        mapView?.showsUserLocation = true 
        
        view.addSubview(mapView!)
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if let currentCoordinates = currentCoordinates, let addressLocation = addressLocation {
            let startingPoint = MGLPointAnnotation()
            startingPoint.coordinate = currentCoordinates
            mapView.addAnnotation(startingPoint)
            let endPoint = MGLPointAnnotation()
            endPoint.coordinate = addressLocation 
            mapView.addAnnotation(endPoint)
            //mapView?.setCenter(startingPoint.coordinate, zoomLevel: 14, animated: true)
            mapView.showAnnotations([startingPoint, endPoint], animated: true)
            getFare(startingPoint.coordinate, endPoint.coordinate)
            calculateRoute(from: (currentCoordinates), to: addressLocation) { (route, error) in
                if error != nil {
                    print("Error calculating route")
                }
            }
            
            
        }
    }
    
    func getFare(_ origin: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D) {
        let key = "e^kf8uxP{9z$1Z"
        let urlString = "https://gocab-taxis.eu/get_fares.php?latLngStart=\(origin.latitude),\(origin.longitude)&latLngEnd=\(destination.latitude),\(destination.longitude)&pass=\(key)"
        
        var lower_bound = 0.0
        var upper_bound = 0.0
        let escapedAddress = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        print(escapedAddress)
        
        // No fare information for now 
        
        
        //        if let url = URL(string: escapedAddress) {
        //            URLSession.shared.dataTask(with: url) { (data, response, error) in 
        //                if error != nil {
        //                    print(error!.localizedDescription)
        //                }
        //                guard let data = data else { return }
        //                
        //                do {
        //                    guard let json = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? NSDictionary else {
        //                        print("data doesn't contain JSON")
        //                        return 
        //                    }
        //                    lower_bound = json["lower"] as? Double ?? 0.0
        //                    upper_bound = json["upper"] as? Double ?? 0.0
        //                    DispatchQueue.main.async {
        //                        print("here we are")
        //                        
        //                        print("\(lower_bound)-\(upper_bound) €")
        //                        self.taxiFare.text = "\(lower_bound)-\(upper_bound) €"
        //                        
        //                    }
        //                    
        //                }
        //            }.resume()
        //        }
    }
    
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        
        // Coordinate accuracy is the maximum distance away from the waypoint that the route may still be considered viable, measured in meters. Negative values indicate that a indefinite number of meters away from the route and still be considered viable.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        // Specify that the route is intended for automobiles avoiding traffic
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        
        
        // Generate the route object and draw it on the map
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            self.directionsRoute = routes?.first
            
            self.drawRoute(route: self.directionsRoute!)
        }
    }
    
    func drawRoute(route: Route) {
        let distanceFormatter = LengthFormatter()
        distanceFormatter.unitStyle = .short
        //let formattedDistance = distanceFormatter.string(fromMeters: route.distance
        
        let formattedDistance = distanceFormatter.string(fromValue: route.distance, unit: .meter)
        
        let travelTimeFormatter = DateComponentsFormatter()
        travelTimeFormatter.unitsStyle = .short
        
        let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
        self.timeTextView.text = "ETA: \(formattedTravelTime ?? "No ETA")"
        let distanceIndex = formattedDistance.index(formattedDistance.startIndex,  offsetBy: formattedDistance.count - 1)
        let distanceInMiles = formattedDistance.prefix(upTo: distanceIndex)
        print("distance in Miles: \(distanceInMiles)")
        self.distanceTextView.text = "Distance: \(formattedDistance)"
        guard route.coordinateCount > 0 else { return }
        // Convert the route’s coordinates into a polyline
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        // If there's already a route line on the map, reset its shape to the new route
        if let source = mapView?.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
            
            // Customize the route line color and width
            let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            // Add the source and style layer of the route line to the map
            mapView?.style?.addSource(source)
            mapView?.style?.addLayer(lineStyle)
        }
    }
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
}



