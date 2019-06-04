//
//  AppStyle.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class MyButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        self.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        self.setBackgroundColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), forState: .highlighted)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UIMyLabel: UIView {
    let label = UILabel()
    
    func setLabelText(text:String?)  {
        label.text = text
    }
    
    func setLabelTextColor(color:UIColor) {
        label.textColor = color
    }
    
    func setLabelRobotoFont(font:Font.FontName, size:Double) {
        label.font = Font.getFontRobotoCustomSize(fontName: font, size: size)
    }
    
    func setLabel(text:String?, color:UIColor) {
        label.textColor = color
        label.text = text
    }
}

class UIViewButtonIcon: UIView {
    
    let btn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViewAndContraintByVSF(VSF: "H:[v0(24)]", views: btn)
        addContraintByVSF(VSF: "V:[v0(24)]", views: btn)
        btn.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        btn.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setIconAndColor(icon:UIImage?, color:UIColor?) {
        btn.setImage(icon, for: .normal)
        if let color = color {
            btn.changeIconColor(toColor: color)
        }
    }
}

class UIButtonQuantity: UIMyLabel {
    
    var delegate:UIButtonQuantityDelegate?
    
    private let lblTitle = UIViewLabel()
    private let btnDecreate = UIButton()
    private let btnIncreate = UIButton()
    
    var delegateAlert:UICustomViewAlertDelegate?
    var min = 0
    var max:Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let vCover = UIView()
        addSubViewAndContraintByVSF(VSF: "H:|[v0]|", views: vCover)
        addContraintByVSF(VSF: "V:|-6-[v0]|", views: vCover)
        vCover.layer.cornerRadius = 4
        vCover.layer.borderWidth = 1
        vCover.layer.borderColor = UIColor.getColorRGB(r: 223, g: 237, b: 235).cgColor
        vCover.clipsToBounds = true
        
        let color = UIColor.getColorRGB(r: 182, g: 185, b: 191)
        label.textColor = UIColor.getColorRGB(r: 94, g: 98, b: 102)
        label.textAlignment = .center
        lblTitle.setFont(font: Font.getFontRobotoCustomSize(fontName: .RobotoMedium, size: 11))
        lblTitle.setTextColor(color: color)
        lblTitle.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setTitle(title: "Quantity")
        
        addSubview(views: lblTitle)
        addContraintByVSF(VSF: "H:|-10-[v0]", views: lblTitle)
        addContraintByVSF(VSF: "V:|[v0(13)]", views: lblTitle)
        let vDecreaseTemp = UIView()
        let vIncreaseTemp = UIView()
        vCover.addSubViewAndContraintByVSF(VSF: "H:|[v0(40)][v1][v2(40)]|", views: vDecreaseTemp, label, vIncreaseTemp)
        vCover.addContraintSameVSF(isHorizontal: false, leftOrTop: 0, rightOrBottom: 0, views: vDecreaseTemp, label, vIncreaseTemp)
        
        let vDecrease = UIViewButtonIcon()
        let vIncrease = UIViewButtonIcon()
        vDecrease.setIconAndColor(icon: #imageLiteral(resourceName: "minus"), color: color)
        vIncrease.setIconAndColor(icon: #imageLiteral(resourceName: "plus-1"), color: color)
        vDecreaseTemp.addViewFullScreen(views: vDecrease)
        vDecreaseTemp.addViewFullScreen(views: btnDecreate)
        vIncreaseTemp.addViewFullScreen(views: vIncrease)
        vIncreaseTemp.addViewFullScreen(views: btnIncreate)
        
        btnDecreate.tag = -1
        btnIncreate.tag = 1
        
        btnIncreate.addTarget(self, action: #selector(UIButtonQuantity.btnChangeQuantityAction(_:)), for: .touchUpInside)
        btnDecreate.addTarget(self, action: #selector(UIButtonQuantity.btnChangeQuantityAction(_:)), for: .touchUpInside)
    }
    
    @objc func btnChangeQuantityAction(_ sender:UIButton) {
        if let value = Int (label.text!) {
            let newValue = value + sender.tag
            var valid = true
            var mes = ""
            if(newValue < min) {
                mes = "Quantity is smaller than minimun value"
                valid = false
            }
            if let max = max {
                valid = newValue <= max
                if !valid {
                    mes = "Quantity is greater than maximun value"
                }
            }
            if valid {
                setQuantity(quantity: newValue)
                if sender.tag == 1 {
                    if let delegate = delegate, let myFunc = delegate.increaseQuantity?(buttonQuantity: self) {
                        myFunc
                    }
                } else {
                    if let delegate = delegate {
                        if let myFunc = delegate.decreaseQuantity?(buttonQuantity: self) {
                            myFunc
                        }
                        if newValue == 0 {
                            if let myFunc = delegate.deleteQuantityZero?(buttonQuantity: self) {
                                myFunc
                            }
                        }
                    }
                }
            } else {
                if let delegate = delegate, let myFunc = delegate.alertInvalidValue?(buttonQuantity: self, message: mes) {
                    myFunc
                }
            }
        }
    }
    
    func getQuantity() -> Int {
        return Int (label.text!) ?? 0
    }
    
    func setQuantity(quantity:Int) {
        label.text = "\(quantity)"
    }
    
    func setMinMaxQuantity(min:Int, max:Int?) {
        self.min = min
        self.max = max
    }
    
    func setTitle(title:String?) {
        lblTitle.setTextLabel(text: title)
    }
}

class UICustomView: UIMyLabel {
    
    let icon = UIButton()
    var delegate:UICustomViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UICustomView.tapAction))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
    }
    
    func setBackgroundColor(color:UIColor) {
        backgroundColor = color
    }
    
    func setIcon(icon:UIImage?) {
        self.icon.setImage(icon, for: .normal)
    }
    
    @objc func tapAction()  {
        if let delegate = delegate {
            delegate.btnCustomViewAction(view: self, label: label, icon: icon)
        }
    }
}

class UICustomViewIconPath: UIMyLabel {

    let icon = UIView()
    var changeType = false
    var delegate:UICustomViewIconPathDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UICustomViewIconPath.tapAction))
        addGestureRecognizer(tap)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        addSubview(views: label, icon)
        addContraintByVSF(VSF: "H:|-20-[v0]-2-[v1(14)]-20-|", views: label, icon)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:[v0(14)]", views: icon)
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundColor = UIColor.getColorRGB(r: 79, g: 122, b: 203, alpha: 1)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setLabelRobotoFont(font: .RobotoBlack, size: 12)

    }

    func setupView(height:CGFloat) {
        changeType = true
        self.removeAllSubView()
        icon.removeAllContraints()
        label.removeAllContraints()
        let distance = Int (height / 2)
        addSubview(views: label, icon)
        addContraintByVSF(VSF: "H:|-\(distance)-[v0]-2-[v1(14)]-\(distance)-|", views: label, icon)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:[v0(14)]", views: icon)
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    func changeTypeWhiteBorder() {
        self.removeAllSubView()
        changeType = true
        icon.removeAllContraints()
        label.removeAllContraints()
        addSubview(views: label, icon)
        addContraintByVSF(VSF: "H:|-12-[v0]-2-[v1(8)]-12-|", views: label, icon)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:[v0(8)]", views: icon)
        icon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroundColor = nil
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setLabelRobotoFont(font: .RobotoRegular, size: 10)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }

    @objc func tapAction()  {
        if let delegate = delegate {
            delegate.btnCustomViewAction(view: self, label: label, icon: icon)
        }
    }
}

class UICustomViewBorderButton: UICustomView {
    
    var color = UIColor.getColorRGB(r: 79, g: 122, b: 203)
    var conHeight:NSLayoutConstraint!
    var conWidth:NSLayoutConstraint!
    var conwidthTemp:NSLayoutConstraint!
    
    override func setupView() {
        setupView(height: 32)
    }
    
