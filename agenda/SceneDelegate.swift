//
//  SceneDelegate.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxSwift
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    private let disposeBag = DisposeBag()
    private let notificationViewModel = NotificationViewModel()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: MySchedulesViewController())
        self.window = window
        window.makeKeyAndVisible()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        notificationViewModel.checkPermission()
        
        notificationViewModel.permissionGranted
            .bind(to: permissionGrantedBinder)
            .disposed(by: disposeBag)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    private var permissionGrantedBinder: Binder<Bool> {
        Binder(self) { target, isGranted in
            if !isGranted {
                target.notificationViewModel.requestPermission()
            }
        }
    }
}



