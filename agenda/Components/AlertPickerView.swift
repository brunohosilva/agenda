//
//  AlertPickerView.swift
//  agenda
//
//  Created by Bruno Oliveira on 20/05/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class AlertPickerView: UIView {
    
    //--------------------------------------------------------
    // MARK: - Public Properties
    //--------------------------------------------------------
    
    let selectedAlertOffsetRelay = BehaviorRelay<Int>(value: 0)
    
    //--------------------------------------------------------
    // MARK: - Private UI Components
    //--------------------------------------------------------

    private let alertOptions = [
        ("Na hora do evento", 0),
        ("5 minutos antes", 5),
        ("10 minutos antes", 10),
        ("30 minutos antes", 30),
        ("1 hora antes", 60)
    ]
    
    private let iconLabel = UILabel()
    private let valueLabel = UILabel()
    private let hiddenTextField = UITextField()
    private let pickerView = UIPickerView()
    private let toolbar = UIToolbar()
    private let selectButton = UIBarButtonItem(title: "Selecionar", style: .done, target: nil, action: nil)
    
    private let disposeBag = DisposeBag()
    
    //--------------------------------------------------------
    // MARK: - Initialization
    //--------------------------------------------------------
    
    init(initialIndex: Int = 0) {
        super.init(frame: .zero)
        setupView()
        setupPicker()
        setupBindings()
        setInitialValue(index: initialIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //--------------------------------------------------------
    // MARK: - Setup Methods
    //--------------------------------------------------------
    
    private func setupView() {
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.cornerRadius = 8
        isUserInteractionEnabled = true
        
        iconLabel.text = "⏰ Alerta"
        iconLabel.font = .systemFont(ofSize: 16, weight: .medium)

        valueLabel.textColor = .systemBlue
        valueLabel.font = .boldSystemFont(ofSize: 16)
        valueLabel.textAlignment = .right

        addSubview(iconLabel)
        addSubview(valueLabel)
        addSubview(hiddenTextField)

        iconLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(12)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(12)
            $0.left.greaterThanOrEqualTo(iconLabel.snp.right).offset(8)
        }
        hiddenTextField.snp.makeConstraints {
            $0.width.height.top.left.equalTo(0)
        }
        
        // Tap gesture para mostrar o picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPicker))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupPicker() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        toolbar.sizeToFit()
        toolbar.setItems([selectButton], animated: false)
        
        hiddenTextField.inputView = pickerView
        hiddenTextField.inputAccessoryView = toolbar

    }
    
    private func setupBindings() {
        selectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.hiddenTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    private func setInitialValue(index: Int) {
        if let index = alertOptions.firstIndex(where: { $0.1 == index }) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
            valueLabel.text = alertOptions[index].0
            selectedAlertOffsetRelay.accept(alertOptions[index].1)
        }
    }

    @objc private func showPicker() {
        hiddenTextField.becomeFirstResponder()
    }
}

extension AlertPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        alertOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        alertOptions[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        valueLabel.text = alertOptions[row].0
        selectedAlertOffsetRelay.accept(alertOptions[row].1)
    }
}
