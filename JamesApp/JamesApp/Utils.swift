//
//  Utils.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import UIKit

func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else {
        return
    }
    
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}

extension String: Error {
}
