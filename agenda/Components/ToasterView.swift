//
//  ToasterView.swift
//  agenda
//
//  Created by Bruno Oliveira on 20/05/25.
//

import UIKit
import SnapKit

final class ToasterView: UIView {

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let padding: CGFloat = 16

    init(title: String, description: String) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, description: description)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        layer.cornerRadius = 12
        clipsToBounds = true

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill

        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(padding)
        }
    }

    private func configure(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }

    static func show(in view: UIView, title: String, description: String) {
        let toaster = ToasterView(title: title, description: description)
        view.addSubview(toaster)

        toaster.alpha = 0
        toaster.transform = CGAffineTransform(translationX: 0, y: 50)

        toaster.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }

        UIView.animate(withDuration: 0.3) {
            toaster.alpha = 1
            toaster.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            UIView.animate(withDuration: 0.3, animations: {
                toaster.alpha = 0
                toaster.transform = CGAffineTransform(translationX: 0, y: 50)
            }, completion: { _ in
                toaster.removeFromSuperview()
            })
        }
    }
}
