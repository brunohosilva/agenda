//
//  AddOrEditScheduleViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxRelay
import RxSwift
import RxCocoa
import SnapKit

class AddOrEditScheduleViewController: UIViewController {
    
    //--------------------------------------------------------
    // MARK: - Injected Properties
    //--------------------------------------------------------
    
    private let viewModel: ScheduleViewModelProtocol
    private let editingItem: ScheduleModel?
    
    //--------------------------------------------------------
    // MARK: - Events
    //--------------------------------------------------------
    
    let scheduleCreated = PublishRelay<ScheduleModel>()
    let selectHourDoneTapped = PublishRelay<Void>()
    let selectedAlertOffsetRelay = BehaviorRelay<Int>(value: 0)
    let saveTypeRelay = PublishRelay<SaveType>()
    
    //--------------------------------------------------------
    // MARK: - UI Properties
    //--------------------------------------------------------
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let timeField = UITextField()
    private let timePicker = UIDatePicker()
    
    private lazy var alertPickerView: AlertPickerView = {
        return AlertPickerView(initialIndex: editingItem?.alertOffsetInMinutes ?? 0)
    }()
     
    private let saveButton = ButtonView(
        title: "Salvar",
        backgroundColor: .systemBlue
    )
    private let cancelButton = ButtonView(
        title: "Cancelar",
        backgroundColor: .systemRed
    )
    private let disposeBag = DisposeBag()
    
    private let toolbar = UIToolbar()
    private let selectHourDoneButton = UIBarButtonItem(title: "Concluir", style: .done, target: nil, action: nil)
    
    //--------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------

    init(viewModel: ScheduleViewModelProtocol = ScheduleViewModel(),
         editingItem: ScheduleModel? = nil) {
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
        
        setupScrolView()
        setupTapGesture()
        populateItemIfNeeded()
        setupForm()
        bind()

    }
    
    private func setupScrolView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.bottom.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.top.equalTo(scrollView)
            $0.left.right.bottom.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
    }
    
    private func populateItemIfNeeded() {
        guard let item = editingItem else { return }
        
        titleTextField.text = item.title
        descriptionTextField.text = item.description
        timeField.text = item.time
        
        if let date = formatToDate(dateFormat: "dd/MM/yyyy", dateString: item.date) {
            datePicker.date = date
        }
        
        if let timeDate = formatToDate(dateFormat: "HH:mm", dateString: item.time) {
            timePicker.date = timeDate
        }
        
    }
    
    private func setupForm() {
        [titleTextField, descriptionTextField, datePicker, timeField, alertPickerView, saveButton, cancelButton].forEach {
            contentView.addSubview($0)
        }
        
        [titleTextField, descriptionTextField, timeField].forEach {
            $0.borderStyle = .roundedRect
        }
        
        titleTextField.placeholder = "Titulo"
        descriptionTextField.placeholder = "Descrição"
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "pt_BR")
        
        timePicker.datePickerMode = .time
        timePicker.locale = Locale(identifier: "pt_BR")
        timePicker.preferredDatePickerStyle = .wheels
        
        toolbar.sizeToFit()
        toolbar.setItems([selectHourDoneButton], animated: false)
        
        timeField.inputView = timePicker
        timeField.inputAccessoryView = toolbar
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(20)
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
        alertPickerView.snp.makeConstraints {
            $0.top.equalTo(timeField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
            $0.height.equalTo(50)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(alertPickerView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(saveButton)
            $0.height.equalTo(44)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
    }
    
    private func bind() {

        selectHourDoneButton.rx.tap
            .bind(to: toolbarTapBinder)
            .disposed(by: disposeBag)
                
        timePicker.rx.date
            .map { [weak self] in self?.formatToDateString(dateFormat: "HH:mm", date: $0) ?? "" }
            .bind(to: timeField.rx.text)
            .disposed(by: disposeBag)
        
        saveButton.buttonTap
            .bind(to: saveButtonBinder)
            .disposed(by: disposeBag)
        
        cancelButton.buttonTap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private var toolbarTapBinder: Binder<Void> {
        Binder(self) { target, _ in
            target.timeField.resignFirstResponder()
        }
    }
    
    private var saveButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            let id = target.editingItem?.id ?? UUID()
            
            let scheduleModel = ScheduleModel(
                id: id,
                title: target.titleTextField.text ?? "",
                description: target.descriptionTextField.text ?? "",
                date: target.formatToDateString(dateFormat: "dd/MM/yyyy", date: target.datePicker.date) ?? "",
                time: target.timeField.text ?? "",
                alertOffsetInMinutes: target.alertPickerView.selectedAlertOffsetRelay.value
            )
            
            if target.editingItem != nil {
                target.viewModel.updateSchedule(updatedItem: scheduleModel)
                target.saveTypeRelay.accept(.editSave)
            } else {
                target.viewModel.addSchedule(item: scheduleModel)
                target.saveTypeRelay.accept(.newSave)
            }
            
            target.dismiss(animated: true)
        }
    }
}

extension AddOrEditScheduleViewController {
    
    private func formatToDate(dateFormat: String, dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.date(from: dateString)
    }
    
    private func formatToDateString(dateFormat: String, date: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
    
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

}
