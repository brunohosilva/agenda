//
//  AddOrEditScheduleViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxRelay
import RxSwift

class AddOrEditScheduleViewController: UIViewController {
    
    //--------------------------------------------------------
    // MARK: - Injected Properties
    //--------------------------------------------------------
    
    private let viewModel: ScheduleViewModel
    private let editingItem: ScheduleModel?
    
    //--------------------------------------------------------
    // MARK: - Events
    //--------------------------------------------------------
    
    let scheduleCreated = PublishRelay<ScheduleModel>()
    
    //--------------------------------------------------------
    // MARK: - UI Properties
    //--------------------------------------------------------
    
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let timeField = UITextField()
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    private let disposeBag = DisposeBag()
    
    //--------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------
    
    init(viewModel: ScheduleViewModel, editingItem: ScheduleModel? = nil) {
        self.viewModel = viewModel
        self.editingItem = editingItem
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = editingItem != nil ? "Editar agendamento" : "Novo agendamento"
        
        populateItemIfNeeded()
        setupForm()
        bind()
    }
    
    private func populateItemIfNeeded() {
        guard let item = editingItem else { return }
        
        titleTextField.text = item.title
        descriptionTextField.text = item.description
        timeField.text = item.time
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let date = formatter.date(from: item.date) {
            datePicker.date = date
        }
    }
    
    private func setupForm() {
        [titleTextField, descriptionTextField, datePicker, timeField, saveButton, cancelButton].forEach {
            view.addSubview($0)
        }
        
        [titleTextField, descriptionTextField, timeField].forEach {
            $0.borderStyle = .roundedRect
        }
        
        titleTextField.placeholder = "Titulo"
        descriptionTextField.placeholder = "Descrição"
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "pt_BR")
        timeField.placeholder = "Horário (ex: 10:00)"
        
        saveButton.setTitle("Salvar", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.layer.cornerRadius = 10
        saveButton.clipsToBounds = true
        
        cancelButton.setTitle("Cancelar", for: .normal)
        cancelButton.backgroundColor = .systemRed
        cancelButton.layer.cornerRadius = 10
        cancelButton.clipsToBounds = true
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
        descriptionTextField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        datePicker.snp.makeConstraints {
            $0.top.equalTo(descriptionTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        timeField.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(timeField.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
    
    }
    
    private func bind() {
        saveButton.rx.tap
            .bind(to: saveButtonBinder)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private var saveButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            let id = target.editingItem?.id ?? UUID()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"

            let dateString = dateFormatter.string(from: target.datePicker.date)
            
            let scheduleModel = ScheduleModel(
                id: id,
                title: target.titleTextField.text ?? "",
                description: target.descriptionTextField.text ?? "",
                date: dateString,
                time: target.timeField.text ?? ""
            )
            
            if target.editingItem != nil {
                target.viewModel.updateSchedule(updatedItem: scheduleModel)
            } else {
                target.viewModel.addSchedule(item: scheduleModel)
            }
            
            target.dismiss(animated: true)
        }
    }
    
}
