//
//  Extension.swift
//  LuvabSigner
//
//  Created by Nguyen Xuan Khang on 9/17/19.
//  Copyright © 2019 Luva. All rights reserved.
//

import Foundation
import UIKit
import OneSignal

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIApplication {
    func getAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    public func localizedString() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func encodeUrl() -> String {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
    
    func decodeUrl() -> String {
        return self.removingPercentEncoding ?? ""
    }

}

extension UIView {
    
    func viewFromNibForClass() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    func viewFromParentView(parentView: UIView) -> UIView? {
        var view: UIView?
        for child: UIView in parentView.subviews {
            if (String(describing: child.self) == String(describing: self)) {
                view = child
                
                break
            }
        }
        
        return view
    }
    
    func addFullSubView(child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(child)
        
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor),
            child.topAnchor.constraint(equalTo: topAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
}

extension URL {
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String: String]()
        if let keyValues = self.query?.decodeUrl().components(separatedBy: "&") {
            if(keyValues.count > 0) {
                results["host"] = self.host ?? ""
                results["path"] = self.path
                for pair in keyValues {
                    let kv = pair.components(separatedBy: "=")
                    if kv.count > 1 {
                        results.updateValue(kv[1], forKey: kv[0])
                    }
                }
            }
            return results
        }
        return nil
        
    }
}

extension AppDelegate: OSPermissionObserver, OSSubscriptionObserver {
    
    
    func setupOnsignal(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        OneSignal.setSubscription(true)
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            if let additionalData = result?.notification.payload?.additionalData {

            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppAlerts: true, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId:"abc3541d-068d-47d5-8b91-8da37e5dd2ce", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        
        OneSignal.add(self as OSSubscriptionObserver)
        self.onRegisterForPushNotifications()
    }
    
    // Add this new method
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
                self.onRegisterForPushNotifications()
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(stateChanges)")
    }
    
    // Output:
    
    // TODO: update docs to change method name
    // Add this new method
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
            self.onRegisterForPushNotifications()
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
    }
    
    func onRegisterForPushNotifications() {
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let hasPrompted = status.permissionStatus.hasPrompted
        if hasPrompted == false {
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                if accepted == true {
                    
                    print("User accepted notifications: \(accepted)")
                    if let onesignalUserId = status.subscriptionStatus.userId {
                        bSignerServiceManager.sharedInstance.oneSignalUserId = onesignalUserId
                    }
                } else {
                    print("User accepted notifications: \(accepted)")
                }
            })
        } else {
            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
            if(status.permissionStatus.status == .authorized) {
                if let onesignalUserId = status.subscriptionStatus.userId {
                    bSignerServiceManager.sharedInstance.oneSignalUserId = onesignalUserId
                }
                
            } else {
                displaySettingsNotification()
            }
        }
    }
    
    func displaySettingsNotification() {
        
    }
}