    func setupView(height:CGFloat) {
        if !subviews.isEmpty {
            removeAllSubView()
        }
        layer.borderWidth = 1
        clipsToBounds = true
        label.font = Font.getFontRobotoStandardSize(fontName: .RobotoBlack, size: .h5)
        let vTemp = UIView()
        let dis = Int (height / 2)
        addSubViewAndContraintByVSF(VSF: "H:|-\(dis)-[v0]-2-[v1]-\(dis)-|", views: label, vTemp)
        addContraintSameVSF(isHorizontal: false, leftOrTop: 0, rightOrBottom: 0, views: label, vTemp)
        conwidthTemp = vTemp.widthAnchor.constraint(equalToConstant: 16)
        conwidthTemp.isActive = true
        
        vTemp.addSubview(views: icon)
        icon.rightAnchor.constraint(equalTo: vTemp.rightAnchor, constant: 5).isActive = true
        icon.centerYAnchor.constraint(equalTo: vTemp.centerYAnchor).isActive = true
        conWidth = icon.widthAnchor.constraint(equalToConstant: 14)
        conWidth.isActive = true
        conHeight = icon.heightAnchor.constraint(equalToConstant: 14)
        conHeight.isActive = true
        setColor()
    }
    
    func setSizeIcon(height:CGFloat, width:CGFloat) {
        conWidth.isActive = false
        conWidth = icon.widthAnchor.constraint(equalToConstant: width)
        conWidth.isActive = true
        conHeight.isActive = false
        conHeight = icon.heightAnchor.constraint(equalToConstant: height)
        conHeight.isActive = true
        conwidthTemp.isActive = false
        conwidthTemp = icon.widthAnchor.constraint(equalToConstant: width + 2)
        conwidthTemp.isActive = true
    }
    
    private func setColor() {
        layer.borderColor = color.cgColor
        label.textColor = color
        icon.changeIconColor(toColor: color)
    }
    
    override func setIcon(icon: UIImage?) {
        super.setIcon(icon: icon)
        self.icon.changeIconColor(toColor: color)
    }
    
    func changeColorBorder(toColor:UIColor) {
        color = toColor
        setColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

class UICustomViewLikeButton: UICustomView {
    
    var conHeight:NSLayoutConstraint!
    var conWidth:NSLayoutConstraint!
    
    override func setupView() {
        setupView(height: 40)
        icon.contentMode = .scaleAspectFit
        backgroundColor = UIColor.getColorRGB(r: 79, g: 122, b: 203, alpha: 1)
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setLabelRobotoFont(font: .RobotoBlack, size: 12)
    }
    
    func setupView(height:CGFloat) {
        let dis = Int (height / 2)
        if !self.subviews.isEmpty {
            self.removeAllSubView()
            conHeight.isActive = false
            conWidth.isActive = false
            label.removeAllContraints()
            icon.removeAllContraints()
        }
        let vTemp = UIView()
        addSubview(views: label, vTemp)
        addContraintByVSF(VSF: "H:|-\(dis)-[v0]-2-[v1]-\(dis)-|", views: label, vTemp)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:|[v0]|", views: vTemp)
        vTemp.addSubview(views: icon)
        conHeight = icon.heightAnchor.constraint(equalToConstant: 14)
        conHeight.isActive = true
        conWidth = icon.widthAnchor.constraint(equalToConstant: 14)
        conWidth.isActive = true
        icon.rightAnchor.constraint(equalTo: vTemp.rightAnchor, constant: 5).isActive = true
        icon.centerYAnchor.constraint(equalTo: vTemp.centerYAnchor).isActive = true
    }
    
    func changeTypeWhiteBorder() {
        backgroundColor = nil
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setLabelRobotoFont(font: .RobotoRegular, size: 10)
        if !self.subviews.isEmpty {
            self.removeAllSubView()
            conHeight.isActive = false
            conWidth.isActive = false
            label.removeAllContraints()
            icon.removeAllContraints()
        }
        let dis = Int (self.bounds.height / 2)
        let vTemp = UIView()
        addSubview(views: label, vTemp)
        addContraintByVSF(VSF: "H:|-\(dis)-[v0]-2-[v1(16)]-\(dis)-|", views: label, vTemp)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:|[v0]|", views: vTemp)
        vTemp.addSubview(views: icon)
        
        conHeight = icon.heightAnchor.constraint(equalToConstant: 8)
        conHeight.isActive = true
        conWidth = icon.widthAnchor.constraint(equalToConstant: 8)
        conWidth.isActive = true
        icon.rightAnchor.constraint(equalTo: vTemp.rightAnchor, constant: 4).isActive = true
        icon.centerYAnchor.constraint(equalTo: vTemp.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

class UIQuickAccessSVG: UIMyLabel {
    
    let vPath = UIView()
    var delegate:UIQuickAccessSVGDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIQuickAccessSVG.tapAction))
        addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        let colorText = UIColor.getColorRGB(r: 79, g: 122, b: 203)
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = 2
        layer.borderColor = colorText.cgColor
        addSubview(views: vPath, label)
        vPath.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        vPath.widthAnchor.constraint(equalToConstant: 24).isActive = true
        vPath.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        label.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        label.numberOfLines = 2
        label.textAlignment = .center
        setLabelTextColor(color: colorText)
        setLabelRobotoFont(font: .RobotoBlack, size: 12)
    }
    
    @objc func tapAction()  {
        if let delegate = delegate {
            delegate.btnCustomViewAction(view: self, label: label)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        vPath.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -(bounds.height - 16) / 4).isActive = true
    }
}

class UIQuickAccess: UICustomView {
    
    override func setupView() {
        let colorText = UIColor.getColorRGB(r: 79, g: 122, b: 203)
        layer.cornerRadius = 8
        clipsToBounds = true
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        layer.borderWidth = 2
        layer.borderColor = colorText.cgColor
        addSubview(views: icon, label)
        icon.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        label.topAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        label.numberOfLines = 2
        label.textAlignment = .center
        setLabelTextColor(color: colorText)
        setLabelRobotoFont(font: .RobotoBlack, size: 12)
    }
    
    func setupIcon(path:String) {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -(bounds.height - 16) / 4 ).isActive = true
    }
}

class UITxtRound: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderStyle = UITextField.BorderStyle.roundedRect
        self.autocorrectionType = UITextAutocorrectionType.no
        self.keyboardType = UIKeyboardType.default
        self.returnKeyType = UIReturnKeyType.done
        self.clearButtonMode = UITextField.ViewMode.whileEditing;
        self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if Device.isPhone() {
            let keyboardToolBar = UIToolbar()
            keyboardToolBar.sizeToFit()
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
                UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(MyTextField.doneClicked))
            
            keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
            self.inputAccessoryView = keyboardToolBar
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MyTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.font = UIFont.systemFont(ofSize: 17)
        self.autocorrectionType = UITextAutocorrectionType.no
        self.keyboardType = UIKeyboardType.default
        self.returnKeyType = UIReturnKeyType.done
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - MyTextField
class MyTextField: UITextField {
    
    var hideDelegate:UITextFieldHidePressDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.systemFont(ofSize: 17)
        self.borderStyle = UITextField.BorderStyle.roundedRect
        self.autocorrectionType = UITextAutocorrectionType.no
        self.keyboardType = UIKeyboardType.default
        self.returnKeyType = UIReturnKeyType.done
        self.clearButtonMode = UITextField.ViewMode.whileEditing;
        self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if Device.isPhone() {
            let keyboardToolBar = UIToolbar()
            keyboardToolBar.sizeToFit()
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
                UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(MyTextField.doneClicked))
            
            keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
            self.inputAccessoryView = keyboardToolBar
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneClicked() {
        if let delegate = hideDelegate {
            if delegate.btnKeyBoardHidePressAction != nil {
                delegate.btnKeyBoardHidePressAction!(textField: self)
            }
        }
        self.endEditing(true)
    }
}

//MARK: - UIMyTextField
class UIMyTextField: UIView, UITextFieldDelegate {
    
    var delegate:TextFieldDelegate?
    let textField = UITextField()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.borderStyle = .none
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.delegate = self
        
        if Device.isPhone() {
            let keyboardToolBar = UIToolbar()
            keyboardToolBar.sizeToFit()
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
                UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let doneButton = UIBarButtonItem(title: "Hide", style: .plain, target: self, action: #selector(UIMyTextField.btnHidePressAction))
            
            keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
            textField.inputAccessoryView = keyboardToolBar
        }
    }
    
