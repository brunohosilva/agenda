//
//  AddOrEditScheduleViewControllerSnapshotTests.swift
//  agenda
//
//  Created by Bruno Oliveira on 19/05/25.
//

import UIKit
import Quick
import Nimble
import SnapshotTesting
import RxSwift
import RxRelay

@testable import agenda

class AddOrEditScheduleViewControllerSnapshotTests: QuickSpec {
    override class func spec() {
        describe("snapshot") {
            
            var mockViewModel: MockScheduleViewModel!
            var addOrEditScheduleVC: AddOrEditScheduleViewController!
            
            let scheduleModel = ScheduleModel(id: UUID(),title: "Dentista", description: "Limpeza", date: "20/05/2025", time: "10:00", alertOffsetInMinutes: 10)
            
            beforeEach  {
                mockViewModel = MockScheduleViewModel()
                addOrEditScheduleVC = AddOrEditScheduleViewController(viewModel: mockViewModel, editingItem: scheduleModel)
                addOrEditScheduleVC.view.frame = UIScreen.main.bounds
            }
            
            it("exibe tela de edição de um agendamento") {
                addOrEditScheduleVC.view.layoutIfNeeded()
                
                SnapshotTesting.isRecording = false
                
                expect {
                    SnapshotTesting.assertSnapshot(
                        of: addOrEditScheduleVC,
                        as: .image(on: .iPhoneXr),
                        named: "EditSchedule"
                    )
                }.toNot(throwError())
                
            }
        }
    }
}
