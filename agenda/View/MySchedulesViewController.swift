//
//  MySchedulesViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class MySchedulesViewController: UIViewController, UITableViewDelegate {
    
    //--------------------------------------------------------
    // MARK: - Events
    //--------------------------------------------------------
    
    private let detailTapRelay = PublishRelay<ScheduleModel>()
    private let deleteTapRelay = PublishRelay<ScheduleModel>()
    private let disposeBag = DisposeBag()
    
    //--------------------------------------------------------
    // MARK: - UI Properties
    //--------------------------------------------------------
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let tableView = UITableView()
    private let viewModel = ScheduleViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        tableView.delegate = self
    }
    
    //--------------------------------------------------------
    // MARK: - UITableView
    //--------------------------------------------------------
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let schedule = viewModel.currentItems[indexPath.row]
        detailTapRelay.accept(schedule)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let schedule = viewModel.currentItems[indexPath.row]
        let detailAction = UIContextualAction(style: .normal, title: "Detalhes") { [weak self] _, _, completion in
            self?.detailTapRelay.accept(schedule)
            completion(true)
        }
        detailAction.backgroundColor = .systemBlue

        let deleteAction = UIContextualAction(style: .destructive, title: "Apagar") { [weak self] _, _, completion in
            self?.deleteTapRelay.accept(schedule)
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, detailAction])
        config.performsFirstActionWithFullSwipe = false
        return config
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
            .bind(to: addButtonBinder)
            .disposed(by: disposeBag)
        
        viewModel.scheduleItemsObservable
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, scheduleData, cell in
                cell.textLabel?.text = scheduleData.title
            }
            .disposed(by: disposeBag)
        
        detailTapRelay
            .bind(to: detailTapBinder)
            .disposed(by: disposeBag)
        
        deleteTapRelay
            .bind(to: deleteTapBinder)
            .disposed(by: disposeBag)
    }
    
    private var addButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            let addScheduleVC = AddScheduleViewController(viewModel: target.viewModel)
            let navigationVC = UINavigationController(rootViewController: addScheduleVC)
            target.present(navigationVC, animated: true)
        }
    }
    
    private var detailTapBinder: Binder<ScheduleModel> {
        Binder(self) { target, scheduleData in
            print("pegar detalhes do item: \(scheduleData)")
        }
    }
    
    private var deleteTapBinder: Binder<ScheduleModel> {
        Binder(self) { target, scheduleData in
            target.viewModel.removeSchedule(item: scheduleData)
        }
    }
}
