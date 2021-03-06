//
//  AppDelegate.swift
//  musicprof
//
//  Created by Alexis Morell Blanco on 29/01/18.
//  Copyright © 2018 Alexis Morell Blanco. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Braintree
import PushNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let PAYMENT_SCHEME = "com.mx.musicprof.payments"

    var window: UIWindow?
    
    let pushNotifications = PushNotifications.shared
    var openMessage: Message?
    var badgeTimer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UINavigationBar.appearance().barTintColor = UIColor(displayP3Red: 57/255, green: 56/255, blue: 58/255, alpha: 0)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = true
        
        self.pushNotifications.start(instanceId: "be4fd2f6-aeb2-4b70-84a7-caa9b325cb40")
        self.pushNotifications.registerForRemoteNotifications()
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String:Any] {
            print("Opened from notification with \(notification)")
            if let data = notification["data"] as? [String: AnyObject], let message = data["message"] as? [String:Any] {
                openMessage = Message(fromJSON: message)
            }
        }
        
        application.setMinimumBackgroundFetchInterval(600)

        BTAppSwitch.setReturnURLScheme(PAYMENT_SCHEME)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("[NOTIFICATION] \(userInfo)")
        self.pushNotifications.handleNotification(userInfo: userInfo)
        return completionHandler(.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == PAYMENT_SCHEME {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        application.updateBadge(completionHandler: completionHandler)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
        badgeTimer?.invalidate()
        badgeTimer = nil
        application.updateBadge {_ in }
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        application.updateBadge {
//
//        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.badgeTimer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true, block: { (timer) in
            UIApplication.shared.updateBadge { _ in }
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension UIApplication {
    func updateBadge(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("[BADGE] Updating badge")
        guard let user = ApiManager.shared.user else { return completionHandler(.noData) }
        ApiManager.shared.getNextReservations(ofUser: user) { (result) in
            switch result {
            case .success(let reservations):
                let count = reservations.countUnreadMessages()
                print("[BADGE]", count, "unread messages")
                let changed = self.applicationIconBadgeNumber != count
                self.applicationIconBadgeNumber = count
                completionHandler(changed ? .newData : .noData)
            default:
                completionHandler(.failed)
            }
        }
    }
    
    func decreaseBadge() {
        self.applicationIconBadgeNumber = max(self.applicationIconBadgeNumber - 1, 0)
    }
}
