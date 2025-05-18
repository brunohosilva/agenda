//
//  NotificationViewModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 18/05/25.
//

import Foundation
import UserNotifications
import RxSwift
import RxCocoa

class NotificationViewModel {
    private let disposeBag = DisposeBag()
    
    let permissionGranted: BehaviorRelay<Bool> = .init(value: false)
    
    init() {
        checkPermission()
    }
    
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.permissionGranted.accept(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.permissionGranted.accept(granted)
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Agendar a notificação
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                print("Notificação agendada para \(date)")
            }
        }
        
        if date < Date() {
            print("Data informada está no passado. A notificação não será agendada.")
            return
        } else {
            print("Data está certa vai chegar a notificação")
        }
        
    }
}
