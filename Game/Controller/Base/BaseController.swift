//
//  BaseController.swift
//  VAC Agent
//
//  Created by Mytruong on 5/8/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
    
    typealias completion = (()->())?
    var arrModalView:[UIView?] = []
    var doViewDidAppear = false
    var isObserveKeyboard = true
    
    //Modal Upload hinh
    var isSetupModPostImage = false //Khởi tạo lúc chuẩn bị hiện controller
    var lblModNumberUploadImage:UILabel! //Số lượng hình đang upload
    var vModNumberUploadImage:UIView!
    var actNumberUpload:UIActivityIndicatorView!
    
    
    //MARK: - Method
    override func viewDidLoad() {
        super.viewDidLoad()
        hideAllModalView()
        setupViewInViewDidLoad()
        setupDataInViewDidLoad()
        if isObserveKeyboard {
            NotificationCenter.default.addObserver(self, selector: #selector(BaseController.show(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(BaseController.hide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !doViewDidAppear {
            doViewDidAppear = true
            showAllModalView()
            setupViewInViewDidAppear()
            setupDataInViewDidAppear()
        } else {
            setupViewEveryPressBack()
            setupDataEveryPressBack()
        }
    }
    
    func setupViewInViewDidLoad() {
        setupMainView()
        setupAllModalView()
        if isSetupModPostImage {
            setupModPostImage()
        }
    }
    
    func setupModPostImage() {
        vModNumberUploadImage = createViewModal(height: nil)
        vModNumberUploadImage.backgroundColor = #colorLiteral(red: 0.9204347646, green: 0.9204347646, blue: 0.9204347646, alpha: 1).withAlphaComponent(0.5)
        let color = UIColor.getColorRGB(r: 222, g: 112, b: 68)
        actNumberUpload = UIActivityIndicatorView()
        actNumberUpload.style = .whiteLarge
        actNumberUpload.color = color
        vModNumberUploadImage.addSubview(views: actNumberUpload)
        actNumberUpload.centerXAnchor.constraint(equalTo: vModNumberUploadImage.centerXAnchor).isActive = true
        actNumberUpload.centerYAnchor.constraint(equalTo: vModNumberUploadImage.topAnchor, constant: UIScreen.main.bounds.height / 3).isActive = true
        lblModNumberUploadImage = UILabel()
        vModNumberUploadImage.addSubview(views: lblModNumberUploadImage)
        lblModNumberUploadImage.centerXAnchor.constraint(equalTo: actNumberUpload.centerXAnchor).isActive = true
        lblModNumberUploadImage.centerYAnchor.constraint(equalTo: actNumberUpload.centerYAnchor).isActive = true
        lblModNumberUploadImage.font = Font.getFontRobotoCustomSize(fontName: .RobotoBold, size: 17)
        lblModNumberUploadImage.textColor = color
    }
    
    func showModalNumberUpload(number:Int) {
        if isSetupModPostImage {
            actNumberUpload.startAnimating()
            lblModNumberUploadImage.text = "\(number)"
            showModalView(vMod: vModNumberUploadImage, oriental: .down, isOpen: true, completion: nil)
        }
    }
    
    func updateNumberUpload(number:Int) {
        if number == 0 {
            actNumberUpload.stopAnimating()
            actNumberUpload.hidesWhenStopped = true
            showModalView(vMod: vModNumberUploadImage, oriental: .down, isOpen: false, completion: nil)
        } else {
            lblModNumberUploadImage.text = "\(number)"
        }
    }
    
    func setupDataInViewDidLoad() {
        
    }
    
    func setupViewInViewDidAppear() {
        
    }
    
    func setupGradientOtherView(arrColors:[CGColor]) {
        
    }
    
    func setupDataInViewDidAppear() {
        
    }
    
    func setupViewEveryPressBack() {
        
    }
    
    func setupDataEveryPressBack() {
        
    }
    
    func checkBeforeChangeViewController() -> Bool {
        return true
    }
    
    func checkBeforeBackViewController() -> Bool {
        return true
    }
    
    func changeViewController(_ scr:UIViewController, completion:completion) {
        if checkBeforeChangeViewController() {
            present(scr, animated: true, completion: completion)
        }
    }
    
    func backPreviousViewController(_ completion:completion)  {
        if checkBeforeBackViewController() {
            hideAllModalView()
            dismiss(animated: true, completion: completion)
        }
    }
    
    func showAllModalView() {
        for view in arrModalView {
            if view != nil {
                view!.isHidden = false
            }
        }
    }
    
    func hideAllModalView() {
        for view in arrModalView {
            if view != nil {
                view!.isHidden = true
            }
        }
    }
    
    
    @objc func show(_ notification:NSNotification) {
        let valueKeyboard:NSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let sizeKeyboard:CGRect = valueKeyboard.cgRectValue
        keyboardWillShow(keyBoardSize: sizeKeyboard.size)
    }
    
    func keyboardWillShow(keyBoardSize:CGSize) {
        
    }
    
    @objc func hide(_ notification:NSNotification) {
        
    }
    
    func setupMainView() {
        
    }
    
    func setupAllModalView() {
        
    }
    
    func createViewModal(height:CGFloat?) -> UIView {
        let vMod = UIView()
        view.addSubview(views: vMod)
        vMod.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        vMod.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        vMod.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        if let h = height {
            vMod.heightAnchor.constraint(equalToConstant: h).isActive = true
        } else {
            vMod.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
            vMod.backgroundColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1).withAlphaComponent(0.75)
        }
        return vMod
    }
    
    func showModalView(vMod:UIView,oriental:ModalOriental, isOpen:Bool, completion:(()->())?,height:CGFloat?=nil)  {
        var h = vMod.bounds.height
        if let height = height {
            h = height
        }
        if isOpen {
            UIView.animate(withDuration: 0.25, animations: {
                var tranform:CATransform3D!
                switch oriental {
                case .down:
                    tranform = CATransform3DTranslate(CATransform3DIdentity, 0, h, 0)
                case .up:
                    tranform = CATransform3DTranslate(CATransform3DIdentity, 0, -h, 0)
                case .left:
                    tranform = CATransform3DTranslate(CATransform3DIdentity, vMod.bounds.width, 0, 0)
                case .right:
                    tranform = CATransform3DTranslate(CATransform3DIdentity, -vMod.bounds.width, 0, 0)
                }
                vMod.layer.transform = tranform
            }) { (t) in
                if let completion = completion {
                    completion()
                }
            }
        } else {
            UIView.animate(withDuration: 0.35, animations: {
                vMod.layer.transform = CATransform3DIdentity
            }) { (t) in
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
}
