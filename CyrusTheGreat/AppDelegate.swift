//
//  AppDelegate.swift
//  CyrusTheGreat
//
//  Created by Dotun Opasina on 2/16/16.
//  Copyright (c) 2016 Dotun Opasina. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var userFire: FIRDatabaseReference! // CyrusTheGreat Connection
    var meetAccept: Bool!
    var userIdentifier:String! // uid from firebase
    var userFirstName: String!
    var otherUserIdentifieir: String!
    var userObject:User!
    var connectedProfile:UserProfile!
    var iamInitiator:Bool! // Chat initiator

    var locationManager  = CLLocationManager()
    var justMetUpWith = ""
    var myImage:UIImage!
    var userMetWith:User!
    var firebaseUser:FIRUser!
   
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        FIRApp.configure()
        userFire = FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/")

        meetAccept = false
        
        locationManager.requestWhenInUseAuthorization()
        
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Use Firebase library to configure APIs

        return true
    }
    
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(application: UIApplication, willEncodeRestorableStateWithCoder coder: NSCoder) {
 
    }
    func application(application: UIApplication, didDecodeRestorableStateWithCoder coder: NSCoder) {
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
       
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        FIRApp.configure()
//        userFire = FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/")
//        meetAccept = false
        if (FIRApp.allApps() == nil ) {
            FIRApp.configure()
            userFire = FIRDatabase.database().referenceFromURL("https://cyrusthegreat.firebaseio.com/")

        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        userFirebaseManager.updateUserState("InActive")
        
//        let userExactPath = Firebase(url:"https://cyrusthegreat.firebaseio.com/activeusers/\(userFirebaseManager.userId)")
//        userFirebaseManager.updateUserState("Not Active")
//        userFirebaseManager.disConnect(true)
       
        
    }
    
    
    
    


}

//
//extension UIApplication {
//    class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
//        if let nav = base as? UINavigationController {
//            return topViewController(nav.visibleViewController)
//        }
//        if let tab = base as? UITabBarController {
//            if let selected = tab.selectedViewController {
//                return topViewController(selected)
//            }
//        }
//        if let presented = base?.presentedViewController {
//            return topViewController(presented)
//        }
//        return base
//    }
//}



