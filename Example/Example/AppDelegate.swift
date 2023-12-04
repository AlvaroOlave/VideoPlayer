//
//  AppDelegate.swift
//  Example
//
//  Created by Álvaro Olave Bañeres on 29/11/23.
//

import UIKit
import VideoPlayer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let _ = window?.rootViewController?.presentedViewController as? FullScreenVideoPlayerViewController {
            return [.landscape, .portrait]
        } else {
            _ = Bundle.main.infoDictionary?["UISupportedInterfaceOrientations"] as? [String]
            
            return .portrait
        }
    }
}

private extension UIInterfaceOrientation {
    init?(string: String) {
        switch string {
        case "UIInterfaceOrientationPortrait":
            self = UIInterfaceOrientation.portrait
        case "UIInterfaceOrientationPortraitUpsideDown":
            self = UIInterfaceOrientation.portraitUpsideDown
        case "UIInterfaceOrientationLandscapeLeft":
            self = UIInterfaceOrientation.landscapeLeft
        case "UIInterfaceOrientationLandscapeRight":
            self = UIInterfaceOrientation.landscapeRight
        default:
            self = UIInterfaceOrientation.portrait
        }
    }
    
    var string: String {
        switch self {
        case .unknown:
            return "unknown"
        case .portrait:
            return "UIInterfaceOrientationPortrait"
        case .portraitUpsideDown:
            return "UIInterfaceOrientationPortraitUpsideDown"
        case .landscapeLeft:
            return "UIInterfaceOrientationLandscapeLeft"
        case .landscapeRight:
            return "UIInterfaceOrientationLandscapeRight"
        @unknown default:
            return "unknown"
        }
    }
}

