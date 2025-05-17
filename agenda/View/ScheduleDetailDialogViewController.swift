//
//  ScheduleDetailDialogViewController.swift
//  agenda
//
//  Created by Bruno Oliveira on 17/05/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ScheduleDetailsDialogViewController: UIViewController {
    
    
    private let schedule: ScheduleModel
    private let disposeBag = DisposeBag()
    private let closeModalRequested = PublishRelay<Void>()
    
    private let backgroundView = UIView()
    private let dialogView = UIView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    init(schedule: ScheduleModel) {
        self.schedule = schedule
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle   = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) não implementado")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
        bind()
    }
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(dialogView)
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        dialogView.backgroundColor = .systemBackground
        dialogView.layer.cornerRadius = 16
        dialogView.layer.shadowColor = UIColor.black.cgColor
        dialogView.layer.shadowOpacity = 0.3
        dialogView.layer.shadowRadius = 10
        dialogView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialogView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        [titleLabel, descriptionLabel, dateLabel].forEach {
            dialogView.addSubview($0)
            $0.numberOfLines = 0
            $0.textAlignment = .center
        }
        dialogView.addSubview(closeButton)
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        closeButton.setTitle("Fechar", for: .normal)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dialogView).offset(20)
            $0.left.right.equalTo(dialogView).inset(16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.left.right.equalTo(titleLabel)
        }
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.left.right.equalTo(titleLabel)
        }
        closeButton.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.bottom.equalTo(dialogView).offset(-20)
            $0.centerX.equalTo(dialogView)
        }
    }
    
    private func populateData() {
        titleLabel.text = schedule.title
        descriptionLabel.text = schedule.description
        dateLabel.text = "Dia: \(schedule.date) às \(schedule.time)"
    }
    
    private func bind() {
        
        closeModalRequested
            .bind(to: closeModalRequestedBinder)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap
            .bind(to: closeModalRequested)
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        backgroundView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .map { _ in () }
            .bind(to: closeModalRequested)
            .disposed(by: disposeBag)
    }
    
    
    private var closeModalRequestedBinder: Binder<Void> {
        Binder(self) { target, _ in
            target.dismiss(animated: true)
        }
    }
}
