//
//  ScheduleViewModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import RxSwift
import RxCocoa

final class ScheduleViewModel {
    
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
    }
}
