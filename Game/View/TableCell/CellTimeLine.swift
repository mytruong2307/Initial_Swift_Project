//
//  File.swift
//  VAC Agent
//
//  Created by Mytruong on 4/3/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class CellTimeLine: BaseTableCell {
    
    let lblTime = UIViewLabel()
    let lblDetail = UILabel()
    let lblSubject = UILabel()
    let vBackgroundTable = UIView()
    let vLineBefore = UIView()
    let circle = UIView()
    let vLineAfter = UIView()
    var timeLine:TimeLine!
    
    override func setupView() {
        let vTime = UIView()
        let vCircle = UIView()
        let vInfo = UIView()
        addSubview(views: vTime, vCircle, vInfo)
        addContraintByVSF(VSF: "H:|-10-[v0]-5-[v1]-5-[v2]-10-|", views: vTime, vCircle, vInfo)
        addContraintByVSF(VSF: "V:|[v0]|", views: vTime)
        addContraintByVSF(VSF: "V:|[v0]|", views: vCircle)
        addContraintByVSF(VSF: "V:|[v0]|", views: vInfo)
        
        vTime.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2).isActive = true
        vCircle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
        
        vTime.addSubview(views: lblTime)
        vTime.addContraintByVSF(VSF: "H:|[v0]|", views: lblTime)
        vTime.addContraintByVSF(VSF: "V:|-5-[v0(30)]", views: lblTime)
        
        circle.layer.cornerRadius = 15
        circle.clipsToBounds = true
        
        vCircle.addSubview(views: vLineBefore, circle, vLineAfter)
        vCircle.addContraintByVSF(VSF: "H:[v0(5)]", views: vLineBefore)
        vCircle.addContraintByVSF(VSF: "H:[v0(5)]", views: vLineAfter)
        vCircle.addContraintByVSF(VSF: "H:[v0(30)]", views: circle)
        vCircle.addContraintByVSF(VSF: "V:|[v0(5)][v1(30)][v2]|", views: vLineBefore, circle, vLineAfter)
        
        vLineBefore.centerXAnchor.constraint(equalTo: vCircle.centerXAnchor).isActive = true
        vLineAfter.centerXAnchor.constraint(equalTo: vCircle.centerXAnchor).isActive = true
        circle.centerXAnchor.constraint(equalTo: vCircle.centerXAnchor).isActive = true
        
        vCircle.addSubview(views: vBackgroundTable)
        vBackgroundTable.heightAnchor.constraint(equalToConstant: 20).isActive = true
        vBackgroundTable.widthAnchor.constraint(equalToConstant: 20).isActive = true
        vBackgroundTable.centerXAnchor.constraint(equalTo: circle.centerXAnchor).isActive = true
        vBackgroundTable.centerYAnchor.constraint(equalTo: circle.centerYAnchor).isActive = true
        
        vBackgroundTable.layer.cornerRadius = 10
        vBackgroundTable.clipsToBounds = true
        
        vBackgroundTable.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let line = UIView()
        line.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        vInfo.addSubview(views: lblSubject, lblDetail, line)
        vInfo.addContraintByVSF(VSF: "H:|[v0]|", views: lblSubject)
        vInfo.addContraintByVSF(VSF: "H:|[v0]|", views: lblDetail)
        vInfo.addContraintByVSF(VSF: "H:|[v0]|", views: line)
        vInfo.addContraintByVSF(VSF: "V:|-5-[v0(30)][v1]-10-[v2(1)]|", views: lblSubject, lblDetail, line)
        
        lblSubject.font = UIFont.boldSystemFont(ofSize: 17)
        lblDetail.font = UIFont.systemFont(ofSize: 14)
        lblDetail.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        lblDetail.numberOfLines = 0
        lblTime.clipToBound(cornerRadius: 5, clipsToBounds: true)
        lblTime.setFontSize(size: 14, isBold: true)
        lblTime.label.textAlignment = .center
    }
    
    override func setupData() {
        lblTime.setTextLabel(text: timeLine.time)
        lblTime.setBackgroundColor(color: timeLine.color)
        lblTime.setTextColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        circle.backgroundColor = timeLine.color
        vLineAfter.backgroundColor = timeLine.isLast ? nil : timeLine.color
        vLineBefore.backgroundColor = timeLine.isFirst ? nil : timeLine.beforeColor
        lblDetail.text = timeLine.detail
        lblSubject.text = timeLine.subject
    }
    
    
}
