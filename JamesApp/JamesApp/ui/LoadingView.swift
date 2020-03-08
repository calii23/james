//
//  LoadingView.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    @Binding var appState: AppState
    
    var body: some View {
        Text("Loading app data...")
            .onAppear {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    switch settings.authorizationStatus {
                    case .notDetermined:
                        self.appState = .requestPermission
                    case .authorized:
                        self.appState = .canRegister
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    case .denied:
                        self.appState = .permissionDenied
                    case .provisional:
                        print("authorization status is provisional")
                        self.appState = .error
                    @unknown default:
                        print("unknown authorization status: \(settings.authorizationStatus)")
                        self.appState = .error
                    }
                }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(appState: .constant(.loading))
    }
}
