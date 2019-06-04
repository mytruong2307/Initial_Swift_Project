//
//  PublicFuntion.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit
import SystemConfiguration
import WebKit

//Mercg 2 dictionary
func +=<K, V> ( left: inout [K : V], right: [K : V]) {
    for (k, v) in right {
        left[k] = v
    }
}

func isConnectedToNetwork() -> Bool {
    guard let flags = getFlags() else { return false }
    let isReachable = flags.contains(.reachable)
    let needsConnection = flags.contains(.connectionRequired)
    return (isReachable && !needsConnection)
}

func getFlags() -> SCNetworkReachabilityFlags? {
    guard let reachability = ipv4Reachability() ?? ipv6Reachability() else {
        return nil
    }
    var flags = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(reachability, &flags) {
        return nil
    }
    return flags
}

func ipv6Reachability() -> SCNetworkReachability? {
    var zeroAddress = sockaddr_in6()
    zeroAddress.sin6_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin6_family = sa_family_t(AF_INET6)
    
    return withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    })
}

func ipv4Reachability() -> SCNetworkReachability? {
    var zeroAddress = sockaddr_in()
    zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    return withUnsafePointer(to: &zeroAddress, {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            SCNetworkReachabilityCreateWithAddress(nil, $0)
        }
    })
}

func getTimeStamp() -> UInt64 {
    let date = NSDate()
    return UInt64(floor(date.timeIntervalSince1970 * 1000))
}

func downloadImageFromLink(link:String, completion: @escaping (UIImage?)->())  {
    let queue = DispatchQueue(label: link)
    queue.async {
        if let url = URL(string: link) {
            let request = URLRequest(url:url)
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            let ses = URLSession(configuration: config)
            ses.dataTask(with: request, completionHandler: { (data, res, err) in
                if let response = res as? HTTPURLResponse {
                    let status = response.statusCode
                    if status == 404 {
                        //Khong tim thay file hinh
                        DispatchQueue.main.async {
                            completion(nil)
                            showConsole(mess: "Khong tim thay URL (404): \(link)")
                        }
                    } else if status == 200{
                        DispatchQueue.main.async {
                            if let data = data {
                                if let img = UIImage(data: data) {
                                    completion(img)
                                } else {
                                    showConsole(mess: "Loi hinh: \(link)")
                                    showConsole(mess: data as Any)
                                    completion(nil)
                                }
                            } else {
                                showConsole(mess: "Loi hinh: \(link)")
                                completion(nil)
                            }
                        }
                    } else {
                        if let err = err {
                            showConsole(mess: "loi = \(err.localizedDescription) - link = \(link)")
                        }
                    }
                }
            }).resume()
        } else {
            completion(nil)
        }
    }
}

func compare2Date(fromDate:String, toDate:String) -> Bool? {
    let from = fromDate.split(separator: "/")
    let to = toDate.split(separator: "/")
    if from.count != 3 || to.count != 3 {
        return nil
    } else {
        if let yF = Int (from[2]), let yT = Int (to[2]) {
            if yT < yF {
                return false
            } else if yT > yF {
                return true
            } else {
                if let mF = Int (from[1]), let mT = Int (to[1]) {
                    if mT < mF {
                        return false
                    } else if mT > mF {
                        return true
                    } else {
                        if let dF = Int (from[0]), let dT = Int (to[0]) {
                            return dT >= dF
                        } else {
                            return nil
                        }
                    }
                }
            }
        }
        return nil
    }
}

