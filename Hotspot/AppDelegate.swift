//
//  AppDelegate.swift
//  Hotspot
//
//  Created by Léa Motisi on 16/02/2017.
//  Copyright © 2017 Team Rocket. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Alamofire

let centerLat = 48.831034
let centerLon = 2.355265

extension Notification.Name {
    static let locationDidChange = Notification.Name("locationDidChange")
    static let hotSpotsDidChange = Notification.Name("hotSpotsDidChange")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let geoCoder = CLGeocoder()
    var userCodePostal: String! = ""
    let locationManager = CLLocationManager()
    let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
    
    var hotSpots: [[String: Any]]? {
        didSet {
            let notification = Notification(name: Notification.Name.hotSpotsDidChange)
            NotificationCenter.default.post(notification)
        }
    }
    
    var postalCode:String! = "" {
        didSet {
            self.userCodePostal = self.postalCode
        }
    };
    
    var userLocation: CLLocation? {
        didSet {
            let notification = Notification(name: Notification.Name.locationDidChange, object: userLocation, userInfo: nil)
            NotificationCenter.default.post(notification)
        }
    }
    
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // UserDefaults sample code
        let defaults = UserDefaults.standard
        
        defaults.set([1, 2], forKey: "a")
        defaults.synchronize()
        
        let _ = defaults.array(forKey: "a")
        
        
        // Notification sample code
        NotificationCenter.default.addObserver(self, selector: #selector(locationDidChange), name: NSNotification.Name.locationDidChange, object: nil)
        
        
        // !!! Don't do that this way !!!
        self.startLocate()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Hotspot")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}


// MARK: - hotSpots methods
extension AppDelegate {
    
    func locationDidChange(notification: Notification) {
        guard let userLocation = notification.object as? CLLocation else { return }
        
        fetchHotSpots(around: userLocation)
    }
    
    func fetchHotSpots(around location: CLLocation) {
        
        let urlString = "https://opendata.paris.fr/api/records/1.0/search/?"
        let parameters: [String: Any] = [
            "accept": "application/json",
            "dataset": "liste_des_sites_des_hotspots_paris_wifi",
            "rows": 500,
            "arrondissement" : self.userCodePostal,
            ]

        Alamofire
            .request(urlString, parameters: parameters)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                
                switch response.result {
                    
                case .success(let json):
                    guard   let content = json as? [String:Any],
                        
                        let records = content["records"] as? [[String:Any]] else {return}
                
                    self.hotSpots = records
                    print(json)
                case .failure(let error):
                    print(error)
                }
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    
    func startLocate() {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100.0
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locations: \(locations)")
        
        self.userLocation = locations.last
        
        self.geoCoder.reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error )->
            Void in
            if error != nil {
                print("Error lors du reverse geoLocation : \(error.debugDescription)")
                return
            }
            if placemarks!.count > 0 {
                
                let placemark = placemarks![0] as CLPlacemark
                
                self.postalCode = (placemark.postalCode  != nil) ? placemark.postalCode : ""; print("placemark update à : \(self.postalCode)")
                
            }else{print("Aucun placemark !")}
        }
    )}
    
}
