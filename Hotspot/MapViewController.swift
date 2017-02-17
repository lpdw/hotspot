//
//  MapViewController.swift
//  Lundi
//
//  Created by Etienne Vautherin on 13/02/2017.
//  Copyright © 2017 allTouches. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Alamofire

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(hotSpotsDidChange), name: NSNotification.Name.hotSpotsDidChange, object: nil)
    }
    
    
    func hotSpotsDidChange(notification: Notification) {
        let center = AppDelegate.instance().center
        let camera = MKMapCamera(lookingAtCenter: center, fromEyeCoordinate: center, eyeAltitude: 5000.0)
        self.mapView.setCamera(camera, animated: true)
        
        if let hotSpots = AppDelegate.instance().hotSpots {
            setAnnotations(with: hotSpots)
        }
    }
    
    
    func setAnnotations(with hotSpots: [[String: Any]]) {
        
        let centerLocation = CLLocation(latitude: centerLat, longitude: centerLon)
        
        //        for content in fountains {
        //            if  let loc = content["loc"] as? [String: Any],
        //                let lat = loc["lat"] as? CLLocationDegrees,
        //                let lon = loc["lon"] as? CLLocationDegrees
        //            {
        //                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        //                let fountain = Fountain(coordinate: coordinate)
        //                self.mapView.addAnnotation(fountain)
        //            }
        //        }
        //
        //
        //        let annotations0 = fountains
        //            .map { (content: [String : Any]) -> MKAnnotation in
        //                if  let loc = content["loc"] as? [String: Any],
        //                    let lat = loc["lat"] as? CLLocationDegrees,
        //                    let lon = loc["lon"] as? CLLocationDegrees
        //                {
        //                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        //                    let fountain = Fountain(coordinate: coordinate)
        //                    return fountain
        //                }
        //                let coordinate = CLLocationCoordinate2D()
        //                return Fountain(coordinate: coordinate)
        //            }
        

        
        let annotations = hotSpots
            .flatMap { (content: [String : Any]) -> MKAnnotation? in
                if  let fields = content["fields"] as? [String : Any],
                    let geo_point_2d = fields["geo_point_2d"] as? [CLLocationDegrees]
                    
                {
                    let coordinate = CLLocationCoordinate2D(latitude: geo_point_2d[0], longitude: geo_point_2d[1])
                    let hotSpot = HotSpot(coordinate: coordinate)
                    hotSpot.title = fields["nom_site"] as? String
                    hotSpot.subtitle = fields["adresse"] as? String
                    return hotSpot
                }
                return nil
            }
            .sorted { /* (f0: MKAnnotation, f1: MKAnnotation) -> Bool in */
                let location0 = CLLocation(latitude: $0.coordinate.latitude,
                                           longitude: $0.coordinate.longitude)
                let location1 = CLLocation(latitude: $1.coordinate.latitude,
                                           longitude: $1.coordinate.longitude)
                let distance0 = centerLocation.distance(from: location0)
                let distance1 = centerLocation.distance(from: location1)
                
                return distance0 < distance1
        }
        
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.image = #imageLiteral(resourceName: "Pointer")
        return view
    }
    
}