func printablePdfData(webView: WKWebView,forA4Size:Bool=true) -> NSData {
    let targetSize = forA4Size ? CGSize(width: 2480, height: 3504) : CGSize(width: 2550, height: 3300)
    let renderer = PRV300dpiPrintRenderer()
    let formatter = webView.viewPrintFormatter()
    formatter.perPageContentInsets = UIEdgeInsets()
    renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
    let topPadding: CGFloat = 115.0
    let bottomPadding: CGFloat = 117.0
    let leftPadding: CGFloat = 100.0
    let rightPadding: CGFloat = 100.0
    let printableRect = CGRect(x: leftPadding, y: topPadding, width: targetSize.width - leftPadding - rightPadding, height: targetSize.height - topPadding - bottomPadding)
    let targetRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    renderer.setValue(NSValue(cgRect: targetRect), forKey: "paperRect")
    renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
    let data = renderer.pdfData()
    return data
}

func loadHtmlStringInLabel(text:String, attr: @escaping (NSAttributedString) -> (), color:UIColor = UIColor.gray) {
    guard let data = text.data(using: .unicode) else { return attr(NSAttributedString()) }
    let queue = DispatchQueue(label: "html")
    queue.async {
        do {
            var result = try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType:  NSAttributedString.DocumentType.html], documentAttributes: nil)
            let attributedStringColor = [NSAttributedString.Key.foregroundColor: color]
            result = NSAttributedString(string: result.string, attributes: attributedStringColor)
            DispatchQueue.main.async {
                attr(result)
            }
        } catch {
            DispatchQueue.main.async {
                attr(NSAttributedString())
            }
        }
    }
}

func convertToJsonString(from obj:Any) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: obj, options: []) else {
        return nil
    }
    return String(data: data, encoding: String.Encoding.utf8)
}

func convertJsonStringToDictionary(jsonStr:String) -> Dictionary<String,Any>? {
    if let data = jsonStr.data(using: String.Encoding.utf8) {
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,Any>
            return dic
        } catch let error as NSError {
            print(error)
        }
    }
    return nil
}


func renderUIImageFromUIView(v:UIView) -> UIImage? {
    if #available(iOS 10.0, *) {
        let renderer = UIGraphicsImageRenderer(size: v.bounds.size)
        let image = renderer.image { ctx in
            v.drawHierarchy(in: v.bounds, afterScreenUpdates: true)
        }
        return image
    }
    return nil
}

func readFile(path: String) -> Array<String> {
    do {
        let contents:NSString = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
        let trimmed:String = contents.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        let lines:Array<String> =  NSString(string: trimmed).components(separatedBy: .newlines)
        return lines
    } catch {
        print("Unable to read file: \(path)");
        return [String]()
    }
}
func getSubString(str:String, findStart:String, findEnd:String) -> String? {
    if let subStart = getSubString(str: str, find: findStart, isGetBegin: false) {
        if let result = getSubString(str: subStart, find: findEnd, isGetBegin: true) {
            return result
        }
    }
    return nil
}

