//
//  Constant.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

var isTestServer = true
var isHadLogout = false
var tokenString = ""
var tokenDeviceStr = ""
var isActiveBug = false
let TOKEN_KEY:String = "vac_key"
let isShowConsoleLog = true
var numberRequestFail = 0 //Số Request chưa có response

enum Language {
    enum VN:String {
        case play = "Chơi"
        case still = "Mà"
        case learn = "Học"
    }
    
    enum EN:String {
        case play = "Play"
        case still = "Still"
        case learn = "Learn"
    }
}


enum Host: String {
    case story = "story.vietaircargo.com"
    case senter = "senter.vietaircargo.com"
    case cloud = "cloud.vietaircargo.com"
    case staging = "staging.vietaircargo.com"
    case dev = "dev.vietaircargo.com"
}

var BASE_DOMAIN = isTestServer ? Host.dev.rawValue : Host.cloud.rawValue

enum Method: String, Codable {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    var toString:String{
        return self.rawValue
    }
}

enum ModalOriental:String {
    case down = "DOWN"
    case up = "UP"
    case left = "LEFT"
    case right = "RIGHT"
}

enum GradientDirections: Int {
    case LeftToRight
    case RightToLeft
    case BottomToTop
    case TopToBottom
    case TopLeftToBottomRight
    case TopRightToBottomLeft
    case BottomLeftToTopRight
    case BottomRightToTopLeft
}

//Thông tin chi tiết Order:
enum API:String, Codable {
    case getVersion = "check-version"
    case login = "agency/signin"
    case recentInvoice = "agency/recent-invoice"
    case costSummary = "agency/cost-summary"
    case loadInvoice = "agency/order/list-order"
    case loadInvoiceAgency = "agency/order/invoice-details"
    case updateOrder = "agency/order/update-good"
    case updateOrderAddress = "agency/order/update-order-address"
    case updateOrderGoodPhoto = "agency/order/update-good-photo"
    
    case DELETE_GOOD = "order-goods/delete"
    case GET_PHOTO_ID = "order-photo/add-name-photo"
    case UPDATE_ORDER_PHOTO = "order-photo/update-exist"
    case GET_GOODS = "order-goods/list" //Them id
    case UPDATE_TOKEN_DEVICE = "user/user-update-device-token"
    case UPDATE_GROUND_STATUS = "user/update-app-ground"
    case UPLOAD_LOG_FILE = "user/upload-log-file"
    case GET_PROVINCE_VN = "packages/list-provice-vn"
    case SEND_PHOTO = "order-photo/add-file-photo"
    
    case DATA_RES = "status"
    case DATA_MESSAGE = "message"
    case DATA_RETURN = "result"
    
    case STATUS_OK = "success"
    case STATUS_NOK = "fail"
    
    func getLinkService() ->String {
        return "https://\(BASE_DOMAIN)/apis/" + self.rawValue
    }
    
    var LINK_SERVICE:String {
        return "https://\(BASE_DOMAIN)/apis/" + self.rawValue
    }
    
    func getString() -> String {
        return self.rawValue
    }
}

//Dung cho phan biet file png, jpg...
enum ImageFormat {
    case Unknown, PNG, JPEG, GIF, TIFF
}

enum UI:String {
    // LOGIN
    // LOGIN
    case LOGO = "Admin - "
    case NAME = "VietAirCargo"
    case LBL_EMAIL = "E-mail"
    case LBL_PASS = "Mật khẩu"
    case LBL_REMEMBER = "Ghi nhớ đăng nhập (30 phút Idle)"
    case LBL_REM_FOREVER = "Ghi nhớ đến khi đăng xuất"
    case BTN_LOGIN = "ĐĂNG NHẬP"
    case LBL_SHORT_PINCODE = "PINCODE"
    case LBL_PINCODE = "Pincode"
    case LBL_PENDING_TASK = "Các công việc đang thực hiện, vui lòng không thao tác hay thoát App, đợi đến khi hoàn thành"
    
    func getText() -> String {
        return self.rawValue
    }
    
}


enum ALERT:String {
    //THÔNG BÁO
    case ERROR = "Lỗi !!!"
    case NOTICE = "Thông báo"
    case DOING_JOB = "Đang thực hiện: "
    case BACK_3_TIMES = ". Bạn đã click quay về 3 lần, bạn có chắc muốn về lại màn hình trước không? Nếu quay lại dữ liệu upload có thể bị mất."
    case ERR_EMPTY_TEXTFIELD = " chưa được nhập"
    case ERR_INVALIDATE_TYPE = " nhập không đúng "
    case NO_INTERNET_CONNECTION = " Please check internet connection and don't exit App."
    case SEND_3_TIMES = "Lỗi đã upload 3 lần Link: "
    case WARNING_MEMORY = "Amount of available memory is low"
    case CHECK_ORDER = "Kiểm hàng"
    case ERR_SAVE_MARKED_DOCUMENT = "Lỗi lưu hình đánh dấu vào Document"
    case ERR_SAVE_MAIN_IMG_DOCUMENT = "Lỗi lưu hình chính vào Document"
    case ERR_UPLOAD_IMAGE = "Lỗi upload hình cho đơn hàng. Hãy vẽ hình đánh dấu để upload lại hình"
    case ERR_NOT_CHOOSE_PHOTO = "Bạn chưa chọn hình"
    case DENY_PHOTO_GALLERY = "Không thể truy cập Photo Library do bạn từ chối quyền truy cập của App vào setting để mở quyền truy cập cho app."
    
    case CANCEL = "Thoát"
    case OK = "OK"
    case YES = "Có"
    case NO = "Không"
    
    
    func getAlertMessage() -> String{
        return self.rawValue
    }
}
