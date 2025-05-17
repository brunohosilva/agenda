//
//  ViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
    private let viewModel = ScheduleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindTableView()
    }
    
    private func setupUI() {
        title = "Agenda"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bindTableView() {
        
        viewModel.scheduleItems
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, scheduleData, cell in
                cell.textLabel?.text = scheduleData.title
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(ScheduleModel.self)
            .bind(to: selectedItemBinder)
            .disposed(by: disposeBag)
    }
    
    private var selectedItemBinder: Binder<ScheduleModel> {
        Binder(self) { target, selected in
            print("Selecionado: \(selected)")
        }
    }
}