func getSubString(str:String, find:String, isGetBegin:Bool = true) -> String? {
    if let range = str.range(of: find) {
        let index = range.lowerBound
        let index2 = str.index(index, offsetBy: find.count)
        let arrChar = isGetBegin ? str[..<index] : str[index2..<str.endIndex]
        return String(arrChar)
    }
    return nil
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func convertDateFromMySQL(strFromMySql:String) -> String? {
    if strFromMySql.contains("/") {
        return strFromMySql
    } else {
        let arr = strFromMySql.components(separatedBy: "-")
        if arr.count == 3 {
            return "\(arr[2])/\(arr[1])/\(arr[0])"
        } else {
            return nil
        }
    }
}

func convertOrderDateToVNFormat(str:String) -> String {
    let date = str.split(separator: " ")
    if date.count == 2 {
        if let day = convertDateFromMySQL(strFromMySql: String(date[0])) {
            let end = date[1].index(date[1].startIndex, offsetBy: 5)
            let hour = date[1][..<end]
            return hour + " " + day
        }
    }
    return ""
}

func convertStringToDateToSaveMySQL(strDate:String, strHour:String) -> String? {
    let newStrHour = strHour.trimmingCharacters(in: .whitespacesAndNewlines)
    if newStrHour.count == 5 {
        if checkValidDate(strDate: strDate) {
            var result = newStrHour + ":00"
            let arrTime = strDate.split{$0 == "/"}.map(String.init)
            if arrTime.count > 2{
                result = arrTime[2] + "-" + arrTime[1] + "-" + arrTime[0] + " " + result
                return result
            } else {
                return nil
            }
        } else {
            return nil
        }
    } else {
        return nil
    }
}

func convertStringToDateToSaveMySQL(date:String) -> String {
    if date.contains("-") {
        return date
    } else {
        return convertStringToDateToSaveMySQL(strDate: date)!
    }
}

func getCurrentDateMySQL() -> String {
    let current = getDateOnly()
    return convertStringToDateToSaveMySQL(date: current)
}

func convertStringToDateToSaveMySQL(strDate:String) -> String? {
    if checkValidDate(strDate: strDate) {
        let arrTime = strDate.components(separatedBy: "/")
        if arrTime.count == 3{
            return arrTime[2] + "-" + arrTime[1] + "-" + arrTime[0]
        } else {
            return nil
        }
    } else {
        return nil
    }
}

func checkValidDate(strDate:String) -> Bool {
    let newStrDate = strDate.trimmingCharacters(in: .whitespacesAndNewlines)
    if newStrDate.count == 10 {
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        if let _ = format.date(from: newStrDate) {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}

func currentOrientation() -> UIInterfaceOrientation {
    return UIApplication.shared.statusBarOrientation
}

func createRamdomString(numberCharacter:Int,characters:Array<Character>? = nil,isSpecialChar:Bool = false) -> String{
    var charactersDefault:Array<Character> = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0","!","@","#","$","%","^","&","_","-"]
    if !isSpecialChar {
        charactersDefault = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0"]
    }
    var str:String = ""
    for _ in 1...numberCharacter{
        if let characters = characters{
            let rd:Int = Int(arc4random()) % characters.count
            str += "\(characters[rd])"
        }else{
            let rd:Int = Int(arc4random()) % charactersDefault.count
            str += "\(charactersDefault[rd])"
        }
    }
    return str
}

//kind = 0 -> Chi co chu, 1: co so, 2: co ky tu dac biet
func createRamdomString(numberCharacter:Int = 1,kind:Int = 0) -> String{
    var charactersDefault:Array<Character>
    switch kind {
    case 0:
        charactersDefault = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"]
        break
    case 1:
        charactersDefault = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0"]
        break
    default:
        charactersDefault = ["q","w","e","r","t","y","u","i","o","p","a","s","d","f","g","h","j","k","l","z","x","c","v","b","n","m","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0","!","@","#","$","%","^","&","_","-"]
        break
    }
    var str:String = ""
    for _ in 1...numberCharacter{
        let rd:Int = Int(arc4random()) % charactersDefault.count
        str += "\(charactersDefault[rd])"
    }
    return str
}
func getFileSizeOfImage(image:UIImage,isJPG:Bool = true) -> Double {
    let imgData: NSData = isJPG ? NSData(data: (image).jpegData(compressionQuality: 1)!) : NSData(data: image.pngData()!)
    return Double(imgData.length) / 1024.0
}

func showConsole(mess:Any...) {
    if Device.isSimulator() || isTestServer || isShowConsoleLog {
        print("------------------------------------------------------------------------")
        for m in mess {
            print("\(m)")
        }
    }
}

func dostuff(getName: Bool) -> String
{
    if (getName) {
        return #function
    }
    return ""
}

func getTextUI(ui:UI) -> String {
    return ui.getText()
}
func getLinkService(link:API) -> String {
    return link.getLinkService()
}

func getResultAPI(link:API) -> String {
    return link.getString()
}

func getAlertMessage(msg:ALERT) -> String {
    return msg.getAlertMessage()
}

func getArrDataForDate(dayInput:Int?,monthInput:Int?,year:Int) -> Array<Int> {
    if dayInput == nil && monthInput == nil {
        return []
    }
    var arrSelect:Array<Int> = []
    let arrData:Array<Int> = dayInput != nil ? [Int](1...12) : [Int](1...31)
    if let month = monthInput {
        if month == 2 {
            arrSelect = checkYear(year: year) ? arrData.filter({$0 < 30}) : arrData.filter({$0 < 29})
        } else if month < 8 {
            arrSelect =  month % 2 == 0 ? arrData.filter({$0 < 31}) : arrData
        } else {
            arrSelect =  month % 2 != 0 ? arrData.filter({$0 < 31}) : arrData
        }
        
        let date = month < 10 ? "01/0\(month)/\(year)" : "01/\(month)/\(year)"
        if let dayOfweek = getDayOfWeek(date) {
            var i = 1
            while i < dayOfweek {
                arrSelect.insert(0, at: 0)
                i += 1
            }
        }
    } else {
        if let day = dayInput{
            if day == 30 || day == 31 {
                arrSelect = arrData.filter({$0 != 2})
            } else if day == 29 {
                arrSelect = checkYear(year: year) ? arrData : arrData.filter({$0 != 2})
            } else {
                arrSelect = arrData
            }
        }
    }
    return arrSelect
}

func crashHere() {
    let arr:Array<Int> = []
    showConsole(mess: arr[0])
}

//isEndThisYear: true = Nam hien tai la nam cuoi cua mang, false: Nam hien tai la nam giua
//numberYear: So nam se lay
func getArrDataYear(numberYear:Int, isEndThisYear:Bool = true) -> Array<Int> {
    var arrResult:Array<Int> = []
    let year = getYear()
    let startYear = isEndThisYear ? year - numberYear : year - numberYear / 2 - 1
    for y in 1 ... numberYear {
        arrResult.append(startYear + y)
    }
    return arrResult
}

func generateBoundaryString() -> String
{
    return "Boundary-\(NSUUID().uuidString)"
}

func getTime() -> String{
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let second = calendar.component(.second, from: date)
    let nano = calendar.component(.nanosecond, from: date)
    return "\(hour)-\(minutes)-\(second)-\(nano)"
}
func getDate(isLog:Bool=false)->String{
    let date = Date()
    let calendar = Calendar.current
    let d = calendar.component(.day, from: date)
    let m = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let h = calendar.component(.hour, from: date)
    let mi = calendar.component(.minute, from: date)
    let s = calendar.component(.second, from: date)
    let day = d < 10 ? "0\(d)" : "\(d)"
    let month = m < 10 ? "0\(m)" : "\(m)"
    let hour = h < 10 ? "0\(h)" : "\(h)"
    let minutes = mi < 10 ? "0\(mi)" : "\(mi)"
    let second = s < 10 ? "0\(s)" : "\(s)"
    return !isLog ? "\(day)/\(month)/\(year) \(hour):\(minutes)" : "\(hour):\(minutes):\(second) \(day)/\(month)/\(year)"
}

func getDate(separate:String)->String{
    let date = Date()
    let calendar = Calendar.current
    let d = calendar.component(.day, from: date)
    let m = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let h = calendar.component(.hour, from: date)
    let mi = calendar.component(.minute, from: date)
    let s = calendar.component(.second, from: date)
    let day = d < 10 ? "0\(d)" : "\(d)"
    let month = m < 10 ? "0\(m)" : "\(m)"
    let hour = h < 10 ? "0\(h)" : "\(h)"
    let minutes = mi < 10 ? "0\(mi)" : "\(mi)"
    let second = s < 10 ? "0\(s)" : "\(s)"
    return "\(hour)\(minutes)\(second)\(separate)\(day)\(month)\(year)"
}

func getDateForFileChat()->String{
    let date = Date()
    let calendar = Calendar.current
    let d = calendar.component(.day, from: date)
    let m = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let h = calendar.component(.hour, from: date)
    let mi = calendar.component(.minute, from: date)
    let s = calendar.component(.second, from: date)
    let day = d < 10 ? "0\(d)" : "\(d)"
    let month = m < 10 ? "0\(m)" : "\(m)"
    let hour = h < 10 ? "0\(h)" : "\(h)"
    let minutes = mi < 10 ? "0\(mi)" : "\(mi)"
    let second = s < 10 ? "0\(s)" : "\(s)"
    return "\(year)\(month)\(day)\(hour)\(minutes)\(second)"
    
}

func getDateOnly() -> String {
    let date = Date()
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let dayStr = day < 10 ? "0\(day)" : "\(day)"
    let monthStr = month < 10 ? "0\(month)" : "\(month)"
    return "\(dayStr)/\(monthStr)/\(year)"
}

func getTimeOnly(isFull:Bool=false) -> String {
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let hourStr = hour < 10 ? "0\(hour)" : "\(hour)"
    let minStr = minutes < 10 ? "0\(minutes)" : "\(minutes)"
    if isFull {
        let sec = calendar.component(.second, from: date)
        let secStr = sec < 10 ? "0\(sec)" : "\(sec)"
        return "\(hourStr):\(minStr):\(secStr)"
    } else {
        return "\(hourStr):\(minStr)"
    }
}

func getHour() -> String {
    let date = Date()
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let hourStr = hour < 10 ? "0\(hour)" : "\(hour)"
    return "\(hourStr)"
}

func getMinutes() -> String {
    let date = Date()
    let calendar = Calendar.current
    let minute = calendar.component(.minute, from: date)
    let minuteStr = minute < 10 ? "0\(minute)" : "\(minute)"
    return "\(minuteStr)"
}

func getYear()-> Int {
    let date = Date()
    let calendar = Calendar.current
    return calendar.component(.year, from: date)
}

func getMonth()-> Int {
    let date = Date()
    let calendar = Calendar.current
    return calendar.component(.month, from: date)
}

func getDay()-> Int {
    let date = Date()
    let calendar = Calendar.current
    return calendar.component(.day, from: date)
}

func createDay(day:Int, month:Int, year:Int) -> String {
    var strDate = "\(year)"
    strDate = month < 10 ? "0\(month)/" + strDate : "\(month)/" + strDate
    strDate = day < 10 ? "0\(day)/" + strDate : "\(day)/" + strDate
    return strDate
}

func isValidDate(dateVNFormat:String, currentDateFormDB:String?=nil,dayAdjust:Int=0) -> Bool {
    var dateCurrent = Date()
    let dateFormatter = DateFormatter()
    if let currentDateFormDB = currentDateFormDB {
        if currentDateFormDB != "" {
            dateFormatter.dateFormat = "yyyy-MM-dd" //Your date format
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+0:00") //Current time zone
            dateCurrent = dateFormatter.date(from: currentDateFormDB)!
        }
    }
    
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let date = dateFormatter.date(from: dateVNFormat)!
    let dateCur = Calendar.current.date(byAdding: .day, value: dayAdjust, to: dateCurrent)!
    return date >= dateCur
}

func isPastDate(dateVNFormat:String,currentMySQL:String? = nil) -> Bool {
    let y1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 2, isFromMySQLDB: true) : getYear()
    let m1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 1, isFromMySQLDB: true) : getMonth()
    let d1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 0, isFromMySQLDB: true) : getDay()
    let year = getDMYFormString(strDate: dateVNFormat, kind: 2, isFromMySQLDB: false)
    let month = getDMYFormString(strDate: dateVNFormat, kind: 1, isFromMySQLDB: false)
    let day = getDMYFormString(strDate: dateVNFormat, kind: 0, isFromMySQLDB: false)
    if year < y1 {
        return true
    } else if year == y1 {
        if month < m1 {
            return true
        } else if month > m1 {
            return false
        } else {
            return day < d1
        }
    } else {
        return false
    }
}

