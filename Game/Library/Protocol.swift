//
//  Protocol.swift
//  VAC Agent
//
//  Created by Mytruong on 3/30/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

@objc protocol TextFieldDelegate {
    @objc optional func didBeginEditing(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func didEndEditing(myTextField:UIMyTextField, textfield:UITextField)
    @available(iOS 10.0, *)
    @objc optional func didEndEditingReason(myTextField:UIMyTextField, reason: UITextField.DidEndEditingReason, textfield:UITextField)
    @objc optional func shouldClear(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func shouldReturn(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func shouldEndEditing(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func shouldBeginEditing(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func didHideKeyBoardPress(myTextField:UIMyTextField, textfield:UITextField)
    @objc optional func isEditing(myTextField:UIMyTextField, textfield:UITextField, text:String)
    
}

@objc protocol GetPhotoInGalleryDelegate {
    @objc optional func pickupAnImage(position:Int, img:UIImage)
}

@objc protocol TakePicturesDelegate {
    @objc optional func takeAnPhoto(position:Int, img:UIImage)
}

@objc protocol SearchBarDelegate {
    @objc optional func searchBarTextDidEndEditing(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarTextDidBeginEditing(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarShouldEndEditing(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarShouldBeginEditing(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarCancelButtonClicked(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarSearchButtonClicked(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarBookmarkButtonClicked(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarResultsListButtonClicked(mySearchBar:UIMySearchBar, searchBar:UISearchBar)
    @objc optional func searchBarTextDidChange(mySearchBar:UIMySearchBar, searchBar:UISearchBar, text: String)
    @objc optional func searchBarSelectedScopeButtonIndexDidChange(mySearchBar:UIMySearchBar, searchBar:UISearchBar, selectedScope: Int)
    @objc optional func searchBarShouldChangeTextIn(mySearchBar:UIMySearchBar, searchBar:UISearchBar, text: String)
}

protocol UIButtonDelegate {
    func btnTextFieldButtonAction(button:UIButton, text: String)
}

protocol UITxtButtonDelegate {
    func btnTextFieldButtonAction(view: UITextFieldButton,button:UIButton, textField: UITextField)
}

protocol UICheckBoxDelegate {
    func btnCheckAction(btn:UICheckBox, isChecked:Bool)
}

@objc protocol UICustomViewAlertDelegate {
    @objc optional func showAlert(alert:String)
}

@objc protocol UIButtonQuantityDelegate {
    @objc optional func increaseQuantity(buttonQuantity:UIButtonQuantity)
    @objc optional func decreaseQuantity(buttonQuantity:UIButtonQuantity)
    @objc optional func deleteQuantityZero(buttonQuantity:UIButtonQuantity)
    @objc optional func alertInvalidValue(buttonQuantity:UIButtonQuantity, message:String)
}


@objc protocol UISelectedBoxDelegate {
    @objc optional func beforePressButtonSelect(mySelectedBox:UISelectedBox,arr:[String])
    @objc optional func afterPressButtonSelect(mySelectedBox:UISelectedBox,arr:[String])
    @objc optional func finishSelectAt(mySelectedBox:UISelectedBox,indexPath:IndexPath)
}

//UIQuickAccessSVG
@objc protocol UIQuickAccessSVGDelegate {
    @objc func btnCustomViewAction(view:UIQuickAccessSVG,label:UILabel)
}

@objc protocol UICustomViewIconPathDelegate {
    @objc func btnCustomViewAction(view:UICustomViewIconPath,label:UILabel,icon:UIView)
}

@objc protocol UICustomViewDelegate {
    @objc func btnCustomViewAction(view:UICustomView,label:UILabel,icon:UIButton)
}

@objc protocol UITextFieldHidePressDelegate {
    @objc optional func btnKeyBoardHidePressAction(textField:UITextField)
}
