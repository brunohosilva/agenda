//
//  ScheduleViewModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol ScheduleViewModelProtocol {
    var currentItems: [ScheduleModel] { get }
    var scheduleItemsObservable: Observable<[ScheduleModel]> { get }
    
    func removeSchedule(item: ScheduleModel)
    func addSchedule(item: ScheduleModel)
    func updateSchedule(updatedItem: ScheduleModel)
}

final class ScheduleViewModel: ScheduleViewModelProtocol {
    
    private let notificationViewModel = NotificationViewModel()
    private let storage = ScheduleStorage()
    private let scheduleItems: BehaviorRelay<[ScheduleModel]>
    
    var scheduleItemsObservable: Observable<[ScheduleModel]> {
        scheduleItems.asObservable()
    }
    
    var currentItems: [ScheduleModel] {
        return scheduleItems.value
    }

    init() {
        let savedItems = storage.fetch()
        self.scheduleItems = BehaviorRelay(value: savedItems)
    }
    
    func addSchedule(item: ScheduleModel) {
        var currentItems = scheduleItems.value
        currentItems.append(item)
        scheduleItems.accept(currentItems)
        storage.save(currentItems)
        
        if let date = combineDateAndTime(dateString: item.date, timeString: item.time) {
            notificationViewModel.scheduleNotification(
                title: item.title,
                body: item.description,
                date: date,
                offsetInMinutes: item.alertOffsetInMinutes
            )
        }
    }
    
    func combineDateAndTime(dateString: String, timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return formatter.date(from: "\(dateString) \(timeString)")
    }
    
    func removeSchedule(item: ScheduleModel) {
        var current = scheduleItems.value
        current.removeAll { $0.id == item.id }
        scheduleItems.accept(current)
        storage.save(current)
    }
    
    func updateSchedule(updatedItem: ScheduleModel) {
        var current = scheduleItems.value
        if let index = current.firstIndex(where: { $0.id == updatedItem.id }) {
            current[index] = updatedItem
            scheduleItems.accept(current)
            storage.save(current)
        }
    }
}