func isPastDate(day:Int, month:Int, year:Int,currentMySQL:String? = nil) -> Bool {
    let y1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 2, isFromMySQLDB: true) : getYear()
    let m1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 1, isFromMySQLDB: true) : getMonth()
    let d1 = currentMySQL != nil ? getDMYFormString(strDate: currentMySQL!, kind: 0, isFromMySQLDB: true) : getDay()
    if year < y1 {
        return true
    } else if year == y1 {
        if month < m1 {
            return true
        } else if month > m1 {
            return false
        } else {
            return day < d1
        }
    } else {
        return false
    }
}

//func isPastDate(day:Int, month:Int, year:Int) -> Bool {
//    let y1 = getYear()
//    let m1 = getMonth()
//    let d1 = getDay()
//    if year < y1 {
//        return true
//    } else if year == y1 {
//        if month < m1 {
//            return true
//        } else if month > m1 {
//            return false
//        } else {
//            return day < d1
//        }
//    } else {
//        return false
//    }
//}

func createDate(day:Int, month:Int, year:Int) -> Date? {
    var c = DateComponents()
    c.year = year
    c.month = month
    c.day = day + 1
    return Calendar(identifier: .gregorian).date(from: c)
}
//kind = 0: ngay, 1: thang , 2: nam
func getDMYFormString(strDate:String,kind:Int=0,isFromMySQLDB:Bool = false) -> Int {
    if isFromMySQLDB {
        let arr = strDate.components(separatedBy: "-")
        return Int (arr[2 - kind])!
    } else {
        if checkValidDate(strDate: strDate) {
            let arr = strDate.components(separatedBy: "/")
            return Int (arr[kind])!
        }
    }
    return 0
}

