//
//  PermissionManager.swift
//  Permission
//
//  Created by SDNA Tech on 14/09/23.
//

import UIKit
import UserNotifications

enum PermissionStatus {
    case notDetermined
    case denied
    case authorized
    case restricted
}

class PushNotification: NSObject {
    
    @Published var pushNotificationPermission: PermissionStatus = .notDetermined
    
    func requestPushNotificationSettings() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional) else {
                self.pushNotificationPermission = .denied
                return
            }
            self.pushNotificationPermission = .authorized
        }
    }
    
    func requestPushNotificationPermission() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
                self.pushNotificationPermission = .denied
            } else if granted {
                self.pushNotificationPermission = .authorized
            } else {
                self.pushNotificationPermission = .denied
            }
        }
    }
    
    func registerForRemoteNotifications() {
        DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
    }
}
