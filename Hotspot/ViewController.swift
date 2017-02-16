//
//  ViewController.swift
//  Hotspot
//
//  Created by Léa Motisi on 16/02/2017.
//  Copyright © 2017 Team Rocket. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let urlString = "https://opendata.paris.fr/api/records/1.0/search/?dataset=liste_des_sites_des_hotspots_paris_wifi&rows=500"
        
        let urlString = "https://opendata.paris.fr/api/records/1.0/search/?"
        
        let parameters: [String: Any] = [
            "dataset": "liste_des_sites_des_hotspots_paris_wifi",
            "rows" : 500
        ]
        
        Alamofire
            .request(urlString, parameters: parameters)
            .validate()
            .responseJSON { (response: DataResponse<Any>) in
                
                switch response.result {
                    
                case .success(let json):
                    print(json)
                case .failure(let error):
                    print(error)
                }
        }

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