func getDayOfWeek(_ today:String) -> Int? {
    let formatter  = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    guard let todayDate = formatter.date(from: today) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    return weekDay
}

func checkYear(year:Int) ->Bool {
    return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
}

func convertHexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

func convertTimeToDateString(time:UInt64,dateFormat:String,isTicket:Bool=false) -> String {
    let div:UInt64 = isTicket ? 1 : 1000
    let date = Date(timeIntervalSince1970: TimeInterval(time/div))
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current//Set timezone that you want
    dateFormatter.locale = NSLocale.current
    dateFormatter.dateFormat = dateFormat //Specify your format that you want
    return dateFormatter.string(from: date)
}



func convertDoubleToString(value:Double,isHadFractionDigits:Bool=true) -> String?{
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true
    currencyFormatter.currencySymbol = ""
    currencyFormatter.numberStyle = NumberFormatter.Style.currency
    currencyFormatter.maximumFractionDigits = isHadFractionDigits ? 2 : 0
    currencyFormatter.roundingMode = .ceiling
    // localize to your grouping and decimal separator
    currencyFormatter.locale = NSLocale.current
    if let result = currencyFormatter.string(from: NSNumber(value: value)) {
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return nil
}

func showPrice(gia:Double, giamgia:Double = 0)->NSMutableAttributedString{
    let giagoc:Double = giamgia + gia
    let gg = showVNCurrency(gia: giagoc)
    let result:NSMutableAttributedString = NSMutableAttributedString(string: gg)
    result.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, result.length))
    return result
}

