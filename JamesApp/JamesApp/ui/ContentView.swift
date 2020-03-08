//
//  ContentView.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 05.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import SwiftUI
import UserNotifications

enum AppState {
    case loading
    case requestPermission
    case permissionDenied
    case canRegister
    case error
}

struct ContentView: View {
    @State var appState: AppState = .loading
    
    var body: some View {
        Group {
            if appState == .loading {
                LoadingView(appState: $appState)
            } else if appState == .requestPermission {
                RequestPermissionView(appState: $appState)
            } else if appState == .permissionDenied {
                PermissionDeniedView()
            } else if appState == .canRegister {
                CanRegisterView()
            } else if appState == .error {
                Text("We are sorry but the app encountered an internal error. Please look at the log files for more information or concat the app author.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in self.appState = .loading }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
