//
//  ScheduleStorage.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import Foundation

class ScheduleStorage {
    private let key = "storedSchedules"
    
    func save(_ schedules: [ScheduleModel]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(schedules) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func fetch() -> [ScheduleModel] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode([ScheduleModel].self, from: data)) ?? []
    }
}
