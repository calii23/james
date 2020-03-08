//
//  CanRegisterView.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import SwiftUI
import Darwin
import CoreLocation

//struct LocationManagerObserver: UIViewRepresentable {
//    private var manager: CLLocationManager
//    private var callback: (CLAuthorizationStatus) -> Void
//
//    init(manager: CLLocationManager, callback: @escaping (CLAuthorizationStatus) -> Void) {
//        self.manager = manager
//        self.callback = callback
//    }
//
//    func makeUIView(context: Context) -> UILabel {
//        return UILabel()
//    }
//
//    func updateUIView(_ uiView: UILabel, context: Context) {
//    }
//
//    func makeCoordinator() -> LocationManagerObserver.Coordinator {
//        return Coordinator(manager, callback)
//    }
//
//    class Coordinator: NSObject, CLLocationManagerDelegate {
//        let authorizationCallback: (CLAuthorizationStatus) -> Void
//
//        init(_ manager: CLLocationManager, _ authorizationCallback: @escaping (CLAuthorizationStatus) -> Void) {
//            self.authorizationCallback = authorizationCallback
//            super.init()
//            manager.delegate = self
//        }
//
//        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//            self.authorizationCallback(status)
//        }
//    }
//}

struct CanRegisterView: View {
    @State var showRegistrationFailed = false
    
    @State private var manager = CLLocationManager()
    @State private var locationAuthorization = CLLocationManager.authorizationStatus()
    
    @State private var currentSSID = getSSID()
    
    var body: some View {
        VStack(spacing: 10) {
            Text("The app has the permission to send push notifications. Now you can register this iPhone to your doorbell detector. This should jsut work as long as the you are in the same WiFi as the device. Just press the button below. If your device was registered, you will get a push notification to inform you about that it worked.")
                .multilineTextAlignment(.center)
            
            if locationAuthorization != .authorizedAlways {
                Text(locationAuthorization != .authorizedWhenInUse ? "WARNING: You need to grant location permission always, otherwise no WiFi information can be received when receiveing a push notification." :  "WARNING: Apple decided that in iOS 13 it is required to give an app permission to location services to allow the app to get information about the current WiFi. This means that this app requires location permission to check whether you at home or not. You can use this app without giving it location permission but then you will receive push notifications always not only when you are home.")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                if locationAuthorization == .notDetermined {
                    Button("Request permission") { NotificationCenter.default.post(name: AppDelegate.didUserRequestedLocationAuthorization, object: nil) }
                } else {
                    Button("Open settings") { openSettings() }
                }
            } else {
                Text("Please make sure that the app has access to location 'Always' not only 'While Using the App'. This is required for the app. Otherwise you will not receive any push notifications.")
                    .italic()
                    .multilineTextAlignment(.center)
                Button("Open settings") { openSettings() }
                Text(currentSSID.map { "Currently you are in the WiFi: \($0)" } ?? "You are currently not connected to any WiFi!")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            
            Button("Register iPhone") {
                if let token = (UIApplication.shared.delegate as? AppDelegate)?.token {
                    if !broadcastUdpMessage(message: "REGISTER \(token)", port: 32425) {
                        print("failed to broadcast udp packet")
                        self.showRegistrationFailed = true
                    }
                } else {
                    print("missing device token")
                    self.showRegistrationFailed = true
                }
            }
            .disabled(locationAuthorization == .authorizedAlways && currentSSID == nil)
        }
        .padding()
        .alert(isPresented: $showRegistrationFailed) {
            Alert(title: Text("Failed to register"), message: Text("The registration failed, if this error persist please contact the app author."))
        }
        .onReceive(NotificationCenter.default.publisher(for: AppDelegate.didChangedLocationAuthorization)) { notification in
            let status = notification.object as! CLAuthorizationStatus
            self.locationAuthorization = status
            if status == .authorizedAlways {
                self.currentSSID = getSSID()
            }
        }
    }
}

struct CanRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        CanRegisterView()
    }
}
