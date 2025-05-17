//
//  ScheduleViewModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import RxSwift
import RxCocoa

final class ScheduleViewModel {
    let scheduleItems: Observable<[ScheduleModel]>
    
    init() {
        self.scheduleItems = Observable.just(
            [
                .init(id: 1, title: "Titulo primeiro agendamento", description: "Dentista", date: "12/12/12", time: "10:30"),
                .init(id: 2, title: "Titulo segundo agendamento", description: "Escola", date: "12/12/12", time: "10:30"),
                .init(id: 3, title: "Titulo terceiro agendamento", description: "Futebol", date: "12/12/12", time: "10:30")
            ],
        )
    }
}
