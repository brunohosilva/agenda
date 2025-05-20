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
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    // --- Aqui substituímos o alertPickerField visível por uma UIView que será o card ---
    private let alertSelectionView = UIView()
    private let alertIconLabel = UILabel()
    private let alertValueLabel = UILabel()
        
    private let hiddenPickerField = UITextField() // Campo oculto para mostrar picker
    
    private let alertPicker = UIPickerView()
    private let alertOptions = [
        ("Na hora do evento", 0),
        ("5 minutos antes", 5),
        ("10 minutos antes", 10),
        ("30 minutos antes", 30),
        ("1 hora antes", 60)
    ]
    private let alertToolbar = UIToolbar()
    private let selectAlertOptionButton = UIBarButtonItem(title: "Selecionar", style: .done, target: nil, action: nil)
    
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
        setupInitialAlertValue()
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
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        if let date = formatter.date(from: item.date) {
            datePicker.date = date
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        if let timeDate = timeFormatter.date(from: item.time) {
            timePicker.date = timeDate
        }
        
        if let index = alertOptions.firstIndex(where: { $0.1 == item.alertOffsetInMinutes }) {
            alertPicker.selectRow(index, inComponent: 0, animated: false)
            alertValueLabel.text = alertOptions[index].0
            selectedAlertOffsetRelay.accept(alertOptions[index].1)
        }
    }
    
    private func setupForm() {
        [titleTextField, descriptionTextField, datePicker, timeField, alertSelectionView, hiddenPickerField, saveButton, cancelButton].forEach {
            contentView.addSubview($0)
        }
        
        [alertIconLabel, alertValueLabel].forEach {
            alertSelectionView.addSubview($0)
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
        
        alertPicker.delegate = self
        alertPicker.dataSource = self
        
        alertIconLabel.text = "⏰ Alerta"
        alertIconLabel.font = .systemFont(ofSize: 16, weight: .medium)
    
        alertValueLabel.textColor = .systemBlue
        alertValueLabel.font = .boldSystemFont(ofSize: 16)
        alertValueLabel.textAlignment = .right
        
        hiddenPickerField.inputView = alertPicker
        hiddenPickerField.isHidden = true
        hiddenPickerField.inputAccessoryView = alertToolbar
        
        // Configura aparência do card alerta
        alertSelectionView.layer.borderWidth = 1
        alertSelectionView.layer.borderColor = UIColor.systemGray4.cgColor
        alertSelectionView.layer.cornerRadius = 8
        alertSelectionView.isUserInteractionEnabled = true
        
        alertToolbar.sizeToFit()
        alertToolbar.setItems([selectAlertOptionButton], animated: false)
    
        // Gesture para abrir picker ao tocar no card alerta
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showAlertPicker))
        alertSelectionView.addGestureRecognizer(tapGesture)
        
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
        alertSelectionView.snp.makeConstraints {
            $0.top.equalTo(timeField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
            $0.height.equalTo(50)
        }
        hiddenPickerField.snp.makeConstraints { make in
            make.top.left.equalToSuperview() // posição qualquer, pois é oculto
            make.width.height.equalTo(0)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(alertSelectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(44)
        }
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(saveButton.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(saveButton)
            $0.height.equalTo(44)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-20)
        }
        
        // Layout das labels no card alerta
        alertIconLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(12)
        }
        alertValueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(12)
            $0.left.greaterThanOrEqualTo(alertIconLabel.snp.right).offset(8)
        }
    
    }
    
    private func bind() {

        selectHourDoneButton.rx.tap
            .bind(to: toolbarTapBinder)
            .disposed(by: disposeBag)
        
        selectAlertOptionButton.rx.tap
            .bind(to: selectAlertOptionButtonBinder)
            .disposed(by: disposeBag)
        
        timePicker.rx.date
            .map { [timeFormatter]  in timeFormatter.string(from: $0)}
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
    
    private var selectAlertOptionButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            target.hiddenPickerField.resignFirstResponder()
        }
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
                time: target.timeField.text ?? "",
                alertOffsetInMinutes: target.selectedAlertOffsetRelay.value
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

extension AddOrEditScheduleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        alertOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        alertOptions[row].0
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        alertValueLabel.text = alertOptions[row].0
        selectedAlertOffsetRelay.accept(alertOptions[row].1)
    }
}

extension AddOrEditScheduleViewController {
    
    private func setupInitialAlertValue() {
        if editingItem == nil {
            alertPicker.selectRow(0, inComponent: 0, animated: false)
            alertValueLabel.text = alertOptions[0].0
            selectedAlertOffsetRelay.accept(alertOptions[0].1)
        }
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func showAlertPicker() {
        hiddenPickerField.becomeFirstResponder()
    }
}
