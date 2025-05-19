//
//  MySchedulesViewControllerSnapshotTests.swift
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

class MySchedulesViewControllerSnapshotTests: QuickSpec {
    override class func spec() {
        describe("Snapshot") {
            var mockViewModel: MockScheduleViewModel!
            var mySchedulesVC: MySchedulesViewController!

            beforeEach {
                mockViewModel = MockScheduleViewModel()
                mySchedulesVC = MySchedulesViewController(viewModel: mockViewModel)
                mySchedulesVC.view.frame = UIScreen.main.bounds
            }

            it("exibe o estado vazio") {
                mockViewModel.setItems([])
                mySchedulesVC.view.layoutIfNeeded()
                
                SnapshotTesting.isRecording = false

                expect {
                    SnapshotTesting.assertSnapshot(
                        of: mySchedulesVC,
                        as: .image(on: .iPhoneXr),
                        named: "EmptyState"
                    )
                }.toNot(throwError())
            }

            it("exibe agendamentos") {
                let items = [
                    ScheduleModel(id: UUID(),title: "Dentista", description: "Limpeza", date: "20/05/2025", time: "10:00", alertOffsetInMinutes: 10),
                    ScheduleModel(id: UUID(), title: "Trabalho", description: "Freelancer", date: "21/05/2025", time: "08:30", alertOffsetInMinutes: 15)
                ]
                mockViewModel.setItems(items)
                mySchedulesVC.view.layoutIfNeeded()
                
                SnapshotTesting.isRecording = false

                expect {
                    SnapshotTesting.assertSnapshot(
                        of: mySchedulesVC,
                        as: .image(on: .iPhoneXr),
                        named: "WithItems"
                    )
                }.toNot(throwError())
            }
        }
    }
}

