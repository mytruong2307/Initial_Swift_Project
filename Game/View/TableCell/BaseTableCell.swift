//
//  BaseTableCell.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class BaseTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    override func layoutSubviews() {
        setupData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupView() {
        backgroundColor = UIColor.clear
    }
    @objc func setupData() {
        
    }
}