func showVNCurrency(gia:Double) -> String {
    var giamoi:Int64 = Int64 (gia)
    var result:String = ""
    while giamoi >= 1000 {
        let du = showNumber (so: giamoi % 1000)
        if result != "" {
            result = "\(du).\(result)"
        } else {
            result = "\(du)"
        }
        
        giamoi = giamoi / 1000
    }
    result = "\(giamoi).\(result)"
    return result
}
func showNumber(so:Int64)->String {
    var kq:String = ""
    if so < 10 {
        kq =  "00\(so)"
    } else if so < 100 {
        kq = "0\(so)"
    } else {
        kq = "\(so)"
    }
    return kq
}

func fileInDocumentsDirectory(filename: String) -> String {
    let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    return "\(documentsFolderPath)\(filename)"
}

func getFileDocumentDirecttory(fileName includeExtention:String) -> Data? {
    do {
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let file = docDir.appendingPathComponent(includeExtention)
        if file.isFileURL {
            do {
                return try Data(contentsOf: file)
            } catch {
                return nil
            }
        }
        return nil
    } catch {
        return nil
    }
}

func deleteFileDocumentDirectory(includeExtention fileName:String) -> Bool {
    do {
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = docDir.appendingPathComponent(fileName)
        if url.isFileURL {
            do {
                try FileManager.default.removeItem(at: url)
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    } catch {
        return false
    }
}

func saveFileDocumentDirectory(data:Data, fileFullName includeExtention:String) -> Bool{
    //Luu shape
    do {
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = docDir.appendingPathComponent(includeExtention)
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    } catch {
        return false
    }
}



func saveImageDocumentDirectory(image:UIImage, fileName:String, type:String = "png", rate:CGFloat = 1) ->Bool{
    //Luu shape
    do {
        let docDir = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let imageURL = docDir.appendingPathComponent(fileName)
        let imgData = type.lowercased() == "png" ? image.pngData()! : image.jpegData(compressionQuality: rate)!
        do {
            try imgData.write(to: imageURL)
            return true
        } catch {
            return false
        }
    } catch {
        return false
    }
}

func convertStringToDate(date:String,isVNFormat:Bool=false) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = !isVNFormat ? "yyyy-MM-dd" : "dd/MM/yyyy";
    return dateFormatter.date(from: date)
}

func convertDateToString(date:Date,isVNFormat:Bool=true) -> String {
    let calendar = Calendar.current
    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    let dayStr = day < 10 ? "0\(day)" : "\(day)"
    let monthStr = month < 10 ? "0\(month)" : "\(month)"
    return isVNFormat ? "\(dayStr)/\(monthStr)/\(year)" : "\(year)-\(monthStr)-\(dayStr)"
}

func getDateAdjust(dayAjust:Int,date:String = getDateOnly()) -> Date? {
    if let to = convertStringToDate(date: date) {
        return Calendar.current.date(byAdding: .day, value: dayAjust, to: to)
    }
    return nil
}

func getDaysBetween2Dates(fromDate:UInt64,toDate:Date=Date()) -> Int? {
    let calendar = NSCalendar.current
    let date = Date(timeIntervalSince1970: TimeInterval(fromDate))
    let date1 = calendar.startOfDay(for: date)
    let date2 = calendar.startOfDay(for: toDate)
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    return components.day
}
func getDaysBetween2Dates(fromDate:Date,toDate:Date=Date()) -> Int? {
    let calendar = NSCalendar.current
    let date1 = calendar.startOfDay(for: fromDate)
    let date2 = calendar.startOfDay(for: toDate)
    let components = calendar.dateComponents([.day], from: date1, to: date2)
    return components.day
}

// date: 2019-03-19 -> 19 Mar, 2019
func getStandardDate(date:String) -> String {
    if !date.isEmpty {
        if let sub = getSubString(str: date, find: " ", isGetBegin: true) {
            let arr = sub.split(separator: "-")
            let month = getStandardMonth(month: String(arr[1]))
            return "\(arr[2]) \(month), \(arr[0])"
        }
    }
    return ""
}

func getStandardMonth(month:String) -> String {
    switch month {
    case "01":
        return "Jan"
    case "02":
        return "Feb"
    case "03":
        return "Mar"
    case "04":
        return "Apr"
    case "05":
        return "May"
    case "06":
        return "Jun"
    case "07":
        return "Jul"
    case "08":
        return "Aug"
    case "09":
        return "Sep"
    case "10":
        return "Oct"
    case "11":
        return "Nov"
    default:
        return "Dec"
    }
}

func parseJson(body:Any) -> Dictionary<String,Any>? {
    if let objStr = body as? String {
        //step 2: convert the string to Data
        let data: Data = objStr.data(using: .utf8)!
        do {
            if let jsObj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) as? Dictionary<String, Any> {
                return jsObj
            }
        } catch _ {
            print("having trouble converting it to a dictionary")
        }
    }
    //    if let jsonArr = jsObj as? [Dictionary<String, Any>] {
    //        for jsonObj in jsonArr {
    //            let hPrice = HousePrice(dict: jsonObj)
    //            housePrices.append(hPrice)
    //        }
    //    }
    return nil
}

