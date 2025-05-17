//
//  AddScheduleViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxRelay
import RxSwift

class AddScheduleViewController: UIViewController {
    
    //--------------------------------------------------------
    // MARK: - Events
    //--------------------------------------------------------
    
    let scheduleCreated = PublishRelay<ScheduleModel>()
    
    //--------------------------------------------------------
    // MARK: - UI Properties
    //--------------------------------------------------------
    
    private let titleTextField = UITextField()
    private let descriptionTextField = UITextField()
    private let dateField = UITextField()
    private let timeField = UITextField()
    private let saveButton = UIButton()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Novo agendamento"
        
        setupForm()
        bind()
    }
    
    private func setupForm() {
        [titleTextField, descriptionTextField, dateField, timeField, saveButton].forEach {
            view.addSubview($0)
        }
        
        // Configuração dos campos
        [titleTextField, descriptionTextField, dateField, timeField].forEach {
            $0.borderStyle = .roundedRect
        }
        
        titleTextField.placeholder = "Titulo"
        descriptionTextField.placeholder = "Descrição"
        dateField.placeholder = "Data (ex: 2025-05-20)"
        timeField.placeholder = "Horário (ex: 10:00)"
        saveButton.setTitle("Salvar", for: .normal)
        saveButton.backgroundColor = .systemBlue
        
        // Layout com SnapKit
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.left.right.equalToSuperview().inset(20)
        }
        descriptionTextField.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        dateField.snp.makeConstraints {
            $0.top.equalTo(descriptionTextField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        timeField.snp.makeConstraints {
            $0.top.equalTo(dateField.snp.bottom).offset(12)
            $0.left.right.equalTo(titleTextField)
        }
        saveButton.snp.makeConstraints {
            $0.top.equalTo(timeField.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    
    }
    
    private func bind() {
        saveButton.rx.tap
            .bind(to: saveButtonBinder)
            .disposed(by: disposeBag)
    }
    
    private var saveButtonBinder: Binder<Void> {
        Binder(self) { target, _ in
            let scheduleModel = ScheduleModel(
                id: Int.random(in: 1000...9999),
                title: target.titleTextField.text ?? "",
                description: target.descriptionTextField.text ?? "",
                date: target.dateField.text ?? "",
                time: target.timeField.text ?? ""
            )
            print("Vai salvar --> ", scheduleModel)
        }
    }
    
}
