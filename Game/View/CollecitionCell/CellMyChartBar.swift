//
//  CellMyChartBar.swift
//  VAC Agent
//
//  Created by Mytruong on 5/6/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class CellMyChartBar: BaseCollectionCell {
    
    let lbl = UILabel()
    let vBar = UIView()
    
    override func setupView() {
        backgroundColor = UIColor.clear
        let vBarContainer = UIView()
        addSubview(views: vBarContainer, lbl)
        addContraintByVSF(VSF: "V:|[v0][v1(30)]|", views: vBarContainer, lbl)
        addContraintSameVSF(isHorizontal: true, leftOrTop: 0, rightOrBottom: 0, views: vBarContainer, lbl)
        vBarContainer.addSubview(views: vBar)
        vBarContainer.addContraintByVSF(VSF: "H:[v0]", views: vBar)
        vBarContainer.addContraintByVSF(VSF: "V:|[v0]|", views: vBar)
        vBar.centerXAnchor.constraint(equalTo: vBarContainer.centerXAnchor).isActive = true
        lbl.textAlignment = .center
        lbl.font = Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h5)
    }
    
}