func parse(valueOfkey:Any?)->Int {
    var result = 0
    if let tem = (valueOfkey as? NSString)?.integerValue {
        result = tem
    }
    if result == 0 {
        if let tem = valueOfkey as? Int {
            result = tem
        }
    }
    return result
}

func parse(valueOfkey:Any?)->Int32 {
    var result:Int32 = 0
    if let tem = (valueOfkey as? NSString)?.intValue {
        result = tem
    }
    if result == 0 {
        if let tem = valueOfkey as? Int32 {
            result = tem
        }
    }
    return result
}

func parse(valueOfkey:Any?)->Int64 {
    var result:Int64 = 0
    if let tem = (valueOfkey as? NSString)?.integerValue {
        result = Int64 (tem)
    }
    if result == 0 {
        if let tem = valueOfkey as? Int64 {
            result = tem
        }
    }
    return result
}

func parse(valueOfkey:Any?)->UInt64 {
    var result:UInt64 = 0
    if let tem = (valueOfkey as? NSString)?.integerValue {
        result = UInt64 (tem)
    }
    if result == 0 {
        if let tem = valueOfkey as? UInt64 {
            result = tem
        }
    }
    return result
}
func parse(valueOfkey:Any?)->Double {
    var result:Double = 0
    if let tem = (valueOfkey as? NSString)?.doubleValue {
        result = tem
    }
    if result == 0 {
        if let tem = valueOfkey as? Double {
            result = tem
        }
    }
    return result
}

