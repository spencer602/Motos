//
//  SceneDelegate.swift
//  Moto Strava
//
//  Created by Spencer DeBuf on 11/18/19.
//  Copyright © 2019 Spencer DeBuf. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let model = ModelController()
        
        print("did finish connecting to session")
        print("window = \(self.window == nil ? "nil": "not nil")")
        if let tbc = window?.rootViewController as? UITabBarController {
            print("root as tab bar controller")
            if let nav = tbc.viewControllers?[0] as?  UINavigationController {
                print("navigationController")
                if let dvc = nav.viewControllers.first as? DataViewController {
                    print("data view controller")
                    dvc.modelController = model
                }
            }
            if let mvc = tbc.viewControllers?[1] as?  MapViewController {
                print("second Map View Controller")
                mvc.modelController = model
            }
            
            if let csvc =  tbc.viewControllers?[2] as? CreateSessionViewController {
                csvc.modelController = model
            }
        }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        if let vc = window?.rootViewController as? UITabBarController {
            if let mvc = vc.selectedViewController as? MapViewController {
                print("started updating location")

                mvc.locationManager.startUpdatingLocation()
            }
        }
    }
    

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("did enter background")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        if let vc = window?.rootViewController as? UITabBarController {
            if let createSessionVC = vc.viewControllers?[2] as? CreateSessionViewController {
                if !createSessionVC.isRecordingTracks {
                    createSessionVC.locationManager.stopUpdatingLocation()
                }
            }
            
        }
    }


}

