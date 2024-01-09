/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`LoggerWindowSceneDelegate` is the delegate for the `UIWindowScene` on the phone's display.
*/

import UIKit

class LoggerWindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    
    internal var window: UIWindow?
    
    // MARK: UISceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene, session.configuration.name == "LoggerSceneConfiguration" else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        
//        let colorViewController = UIStoryboard(name: "Color", bundle: nil).instantiateViewController(withIdentifier: "ColorViewController") as! ColorViewController
//        MemoryLogger.shared.colorDelegate = colorViewController
//        window?.rootViewController = colorViewController
//        window?.windowScene = windowScene
//        window?.makeKeyAndVisible()
        
        let logVC = LoggerViewController()
        window?.rootViewController = logVC
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
        MemoryLogger.shared.delegate = logVC
        MemoryLogger.shared.appendEvent("Logger window scene will connect.")
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        if scene.session.configuration.name == "LoggerSceneConfiguration" {
            MemoryLogger.shared.appendEvent("Logger window scene did disconnect.")
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        if scene.session.configuration.name == "LoggerSceneConfiguration" {
            MemoryLogger.shared.appendEvent("Logger window scene did become active.")
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        if scene.session.configuration.name == "LoggerSceneConfiguration" {
            MemoryLogger.shared.appendEvent("Logger window scene will resign active.")
        }
    }
}