    @objc func btnHidePressAction() {
        self.endEditing(true)
        didHideKeyBoardPress(myTextField: self, textfield: textField)
    }
    
    func didHideKeyBoardPress(myTextField:UIMyTextField, textfield:UITextField) {
        
    }
    
    func getPlaceHolder() -> String? {
        return textField.placeholder
    }
    
    func getText() -> String {
        return textField.text!
    }
    
    func isValidEmail() -> Bool {
        let candidate = getText()
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func setKeyboardType(keyboardType:UIKeyboardType)  {
        textField.keyboardType = keyboardType
    }
    
    func setPlaceHolder(placeHolder:String?)  {
        textField.placeholder = placeHolder
    }
    
    func setText(text:String?) {
        textField.text = text
    }
    
    func setTextColor(textColor:UIColor)  {
        textField.textColor = textColor
    }
    
    func setSecureText(isSecure:Bool) {
        textField.isSecureTextEntry = isSecure
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let delegate = delegate {
            if delegate.didBeginEditing != nil {
                delegate.didBeginEditing!(myTextField: self, textfield: textField)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let delegate = delegate {
            if delegate.didEndEditing != nil {
                delegate.didEndEditing!(myTextField: self, textfield: textField)
            }
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            if delegate.shouldClear != nil {
                delegate.shouldClear!(myTextField: self, textfield: textField)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            if delegate.shouldReturn != nil {
                delegate.shouldReturn!(myTextField: self, textfield: textField)
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            if delegate.shouldEndEditing != nil {
                delegate.shouldEndEditing!(myTextField: self, textfield: textField)
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let delegate = delegate {
            if delegate.shouldBeginEditing != nil {
                delegate.shouldBeginEditing!(myTextField: self, textfield: textField)
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let txtAfterUpdate = textField.text as NSString? {
            let text = txtAfterUpdate.replacingCharacters(in: range, with: string)
            if let delegate = delegate {
                if delegate.isEditing != nil {
                    delegate.isEditing!(myTextField: self, textfield: textField, text: text)
                }
            }
        }
        return true
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let delegate = delegate {
            if delegate.didEndEditingReason != nil {
                delegate.didEndEditingReason!(myTextField: self, reason: reason, textfield: textField)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UITextFieldCustom: UIMyTextField {
    private let lblTitle = UIViewLabel()
    private let lblUnit = UILabel()
    private var conWidthUnit: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        let vCover = UIView()
        addSubViewAndContraintByVSF(VSF: "H:|[v0]|", views: vCover)
        addContraintByVSF(VSF: "V:|-6-[v0]|", views: vCover)
        vCover.layer.cornerRadius = 4
        vCover.layer.borderWidth = 1
        vCover.layer.borderColor = UIColor.getColorRGB(r: 223, g: 237, b: 235).cgColor
        vCover.clipsToBounds = true
        
        addSubview(views: lblTitle)
        addContraintByVSF(VSF: "H:|-10-[v0]", views: lblTitle)
        addContraintByVSF(VSF: "V:|[v0(13)]", views: lblTitle)
        lblTitle.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        lblTitle.setFont(font: Font.getFontRobotoCustomSize(fontName: .RobotoMedium, size: 11))
        lblTitle.setTextColor(color: UIColor.getColorRGB(r: 182, g: 185, b: 191))
        lblUnit.font = Font.getFontRobotoCustomSize(fontName: .RobotoMedium, size: 14)
        lblUnit.textColor = UIColor.getColorRGB(r: 182, g: 185, b: 191)
        lblUnit.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        vCover.addSubview(views: lblUnit, textField)
        vCover.addContraintByVSF(VSF: "H:|-10-[v0]-2-[v1]-2-|", views: textField, lblUnit)
        vCover.addContraintSameVSF(isHorizontal: false, leftOrTop: 0, rightOrBottom: 0, views: textField, lblUnit)
        conWidthUnit = lblUnit.widthAnchor.constraint(equalToConstant: 0)
        conWidthUnit.isActive = true
        
        setInputFont(font: Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h4), color: UIColor.getColorRGB(r: 94, g: 98, b: 102))
    }
    
    func setInputFont(font:UIFont?, color:UIColor?) {
        textField.font = font
        textField.textColor = color
    }
    
    func setText(title:String?, unit:String?, placeHold:String?) {
        setTitle(title: title)
        setUnit(unit: unit)
        setPlaceHolder(placeHolder: placeHold)
    }
    
    func setTitle(title:String?) {
        lblTitle.setTextLabel(text: title)
    }
    
    func setUnit(unit:String?) {
        lblUnit.text = unit
        conWidthUnit.isActive = false
        if let unit = unit {
            let fontAttributes = [NSAttributedString.Key.font: Font.getFontRobotoCustomSize(fontName: .RobotoMedium, size: 14)]
            let size = (unit as NSString).size(withAttributes: fontAttributes)
            conWidthUnit = lblUnit.widthAnchor.constraint(equalToConstant: size.width + 2)
        } else {
            conWidthUnit = lblUnit.widthAnchor.constraint(equalToConstant: 0)
        }
        conWidthUnit.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class UITextFieldCustomNoUnit: UIMyTextField {
    private let lblTitle = UIViewLabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        let vCover = UIView()
        addSubViewAndContraintByVSF(VSF: "H:|[v0]|", views: vCover)
        addContraintByVSF(VSF: "V:|-6-[v0]|", views: vCover)
        vCover.layer.cornerRadius = 4
        vCover.layer.borderWidth = 1
        vCover.layer.borderColor = UIColor.getColorRGB(r: 223, g: 237, b: 235).cgColor
        vCover.clipsToBounds = true
        
        addSubview(views: lblTitle)
        addContraintByVSF(VSF: "H:|-10-[v0]", views: lblTitle)
        addContraintByVSF(VSF: "V:|[v0(13)]", views: lblTitle)
        lblTitle.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        lblTitle.setFont(font: Font.getFontRobotoCustomSize(fontName: .RobotoMedium, size: 11))
        lblTitle.setTextColor(color: UIColor.getColorRGB(r: 182, g: 185, b: 191))
        
        vCover.addSubview(views: textField)
        vCover.addContraintByVSF(VSF: "H:|-10-[v0]|", views: textField)
        vCover.addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        setInputFont(font: Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h4), color: UIColor.getColorRGB(r: 94, g: 98, b: 102))
    }
    
    func setInputFont(font:UIFont?, color:UIColor?) {
        textField.font = font
        textField.textColor = color
    }
    
    func setText(title:String?, placeHold:String?) {
        setTitle(title: title)
        setPlaceHolder(placeHolder: placeHold)
    }
    
    func setTitle(title:String?) {
        lblTitle.setTextLabel(text: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITextFieldIcon
class UITextFieldIcon:UIMyTextField {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let height:Int = 40
        let vImage = UIView()
        let vTextField = UIView()
        vImage.layer.borderWidth = 1
        vImage.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        vTextField.layer.borderWidth = 1
        vTextField.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.addSubview(views: vImage, vTextField)
        self.addContraintByVSF(VSF: "H:|[v0(\(height))]", views: vImage)
        self.addContraintByVSF(VSF: "V:|[v0]|", views: vImage)
        vImage.addSubview(views: imageView)
        imageView.centerXAnchor.constraint(equalTo: vImage.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: vImage.centerYAnchor).isActive = true
        
        self.addContraintByVSF(VSF: "H:|-\(height-1)-[v0]|", views: vTextField)
        self.addContraintByVSF(VSF: "V:|[v0]|", views: vTextField)
        
        vTextField.addSubview(views: textField)
        vTextField.addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: textField)
        vTextField.addContraintByVSF(VSF: "V:|[v0]|", views: textField)
    }
    
    func setBorderColor(color:CGColor) {
        if let v = imageView.superview {
            v.layer.borderColor = color
        }
        if let v = textField.superview {
            v.layer.borderColor = color
        }
    }
    
    func setIcon(icon:UIImage?) {
        imageView.image = icon
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITxtButton

class UITxtButton: UIMyTextField {
    
    var delegateButton:UIButtonDelegate!
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        button.layer.borderWidth = 1
        button.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.backgroundColor = #colorLiteral(red: 0.9500891081, green: 0.9500891081, blue: 0.9500891081, alpha: 1)
        button.setBackgroundColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), forState: .highlighted)
        
        button.addTarget(self, action: #selector(UITextFieldButton.buttonAction(_:)), for: .touchUpInside)
    }
    
    func setKindButton(isIcon:Bool, title:String?, height:Int = 40) {
        let vTextField = UIView()
        vTextField.layer.borderWidth = 1
        vTextField.layer.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        self.addSubview(views: vTextField, button)
        if isIcon {
            button.setImage(#imageLiteral(resourceName: "search"), for: .normal)
            button.setImage(#imageLiteral(resourceName: "search_white"), for: .highlighted)
            self.addContraintByVSF(VSF: "H:[v0(\(height))]|", views: button)
            self.addContraintByVSF(VSF: "V:|[v0]|", views: button)
            
            self.addContraintByVSF(VSF: "H:|[v0]-\(height-1)-|", views: vTextField)
            self.addContraintByVSF(VSF: "V:|[v0]|", views: vTextField)
            
            vTextField.addSubview(views: textField)
            vTextField.addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: textField)
            vTextField.addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        } else {
            
            button.setTitle(title, for: .normal)
            button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .highlighted)
            let newHeight:Int = Int(button.intrinsicContentSize.width) + 20
            self.addContraintByVSF(VSF: "H:[v0(\(newHeight))]|", views: button)
            self.addContraintByVSF(VSF: "V:|[v0]|", views: button)
            
            self.addContraintByVSF(VSF: "H:|[v0]-\(newHeight-1)-|", views: vTextField)
            self.addContraintByVSF(VSF: "V:|[v0]|", views: vTextField)
            
            vTextField.addSubview(views: textField)
            vTextField.addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: textField)
            vTextField.addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        }
    }
    
    func setBorderColor(color:CGColor) {
        button.layer.borderColor = color
        if let v = textField.superview {
            v.layer.borderColor = color
        }
    }
    
    func setIcon(icon:UIImage?) {
        button.setImage(icon, for: .normal)
    }
    
    func setTitleButton(title:String?) {
        button.setTitle(title, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func buttonAction(_ sender:UIButton)  {
        if let delegate = delegateButton {
            delegate.btnTextFieldButtonAction(button: sender, text: textField.text!)
        }
    }
}

//MARK: - UITextFieldLabel
class UITextFieldLabel: UIMyTextField {
    
    let label = UILabel()
    let lblStar = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(views: lblStar, label, textField)
        addContraintByVSF(VSF: "H:|[v0(10)][v1][v2]|", views: lblStar, label, textField)
        addContraintByVSF(VSF: "V:|[v0]|", views: lblStar)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        textField.borderStyle = .roundedRect
    }
    
    func setTextFieldSart(isNotEmpty:Bool) {
        if isNotEmpty {
            lblStar.text = "*"
            lblStar.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            lblStar.text = nil
            lblStar.textColor = nil
        }
    }
    
    func setBackgroundColorTextField(color:UIColor?) {
        textField.backgroundColor = color
    }
    
    func setBorderColor(color:CGColor)  {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = color
    }
    
    func setTextLabelColor(color:UIColor?) {
        label.textColor = color
    }
    
    func setWidthLabel(width:CGFloat) {
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setTextLabel(text:String?) {
        label.text = text
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITextFieldLine
class UITextFieldLine: UIMyTextField {
    
    var colorLine = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    let vLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.borderStyle = .none
        addSubview(views: textField, vLine)
        addContraintByVSF(VSF: "H:|[v0]|", views: textField)
        addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        addContraintByVSF(VSF: "H:|[v0]|", views: vLine)
        addContraintByVSF(VSF: "V:[v0(2)]-5-|", views: vLine)
        vLine.backgroundColor = colorLine
    }
    
    func isErrorContent(isError:Bool)  {
        vLine.backgroundColor = isError ? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) : colorLine
    }
    
    func setLineColor(lineColor:UIColor)  {
        colorLine = lineColor
        vLine.backgroundColor = colorLine
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isErrorContent(isError: false)
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITextFieldLabelLine
class UITextFieldLabelLine: UIMyTextField {
    
    var colorLine = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    let vLine = UIView()
    let label = UILabel()
    var contraintTextField:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.borderStyle = .none
        addSubview(views: label, textField, vLine)
        addContraintByVSF(VSF: "V:|[v0][v1]|", views: label, textField)
        addContraintByVSF(VSF: "H:|[v0]|", views: label)
        addContraintByVSF(VSF: "H:|[v0]|", views: textField)
        
        contraintTextField = vLine.topAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        contraintTextField.isActive = true
        vLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        vLine.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        vLine.widthAnchor.constraint(equalTo: textField.widthAnchor, multiplier: 1).isActive = true
        
        vLine.backgroundColor = colorLine
    }
    
    func isErrorContent(isError:Bool)  {
        vLine.backgroundColor = isError ? #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) : colorLine
    }
    
    func setLineColor(lineColor:UIColor)  {
        colorLine = lineColor
        vLine.backgroundColor = colorLine
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        if let placeHolder = textField.placeholder {
            let lbl = UILabel()
            lbl.textColor = textField.textColor
            lbl.text = placeHolder
            addSubview(views: lbl)
            lbl.widthAnchor.constraint(equalTo: textField.widthAnchor, multiplier: 1).isActive = true
            lbl.heightAnchor.constraint(equalTo: textField.heightAnchor, multiplier: 1).isActive = true
            lbl.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
            lbl.topAnchor.constraint(equalTo: textField.topAnchor).isActive = true
            contraintTextField.isActive = false
            contraintTextField = vLine.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
            UIView.animate(withDuration: 0.25, animations: {
                self.contraintTextField.isActive = true
                lbl.layer.transform = CATransform3DTranslate(CATransform3DIdentity, 0, -30, 0)
            }) { (finish) in
                lbl.removeFromSuperview()
                self.label.text = placeHolder + ":"
                self.label.textColor = textField.textColor
                textField.placeholder = nil
            }
        }
        super.textFieldDidBeginEditing(textField)
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        isErrorContent(isError: false)
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITextFieldLineError
class UITextFieldLineError: UITextFieldLine {
    
    let lblError = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let vError = UIView()
        textField.borderStyle = .none
        addSubview(views: textField, vLine, vError)
        addContraintByVSF(VSF: "H:|[v0]|", views: textField)
        addContraintByVSF(VSF: "H:|[v0]|", views: vError)
        addContraintByVSF(VSF: "V:|[v0(30)][v1]|", views: textField, vError)
        
        addContraintByVSF(VSF: "H:|[v0]|", views: vLine)
        addContraintByVSF(VSF: "V:|-27-[v0(1)]", views: vLine)
        
        vError.addSubview(views: lblError)
        vError.addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: lblError)
        vError.addContraintByVSF(VSF: "V:|[v0]|", views: lblError)
        
        lblError.font = UIFont.boldSystemFont(ofSize: 11)
        lblError.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        lblError.numberOfLines = 0
        vLine.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    }
    
    func setErrorContent(content:String?) {
        lblError.text = content
        isErrorContent(isError: content != nil)
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setErrorContent(content: nil)
        return super.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UITextFieldButton
//Usage:
/*
 let textFieldEmail = UITextFieldButton()
 textFieldEmail.setTextLabel(text: "Password (8 letters):")
 textFieldEmail.setButtonIcon(icon: #imageLiteral(resourceName: "icons8-Eye Filled-50"))
 textFieldEmail.isSecretTextEntry(isSecret: true)
 textFieldEmail.delegate = self
 textFieldEmail.buttonDelegate = self
 */
class UITextFieldButton: UIMyTextField {
    
    let label = UILabel()
    let button = UIButton()
    let vTemp = UIView()
    var buttonDelegate: UITxtButtonDelegate!
    var contraintWidthButton:NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        vTemp.layer.cornerRadius = 20
        vTemp.clipsToBounds = true
        vTemp.layer.borderWidth = 0.5
        vTemp.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        vTemp.backgroundColor = UIColor.init(red: 235/255, green: 239/255, blue: 242/255, alpha: 1)
        addSubview(views: label, vTemp)
        addContraintByVSF(VSF: "H:|[v0]|", views: label)
        addContraintByVSF(VSF: "H:|[v0]|", views: vTemp)
        addContraintByVSF(VSF: "V:|[v0]-4-[v1(40)]|", views: label, vTemp)
        vTemp.addSubview(views: textField, button)
        vTemp.addContraintByVSF(VSF: "H:|-20-[v0][v1]-10-|", views: textField, button)
        vTemp.addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        vTemp.addContraintByVSF(VSF: "V:[v0(30)]", views: button)
        contraintWidthButton = button.widthAnchor.constraint(equalToConstant: 0)
        contraintWidthButton.isActive = true
        button.centerYAnchor.constraint(equalTo: vTemp.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(UITextFieldButton.buttonAction(_:)), for: .touchUpInside)
        label.font = Font(.installed(.RobotoBold), size: .standard(.h5)).instance
        label.textColor = UIColor(red: 94/255, green: 98/255, blue: 102/255, alpha: 1)
    }
    
    func setBackgroundColor(color:UIColor?) {
        vTemp.backgroundColor = color
    }
    
    func setTextLabel(text:String?) {
        label.text = text
    }
    
    func setButtonIcon(icon:UIImage?,toColor:UIColor?=nil) {
        button.setImage(icon, for: .normal)
        if let toColor = toColor {
            button.changeIconColor(toColor: toColor)
        }
        contraintWidthButton.isActive = false
        contraintWidthButton = button.widthAnchor.constraint(equalToConstant: 30)
        contraintWidthButton.isActive = true
    }
    
    @objc func buttonAction(_ sender:UIButton) {
        if let delegate = buttonDelegate {
            delegate.btnTextFieldButtonAction(view: self, button: button, textField: textField)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let shadowColor = UIColor(red: 89/255, green: 89/255, blue: 89/255, alpha: 1)
//        vTemp.dropShadow(color: shadowColor, oriental: .top, value: 1, opacity: 0.5, scale: true)
//    }
}

class UITextFieldPathImage: UIMyTextField {
    
    let vPath = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(views: textField, vPath)
        addContraintByVSF(VSF: "H:|-16-[v0]-32-|", views: textField)
        addContraintByVSF(VSF: "V:|[v0]|", views: textField)
        
        addContraintByVSF(VSF: "H:[v0(16)]-16-|", views: vPath)
        addContraintByVSF(VSF: "V:[v0(16)]", views: vPath)
        vPath.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        textField.font = Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h5)
        layer.borderWidth = 1
        layer.borderColor = UIColor.getColorRGB(r: 79, g: 122, b: 203).cgColor
    }
    
    func setIcon(image:UIImage, color:UIColor = UIColor.getColorRGB(r: 79, g: 122, b: 203)) {
        let btn = UIButton()
        let tintedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        btn.tintColor = color
        btn.setImage(tintedImage, for: .normal)
        vPath.addViewFullScreen(views: btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25) {
            let scale = CATransform3DScale(CATransform3DIdentity, (self.bounds.width - self.bounds.height)/textField.bounds.width, 1, 1)
            let transition = CATransform3DTranslate(CATransform3DIdentity, 8, 0, 0)
            textField.layer.transform = CATransform3DConcat(scale, transition)
        }
        vPath.isHidden = true
        return super.textFieldShouldBeginEditing(textField)
    }
    
    override func didHideKeyBoardPress(myTextField: UIMyTextField, textfield: UITextField) {
        super.didHideKeyBoardPress(myTextField: myTextField, textfield: textfield)
        UIView.animate(withDuration: 0.25) {
            self.textField.layer.transform = CATransform3DIdentity
        }
        vPath.isHidden = false
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.25) {
            textField.layer.transform = CATransform3DIdentity
        }
        vPath.isHidden = false
        textField.endEditing(true)
        return super.textFieldShouldReturn(textField)
    }
    
    
}

//MARK: - UISelectedBox
class UISelectedBox: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var delegate : UISelectedBoxDelegate!
    var conHeightTableView:NSLayoutConstraint!
    let label = UILabel()
    let btnSelect = UIButton()
    
    let tableView:UITableView = {
        let tbl = UITableView(frame: CGRect.zero, style: .plain)
        tbl.register(BaseTableCell.self, forCellReuseIdentifier: "BaseTableCell")
        tbl.backgroundColor = UIColor.white
        tbl.layer.borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        tbl.layer.borderWidth = 1
        tbl.rowHeight = 30
        return tbl
    }()
    var arr:[String] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let vTemp = UIView()
        addSubview(views: vTemp, btnSelect)
        addContraintByVSF(VSF: "H:|[v0][v1]|", views: vTemp, btnSelect)
        addContraintByVSF(VSF: "V:|[v0]|", views: vTemp)
        addContraintByVSF(VSF: "V:|[v0]|", views: btnSelect)
        btnSelect.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        vTemp.addSubview(views: label)
        vTemp.addContraintByVSF(VSF: "V:|[v0]|", views: label)
        vTemp.addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: label)
        
        backgroundColor = #colorLiteral(red: 0.9458409317, green: 0.9458409317, blue: 0.9458409317, alpha: 1)
        btnSelect.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        btnSelect.layer.borderWidth = 1
        btnSelect.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        btnSelect.setImage(#imageLiteral(resourceName: "down"), for: .normal)
        
        btnSelect.addTarget(self, action: #selector(UISelectedBox.btnSelectAction(_:)), for: .touchUpInside)
    }
    
    func addTableView() {
        if let superview = self.superview {
            superview.addSubview(views: tableView)
            tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            tableView.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
            tableView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
            conHeightTableView = tableView.heightAnchor.constraint(equalToConstant: 0)
            conHeightTableView.isActive = true
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "BaseTableCell")
        cell.textLabel?.text = arr[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        label.text = arr[indexPath.row]
        conHeightTableView.isActive = false
        conHeightTableView = tableView.heightAnchor.constraint(equalToConstant: 0)
        conHeightTableView.isActive = true
        tableView.isHidden = true
        tableView.tag = 0
        if let delegate = delegate {
            if delegate.finishSelectAt != nil {
                delegate.finishSelectAt!(mySelectedBox: self, indexPath: indexPath)
            }
        }
    }
    
    func setTextLabel(text:String?) {
        label.text = text
    }
    
    func setButtonImage(icon:UIImage?) {
        btnSelect.setImage(icon, for: .normal)
    }
    
    func setDataOfSelector(arr:[String],textInFirstIndexOfArray:String?) {
        self.arr = arr
        if !arr.isEmpty {
            if let firstIndexOfArray = textInFirstIndexOfArray {
                self.arr.insert(firstIndexOfArray, at: 0)
            }
        }
        tableView.reloadData()
    }
    
    @objc func btnSelectAction(_ sender:UIButton) {
        if let delegate = delegate {
            if delegate.beforePressButtonSelect != nil {
                delegate.beforePressButtonSelect!(mySelectedBox: self, arr: arr)
            }
        }
        if !arr.isEmpty {
            tableView.tag = 1 - tableView.tag
            if conHeightTableView != nil {
                conHeightTableView.isActive = false
            }
            if tableView.tag == 0 {
                conHeightTableView = tableView.heightAnchor.constraint(equalToConstant: 0)
                tableView.isHidden = true
            } else {
                let height = arr.count > 5 ? 150 : arr.count * 30
                conHeightTableView = tableView.heightAnchor.constraint(equalToConstant: CGFloat(height))
                tableView.isHidden = false
            }
            conHeightTableView.isActive = true
        }
        if let delegate = delegate {
            if delegate.afterPressButtonSelect != nil {
                delegate.afterPressButtonSelect!(mySelectedBox: self, arr: arr)
            }
        }
    }
}

//MARK: - UIMyProgressBar
class UIMyProgressBar: UIView {
    
    let progress = UIProgressView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        progress.progressViewStyle = .default
        progress.progress = 0
    }
    
    func setProgressColor(color:UIColor?) {
        progress.progressTintColor = color
    }
    
    func setTrackColor(color:UIColor?) {
        progress.trackTintColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgressPercent(percent:Float) {
        progress.progress = percent
    }
}

//MARK: - UIProgressLabel
class UIProgressLabel: UIMyProgressBar {
    
    var lblPercent = UILabel()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let v = UIView()
        addSubview(views: v, progress)
        addContraintByVSF(VSF: "H:[v0]", views: v)
        addContraintByVSF(VSF: "H:|[v0]|", views: progress)
        addContraintByVSF(VSF: "V:|[v0][v1]|", views: v, progress)
        v.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        v.addSubview(views: label, lblPercent)
        v.addContraintByVSF(VSF: "H:|[v0][v1]|", views: label, lblPercent)
        v.addContraintByVSF(VSF: "V:|[v0]|", views: label)
        v.addContraintByVSF(VSF: "V:|[v0]|", views: lblPercent)
        label.widthAnchor.constraint(equalTo: lblPercent.widthAnchor, multiplier: 1).isActive = true
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 15)
        lblPercent.font = UIFont.systemFont(ofSize: 15)
        label.text = "Loading:"
        lblPercent.text = " 0%"
        
    }
    
    override func setProgressPercent(percent: Float) {
        super.setProgressPercent(percent: percent)
        let per = Int (percent.rounded(toPlaces: 2) * 100)
        showConsole(mess: per)
        lblPercent.text = " \(per)%"
        if percent == 1 {
            label.text = "Loaded:"
            progress.progressTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        }
    }
    
    func setFontSize(fontSize:CGFloat) {
        label.font = UIFont.systemFont(ofSize: fontSize)
        lblPercent.font = UIFont.systemFont(ofSize: fontSize)
    }
    
    func setTextLabel(text:String) {
        label.text = text
    }
    
    func setTextColor(color:UIColor) {
        label.textColor = color
        lblPercent.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UICheckBox
class UICheckBox: UIView {
    
    var delegate:UICheckBoxDelegate!
    let buttonCheck = UIButton()
    let label = UILabel()
    var isBlackColor = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(views: buttonCheck, label)
        addContraintByVSF(VSF: "H:|[v0(24)]-10-[v1]|", views: buttonCheck, label)
        addContraintByVSF(VSF: "V:[v0(24)]", views: buttonCheck)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        buttonCheck.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        buttonCheck.layer.borderWidth = 1
        buttonCheck.layer.borderColor = UIColor(red: 218/255, green: 221/255, blue: 224/255, alpha: 1).cgColor
        buttonCheck.layer.cornerRadius = 3
        buttonCheck.clipsToBounds = true
        buttonCheck.backgroundColor = UIColor(red: 235/255, green: 239/255, blue: 242/255, alpha: 1)
        buttonCheck.addTarget(self, action: #selector(UICheckBox.btnCheckAction), for: .touchUpInside)
        
        label.textColor = UIColor(red: 94/255, green: 98/255, blue: 102/255, alpha: 1)
        label.font = Font(.installed(.RobotoMedium), size: .standard(.h5)).instance
    }
    
    func setTextLabel(text:String?) {
        label.text = text
    }
    
    func setTextColor(color:UIColor) {
        label.textColor = color
    }
    
    func setBlackColor(isBlack:Bool) {
        isBlackColor = isBlack
        setImageButton()
    }
    
    func setChecked(isChecked:Bool) {
        buttonCheck.tag = isChecked ? 1 : 0
        setImageButton()
    }
    
    func setImageButton() {
        var image:UIImage? = buttonCheck.tag == 1 ? #imageLiteral(resourceName: "checkmark") : nil
        if !isBlackColor {
            image = buttonCheck.tag == 1 ? #imageLiteral(resourceName: "checked_white") : #imageLiteral(resourceName: "unchecked_white")
        }
        buttonCheck.setImage(image, for: .normal)
    }
    
    @objc func btnCheckAction() {
        buttonCheck.tag = 1 - buttonCheck.tag
        setImageButton()
        if delegate != nil {
            delegate.btnCheckAction(btn: self, isChecked: buttonCheck.tag == 1)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - UIViewLabel
class UIViewLabel: UIView {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(views: label)
        addContraintByVSF(VSF: "H:|-10-[v0]-10-|", views: label)
        addContraintByVSF(VSF: "V:|[v0]|", views: label)
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func clipToBound(cornerRadius:CGFloat, clipsToBounds:Bool) {
        if clipsToBounds {
            layer.cornerRadius = cornerRadius
        }
        self.clipsToBounds = clipsToBounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextLabel(text:String?) {
        label.text = text
    }
    
    func setBackgroundColor(color:UIColor?) {
        backgroundColor = color
    }
    
    func setTextColor(color:UIColor?)  {
        label.textColor = color
    }
    
    func setTextAndTextColor(text:String?, color:UIColor?) {
        label.textColor = color
        label.text = text
    }
    
    func setFontSize(size:CGFloat,isBold:Bool) {
        label.font = isBold ? UIFont.boldSystemFont(ofSize: size) : UIFont.systemFont(ofSize: size)
    }
    
    func setFont(font:UIFont) {
        label.font = font
    }
}

//MARK: - UIMySearchBar
class UIMySearchBar: UIView, UISearchBarDelegate {
    
    var delegate:SearchBarDelegate!
    let searchBar = UISearchBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        searchBar.layer.borderWidth = 1
        searchBar.delegate = self
    }
    
    func setBorderColor(color:CGColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)) {
        searchBar.layer.borderColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarTextDidEndEditing != nil {
                delegate.searchBarTextDidEndEditing!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarTextDidBeginEditing != nil {
                delegate.searchBarTextDidBeginEditing!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        if let delegate = delegate {
            if delegate.searchBarShouldEndEditing != nil {
                delegate.searchBarShouldEndEditing!(mySearchBar: self, searchBar: searchBar)
            }
        }
        return true
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let delegate = delegate {
            if delegate.searchBarShouldBeginEditing != nil {
                delegate.searchBarShouldBeginEditing!(mySearchBar: self, searchBar: searchBar)
            }
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarCancelButtonClicked != nil {
                delegate.searchBarCancelButtonClicked!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarSearchButtonClicked != nil {
                delegate.searchBarSearchButtonClicked!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarBookmarkButtonClicked != nil {
                delegate.searchBarBookmarkButtonClicked!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        if let delegate = delegate {
            if delegate.searchBarResultsListButtonClicked != nil {
                delegate.searchBarResultsListButtonClicked!(mySearchBar: self, searchBar: searchBar)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let delegate = delegate {
            if delegate.searchBarTextDidChange != nil {
                delegate.searchBarTextDidChange!(mySearchBar: self, searchBar: searchBar, text: searchText)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let delegate = delegate {
            if delegate.searchBarSelectedScopeButtonIndexDidChange != nil {
                delegate.searchBarSelectedScopeButtonIndexDidChange!(mySearchBar: self, searchBar: searchBar, selectedScope: selectedScope)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let txtAfterUpdate = searchBar.text as NSString? {
            let text = txtAfterUpdate.replacingCharacters(in: range, with: text)
            if let delegate = delegate {
                if delegate.searchBarShouldChangeTextIn != nil {
                    delegate.searchBarShouldChangeTextIn!(mySearchBar: self, searchBar: searchBar, text: text)
                }
            }
        }
        return true
    }
}

//MARK: - UISearchBarIcon
class UISearchBarIcon: UIMySearchBar {
    let btnSearch = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let height = 40
        btnSearch.layer.borderWidth = 1
        btnSearch.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        setBorderColor(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
        addSubview(views: searchBar, btnSearch)
        self.addContraintByVSF(VSF: "H:|[v0]-\(height-1)-|", views: searchBar)
        self.addContraintByVSF(VSF: "V:|[v0]|", views: searchBar)
        self.addContraintByVSF(VSF: "H:[v0(\(height))]|", views: btnSearch)
        self.addContraintByVSF(VSF: "V:|[v0]|", views: btnSearch)
        btnSearch.setBackgroundColor(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), forState: .highlighted)
        
        btnSearch.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        btnSearch.addTarget(self, action: #selector(UISearchBarIcon.btnSearchAction(_:)), for: .touchUpInside)
    }
    
    override func setBorderColor(color: CGColor) {
        super.setBorderColor(color: color)
        btnSearch.layer.borderColor = color
    }
    
    func setBackgroundSearchButton(color:UIColor,isLightIconColor:Bool) {
        if isLightIconColor {
            btnSearch.setImage(#imageLiteral(resourceName: "search_white"), for: .normal)
        }
        btnSearch.backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func btnSearchAction(_ sender: UIButton) {
        searchBarSearchButtonClicked(searchBar)
    }
}

//MARK: - UICircleView
class UICircleView: UIView {
    
    var strokeWidth:CGFloat = 1
    var fillBackgroundColor:UIColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    var fillColor:UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    var fillWidth:CGFloat = 10
    var whiteWidth:CGFloat = 0.03
    
    var endArc:CGFloat = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.clear
        
        let fullCircle = 2.0 * CGFloat(Double.pi)
        let start:CGFloat = -0.25 * fullCircle
        let end:CGFloat = endArc * fullCircle + start
        
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        var radius:CGFloat = 0.0
        if rect.width > rect.height {
            radius = (rect.width - fillWidth) / 2.0
        }else{
            radius = (rect.height - fillWidth) / 2.0
        }
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(fillWidth)
            context.setLineCap(.square)
            //Vong tron duoi
            context.setStrokeColor(fillBackgroundColor.cgColor)
            context.addArc(center: centerPoint, radius: radius, startAngle: 0, endAngle: fullCircle, clockwise: false)
            context.strokePath()
            
            if endArc > 0 {
                //Vien trang
                context.setStrokeColor(UIColor.white.cgColor)
                context.setLineWidth(self.fillWidth)
                context.addArc(center: centerPoint, radius: radius, startAngle: start - whiteWidth, endAngle: end + whiteWidth, clockwise: false)
                context.strokePath()
                
                //vong tron tren
                context.setStrokeColor(self.fillColor.cgColor)
                context.setLineWidth(self.fillWidth)
                context.addArc(center: centerPoint, radius: radius, startAngle: start, endAngle: end, clockwise: false)
                context.strokePath()
            }
        }
    }
    
    func setStrokeColor(strokecolor color:UIColor) {
        fillBackgroundColor = color
    }
    
    func setStrokeWidth(strokeWidth width:CGFloat)  {
        strokeWidth = width
    }
    
    func setFillColor(fillColor color:UIColor) {
        fillColor = color
    }
    
    func setFillWidth(fillWidth width:CGFloat)  {
        fillWidth = width
    }
    
    func setEndArc(end:CGFloat)  {
        endArc = end
    }
    
    func setBackgroundColor(backgroundColor color:UIColor)  {
        backgroundColor = color
    }
    
    func getFillColor() -> UIColor {
        return fillColor
    }
    
    func getEndArc() -> CGFloat {
        return endArc
    }
}

// MARK: - StrokedLabel
class StrokedLabel: UILabel {
    var strockedText: String = "" {
        willSet(newValue) {
            let strokeTextAttributes:Dictionary <NSAttributedString.Key,Any> = [
                NSAttributedString.Key.strokeColor : UIColor.white,
                NSAttributedString.Key.strokeWidth : -2.0,
                NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)
            ]
            let customizedText = NSMutableAttributedString(string: newValue,
                                                           attributes: strokeTextAttributes)
            attributedText = customizedText
        }
    }
}
//MARK: - UIMyChartBarView
class UIMyChartBarView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dicField:[String:UIColor] = [:]
    var dicData:[String:Any] = [:]
    var arrInOrder:[String] = []
    let lblTitle = UILabel()
    
    let vYAxis = UIView() //Chứa các giá trị
    let vChartLine = UIView() // Chứa các đường gạch ngang
    let vChartBar = UIView() // Chứa Collection View
    let vInfo = UIView()
    var conHeightTitle:NSLayoutConstraint!
    var textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var isChartIntValue = true
    var min:Double = 0
    var max:Double = 0
    var horizotalLines = 5 //So gach ngang
    var steps:Double = 1 //Khoang cach cua moi gach
    var widthBar:Int = 5 //Do rong cua Bar
    
    @objc let colChart:UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        let v = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        v.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        v.register(CellMyChartBar.self, forCellWithReuseIdentifier: "CellMyChartBar")
        v.backgroundColor = UIColor.clear
        v.allowsMultipleSelection = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let vChart = UIView()
        addSubview(views: lblTitle, vChart, vInfo)
        addContraintByVSF(VSF: "V:|[v0]-5-[v1]-5-[v2(30)]-10-|", views: lblTitle, vChart, vInfo)
        addContraintSameVSF(isHorizontal: true, leftOrTop: 15, rightOrBottom: 15, views: lblTitle, vChart, vInfo)
        lblTitle.textAlignment = .center
        lblTitle.font = Font.getFontRobotoStandardSize(fontName: .RobotoBlack, size: .h5)
        conHeightTitle = lblTitle.heightAnchor.constraint(equalToConstant: 0)
        conHeightTitle.isActive = true
        
        let vChartTemp = UIView()
        vChart.addSubview(views: vYAxis, vChartTemp)
        vChart.addContraintByVSF(VSF: "H:|[v0(40)][v1]|", views: vYAxis, vChartTemp)
        vChart.addContraintSameVSF(isHorizontal: false, leftOrTop: 0, rightOrBottom: 0, views: vYAxis, vChartTemp)
        vChartTemp.addViewFullScreen(views: vChartLine, vChartBar)
        
        drawLine()
        vChartBar.addViewFullScreen(views: colChart)
        colChart.delegate = self
        colChart.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextColor(color:UIColor) {
        textColor = color
    }
    
    func setTitle(text:String?, color:UIColor = UIColor.black) {
        let const:CGFloat = text == nil ? 0 : 30
        lblTitle.text = text
        lblTitle.textColor = color
        conHeightTitle.isActive = false
        conHeightTitle = lblTitle.heightAnchor.constraint(equalToConstant: const)
        conHeightTitle.isActive = true
        textColor = color
    }
    
    func setAttributedTextTitle(attr:NSAttributedString) {
        lblTitle.attributedText = attr
        conHeightTitle.isActive = false
        conHeightTitle = lblTitle.heightAnchor.constraint(equalToConstant: 30)
        conHeightTitle.isActive = true
    }
    
    func setSteps(steps:Double) {
        if steps * Double (horizotalLines) > max {
            self.steps = steps
        }
    }
    
    func drawWithData(arrInOrder:[String], dicField:[String:UIColor], dicData:[String:Any]) {
        self.arrInOrder = arrInOrder
        setField(dic: dicField)
        setValue(dic: dicData)
    }
    
    private func setField(dic:[String:UIColor]) {
        var arr:[UIView] = []
        var hHSF = ""
        var ind = 0
        let vTemp = UIView()
        for pr in dic {
            let vContent = UIView()
            let lbl = UILabel()
            lbl.textColor = textColor
            lbl.font = Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h5)
            let vColor = UIView()
            lbl.text = pr.key
            vColor.backgroundColor = pr.value
            vContent.addSubview(views: lbl, vColor)
            vContent.addContraintByVSF(VSF: "H:|[v0(9)]-5-[v1]|", views: vColor, lbl)
            vContent.addContraintByVSF(VSF: "V:[v0(9)]", views: vColor)
            vContent.addContraintByVSF(VSF: "V:|[v0]|", views: lbl)
            vColor.centerYAnchor.constraint(equalTo: vContent.centerYAnchor).isActive = true
            vColor.layer.cornerRadius = 4.5
            vColor.clipsToBounds = true
            
            arr.append(vContent)
            vTemp.addSubview(views: vContent)
            vTemp.addContraintByVSF(VSF: "V:|[v0]|", views: vContent)
            hHSF += hHSF.isEmpty ? "[v\(ind)]" : "-20-[v\(ind)]"
            ind += 1
        }
        hHSF = "H:|\(hHSF)|"
        vTemp.addContraintByVSF(VSF: hHSF, views: arr)
        vInfo.addSubview(views: vTemp)
        vInfo.addContraintByVSF(VSF: "V:|[v0]|", views: vTemp)
        vInfo.addContraintByVSF(VSF: "H:[v0]", views: vTemp)
        vTemp.centerXAnchor.constraint(equalTo: vInfo.centerXAnchor).isActive = true
        dicField = dic
    }
    
    private func setValue(dic:[String:Any]) {
        dicData = dic
        if !dic.isEmpty {
            if let first = dic.first {
                if let temp = first.value as? [String:Double] {
                    isChartIntValue = false
                    for pr in temp {
                        min = pr.value
                        max = min
                        break
                    }
                } else if let temp = first.value as? [String:Int]{
                    isChartIntValue = true
                    for pr in temp {
                        min = Double (pr.value)
                        max = min
                        break
                    }
                }
            }
        }
        for pr in dic {
            if isChartIntValue {
                if let dicData = pr.value as? [String:Int] {
                    for pr in dicData {
                        calculateMaxMin(value: Double(pr.value))
                    }
                }
            } else {
                if let dicData = pr.value as? [String:Double] {
                    for pr in dicData {
                        calculateMaxMin(value: pr.value)
                    }
                }
            }
        }
        calculateSteps()
    }
    
    func setHorizontalLines(number:Int) {
        horizotalLines = number
        drawLine()
        calculateSteps()
        colChart.reloadData()
    }
    
    func setWidthBar(width:Int) {
        widthBar = width
        colChart.reloadData()
    }
    
    private func calculateSteps() {
        steps = max / Double(horizotalLines)
        if isChartIntValue {
            steps = steps.rounded(.up)
        }
        enterYAxis()
    }
    
    private func enterYAxis()  {
        if !vYAxis.subviews.isEmpty {
            vYAxis.removeAllSubSubView()
        }
        let vMain = UIView()
        let vTemp = UIView()
        let vXAxis = UIView()
        vYAxis.addSubview(views: vTemp, vXAxis, vMain)
        vYAxis.addContraintByVSF(VSF: "V:|[v0][v1(30)]|", views: vTemp, vXAxis)
        vYAxis.addContraintSameVSF(isHorizontal: true, leftOrTop: 0, rightOrBottom: 0, views: vTemp, vXAxis)
        vMain.leftAnchor.constraint(equalTo: vTemp.leftAnchor).isActive = true
        vMain.topAnchor.constraint(equalTo: vTemp.topAnchor, constant: 7).isActive = true
        vMain.widthAnchor.constraint(equalTo: vTemp.widthAnchor, multiplier: 1).isActive = true
        vMain.heightAnchor.constraint(equalTo: vTemp.heightAnchor, multiplier: 1).isActive = true
        
        var arr:[UIView] = []
        var vSF = ""
        let multiple:CGFloat = 1 / CGFloat (horizotalLines + 1)
        for i in 0...horizotalLines {
            let vBound = UIView()
            vMain.addSubview(views: vBound)
            vMain.addContraintByVSF(VSF: "H:|[v0]|", views: vBound)
            vBound.heightAnchor.constraint(equalTo: vMain.heightAnchor, multiplier: multiple).isActive = true
            vSF += "[v\(i)]"
            arr.append(vBound)
            let lbl = UILabel()
            lbl.textAlignment = .center
            lbl.textColor = textColor
            lbl.font = Font.getFontRobotoStandardSize(fontName: .RobotoMedium, size: .h5)
            if isChartIntValue {
                lbl.text = "\(Int(steps) * (horizotalLines - i))"
            } else {
                lbl.text = convertDoubleToString(value: steps * Double(i))
            }
            vBound.addSubview(views: lbl)
            vBound.addContraintByVSF(VSF: "H:|[v0]|", views: lbl)
            vBound.addContraintByVSF(VSF: "V:[v0]|", views: lbl)
        }
        vSF = "V:|\(vSF)|"
        vMain.addContraintByVSF(VSF: vSF, views: arr)
    }
    
    private func drawLine() {
        //Ve cac duong thang
        if !vChartLine.subviews.isEmpty {
            vChartLine.removeAllSubSubView()
        }
        let vXAxis = UIView()
        let vMainLine = UIView()
        vChartLine.addSubview(views: vMainLine, vXAxis)
        vChartLine.addContraintByVSF(VSF: "V:|[v0][v1(30)]|", views: vMainLine, vXAxis)
        vChartLine.addContraintSameVSF(isHorizontal: true, leftOrTop: 0, rightOrBottom: 0, views: vMainLine, vXAxis)
        
        var arr:[UIView] = []
        var vSF = ""
        let multiple:CGFloat = 1 / CGFloat (horizotalLines + 1)
        for i in 0...horizotalLines {
            let vBound = UIView()
            vMainLine.addSubview(views: vBound)
            vMainLine.addContraintByVSF(VSF: "H:|[v0]|", views: vBound)
            vBound.heightAnchor.constraint(equalTo: vMainLine.heightAnchor, multiplier: multiple).isActive = true
            vSF += "[v\(i)]"
            arr.append(vBound)
            
            let vLine = UIView()
            vLine.backgroundColor = UIColor.getColorRGB(r: 220, g: 238, b: 255)
            vBound.addSubview(views: vLine)
            vBound.addContraintByVSF(VSF: "H:|[v0]|", views: vLine)
            vBound.addContraintByVSF(VSF: "V:[v0(1)]|", views: vLine)
        }
        vSF = "V:|\(vSF)|"
        vMainLine.addContraintByVSF(VSF: vSF, views: arr)
    }
    
    private func calculateMaxMin(value:Double) {
        min = Double.minimum(value, min)
        max = Double.maximum(value, max)
    }
    
    func printProperties() {
        var print = getMinMax()
        print["steps"] = steps
        showConsole(mess: print)
    }
    
    private func getMinMax() -> [String:Double] {
        return ["min" : min, "max" : max]
    }
    
    //MARK: - UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrInOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellMyChartBar", for: indexPath) as! CellMyChartBar
        cell.lbl.text = arrInOrder[indexPath.row]
        cell.lbl.textColor = textColor
        if !cell.vBar.subviews.isEmpty {
            cell.vBar.removeAllSubSubView()
        }
        let vBar = UIView()
        cell.vBar.addSubview(views: vBar)
        cell.addContraintByVSF(VSF: "H:|[v0]|", views: vBar)
        cell.addContraintByVSF(VSF: "V:[v0]|", views: vBar)
        let multiplier = CGFloat (horizotalLines) / CGFloat (horizotalLines + 1)
        vBar.heightAnchor.constraint(equalTo: cell.vBar.heightAnchor, multiplier: multiplier).isActive = true
        setupBar(vBar: vBar, ind: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private func setupBar(vBar:UIView, ind:Int)  {
        if isChartIntValue {
            if let dic = dicData[arrInOrder[ind]] as? [String:Int] {
                var dicResult:[String:Double] = [:]
                for pr in dic {
                    dicResult[pr.key] = Double (pr.value)
                }
                drawBar(vBar: vBar, dic: dicResult)
            }
        } else {
            if let dic = dicData[arrInOrder[ind]] as? [String:Double] {
                drawBar(vBar: vBar, dic: dic)
            }
        }
    }
    
    private func drawBar(vBar:UIView, dic:[String:Double]) {
        var arr:[UIView] = []
        var hSF = ""
        var ind = 0
        let maxRound = steps * Double(horizotalLines)
        for pr in dic {
            let v = UIView()
            v.backgroundColor = dicField[pr.key]
            v.layer.cornerRadius = CGFloat(widthBar) / 2
            v.clipsToBounds = true
            vBar.addSubview(views: v)
            vBar.addContraintByVSF(VSF: "V:[v0]|", views: v)
            let multiplier = CGFloat(pr.value) / CGFloat(maxRound)
            v.heightAnchor.constraint(equalTo: vBar.heightAnchor, multiplier: multiplier).isActive = true
            arr.append(v)
            hSF += hSF.isEmpty ? "[v\(ind)(\(widthBar))]" : "-8-[v\(ind)(\(widthBar))]"
            ind += 1
        }
        hSF = "H:|\(hSF)|"
        vBar.addContraintByVSF(VSF: hSF, views: arr)
    }
    
}
