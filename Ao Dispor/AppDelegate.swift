//
//  AppDelegate.swift
//  Ao Dispor
//
//  Created by André Lamelas on 15/05/17.
//  Copyright © 2017 aodispor.pt. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics
import Siesta

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self, Answers.self])

        RemoteImageView.defaultImageService.configure {
            $0.useNetworkActivityIndicator()
        }

        // Carrega do keychain os dados de login e se não conseguir mantém o header de autenticação a nil
        AoDisporAPI.autenticar()
        // Se o header de autenticação for nil, não está autenticado e mostra o VC correcto
        if !AoDisporAPI.estáAutenticado {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "registoVC")
            let navigationController = self.window?.rootViewController as! UINavigationController
            navigationController.pushViewController(viewController, animated: false)
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}
