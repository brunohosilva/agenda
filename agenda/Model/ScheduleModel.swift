//
//  ScheduleModel.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import Foundation

struct ScheduleModel: Codable {
    var id: UUID
    var title: String
    var description: String
    var date: String
    var time: String
}
