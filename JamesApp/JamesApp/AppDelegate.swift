//
//  AppDelegate.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 05.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let didChangedLocationAuthorization = NSNotification.Name("didChangedLocationAuthorization")
    static let didUserRequestedLocationAuthorization = NSNotification.Name("didUserRequestedLocationAuthorization")
    
    private(set) var tokenMessage: Data?
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        NotificationCenter.default.addObserver(forName: AppDelegate.didUserRequestedLocationAuthorization, object: nil, queue: nil) { _ in
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var tokenMessage = Data(capacity: 36)
        tokenMessage.append(0x2A)
        tokenMessage.append(0x0E)
        tokenMessage.append(0x4D)
        tokenMessage.append(0xE9)
        tokenMessage.append(deviceToken)
        self.tokenMessage = tokenMessage
        #if DEBUG
        print("token:", tokenMessage.map { String(format: "%02x", $0) }.joined())
        #endif
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("failed to register for remote push notification: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let wifi = userInfo["wifi"] as? String else {
            completionHandler(.failed)
            return
        }
        
        guard let type = userInfo["type"] as? Int else {
            completionHandler(.failed)
            return
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if wifi != getSSID() {
                completionHandler(.noData)
                return
            }
        }
        
        self.processNotification(type: type, completionHandler: completionHandler)
    }
    
    private func processNotification(type: Int, completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let content = UNMutableNotificationContent()
        
        if type == 0 {
            content.title = "Doorbell"
            content.body = "Somebody ringed at your door"
            content.sound = .default
        } else if type == 1 {
            content.title = "Registered"
            content.body = "You registered this device"
        } else if type == 2 {
            content.title = "Registered"
            content.body = "This device was already registered"
        } else {
            completionHandler(.failed)
            return
        }
        
        if UIApplication.shared.applicationState == .active {
            let alert = UIAlertController(title: content.title, message: content.body, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.windows.first { $0.rootViewController != nil }?.rootViewController?.present(alert, animated: true, completion: nil)
            completionHandler(.noData)
        } else {
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)) { error in
                if let error = error {
                    print("could not send push notification: \(error)")
                    completionHandler(.failed)
                } else {
                    completionHandler(.newData)
                }
            }
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        NotificationCenter.default.post(name: AppDelegate.didChangedLocationAuthorization, object: status)
    }
}
