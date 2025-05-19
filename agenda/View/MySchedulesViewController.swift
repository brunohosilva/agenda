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
    private let editTapRelay = PublishRelay<ScheduleModel>()
    private let deleteTapRelay = PublishRelay<ScheduleModel>()
    private let disposeBag = DisposeBag()
    
    //--------------------------------------------------------
    // MARK: - UI Properties
    //--------------------------------------------------------
    
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    private let tableView = UITableView()
    
    //--------------------------------------------------------
    // MARK: - UI Empty View State
    //--------------------------------------------------------
    
    private let emptyStateView = UIView()
    private let emptyLabel = UILabel()
    private let emptyAddButton = UIButton(type: .system)
    
    private let viewModel: ScheduleViewModelProtocol

    init(viewModel: ScheduleViewModelProtocol = ScheduleViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let editAction = UIContextualAction(style: .normal, title: "Editar") { [weak self] _, _, completion in
            self?.editTapRelay.accept(schedule)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue

        let deleteAction = UIContextualAction(style: .destructive, title: "Apagar") { [weak self] _, _, completion in
            self?.deleteTapRelay.accept(schedule)
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    private func setupUI() {
        
        title = "Minha agenda"
        navigationItem.rightBarButtonItem = addButton
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "ScheduleCell")
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(emptyStateView)
        
        [emptyLabel, emptyAddButton].forEach {
            emptyStateView.addSubview($0)
        }
        
        emptyStateView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        emptyLabel.text = "Você não possui agendamentos."
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 18)
        emptyLabel.numberOfLines = 0

        emptyAddButton.setTitle("Adicionar agendamento", for: .normal)
        emptyAddButton.setTitleColor(.systemBlue, for: .normal)

        emptyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
            $0.left.right.equalToSuperview().inset(32)
        }

        emptyAddButton.snp.makeConstraints {
            $0.top.equalTo(emptyLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
    }
    
    private func bind() {
        
        addButton.rx.tap
            .bind(to: addButtonBinder)
            .disposed(by: disposeBag)
        
        emptyAddButton.rx.tap
            .bind(to: addButtonBinder)
            .disposed(by: disposeBag)
        
        viewModel.scheduleItemsObservable
            .bind(to: tableView.rx.items(cellIdentifier: "ScheduleCell", cellType: ScheduleCell.self)) { row, scheduleData, cell in
                cell.titleLabel.text = scheduleData.title
                cell.dateTimeLabel.text = "\(scheduleData.date) às \(scheduleData.time)"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                dateFormatter.locale = Locale(identifier: "pt_BR")
                
                if let scheduledDate = self.combinedDate(from: scheduleData) {
                    self.configureDateTimeLabel(cell.dateTimeLabel, with: scheduledDate)
                } else {
                    cell.dateTimeLabel.textColor = .label
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.scheduleItemsObservable
            .map { $0.isEmpty }
            .bind(to: emptyStateBinder)
            .disposed(by: disposeBag)
        
        detailTapRelay
            .bind(to: detailTapBinder)
            .disposed(by: disposeBag)
        
        editTapRelay
            .bind(to: editTapBinder)
            .disposed(by: disposeBag)
        
        deleteTapRelay
            .bind(to: deleteTapBinder)
            .disposed(by: disposeBag)
    }
    
    private var emptyStateBinder: Binder<Bool> {
        Binder(self) { target, isEmpty in
            target.emptyStateView.isHidden = !isEmpty
            target.tableView.isHidden = isEmpty
        }
    }
    
    private var detailTapBinder: Binder<ScheduleModel> {
        Binder(self) { target, scheduleData in
            let scheduleDialogDetailsVC = ScheduleDetailsDialogViewController(schedule: scheduleData)
            target.present(scheduleDialogDetailsVC, animated: true)
        }
    }

    private var addButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            let addScheduleVC = AddOrEditScheduleViewController(viewModel: target.viewModel)
            let navigationVC = UINavigationController(rootViewController: addScheduleVC)
            target.present(navigationVC, animated: true)
        }
    }
    
    private var editTapBinder: Binder<ScheduleModel> {
        Binder(self) { target, scheduleData in
            let editVC = AddOrEditScheduleViewController(viewModel: target.viewModel, editingItem: scheduleData)
            let navigationVC = UINavigationController(rootViewController: editVC)
            target.present(navigationVC, animated: true)
        }
    }
    
    private var deleteTapBinder: Binder<ScheduleModel> {
        Binder(self) { target, scheduleData in
            target.viewModel.removeSchedule(item: scheduleData)
        }
    }
    
    private func combinedDate(from schedule: ScheduleModel) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.date(from: "\(schedule.date) \(schedule.time)")
    }
    
    private func configureDateTimeLabel(_ label: UILabel, with date: Date) {
        label.textColor = date < Date() ? .systemRed : .label
    }

}

#if DEBUG
extension MySchedulesViewController {
    func testTriggerAddButton() {
        addButtonBinder.onNext(())
    }

    func testTriggerDetailTap(_ model: ScheduleModel) {
        detailTapBinder.onNext(model)
    }

    func testTriggerEditTap(_ model: ScheduleModel) {
        editTapBinder.onNext(model)
    }

    func testTriggerDeleteTap(_ model: ScheduleModel) {
        deleteTapBinder.onNext(model)
    }
}
#endif
