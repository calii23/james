//
//  RequestPermissionView.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import SwiftUI
import UserNotifications

struct RequestPermissionView: View {
    @Binding var appState: AppState
    
    var body: some View {
        VStack(spacing: 10) {
            Text("This app only work if it has the permission to send push notifications. So please give us the permission to do so.")
                .multilineTextAlignment(.center)
            Button("Request Permission") {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    if let error = error {
                        print("error requesting permission: \(error)")
                        self.appState = .error
                    } else if granted {
                        DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                        self.appState = .canRegister
                    } else {
                        self.appState = .permissionDenied
                    }
                }
            }
        }
        .padding()
    }
}

struct RequestPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        RequestPermissionView(appState: .constant(.loading))
    }
}

