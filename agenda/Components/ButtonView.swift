//
//  ButtonView.swift
//  agenda
//
//  Created by Bruno Oliveira on 20/05/25.
//

import UIKit
import RxCocoa
import RxSwift

final class ButtonView: UIButton {

    public let buttonTap = PublishRelay<Void>()
    private let disposeBag = DisposeBag()

    init(title: String, backgroundColor: UIColor = .systemBlue, titleColor: UIColor = .white) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor

        layer.cornerRadius = 10
        clipsToBounds = true

        setupBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBinding() {
        rx.tap
            .bind(to: buttonTap)
            .disposed(by: disposeBag)
    }
}
