//
//  AppDelegate.swift
//  WSUXKCD
//
//  Created by Erik M. Buck on 11/3/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Create the Model
    let model = WSUXKCDModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Start the process of obtaining information about available comics
        model.getCurrentInfo()
        
        return true
    }
    
}

