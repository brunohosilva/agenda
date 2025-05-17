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
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let tableView = UITableView()
    private let disposeBag = DisposeBag()
    private let viewModel = ScheduleViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    private func setupUI() {
        
        title = "Minha agenda"
        navigationItem.rightBarButtonItem = addButton
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        
        addButton.rx.tap
            .bind { [weak self] in
                print("Botão + clicado via Rx")
            }
            .disposed(by: disposeBag)
        
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
