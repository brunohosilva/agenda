//
//  MySchedulesViewControllerTests.swift
//  agenda
//
//  Created by Bruno Oliveira on 19/05/25.
//

import XCTest
@testable import agenda

final class MySchedulesViewControllerTests: XCTestCase {

    var viewModel: MockScheduleViewModel!
    var mySchedulesVC: SpyMySchedulesViewController!

    override func setUp() {
        super.setUp()
        viewModel = MockScheduleViewModel()
        mySchedulesVC = SpyMySchedulesViewController(viewModel: viewModel)
        mySchedulesVC.loadViewIfNeeded()
    }

    func test_addButtonBinder_shouldPresentAddOrEditScheduleVC() {
        mySchedulesVC.testTriggerAddButton()
        let presented = mySchedulesVC.presentedViewControllerSpy as? UINavigationController
        XCTAssertNotNil(presented?.topViewController as? AddOrEditScheduleViewController)
    }

    func test_detailTapBinder_shouldPresentScheduleDetailsVC() {
        let mockData = ScheduleModel(id: UUID(), title: "Teste", description: "", date: "20/05/2025", time: "10:00", alertOffsetInMinutes: 0)
        mySchedulesVC.testTriggerDetailTap(mockData)
        XCTAssertTrue(mySchedulesVC.presentedViewControllerSpy is ScheduleDetailsDialogViewController)
    }

    func test_editTapBinder_shouldPresentEditScheduleVCWithData() {
        let mockData = ScheduleModel(id: UUID(), title: "Editar", description: "", date: "21/05/2025", time: "14:00", alertOffsetInMinutes: 10)
        mySchedulesVC.testTriggerEditTap(mockData)
        let nav = mySchedulesVC.presentedViewControllerSpy as? UINavigationController
        let editVC = nav?.topViewController as? AddOrEditScheduleViewController
        XCTAssertNotNil(editVC)    }

    func test_deleteTapBinder_shouldCallRemoveSchedule() {
        let mockData = ScheduleModel(id: UUID(), title: "Apagar", description: "", date: "22/05/2025", time: "09:00", alertOffsetInMinutes: 5)
        mySchedulesVC.testTriggerDeleteTap(mockData)
        XCTAssertEqual(viewModel.removedItem?.id, mockData.id)
    }
}
