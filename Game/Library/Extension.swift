//
//  Extension.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import WebKit
import AVKit

private var actionKey: Void?
private var handle: UInt8 = 0

extension UILabel {
    func addIcon(icon:UIImage, text:String,afterLabel isAfterText:Bool = false)  {
        let attachment = NSTextAttachment()
        attachment.image = icon
        attachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 24)
        let attachmentString = NSAttributedString(attachment: attachment)
        if isAfterText {
            let myString = NSMutableAttributedString(string: text)
            myString.append(attachmentString)
            self.attributedText = myString
        } else {
            let myString = NSMutableAttributedString(string: "")
            myString.append(attachmentString)
            myString.append(NSAttributedString(string: text))
            self.attributedText = myString
        }
    }
    
    func textUnderLine(text:String) {
        self.font = UIFont.systemFont(ofSize: 14)
        let underlineAttriString = NSAttributedString(string:text, attributes:
            [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        self.attributedText = underlineAttriString
    }
    
    
}

extension UIView
{
    enum OrientalShadow: String {
        case all, bottom, top, left, right, topLeft, topRight, bottomLeft, bottomRight
    }
    
    func getOriental(oriental:OrientalShadow, value:CGFloat) -> CGSize {
        switch oriental {
        case .bottom:
            return CGSize(width: 0, height: value)
        case .top:
            return CGSize(width: 0, height: -value)
        case .left:
            return CGSize(width: -value, height: 0)
        case .right:
            return CGSize(width: value, height: 0)
        case .topLeft:
            return CGSize(width: -value, height: -value)
        case .topRight:
            return CGSize(width: value, height: -value)
        case .bottomLeft:
            return CGSize(width: -value, height: value)
        default:
            return CGSize(width: value, height: value)
        }
    }
    
    // OUTPUT 1
    func dropShadow(oriental: OrientalShadow, value:CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = getOriental(oriental: oriental, value: value)
        layer.shadowRadius = layer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, oriental: OrientalShadow, value:CGFloat = 1, opacity: Float = 0.5, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        if oriental != .all {
            layer.shadowOffset = getOriental(oriental: oriental, value: value)
        } else {
            layer.shadowOffset = CGSize(width: -1, height: 1)
        }
        layer.shadowRadius = layer.cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func removeAllSubView() {
        self.subviews.forEach({$0.removeFromSuperview()})
    }
    
    func removeAllSubSubView()  {
        for v in self.subviews {
            if v.subviews.isEmpty {
                v.removeAllContraints()
                v.removeFromSuperview()
            } else {
                v.removeAllSubSubView()
            }
        }
    }
    
    func removeAllContraints()  {
        self.removeConstraints(self.constraints)
    }
    
    func createImage() -> UIImage? {
        let rect: CGRect = self.frame
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func convertToPdf() -> NSMutableData
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, self.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return pdfData }
        
        self.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        return pdfData
    }
    
    func addSubview(views:UIView...) {
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
        }
    }
    
    func addContraintSameVSF(isHorizontal:Bool, leftOrTop:Int, rightOrBottom:Int, views:UIView...) {
        var VSF = "|"
        VSF += leftOrTop == 0 ? "[v0]" : "-\(leftOrTop)-[v0]"
        VSF += rightOrBottom == 0 ? "|" : "-\(rightOrBottom)-|"
        VSF = isHorizontal ? "H:\(VSF)" : "V:\(VSF)"
        for view in views {
            addContraintByVSF(VSF: VSF, views: view)
        }
    }
    
    func addContraintSameVSFSameDimension(isHorizontal:Bool, leftOrTop:Int, rightOrBottom:Int, views:UIView...) {
        var VSF = "|"
        VSF += leftOrTop == 0 ? "[v0]" : "-\(leftOrTop)-[v0]"
        VSF += rightOrBottom == 0 ? "|" : "-\(rightOrBottom)-|"
        VSF = isHorizontal ? "H:\(VSF)" : "V:\(VSF)"
        for (ind,view) in views.enumerated() {
            addContraintByVSF(VSF: VSF, views: view)
            if ind > 0 {
                if isHorizontal {
                    view.heightAnchor.constraint(equalTo: views[0].heightAnchor, multiplier: 1).isActive = true
//                    view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1 /CGFloat(views.count)).isActive = true
                } else {
                    view.widthAnchor.constraint(equalTo: views[0].widthAnchor, multiplier: 1).isActive = true
//                    view.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1 /  CGFloat(views.count)).isActive = true
                }
            }
        }
    }
    
    func addContraintByVSF(VSF:String, views:UIView...) {
        var dic = Dictionary<String,Any>()
        for (index,view) in views.enumerated() {
            dic["v\(index)"] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: VSF, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dic))
    }
    
    func addSubViewAndContraintByVSF(VSF:String, views:UIView...) {
        let add = subviews.isEmpty
        var dic = Dictionary<String,Any>()
        for (index,view) in views.enumerated() {
            if add {
                view.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(view)
            }
            dic["v\(index)"] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: VSF, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dic))
    }
    
    @objc func addContraintByVSF(VSF:String, views:Array<UIView>) {
        var dic = Dictionary<String,Any>()
        for (index,view) in views.enumerated() {
            dic["v\(index)"] = view
        }
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: VSF, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dic))
    }
    
    func addContraintByVSF(isHorizontal:Bool = true, contraint:CGFloat = 0, views:UIView...) {
        var dic = Dictionary<String,Any>()
        var long:String = ""
        var short:String = ""
        if isHorizontal {
            short = contraint > 0 ?  "V:|-\(contraint)-[v0]-\(contraint)-|" : "V:|[v0]|"
        } else {
            short = contraint > 0 ?  "H:|-\(contraint)-[v0]-\(contraint)-|" : "H:|[v0]|"
        }
        for (index,view) in views.enumerated() {
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            dic["v\(index)"] = view
            long += "[v\(index)]"
            self.addContraintByVSF(VSF: short, views: view)
        }
        if isHorizontal {
            long = "H:|\(long)|"
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: long, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dic))
        } else {
            long = "V:|\(long)|"
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: long, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: dic))
        }
        
    }
    
    func addViewFullScreen(views:UIView...) {
        for view in views {
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addContraintByVSF(VSF: "H:|[v0]|", views: view)
            self.addContraintByVSF(VSF: "V:|[v0]|", views: view)
        }
    }
    
    
    
    @objc var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    
    func setGradientBackground(arrColor:[CGColor], startPoint: Point, endPoint: Point, rect:CGRect? = nil) {
        if arrColor.count >= 2 {
            let gradientLayer = CAGradientLayer()
            let b = rect != nil ? rect! : bounds
            gradientLayer.frame = b
            gradientLayer.colors = arrColor
            gradientLayer.startPoint = startPoint.point
            gradientLayer.endPoint = endPoint.point
            var locations:[NSNumber] = [0.0]
            let total = arrColor.count
            if total > 2 {
                for i in 1..<total-2 {
                    let value = Float(i)/Float(total - 1) as NSNumber
                    locations.append(value)
                }
            }
            locations.append(1.0)
            gradientLayer.locations = locations
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
    
    func setGradientBorder(arrColor:[CGColor], startPoint: Point, endPoint: Point, borderWidth:CGFloat, cornerRadius:CGFloat, rect:CGRect? = nil) {
        let shape = CAShapeLayer()
        self.layoutSubviews()
        let b = rect != nil ? rect! : bounds
        shape.frame = b
        shape.lineWidth = borderWidth
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = arrColor
        gradient.startPoint = startPoint.point
        gradient.endPoint = endPoint.point
        gradient.mask = shape
        layer.insertSublayer(gradient, at: 0)
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

extension UITableView {
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func reloadLast(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection: self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func scrollToTop() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
}

extension UIImageView
{
    @objc func loadImageFromInternet(link:String) {
        let act:UIActivityIndicatorView = {
            let v = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
            v.color = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        
        self.addSubview(act)
        act.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        act.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        act.startAnimating()
        downloadImageFromLink(link: link) { (image) in
            act.stopAnimating()
            act.hidesWhenStopped = true
            act.removeFromSuperview()
            if let img = image {
                if img.size.width > 0 {
                    self.image = img
                } else {
                    showConsole(mess: "Loi down hinh: \(link)")
                }
            }
        }
    }
    
    @objc func loadImageFromInternet(link:String, completion: @escaping (UIImage?) -> (), color:UIColor=#colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)) {
        let act:UIActivityIndicatorView = {
            let v = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
            v.color = color
            v.translatesAutoresizingMaskIntoConstraints = false
            return v
        }()
        
        self.addSubview(act)
        act.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        act.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        act.startAnimating()
        downloadImageFromLink(link: link) { (image) in
            act.stopAnimating()
            act.hidesWhenStopped = true
            act.removeFromSuperview()
            if let img = image {
                if img.size.width > 0 {
                    self.image = img
                }
            }
            completion(image)
        }
    }
    
    @objc func addActivityIndicatorView() {
        image = #imageLiteral(resourceName: "no_image")
        let act = UIActivityIndicatorView(style: .whiteLarge)
        act.color = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        self.addSubview(views: act)
        act.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        act.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        act.startAnimating()
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
    
    @objc var topHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height/2))) else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    @objc var bottomHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int(size.height/2))), size: CGSize(width: size.width, height: CGFloat(Int(size.height) - Int(size.height/2))))) else { return nil }
        return UIImage(cgImage: image)
    }
    @objc var leftHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width/2, height: size.height))) else { return nil }
        return UIImage(cgImage: image)
    }
    @objc var rightHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))), height: size.height)))
            else { return nil }
        return UIImage(cgImage: image)
    }
    
    @objc func croppingByFrame(rec:CGRect) -> UIImage? {
        if let cgImage = self.cgImage?.cropping(to: rec) {
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        } else {
            return nil
        }
    }
    
    @objc func resizeImage(scale: CGFloat) -> UIImage {
        let newSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    @objc func resizeImage(scale: CGFloat,scaleByWidth:Bool) -> UIImage {
        var newSize = CGSize.zero
        if scaleByWidth {
            newSize = CGSize(width: self.size.width * scale, height: self.size.height)
        } else {
            newSize = CGSize(width: self.size.width, height: self.size.height * scale)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @objc func resizeImage(targetSize: CGSize, isRatioWidthHeight:Bool = true) -> UIImage {
        if isRatioWidthHeight {
            let widthRatio = targetSize.width / self.size.width
            let heightRatio = targetSize.height / self.size.height
            let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
            let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        } else {
            let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    }
    
    @objc func mergeDifferentSize(imageAbove: UIImage, translation:CGPoint) -> UIImage {
        let maxWidth = self.size.width > imageAbove.size.width ? self.size.width : imageAbove.size.width
        let maxHeight = self.size.height > imageAbove.size.height ? self.size.height : imageAbove.size.height
        let size = CGSize(width: maxWidth, height: maxHeight)
        
        let areaSize = CGRect(x: (maxWidth - self.size.width)/2, y: (maxHeight - self.size.height)/2, width: self.size.width, height: self.size.height)
        let upSize = CGRect(x: (maxWidth - imageAbove.size.width)/2 - translation.x, y: (maxHeight - imageAbove.size.height)/2 - translation.y, width: imageAbove.size.width, height: imageAbove.size.height)
        
        UIGraphicsBeginImageContext(size)
        self.draw(in: areaSize)
        imageAbove.draw(in: upSize, blendMode: CGBlendMode.normal, alpha: 1.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    @objc func merge(imageAbove: UIImage, translation:CGPoint) -> UIImage {
        let size = self.size
        let areaSize = CGRect(origin: CGPoint.zero, size: size)
        let origin = CGPoint(x:  (size.width - imageAbove.size.width)/2 - translation.x, y: (size.height - imageAbove.size.height)/2 - translation.y)
        let upSize = CGRect(origin: origin, size: imageAbove.size)
        UIGraphicsBeginImageContext(size)
        self.draw(in: areaSize)
        imageAbove.draw(in: upSize, blendMode: CGBlendMode.normal, alpha: 1.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func weld2Image(secondImg:UIImage) -> UIImage {
        let size = self.size
        let w = size.width > secondImg.size.width ? size.width : secondImg.size.width
        let newSize = CGSize(width: w, height: size.height + secondImg.size.height)
        
        let o1 = CGPoint(x: (w - size.width)/2, y: 0)
        let o2 = CGPoint(x: (w - secondImg.size.width)/2, y: size.height)
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(origin: o1, size: size))
        secondImg.draw(in: CGRect(origin: o2, size: secondImg.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func imageWithColor(tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1, y: -1)
            context.setBlendMode(.normal)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context.clip(to: rect, mask: self.cgImage!)
            tintColor.setFill()
            context.fill(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    @objc func fixedOrientation() -> UIImage {
        // No-op if the orientation is already correct
        if (imageOrientation == UIImage.Orientation.up) {
            return self
        }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
        
        if (imageOrientation == UIImage.Orientation.down
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: .pi)
        }
        
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: .pi * 2)
        }
        
        if (imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: 0, y: size.height);
            transform = transform.rotated(by: .pi * (-2));
        }
        
        if (imageOrientation == UIImage.Orientation.upMirrored
            || imageOrientation == UIImage.Orientation.downMirrored) {
            
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        if (imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.rightMirrored) {
            
            transform = transform.translatedBy(x: size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height),
                                      bitsPerComponent: cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: cgImage!.colorSpace!,
                                      bitmapInfo: cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        if (imageOrientation == UIImage.Orientation.left
            || imageOrientation == UIImage.Orientation.leftMirrored
            || imageOrientation == UIImage.Orientation.right
            || imageOrientation == UIImage.Orientation.rightMirrored
            ) {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.height,height:size.width))
        } else {
            ctx.draw(cgImage!, in: CGRect(x:0,y:0,width:size.width,height:size.height))
        }
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
}

class BlockBarButtonItem: UIBarButtonItem {
    private var actionHandler: (() -> Void)?
    
    convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: (() -> Void)?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }
    
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: (() -> Void)?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed))
        self.target = self
        self.actionHandler = actionHandler
    }
    
    @objc func barButtonItemPressed(sender: UIBarButtonItem) {
        actionHandler?()
    }
}
extension Dictionary {
    func show() {
        for pr in self {
            if let str = pr.value as? String {
                let value = str.replacingOccurrences(of: "\'", with: "'")
                print("\(pr.key) = \(value)")
            } else if let arr = pr.value as? Array<String> {
                var arrTemp = Array<String>()
                for v in arr {
                    arrTemp.append(v.replacingOccurrences(of: "\'", with: "'"))
                }
                print("\(pr.key) = \(arrTemp)")
            } else {
                print("\(pr.key) = \(pr.value)")
            }
        }
    }
    
    var json: String {
        do {
            let invalidJson = "InValid"
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return ""
        }
    }
    
    var jsonData:Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return jsonData
        } catch {
            return nil
        }
    }
    
    func convertToString() -> String {
        var result = ""
        for (i, value) in self.enumerated() {
            if i == 0 {
                result += "\(value.key)=\(value.value)"
            } else {
                result += "&\(value.key)=\(value.value)"
            }
        }
        return result
    }
}

extension String {
    
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        
        if plusForSpace {
            allowed.addCharacters(in: " ")
        }
        
        var encoded = self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
        if plusForSpace {
            encoded = encoded?.replacingOccurrences(of: "", with: "+")
        }
        return encoded
    }
    
    var parseJSONString: Any? {
        let data = self.data(using: String.Encoding.unicode, allowLossyConversion: false)
        if let jsonData = data {
            do {
                return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments)
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    func getDate(format:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFromString = dateFormatter.date(from: self)
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = format
        return dateFormatter2.string(from: dateFromString!)
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func height(withContraintWidth width:CGFloat, font:UIFont) -> CGFloat {
        let contraint = CGSize(width: width, height: .greatestFiniteMagnitude)
        let bounding = self.boundingRect(with: contraint, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(bounding.height)
    }
    
    func width(withContraintHeight height:CGFloat, font:UIFont) -> CGFloat {
        let contraint = CGSize(width: .greatestFiniteMagnitude, height: height)
        let bounding = self.boundingRect(with: contraint, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
        return ceil(bounding.width)
    }
    
}
extension UIViewController
{
    func playVideo (asset:PHAsset) {
        guard (asset.mediaType == .video)
            else {
                print("Not a valid video media type")
                return
        }
        
        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, info) in
            if let asset = asset as? AVURLAsset {
                DispatchQueue.main.async {
                    let player = AVPlayer(url: asset.url)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }
        }
    }
    
    func playVideo (vContain:UIView, appLocalUrl:URL) {
        DispatchQueue.main.async {
            let player = AVPlayer(url: appLocalUrl)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = vContain.bounds
            vContain.layer.addSublayer(playerLayer)
            player.play()
        }
    }
    
    func playVideo(remoteUrl:String) {
        DispatchQueue.main.async {
            let videoURL = URL(string: remoteUrl)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    func playVideo(vContain:UIView, remoteUrl:String)  {
        DispatchQueue.main.async {
            let videoURL = URL(string: remoteUrl)
            let player = AVPlayer(url: videoURL!)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = vContain.bounds
            vContain.layer.addSublayer(playerLayer)
            player.play()
        }
    }
    
    func isVisible() -> Bool {
        return self.isViewLoaded && self.view.window != nil
    }
    
    func showLog(mess:Any...) {
        if Device.isSimulator() || isTestServer || isShowConsoleLog {
            print("------------------------------------------------------------------------")
            print("Controller: \(self.debugDescription)")
            for m in mess {
                print("\(m)")
            }
        }
    }
    
    func showLog(url:String,param:[String:Any]?,method:Method) {
        if Device.isSimulator() || isTestServer || isShowConsoleLog {
            print("------------------------------------------------------------------------")
            print("Controller: \(self.debugDescription)")
            print(url)
            print("\(method.toString)")
            if let param = param {
                param.show()
            }
        }
    }
    
    func checkFileExist(fileName:String) -> Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: filePath)
        }
        return false
    }
    func drawViewByArraySubviews(view:UIView, arrView:Array<UIView>, distanceVertical:Int) {
        var vVSF = "V:|"
        for (ind,v) in arrView.enumerated() {
            view.addSubview(views: v)
            view.addContraintByVSF(VSF: "H:|[v0]", views: v)
            vVSF += "-\(distanceVertical)-[v\(ind)]"
        }
        vVSF += "-\(distanceVertical)-|"
        view.addContraintByVSF(VSF: vVSF, views: arrView)
    }
    
    func playAlert(id:SystemSoundID=1017)  {
        AudioServicesPlayAlertSound(id)
    }
    
    func playSound(id:SystemSoundID=1016) {
        // to play sound
        AudioServicesPlaySystemSound (id)
    }
    
    func screenShot() -> UIImage {
        //hide controls if needed
        let rect: CGRect = self.view.frame
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.view.layer.render(in: context)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    //URL or String
    func loadAllFileInDocument(folder:String="") -> [Any]? {
        if folder == "" {
            //URL
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            do {
                return try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            } catch {
                print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
            }
        } else {
            //String
            let docsPath = Bundle.main.resourcePath! + "/\(folder)"
            let fileManager = FileManager.default
            do {
                return try fileManager.contentsOfDirectory(atPath: docsPath)
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    func listFilesFromDocumentsFolder() -> Array<String>?{
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var documentsDirectory : String;
        documentsDirectory = paths[0] as String
        do {
            let fileManager = FileManager()
            return try fileManager.contentsOfDirectory(atPath: documentsDirectory)
        } catch {
            self.showLog(mess: "Loi listFilesFromDocumentsFolder")
        }
        
        return nil
    }
    
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func printImage(img:UIImage, targetSize:CGSize?) {
        // Set up print controller
        if UIPrintInteractionController.isPrintingAvailable {
            let printInfo = UIPrintInfo(dictionary:nil)
            printInfo.jobName = "Print label"
            if targetSize == nil {
                printInfo.outputType = UIPrintInfo.OutputType.general
            }
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printInfo
            
            // Assign a UIImage version of my UIView as a printing iten
            printController.printingItem = img
            
            // Do it
            printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
        } else {
            self.showLog(mess: "No Priter on network")
        }
    }
    
    func merge2Image(topImage:UIImage, bottomImage:UIImage, size:CGSize, isSavePhotoLibrary:Bool) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        bottomImage.draw(in: areaSize)
        topImage.draw(in: areaSize, blendMode: .normal, alpha: 0.8)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if isSavePhotoLibrary {
            savePhotoGalerry(image: newImage!)
        }
        return newImage
    }
    
    func savePhotoGalerry(image:UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("save error " + error.localizedDescription)
        } else {
            print("save OK ")
        }
    }
    @objc func popToAdminController() {
        for viewController in (self.navigationController?.viewControllers)! {
            if viewController .isKind(of: IntroduceController.self) {
                let _ = self.navigationController?.popToViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func showAlert(title:String?, mess:String?) {
        if title == getAlertMessage(msg: .ERROR) {
            playAlert()
        }
        let alert:UIAlertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        let btnOK:UIAlertAction = UIAlertAction(title: getAlertMessage(msg: .OK), style: .default, handler: nil)
        alert.addAction(btnOK)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showAlert(title:String?, mess:String?, hasCancel: Bool = false, cancelTitle:String? = nil, complete:@escaping ()->()) {
        if title == getAlertMessage(msg: .ERROR) {
            playAlert()
        }
        let alert:UIAlertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
//        let titleOK = hasCancel ? getAlertMessage(msg: .YES) : getAlertMessage(msg: .OK)
        let titleOK = getAlertMessage(msg: .OK)
        let btnOK:UIAlertAction = UIAlertAction(title: titleOK, style: .destructive) { (btnOK) in
            complete()
        }
        alert.addAction(btnOK)
        if hasCancel {
            let title = cancelTitle == nil ? getAlertMessage(msg: .CANCEL) : cancelTitle!
            let style = Device.isPad() ? UIAlertAction.Style.default : UIAlertAction.Style.cancel
            let btnCancel:UIAlertAction = UIAlertAction(title: title, style: style, handler: { (btnCancel) in
                self.view.endEditing(true)
            })
            alert.addAction(btnCancel)
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showAlert(title:String?, mess:String?, btnATitle:String, btnBTitle:String,hasCancel : Bool = false,cancelTitle:String? = nil, actionA:@escaping ()->(), actionB:@escaping () -> ())  {
        let alert:UIAlertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        let btnA:UIAlertAction = UIAlertAction(title: btnATitle, style: .destructive) { (btnA) in
            actionA()
        }
        alert.addAction(btnA)
        if hasCancel {
            let btnB:UIAlertAction = UIAlertAction(title: btnBTitle, style: .destructive) { (btnB) in
                actionB()
            }
            alert.addAction(btnB)
            let title = cancelTitle == nil ? getAlertMessage(msg: .CANCEL) : cancelTitle!
            let style = Device.isPad() ? UIAlertAction.Style.default : UIAlertAction.Style.cancel
            let btnCancel:UIAlertAction = UIAlertAction(title: title , style: style, handler: {(btnCancel) in
                self.view.endEditing(true)}
            )
            alert.addAction(btnCancel)
        } else {
            let btnB:UIAlertAction = UIAlertAction(title: btnBTitle, style: .default) { (btnB) in
                actionB()
            }
            alert.addAction(btnB)
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showAlert(title:String?, mess:String?, btnATitle:String, btnBTitle:String, hasCancel : Bool, cancelTitle:String?=nil, actionA:@escaping ()->(), actionB:@escaping () -> (), actionCancel:@escaping () -> ())  {
        let alert:UIAlertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        let btnA:UIAlertAction = UIAlertAction(title: btnATitle, style: .destructive) { (btnA) in
            actionA()
        }
        let btnB:UIAlertAction = UIAlertAction(title: btnBTitle, style: .destructive) { (btnB) in
            actionB()
        }
        alert.addAction(btnA)
        alert.addAction(btnB)
        if hasCancel {
            let title = cancelTitle == nil ? getAlertMessage(msg: .CANCEL) : cancelTitle!
            let style = Device.isPad() ? UIAlertAction.Style.default : UIAlertAction.Style.cancel
            let btnCancel:UIAlertAction = UIAlertAction(title: title, style: style, handler: { (btnCancel) in
                actionCancel()
            })
            alert.addAction(btnCancel)
        }
        present(alert, animated: true, completion: nil)
    }
    
    //1: center
    @objc func showActionSheet(title: String?, sender:UIBarButtonItem?, arrSelection:[String], position:Int = 2, hasCancel: Bool = false, cancelTitle:String? = nil, complete:@escaping (String)->()) {
        let alert:UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for select in arrSelection {
            let btnSelect:UIAlertAction = UIAlertAction(title: select, style: .destructive, handler: { (btnSelect) in
                self.view.endEditing(true)
                complete(select)
            })
            alert.addAction(btnSelect)
        }
        
        if hasCancel {
            let title = cancelTitle == nil ? getAlertMessage(msg: .CANCEL) : cancelTitle!
            let style = Device.isPad() ? UIAlertAction.Style.default : UIAlertAction.Style.cancel
            let btnCancel:UIAlertAction = UIAlertAction(title: title, style: style, handler: { (btnCancel) in
                self.view.endEditing(true)
            })
            alert.addAction(btnCancel)
        }
        alert.modalPresentationStyle = UIModalPresentationStyle.popover
        if let popoverController = alert.popoverPresentationController {
            if let sender = sender {
                popoverController.barButtonItem = sender
            } else {
                popoverController.sourceView = self.view //to set the source of your alert
                var rect = CGRect.zero
                if position == 1 {
                    rect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                } else if position == 2 {
                    rect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                }
                
                popoverController.sourceRect = rect
                popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showAlertWithTextField(title:String?, mess:String?, placeHolder:String = "", type:UIKeyboardType = .numbersAndPunctuation, hasCancel: Bool = true, titleOK:String?=nil, titleNo:String?=nil, complete:@escaping (_ text:String?)->()) {
        let alert:UIAlertController = UIAlertController(title: title, message: mess, preferredStyle: .alert)
        var ok = titleOK == nil ? "" : titleOK!
        if ok.isEmpty {
            ok = hasCancel ? getAlertMessage(msg: .YES) : getAlertMessage(msg: .OK)
        }
        alert.addTextField { (textField) in
            textField.placeholder = placeHolder
            textField.keyboardType = type
            textField.addTarget(self, action: #selector(UIViewController.textChanged(_:)), for: .editingChanged)
        }
        let btnOK:UIAlertAction = UIAlertAction(title: ok, style: .destructive, handler: {[weak alert] (_) in
            let text = alert?.textFields![0].text
            if text != "" {
                complete(text)
            }
        })
        alert.addAction(btnOK)
        if hasCancel {
            let title = titleNo == nil ? getAlertMessage(msg: .CANCEL) : titleNo!
            let style = Device.isPad() ? UIAlertAction.Style.default : UIAlertAction.Style.cancel
            let btnCancel:UIAlertAction = UIAlertAction(title: title, style: style, handler: { (btnCancel) in
                self.view.endEditing(true)
            })
            alert.addAction(btnCancel)
        }
        alert.actions[0].isEnabled = false
        present(alert, animated: true, completion: nil)
    }
    
    @objc func textChanged(_ sender: Any) {
        let tf = sender as! UITextField
        var resp : UIResponder! = tf
        while !(resp is UIAlertController) { resp = resp.next }
        let alert = resp as! UIAlertController
        alert.actions[0].isEnabled = (tf.text != "")
    }
    
    func dostuff(getName: Bool) -> String
    {
        if (getName) {
            return #function
        }
        return ""
    }
    
    //0: cach trai phai, 1: cach giua cac view, 2: Do rong cua lbl, 3: do cao cua TextField, 4: small, 5: medium, 6: large, 7: width button
    @objc func getDimension() -> Array<Int> {
        return Device.isPhone() ? [10,5,100,30,17,22,22,150] : [30,15,150,50,17,33,41,200]
    }
    
    func getExtensionOfPath(path:String) -> String {
        let arr = path.components(separatedBy: "/")
        if let fileName = arr.last {
            let ext = fileName.components(separatedBy: ".")
            if let result = ext.last {
                return result.lowercased()
            }
        }
        return ""
    }
    
    func isEmptyTextField(txt:UITextField ...) -> String
    {
        var result = "OK"
        for i in 0...txt.count - 1 {
            if let text = txt[i].text {
                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    result = getAlertMessage(msg: .ERR_EMPTY_TEXTFIELD)
                    if let pHold = txt[i].placeholder {
                        result = pHold + result
                    }
                    txt[i].becomeFirstResponder()
                    break
                }
            }
        }
        return result
    }
    
    func checkTextFieldType(isInt:Bool, txt:UITextField...) -> String {
        var result = "OK"
        for i in 0...txt.count-1 {
            var isOK:Bool = false
            if let text = txt[i].text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if isInt {
                    if let _ = Int(text) {
                        isOK = true
                    }
                } else if let _ = Double(text) {
                    isOK = true
                }
            }
            if !isOK {
                result = getAlertMessage(msg: .ERR_INVALIDATE_TYPE)
                if let pHold = txt[i].placeholder {
                    result = pHold + result
                }
                txt[i].becomeFirstResponder()
                break
            }
        }
        return result
    }
    
    @objc func isValidPassword(candidate:String)->Bool {
        let passRegex = "(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,15}"
        return NSPredicate(format: "SELF MATCHES %@", passRegex).evaluate(with: candidate)
    }
    
    @objc func isValidEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
    func getImage(link:String, completion:@escaping (UIImage) -> ())  {
        let url = URL(string: link)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                completion(UIImage())
            }
            DispatchQueue.main.async {
                completion(UIImage(data: data!)!)
            }
        }).resume()
    }
    
    
    @objc func getImageFromLink(link:String, completion: @escaping (UIImage)->()) {
        downloadImageFromLink(link: link, completion: { (img) in
            if let image = img {
                completion(image)
            } else {
                completion(UIImage())
            }
        })
    }
    
    func showToast(message : String?, inView:UIView, completion:(()-> Void)?, bgColor:UIColor = UIColor.orange, txtColor:UIColor = UIColor.white, size:CGFloat=14) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = bgColor.withAlphaComponent(0.6)
        toastLabel.textColor = txtColor
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont.boldSystemFont(ofSize: size)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        inView.addSubview(views: toastLabel)
        toastLabel.bottomAnchor.constraint(equalTo: inView.bottomAnchor, constant: -50).isActive = true
        toastLabel.centerXAnchor.constraint(equalTo: inView.centerXAnchor).isActive = true
        toastLabel.widthAnchor.constraint(equalTo: inView.widthAnchor, multiplier: 0.75).isActive = true
        toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
        let duration:TimeInterval = completion == nil ? 4 : 1
        UIView.animate(withDuration: duration, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
            if completion != nil {
                completion!()
            }
        })
    }
    
    func downloadImageFromLink(link:String, completion:@escaping (UIImage?)->(), isDisconnetion:Bool=false) {
        let request = createRequest(strURL: link, method: .get, param: nil, dicExtensionFile: nil)
        let task = URLSession.shared.dataTask(with: request) { (data, res, err) in
            if err == nil {
                if let response = res as? HTTPURLResponse {
                    let status = response.statusCode
                    if status == 404 {
                        DispatchQueue.main.async {
                            completion(nil)
                            self.finishResponseFromServer(isDisconnection: isDisconnetion)
                        }
                    } else if status == 200 {
                        DispatchQueue.main.async {
                            if let data = data {
                                if let img = UIImage(data: data) {
                                    completion(img)
                                } else {
                                    self.showLog(mess: "Loi hinh: \(link)")
                                    self.showLog(mess: data as Any)
                                    completion(nil)
                                }
                            } else {
                                self.showLog(mess: "Loi hinh: \(link)")
                                completion(nil)
                            }
                            self.finishResponseFromServer(isDisconnection: isDisconnetion)
                        }
                    } else {
                        //Mat ket noi thuc hien lai
                        self.actionDisconnectInternet(times: 1, isDisconnetion: isDisconnetion, funcString: "downloadImageFromLink", link: link, err: err, doAgain: {
                            self.downloadImageFromLink(link: link, completion: completion, isDisconnetion:isDisconnetion)
                        }, disconnectInternet: { (mes) in
                            self.downloadImageFromLink(link: link, completion: completion, isDisconnetion:true)
                        })
                    }
                }
            } else {
                //Mat ket noi thuc hien lai
                self.actionDisconnectInternet(times: 1, isDisconnetion: isDisconnetion, funcString: "downloadImageFromLink", link: link, err: err, doAgain: {
                    self.downloadImageFromLink(link: link, completion: completion, isDisconnetion:isDisconnetion)
                }, disconnectInternet: { (mes) in
                    self.downloadImageFromLink(link: link, completion: completion, isDisconnetion:true)
                })
            }
        }
        task.resume()
    }
    
    func sendRequest(linkAPI:API, param:[String:Any]?, method:Method, hasLoading:Bool, extraLink:String?, fail:@escaping (Dictionary<String,Any>?)->(), success:@escaping (Dictionary<String,Any>)->(), isAlertFail:Bool, number:Int = 1 ,dicExtensionFile:[String:Any]? = nil, times:Int = 1, isDisconnection:Bool = false) {
        var viewTam:UIView!
        var act:UIActivityIndicatorView!
        if hasLoading {
            viewTam = UIView()
            act = UIActivityIndicatorView()
            self.createViewLoading(act: act, viewTam: viewTam)
        }
        let extra:String = parse(valueOfkey: extraLink)
        let link = extra.isEmpty ? linkAPI.LINK_SERVICE : linkAPI.LINK_SERVICE + "/\(extra)"
        let request = self.createRequest(strURL: link, method: method, param: param, dicExtensionFile: dicExtensionFile)
        let session = URLSession.shared
//        showConsole(mess: getTimeStamp())
        let task = session.dataTask(with: request) { (data, res, err) in
            self.getResponseFromServer(times: times, link:link, data: data, res: res, err: err, act: act, viewTam: viewTam, hasLoading: hasLoading, isDisconnetion: isDisconnection, isAlertFail: isAlertFail, doAgain: { (isDisconnetNetwork) in
                let time = isDisconnetNetwork ? 1 : times + 1
                self.sendRequest(linkAPI: linkAPI, param: param, method: method, hasLoading: hasLoading, extraLink: extraLink, fail: fail, success: success, isAlertFail: isAlertFail, dicExtensionFile: dicExtensionFile, times: time, isDisconnection: isDisconnetNetwork)
            }, rollBack: { (data) in
                fail(data)
            }, success: { (data) in
                success(data)
            })
        }
        task.resume()
    }
    
    //doAgain(true) -> Reset lai so lan
    func getResponseFromServer(times:Int,link:String, data:Data?, res:URLResponse?, err:Error?, act: UIActivityIndicatorView?, viewTam: UIView?, hasLoading:Bool?, isDisconnetion:Bool, isAlertFail:Bool, doAgain:@escaping (Bool)->(), rollBack:@escaping (Dictionary<String,Any>?)->(), success:@escaping (Dictionary<String,Any>)->()) {
        DispatchQueue.main.async {
            if hasLoading == true && viewTam != nil && act != nil {
                self.stopLoading(act: act!, viewTam: viewTam!)
            }
            self.finishGetResponse(fromFunction: "getResponseFromServer", times: times, link: link, data: data, res: res, err: err, isDisconnetion: isDisconnetion, isAlert404: isAlertFail, isAlert200: isAlertFail, doAgain: doAgain, rollBack: rollBack, success: success)
        }
    }
    
    func createRequest(strURL:String, method:Method, param:[String:Any]?, dicExtensionFile:[String:Any]?) -> URLRequest {
        var request:URLRequest!
        if method == .get || method == .delete {
            let url = URL(string: strURL)
            request = URLRequest(url: url!)
            request.httpMethod = method.toString
            var extra = ""
            if let param = param {
                for pr in param {
                    extra += extra.isEmpty ? "?\(pr.key)=\(pr.value)" : "&\(pr.key)=\(pr.value)"
                }
            }
            showLog(url: strURL + extra, param: nil, method: method)
            if !tokenString.isEmpty {
                request.addValue("\(tokenString)", forHTTPHeaderField: "token")
            }
        } else {
            showLog(url: strURL, param: param, method: method)
            let url = URL(string: strURL)
            request = URLRequest(url: url!)
            request.httpMethod = method.toString
            if !tokenString.isEmpty {
                request.addValue("\(tokenString)", forHTTPHeaderField: "token")
            }
            if let param = param {
                let boundary = generateBoundaryString()
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                request.httpBody = createBody(parameters: param, boundary: boundary, dicFileExtension: dicExtensionFile)
            }
        }
        return request
    }
    
    func createBody(parameters:[String:Any], boundary:String, dicFileExtension:[String:Any]?) -> Data {
        var body = NSMutableData()
        for pr in parameters {
            if let arrData = pr.value as? [Data], let arrExt = dicFileExtension?[pr.key] as? [String] {
                for (index,data) in arrData.enumerated() {
                    let fname:String = "\(getTime())_\(index).\(arrExt[index])"
                    body = parseDataToBodyPost(body: body, key: pr.key, isArray: true, data: data, fileName: fname, boundary: boundary)
                }
            }
            if let data = pr.value as? Data, let ext = dicFileExtension?[pr.key] as? String {
                let fname:String = "\(getTime()).\(ext)"
                body = parseDataToBodyPost(body: body, key: pr.key, isArray: false, data: data, fileName: fname, boundary: boundary)
            }
            else if let arrImg = pr.value as? [UIImage], let arrExt = dicFileExtension?[pr.key] as? [String] {
                for (index,img) in arrImg.enumerated() {
                    let fname:String = "\(getTime())_\(index).\(arrExt[index])"
                    body = parseImageToBody(body: body, key: pr.key, isArray: true, img: img, filename: fname, boundary: boundary)
                }
            }
            else if let img = pr.value as? UIImage, let ext = dicFileExtension?[pr.key] as? String {
                let fname:String = "\(getTime()).\(ext)"
                body = parseImageToBody(body: body, key: pr.key, isArray: false, img: img, filename: fname, boundary: boundary)
            }
            else if let data = pr.value as? [Any] {
                for value in data {
                    body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                    body.append("Content-Disposition: form-data; name=\"\(pr.key)[]\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                    body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
                }
            } else {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(pr.key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(pr.value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        return body as Data
    }
    
    func parseDataToBodyPost(body:NSMutableData, key:String, isArray:Bool, data:Data, fileName:String, boundary:String) -> NSMutableData {
        let mimetype = mimeTypeForPath(path: fileName)
        let newKey = isArray ? "\(key)[]" : key
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"\(newKey)\"; filename=\"\(fileName)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        return body
    }
    
    func parseImageToBody(body:NSMutableData, key:String, isArray:Bool, img:UIImage, filename:String, boundary:String) -> NSMutableData {
        let kind = getExtensionOfPath(path:filename)
        let data = kind == "jpg" || kind == "jpeg" ? img.jpegData(compressionQuality: 1.0)! : img.pngData()!
        return parseDataToBodyPost(body: body, key: key, isArray: isArray, data: data, fileName: filename, boundary: boundary)
    }
    
    func sendRequestGetHTML(link:String, hasLoading:Bool, isDisconnetion:Bool=false, completion:@escaping (String)->())  {
        let viewTam = UIView()
        let act = UIActivityIndicatorView()
        if hasLoading {
            self.createViewLoading(act: act, viewTam: viewTam)
        }
        let request = createRequest(strURL: link, method: .get, param: nil, dicExtensionFile: nil)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, res, err) in
            DispatchQueue.main.async {
                if hasLoading {
                    self.stopLoading(act: act, viewTam: viewTam)
                }
                if err == nil {
                    if let response = res as? HTTPURLResponse {
                        let status = response.statusCode
                        if status == 404 || status == 400{
                            completion("")
                            showConsole(mess: "sendRequestGetHTML 404 Roll Back link = \(link)")
                            self.finishResponseFromServer(isDisconnection: isDisconnetion)
                        } else if status == 200 {
                            if let returnData = String(data: data!, encoding: .utf8) {
                                completion(returnData)
                            } else {
                                completion("")
                            }
                            self.finishResponseFromServer(isDisconnection: isDisconnetion)
                        } else {
                            //Mat ket noi thuc hien lai
                            self.actionDisconnectInternet(times: 1, isDisconnetion: isDisconnetion, funcString: "sendRequestGetHTML", link:link, err: err, doAgain: {
                                self.sendRequestGetHTML(link:link, hasLoading:hasLoading ,isDisconnetion: isDisconnetion, completion:completion)
                            }, disconnectInternet: { (mes) in
                                self.sendRequestGetHTML(link:link, hasLoading:hasLoading, isDisconnetion: true, completion:completion)
                            })
                        }
                    }
                } else {
                    //Mat ket noi thuc hien lai
                    self.actionDisconnectInternet(times: 1, isDisconnetion: isDisconnetion, funcString: "sendRequestGetHTML", link:link, err: err, doAgain: {
                        self.sendRequestGetHTML(link:link, hasLoading:hasLoading ,isDisconnetion: isDisconnetion, completion:completion)
                    }, disconnectInternet: { (mes) in
                        self.sendRequestGetHTML(link:link, hasLoading:hasLoading, isDisconnetion: true, completion:completion)
                    })
                }
            }
        }
        task.resume()
    }
    
    func finishGetResponse(fromFunction:String, times:Int,link:String, data:Data?, res:URLResponse?, err:Error?, isDisconnetion:Bool, isAlert404:Bool, isAlert200:Bool, doAgain:@escaping (Bool)->(), rollBack:@escaping (Dictionary<String,Any>?)->(), success:@escaping (Dictionary<String,Any>)->()) {
//        showConsole(mess: res as Any, err as Any)
        if err == nil {
            if let response = res as? HTTPURLResponse {
                let status = response.statusCode
                if status == 404 || status == 400{
                    if isAlert404 {
                        do {
                            let myData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            if let object = myData as? Dictionary<String,Any> {
                                if let result = object[getResultAPI(link: API.DATA_RES)] as? String {
                                    if result != getResultAPI(link: API.STATUS_OK) {
                                        showConsole(mess: "\(fromFunction): 404 STATUS FAIL")
                                        if let mess = object[getResultAPI(link: API.DATA_MESSAGE)] as? String {
                                            self.showAlert(title: getAlertMessage(msg: .ERROR), mess: mess)
                                        }
                                    }
                                }
                                showConsole(mess: object)
                                rollBack(nil)
                            } else {
                                showConsole(mess: link)
                                showConsole(mess: "\(fromFunction): 404 Loi parse DICTIONARY")
                                showConsole(mess: myData)
                                rollBack(nil)
                            }
                        } catch {
                            showConsole(mess: link)
                            showConsole(mess: "\(fromFunction): 404 Loi parse JSON")
                            showConsole(mess: data as Any)
                            rollBack(nil)
                        }
                    } else {
                        showConsole(mess: "\(fromFunction): 404 \(link)")
                        showConsole(mess: data as Any)
                        rollBack(nil)
                    }
                    self.finishResponseFromServer(isDisconnection: isDisconnetion)
                } else if status == 200 {
                    do {
                        let myData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        if let object = myData as? Dictionary<String,Any> {
                            var isSessionPass = true
                            if !isHadLogout {
                                if let state = object["state"] {
                                    let st:Int = parse(valueOfkey: state)
                                    isSessionPass = st == 1
                                    if !isSessionPass {
                                        rollBack(nil)
                                        if let mes = object["message"] as? String {
                                            self.showAlert(title: getAlertMessage(msg: .NOTICE), mess: mes, complete: {
                                                isHadLogout = true
                                            })
                                        }
                                    }
                                }
                                if isSessionPass {
                                    if let result = object[getResultAPI(link: API.DATA_RES)] as? String {
                                        if result == getResultAPI(link: API.STATUS_OK) {
                                            success(object)
                                        } else {
                                            if isAlert404 {
                                                if let mess = object[getResultAPI(link: API.DATA_MESSAGE)] as? String {
                                                    if isAlert200 {
                                                        self.showAlert(title: getAlertMessage(msg: .ERROR), mess: mess, complete: {
                                                            showConsole(mess: link)
                                                            showConsole(mess: "\(fromFunction): 200, STATUS fail")
                                                            showConsole(mess: object)
                                                        })
                                                    }
                                                    rollBack(object)
                                                } else {
                                                    showConsole(mess: link)
                                                    showConsole(mess: "\(fromFunction): 200, STATUS fail, Không có message")
                                                    showConsole(mess: object)
                                                    if isAlert200 {
                                                        rollBack(nil)
                                                    } else {
                                                        rollBack(object)
                                                    }
                                                }
                                            } else {
                                                showConsole(mess: link)
                                                showConsole(mess: "\(fromFunction): 200, STATUS fail")
                                                showConsole(mess: object)
                                                rollBack(object)
                                            }
                                        }
                                    } else {
                                        showConsole(mess: link)
                                        showConsole(mess: "\(fromFunction): Thiếu trả về STATUS")
                                        rollBack(nil)
                                    }
                                }
                            } else {
                                showConsole(mess: link)
                                showConsole(mess: "\(fromFunction): 200 Need to Logout")
                                rollBack(nil)
                            }
                        } else {
                            showConsole(mess: link)
                            showConsole(mess: "\(fromFunction): 200 parse DICTIONARY")
                            showConsole(mess: myData)
                            rollBack(nil)
                        }
                    } catch {
                        showConsole(mess: link)
                        showConsole(mess: "\(fromFunction): 200 parse JSON")
                        showConsole(mess: data as Any)
                        rollBack(nil)
                    }
                    self.finishResponseFromServer(isDisconnection: isDisconnetion)
                } else if status == 401 {
                    showConsole(mess: "Lỗi xác thực 401")
                } else {
                    //Mat ket noi thuc hien lai
                    self.actionDisconnectInternet(times:times, isDisconnetion: isDisconnetion, funcString: fromFunction, link: link, err: err, doAgain: {
                        doAgain(false)
                    }, disconnectInternet: { (mes) in
                        doAgain(true)
                    })
                }
            }
        } else {
            showLog(mess: err!.localizedDescription)
            self.actionDisconnectInternet(times:times, isDisconnetion: isDisconnetion, funcString: fromFunction, link:link, err: err, doAgain: {
                doAgain(false)
            }, disconnectInternet: { (mes) in
                doAgain(true)
            })
        }
    }
    
    func actionDisconnectInternet(times:Int, isDisconnetion:Bool, funcString:String, link:String, err:Error?, doAgain:@escaping ()->(), disconnectInternet:@escaping (String)->()) {
        if !isDisconnetion {
            DispatchQueue.main.async {
                if let error = err {
                    let mes = error.localizedDescription +  getAlertMessage(msg: .NO_INTERNET_CONNECTION)
                    if numberRequestFail == 0 {
                        self.showModPendingDisConnectInternet(isOpen: true, mes:mes)
                    }
                    disconnectInternet(mes)
                    numberRequestFail += 1
                } else {
                    if isConnectedToNetwork() {
                        if times == 3 {
                            let mes = getAlertMessage(msg: .SEND_3_TIMES) + link
                            if numberRequestFail == 0 {
                                self.showModPendingDisConnectInternet(isOpen: true, mes:mes)
                            }
                            disconnectInternet(mes)
                            numberRequestFail += 1
                        } else {
                            doAgain()
                        }
                    }
                }
            }
        } else {
            if let error = err {
                let mes = error.localizedDescription + getAlertMessage(msg: .NO_INTERNET_CONNECTION)
                disconnectInternet(mes)
            } else {
                disconnectInternet("")
            }
        }
    }
    
    @objc func createViewLoading(act: UIActivityIndicatorView, viewTam: UIView) {
        view.addViewFullScreen(views: viewTam)
        //Hinh nen
        viewTam.backgroundColor = #colorLiteral(red: 0.9387122845, green: 0.9387122845, blue: 0.9387122845, alpha: 1).withAlphaComponent(0.75)
        act.style = .whiteLarge
        act.color = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        viewTam.addSubview(views: act)
        act.centerXAnchor.constraint(equalTo: viewTam.centerXAnchor).isActive = true
        act.centerYAnchor.constraint(equalTo: viewTam.topAnchor, constant: UIScreen.main.bounds.height / 3).isActive = true
        act.startAnimating()
    }
    
    @objc func stopLoading(act: UIActivityIndicatorView, viewTam: UIView)  {
        act.stopAnimating()
        act.hidesWhenStopped = true
        viewTam.removeFromSuperview()
        self.view.layoutIfNeeded()
    }
    
    @objc func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        var stringMimeType = "application/octet-stream";
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as CFString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                stringMimeType = mimetype as NSString as String
            }
        }
        return stringMimeType;
    }
    
    func finishResponseFromServer(isDisconnection:Bool)  {
        //Neu link bi mat ket noi internet thi tang numberRequestFail
        DispatchQueue.main.async {
            if isDisconnection {
                numberRequestFail -= 1
                if numberRequestFail == 0 {
                    self.showModPendingDisConnectInternet(isOpen: false, mes: "")
                }
            }
        }
    }
    
    @objc func showModPendingDisConnectInternet(isOpen:Bool,mes:String) {
        
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    static func randomLessThanOne() -> CGFloat {
        return CGFloat(drand48())
    }
}

extension UIColor {
    
    @objc static func getColorRGB(r:CGFloat, g:CGFloat, b:CGFloat, alpha:CGFloat = 1) -> UIColor {
        return UIColor(red: r/255, green:g/255, blue: b/255, alpha: alpha)
    }
    
    @objc static func random() -> UIColor {
        var red = CGFloat.randomLessThanOne()
        var green = CGFloat.randomLessThanOne()
        var blue = CGFloat.randomLessThanOne()
        while red == 1 && blue == 1 && green == 1 {
            red = CGFloat.randomLessThanOne()
            green = CGFloat.randomLessThanOne()
            blue = CGFloat.randomLessThanOne()
        }
        return UIColor(red:red, green:green, blue:blue, alpha: 1.0)
    }
}

extension UIFont {
    var bold: UIFont {
        return with(traits: .traitBold)
    } // bold
    
    var italic: UIFont {
        return with(traits: .traitItalic)
    } // italic
    
    var boldItalic: UIFont {
        return with(traits: [.traitBold, .traitItalic])
    } // boldItalic
    
    
    func with(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(traits) else {
            return self
        } // guard
        
        return UIFont(descriptor: descriptor, size: 0)
    } // with(traits:)
} // extension

extension Date {
    init(ticks: UInt64) {
        // Dung: let date = Date(ticks: 636110903202288256)
        self.init(timeIntervalSince1970: Double(ticks)/10_000_000 - 62_135_596_800)
    }
    var ticks: UInt64 {
        // Dung: let ticks = Date().ticks
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
extension TimeInterval {
    var minuteSecondMS: String {
        return String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    var minute: Int {
        return Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        return Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        return Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

extension Int {
    var msToSeconds: Double {
        return Double(self) / 1000
    }
}
extension Notification.Name {
    static let myNotification = Notification.Name("myNotification")
}

extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

extension Array {
    func unique<T:Hashable>(by: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(by(value)) {
                set.insert(by(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
    
    func show(_ text:String="", isBug:Bool=false) {
        if Device.isSimulator() || isTestServer || isBug {
            if !text.isEmpty {
                let extra = self.isEmpty ? " rỗng" : ""
                showConsole(mess: text + extra)
            } else {
                let extra = self.isEmpty ? "Mãng rỗng" : ""
                showConsole(mess: text + extra)
            }
            if !self.isEmpty {
                for (index,obj) in self.enumerated() {
                    showConsole(mess: "\(index + 1)/ \(obj)")
                }
            }
        }
    }
    //    Cach dung:
    //    let newElement = "c"
    //    var myArray = ["b", "e", "d", "a"]
    //    let index = myArray.insertionIndexOf(newElement) { $0 < $1 } // Or: myArray.indexOf(c, <)
    //    myArray.insert(newElement, atIndex: index)
    //    Result = myArray is now [a, b, c, d, e]
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

typealias UIButtonTargetClosure = (UIButton) -> ()

class ClosureWrapper: NSObject {
    let closure: UIButtonTargetClosure
    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

extension UIButton {
    
    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }
    
    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }
    
    @objc func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }
    
    func changeIconColor(toColor:UIColor)  {
        let origImage = self.currentImage;
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        tintColor = toColor
    }
}

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

extension UIBarButtonItem {
    private var _action: () -> () {
        get {
            return objc_getAssociatedObject(self, &actionKey) as! () -> ()
        }
        set {
            objc_setAssociatedObject(self, &actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    convenience init(title: String?, style: UIBarButtonItem.Style, action: @escaping () -> ()) {
        self.init(title: title, style: style, target: nil, action: #selector(pressed))
        self.target = self
        self._action = action
    }
    
    convenience init(image: UIImage?, style: UIBarButtonItem.Style, action: @escaping () -> ()) {
        self.init(image: image, style: style, target: nil, action: #selector(pressed))
        self.target = self
        self._action = action
    }
    
    @objc private func pressed(sender: UIBarButtonItem) {
        _action()
    }
    
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, isDefMod:Bool = true, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        var badgeWidth = 8
        var numberOffset = 4
        
        if number > 9 {
            badgeWidth = 12
            numberOffset = 6
        }
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = isDefMod ? CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y)) : CGPoint(x: view.frame.width - (2 * radius + offset.x), y: (2 * radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = isDefMod ? CGRect(origin: CGPoint(x: location.x - CGFloat(numberOffset), y: offset.y), size: CGSize(width: badgeWidth, height: 16)) : CGRect(origin: CGPoint(x: location.x - CGFloat(numberOffset), y: offset.y + radius), size: CGSize(width: badgeWidth, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}

class FakePrintPaper: UIPrintPaper {
    
    private let size: CGSize
    override var paperSize: CGSize { return size }
    override var printableRect: CGRect  { return CGRect(origin: CGPoint.zero, size: size) }
    
    init(size: CGSize) {
        self.size = size
    }
}
class Downloader {
    class func copyDocumentsToICloudDrive() {
        let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
        let localDocumentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        if let iCloudDocumentsURL = iCloudDocumentsURL {
            var isDir:ObjCBool = false
            if (FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir)) {
                do {
                    try FileManager.default.removeItem(at: iCloudDocumentsURL)
                } catch {
                    showConsole(mess: "Loi Xoa file da co tren ICloud")
                }
                do {
                    try FileManager.default.copyItem(at: localDocumentsURL!, to: iCloudDocumentsURL)
                } catch {
                    showConsole(mess: "Loi Copy file tu local sang IClous")
                }
            }
        }
    }
    
    class func load(urlStr: String, filename:String, completion: @escaping (_ didSave:Bool,_ url:URL?) -> ()) {
        let url = URL(string: urlStr)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let file = filename.split(separator: ".")
                if file.count >= 2 {
                    var localUrl = docDir.appendingPathComponent(filename)
                    var isDir:ObjCBool = false
                    var number:Int = 1
                    while FileManager.default.fileExists(atPath: localUrl.path, isDirectory: &isDir) {
                        number += 1
                        let newName =  "\(file[0])_\(number).\(file[1])"
                        localUrl = docDir.appendingPathComponent(newName)
                    }
                    do {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                        DispatchQueue.main.async {
                            completion(true, localUrl)
                        }
                    } catch (let writeError) {
                        showConsole(mess: "load: error writing file \(filename) : \(writeError)")
                        DispatchQueue.main.async {
                            completion(false, nil)
                        }
                    }
                }
                
            } else {
                showConsole(mess: "load: Failure: %@", error?.localizedDescription as Any)
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        }
        task.resume()
    }
    
    class func exportToICloud(urlStr: String, filename:String, completion: @escaping (_ exported:Bool?) -> ()) {
        load(urlStr: urlStr, filename: filename) { (save, url) in
            if save, let localUrl = url {
                //is iCloud working?
                if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
                    //Create the Directory if it doesn't exist
                    if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                        //This gets skipped after initial run saying directory exists, but still don't see it on iCloud
                        do {
                            try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            showConsole(mess: "Tao thu muc loi ")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                            return
                        }
                    }
                    //If file exists on iCloud remove it
                    //                    iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(filename)
                    if (FileManager.default.fileExists(atPath: iCloudDocumentsURL.appendingPathComponent(filename).path, isDirectory: nil)) {
                        do {
                            try FileManager.default.removeItem(at: iCloudDocumentsURL.appendingPathComponent(filename))
                            showConsole(mess: "Xoa File cu thanh cong")
                        } catch {
                            showConsole(mess: "Xoa File cu loi")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                            return
                        }
                    }
                    let queue = DispatchQueue(label: urlStr)
                    queue.async {
                        do {
                            try FileManager.default.copyItem(at: localUrl, to: iCloudDocumentsURL)
                            DispatchQueue.main.async {
                                showConsole(mess: "Luu thanh cong \(iCloudDocumentsURL.path)")
                                DispatchQueue.main.async {
                                    completion(true)
                                }
                            }
                            do {
                                try FileManager.default.removeItem(at: localUrl)
                                showConsole(mess: "Xoa file local thanh cong")
                            } catch {
                                showConsole(mess: "Xoa file local bi loi")
                            }
                        } catch (let writeError) {
                            DispatchQueue.main.async {
                                completion(false)
                            }
                            showConsole(mess: "Loi luu file \(filename) : \(writeError)")
                        }
                    }
                } else {
                    showConsole(mess: "iCloud is NOT working!")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                }
            } else {
                showConsole(mess: "exportToICloud Luu local Document bi loi")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
}

extension WKWebView {
    func loadFromURL(urlStr:String)  {
        let url = URL(string: urlStr)
        var request = URLRequest(url: url!)
        if tokenString != "" {
            request.addValue(tokenString, forHTTPHeaderField: "token")
        }
        load(request)
        showConsole(mess: "loadFromURL finished")
    }
}

extension CGContext {
    func drawPath(_ points: [CGPoint]) {
        if let p = points.first {
            move(to: p)
            points.forEach { addLine(to: $0) }
        }
    }
    func drawPolygon(_ points: [CGPoint]) {
        if let p = points.last {
            move(to: p)
            points.forEach { addLine(to: $0) }
        }
    }
    func arc(radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) {
        let arc = CGMutablePath()
        arc.addArc(center: .zero, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        addPath(arc)
    }
    func circle(radius: CGFloat) {
        arc(radius: radius, startAngle: 0.0, endAngle: CGFloat(2 * Double.pi))
    }
    func saveContext(operation: () -> ()) {
        saveGState()
        operation()
        restoreGState()
    }
    func scale(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
        saveContext {
            scaleBy(x: x, y: y)
            operation(self)
        }
    }
    func translate(x: CGFloat, y: CGFloat, operation: (CGContext) -> ()) {
        saveContext {
            translateBy(x: x, y: y)
            operation(self)
        }
    }
    func rotate(angle: CGFloat, operation: (CGContext) -> ()) {
        saveContext {
            rotate(by: angle)
            operation(self)
        }
    }
}

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    //Multi: làm tròn đến hàng đơn vị, hàng chục, hàng trăm
    func roundedTo(multi:Double) -> Double {
        return (self / multi).rounded() * multi
    }
}

extension CAGradientLayer {
    
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            }
        }
    }
    
    convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
        self.init()
        self.startPoint = start.point
        self.endPoint = end.point
        self.colors = colors
        self.locations = (0..<colors.count).map(NSNumber.init)
        self.type = type
    }
}

class RadialGradientLayer: CALayer {
    
    var center:CGPoint = CGPoint(x: 50, y: 50)
    var radius:CGFloat = 20
    var colors:[CGColor] = [UIColor(red: 251/255, green: 237/255, blue: 33/255, alpha: 1.0).cgColor , UIColor(red: 251/255, green: 179/255, blue: 108/255, alpha: 1.0).cgColor]
    
    override init(){
        super.init()
        needsDisplayOnBoundsChange = true
    }
    
    init(center:CGPoint,radius:CGFloat,colors:[CGColor]){
        self.center = center
        self.radius = radius
        self.colors = colors
        super.init()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let locations:[CGFloat] = [0.0, 1.0]
        
        if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations) {
            ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [])
        }
    }
}

class CenteredTextLayer:CATextLayer {
    
    override init() {
        super.init()
        alignmentMode = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let textHeight = (string as! String).height(withContraintWidth: bounds.width, font: self.font as! UIFont)
        let yDiff = (self.bounds.height - textHeight)/2
        ctx.saveGState()
        ctx.translateBy(x: 0, y: yDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}

