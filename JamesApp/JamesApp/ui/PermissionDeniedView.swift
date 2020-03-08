//
//  PermissionDeniedView.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import SwiftUI

struct PermissionDeniedView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("The app does not have the permission to send push notifications! To use this app please go to the settings and enable push notifications!")
                .multilineTextAlignment(.center)
            Button("Open settings") { openSettings() }
        }
        .padding()
    }
}

struct PermissionDeniedView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionDeniedView()
    }
}