func parse(valueOfkey:Any?)->CGFloat {
    var result:CGFloat = 0
    if let tem = (valueOfkey as? NSString)?.floatValue {
        result = CGFloat(tem)
    }
    if result == 0 {
        if let tem = valueOfkey as? CGFloat {
            result = CGFloat(tem)
        }
    }
    return result
}

func parse(valueOfkey:Any?)->String {
    if let imgStr = valueOfkey as? String {
        return imgStr
    } else {
        return ""
    }
}

func parseExtra(extraLink:Any?) -> String {
    if let str = extraLink as? String {
        return str
    } else if let arr = extraLink as? Array<String> {
        return arr.joined(separator: "/")
    } else {
        return ""
    }
}

func decodeBase64(base64Encoded:String) -> String? {
    let decodedData = Data(base64Encoded: base64Encoded)!
    return String(data: decodedData, encoding: .utf8)
}

func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
    let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    return (rand) * (to - from) + from
}

func randomInt(min:Int, max:Int) -> Int {
    return Int(arc4random_uniform(UInt32(max-min+1))) + min
}

func randomInt(_ n: Int, isHasZero:Bool=false) -> Int {
    if !isHasZero {
        var i = Int(arc4random_uniform(UInt32(n+1)))
        while i == 0 {
            i = Int(arc4random_uniform(UInt32(n+1)))
        }
        return i
    } else {
        return Int(arc4random_uniform(UInt32(n)))
    }
}

func getImageDocumentDirectory(file:String) -> UIImage {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    let url = NSURL(fileURLWithPath: path)
    let filePath = url.appendingPathComponent(file)?.path
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath!) {
        return UIImage(contentsOfFile: filePath!)!
    } else {
        print("FILE NOT FOUND")
    }
    return UIImage()
}

