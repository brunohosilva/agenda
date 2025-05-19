//
//  MockScheduleViewModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 19/05/25.
//

import RxRelay
import RxSwift

class MockScheduleViewModel: ScheduleViewModelProtocol {
    private let itemsRelay = BehaviorRelay<[ScheduleModel]>(value: [])
    
    var currentItems: [agenda.ScheduleModel] = []
    var scheduleItemsObservable: Observable<[ScheduleModel]> {
        return itemsRelay.asObservable()
    }
    var removedItem: ScheduleModel?
    
    func addSchedule(item: agenda.ScheduleModel) {}
    func updateSchedule(updatedItem: agenda.ScheduleModel) {}
    func setItems(_ items: [ScheduleModel]) {
        itemsRelay.accept(items)
    }
    func removeSchedule(item: ScheduleModel) {
        removedItem = item
    }
}
