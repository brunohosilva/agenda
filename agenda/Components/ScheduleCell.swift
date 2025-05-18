//
//  ScheduleCells.swift
//  agenda
//
//  Created by Bruno Oliveira on 18/05/25.
//

import Foundation
import UIKit

class ScheduleCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let dateTimeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        dateTimeLabel.font = .systemFont(ofSize: 14)
        dateTimeLabel.textColor = .gray
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateTimeLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        contentView.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

