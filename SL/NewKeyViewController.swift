//
//  NewKeyViewController.swift
//  SL
//
//  Created by Трифон Шейкин on 26/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import SQLite
import CryptoSwift

class NewKeyViewController: UIViewController, QRCodeReaderViewControllerDelegate, UITextViewDelegate  {
    
    var database: Connection!
    var key1: Key!
    var key2: Key!
    var ipAddrDoorId = [[UInt8]]()
    var keys = [Key]()
    var accessCodeType: Int = 0
    let ONE_LOCK: Int = 1
    let MULTIPLE_LOCKS: Int = 2
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var resultOfScan: UILabel!
    @IBOutlet weak var resultOfScan2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "Color")
        textView.delegate = self
        resultOfScan.text = ""
        resultOfScan2.text = ""
        textView.text = "Paste your access code or scan QR-code"
 
        //let dataStore = SQLiteDataStore.sharedInstance
        
        
        //textView.text = "q"
        // Do any additional setup after loading the view.
    }
    
    
    
    
    @IBAction func onSave(_ sender: Any) {
        if accessCodeType == ONE_LOCK{
            do {
                let oldKey1 = try KeyDataHelper.findByDoorId(doorId: key1.doorIdString!)
                if(oldKey1 != nil){
                    key1.rowId = oldKey1?.rowId
                    key1.keyTitle = oldKey1?.keyTitle
                    do {try KeyDataHelper.update(item: key1)}
                    catch{}
                }else{
                    do {
                        try KeyDataHelper.insert(
                            item: key1)
                    } catch _ {}
                }
            }catch{}
            
            do {
                let oldKey2 = try KeyDataHelper.findByDoorId(doorId: key2.doorIdString!)
                if(oldKey2 != nil){
                    key2.rowId = oldKey2?.rowId
                    key2.keyTitle = oldKey2?.keyTitle
                    do {try KeyDataHelper.update(item: key2)}
                    catch{}
                }else{
                    do {
                        try KeyDataHelper.insert(
                            item: key2)
                    } catch _ {}
                }
            }catch{}

        }else if accessCodeType == MULTIPLE_LOCKS {
            do {
                let oldKey1 = try KeyDataHelper.findByDoorId(doorId: key1.doorIdString!)
                if(oldKey1 != nil){
                    key1.rowId = oldKey1?.rowId
                    key1.keyTitle = oldKey1?.keyTitle
                    do {try KeyDataHelper.update(item: key1)}
                    catch{}
                }else{
                    do {
                        try KeyDataHelper.insert(
                            item: key1)
                    } catch _ {}
                }
            }catch{}
            
            do {
                let oldKey2 = try KeyDataHelper.findByDoorId(doorId: key2.doorIdString!)
                if(oldKey2 != nil){
                    key2.rowId = oldKey2?.rowId
                    key2.keyTitle = oldKey2?.keyTitle
                    do {try KeyDataHelper.update(item: key2)}
                    catch{}
                }else{
                    do {
                        try KeyDataHelper.insert(
                            item: key2)
                    } catch _ {}
                }
            }catch{}
            
            for k in keys {
                do {
                    let oldKey2 = try KeyDataHelper.findByDoorId(doorId: k.doorIdString!)
                    if(oldKey2 != nil){
                        var newK = k
                        newK.rowId = oldKey2?.rowId
                        newK.keyTitle = oldKey2?.keyTitle
                        do {try KeyDataHelper.update(item: newK)}
                        catch{}
                    }else{
                        do {
                            try KeyDataHelper.insert(
                                item: k)
                        } catch _ {}
                    }
                }catch{}
             
                
                
            }
        }
        
        
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pasteFromClipboard(_ sender: Any) {
        
        let pb: UIPasteboard = UIPasteboard.general;
        textView.text = pb.string
        if textView.text != ""{
            checkEnteredText(text: textView.text)
        }
        
       
        
    }
    
    
    @IBAction func onClear(_ sender: Any) {
        textView.text = "Paste your access code or scan QR-code"
        resultOfScan.text = ""
        resultOfScan2.text = ""
    }
    
    
    
    func textViewDidChange(_ textView: UITextView) { //HandletextViewDidChange
       
        checkEnteredText(text: textView.text)

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    
    @IBAction func onScan(_ sender: Any) {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
   
    // MARK: - QRCodeReaderViewController Delegate Methods
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        textView.text = result.value
        checkEnteredText(text: result.value)
    
        dismiss(animated: true, completion: nil)
    }
    
    
    func checkEnteredText(text: String){
       
            if getKeysFromAccessCode(accessCode: text){
                resultOfScan.text = "Key 1: " + accessTimeByteToStr(bytes: key1.startDoorTime!) + " - " + accessTimeByteToStr(bytes: key1.stopDoorTime!)
                resultOfScan2.text = "Key 2: " + accessTimeByteToStr(bytes: key2.startDoorTime!) + " - " + accessTimeByteToStr(bytes: key2.stopDoorTime!)
                saveButton.isEnabled = true
                saveButton.isSelected = true
                
            }else{
                saveButton.isEnabled = false
                saveButton.isSelected = false
                resultOfScan.text = "Error in access code"
                resultOfScan2.text = ""
            }
    }
    

    
    /* return new String("Door 1 access time:"+
     "\nFrom: " + accessTimeByteToStr(door1StartTime) +
     "\n     To: " + accessTimeByteToStr(door1StopTime) +
     "\n\nDoor 2 access time:"+
     "\nFrom: " + accessTimeByteToStr(door2StartTime) +
     "\n     To: " + accessTimeByteToStr(door2StopTime));
     */
    func getKeysFromAccessCode(accessCode: String) -> Bool{
        let accessBytes = (accessCode.fromBase64() ?? nil)!
        if xorOk(input: accessBytes) == false {
            return false
        }
        accessCodeType = 0
        if accessBytes.count == 78 {
            accessCodeType = ONE_LOCK
            var userAes = [UInt8] (accessBytes[0..<16])
            userAes.append(contentsOf: accessBytes[0..<16])
            let userId = [UInt8] (accessBytes[0..<4])
            let secretWord = [UInt8] (accessBytes[16..<48])
            let ipAddr = [UInt8] (accessBytes[48..<52])
            let ipStr = ipByteToStr(ip: ipAddr)
            let door1Id = [UInt8] (accessBytes[52..<56])
            var door2Id = [UInt8] (accessBytes[52..<56])
            door2Id[3] = door2Id[3] + 1
            let door1Str = byteArrayToBase64Str(input: door1Id)
            let door2Str = byteArrayToBase64Str(input: door2Id)
            let userTag = Int64(accessBytes[56])
            let door1StartTime = [UInt8] (accessBytes[57..<62])
            let door1StopTime = [UInt8] (accessBytes[62..<67])
            let door2StartTime = [UInt8] (accessBytes[67..<72])
            let door2StopTime = [UInt8] (accessBytes[72..<77])
            
            key1 = Key(rowId: 0,
                                       keyTitle: "Key 1",
                                       aesKey: Blob(bytes: userAes),
                                       ipAddress: ipStr,
                                       doorIdString: door1Str,
                                       doorIdOfBro: door2Str,
                                       userId: Blob(bytes: userId),
                                       userTag: userTag,
                                       startDoorTime: Blob(bytes: door1StartTime),
                                       stopDoorTime: Blob(bytes: door1StopTime),
                                       accessPointSsid: "",
                                       acActivated: 0,
                                       acSecretWord: Blob(bytes: secretWord))
                                       

            key2 = Key(rowId: 0,
                                       keyTitle: "Key 2",
                                       aesKey: Blob(bytes: userAes),
                                       ipAddress: ipStr,
                                       doorIdString: door2Str,
                                       doorIdOfBro: door1Str,
                                       userId: Blob(bytes: userId),
                                       userTag: userTag,
                                       startDoorTime: Blob(bytes: door2StartTime),
                                       stopDoorTime: Blob(bytes: door2StopTime),
                                       accessPointSsid: "",
                                       acActivated: 0,
                                       acSecretWord: Blob(bytes: secretWord))
            return true
        }else if (accessBytes.count - 47) % 8 == 0{
            accessCodeType = MULTIPLE_LOCKS
            var userAes = [UInt8] (accessBytes[0..<16])
            userAes.append(contentsOf: accessBytes[0..<16])
            let userId = [UInt8] (accessBytes[0..<4])
            let secretWord = [UInt8] (accessBytes[16..<32])
            let doorStopTime = [UInt8] (accessBytes[33..<38])
            let doorStartTime = getCurrentTime()
            let ipAddr = [UInt8] (accessBytes[38..<42])
            let ipStr = ipByteToStr(ip: ipAddr)
            let door1Id = [UInt8] (accessBytes[42..<46])
            var door2Id = [UInt8] (accessBytes[42..<46])
            door2Id[3] = door2Id[3] + 1
            let door1Str = byteArrayToBase64Str(input: door1Id)
            let door2Str = byteArrayToBase64Str(input: door2Id)
            let userTag = Int64(accessBytes[32])
            ipAddrDoorId.removeAll()
            for i in stride(from: 46, to: accessBytes.count - 1, by: 8) {
                let ipId = [UInt8] (accessBytes[i...i+8])
                ipAddrDoorId.append(ipId)
            }
            
            key1 = Key(rowId: 0,
                                       keyTitle: "Key 1",
                                       aesKey: Blob(bytes: userAes),
                                       ipAddress: ipStr,
                                       doorIdString: door1Str,
                                       doorIdOfBro: door2Str,
                                       userId: Blob(bytes: userId),
                                       userTag: userTag,
                                       startDoorTime: Blob(bytes: doorStartTime),
                                       stopDoorTime: Blob(bytes: doorStopTime),
                                       accessPointSsid: "",
                                       acActivated: 2,
                                       acSecretWord: Blob(bytes: secretWord))
                                       

            key2 = Key(rowId: 0,
                                       keyTitle: "Key 2",
                                       aesKey: Blob(bytes: userAes),
                                       ipAddress: ipStr,
                                       doorIdString: door2Str,
                                       doorIdOfBro: door1Str,
                                       userId: Blob(bytes: userId),
                                       userTag: userTag,
                                       startDoorTime: Blob(bytes: doorStartTime),
                                       stopDoorTime: Blob(bytes: doorStopTime),
                                       accessPointSsid: "",
                                       acActivated: 2,
                                       acSecretWord: Blob(bytes: secretWord))
            
            keys.removeAll()
            for ipId in ipAddrDoorId {
                var i: Int = 2;
                let ip = [UInt8] (ipId[0..<4])
                let ips = ipByteToStr(ip: ip)
                let d1Id = [UInt8] (ipId[4..<8])
                var d2Id = [UInt8] (ipId[4..<8])
                d2Id[3] = d2Id[3] + 1
                let d1Str = byteArrayToBase64Str(input: d1Id)
                let d2Str = byteArrayToBase64Str(input: d2Id)
                let uTag: Int64 = 10;
                i += 1
                let addkey1 = Key(rowId: 0,
                               keyTitle: "Key \(i)",
                                 aesKey: Blob(bytes: userAes),
                              ipAddress: ips,
                           doorIdString: d1Str,
                            doorIdOfBro: d2Str,
                                 userId: Blob(bytes: userId),
                                userTag: uTag,
                          startDoorTime: Blob(bytes: doorStartTime),
                           stopDoorTime: Blob(bytes: doorStopTime),
                        accessPointSsid: "",
                            acActivated: 3,
                           acSecretWord: Blob(bytes: secretWord))
                keys.append(addkey1)
                i += 1
                let addkey2 = Key(rowId: 0,
                               keyTitle: "Key \(i)",
                                 aesKey: Blob(bytes: userAes),
                              ipAddress: ips,
                           doorIdString: d2Str,
                            doorIdOfBro: d1Str,
                                 userId: Blob(bytes: userId),
                                userTag: uTag,
                          startDoorTime: Blob(bytes: doorStartTime),
                           stopDoorTime: Blob(bytes: doorStopTime),
                        accessPointSsid: "",
                            acActivated: 3,
                           acSecretWord: Blob(bytes: secretWord))
                keys.append(addkey2)
                                
            }
            return true
        }
        return false
    }
    
    func getCurrentTime() -> [UInt8]{
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)

        var output: [UInt8] = []
        var tempX_: UInt8
        var temp_X: UInt8

        temp_X = UInt8(year % 10)
        tempX_ = UInt8((year / 10 % 10) << 4)
        output.append(UInt8(tempX_ | temp_X))

        temp_X = UInt8(month % 10)
        tempX_ = UInt8((month / 10 % 10) << 4)
        output.append(UInt8(tempX_ | temp_X))

        temp_X = UInt8(day % 10)
        tempX_ = UInt8((day / 10 % 10) << 4)
        output.append(UInt8(tempX_ | temp_X))

        temp_X = UInt8(hour % 10)
        tempX_ = UInt8((hour / 10 % 10) << 4)
        output.append(UInt8(tempX_ | temp_X))

        temp_X = UInt8(minute % 10)
        tempX_ = UInt8((minute / 10 % 10) << 4)
        output.append(UInt8(tempX_ | temp_X))
        
        return output
    }
  
    
    
    func accessTimeByteToStr(bytes: Blob) -> String{
        let string: String = bytes.toHex()
        //var hour, minute, day, month,
        var year :String = ""
        var month :String = ""
        var day :String = ""
        var minute :String = ""
        var hour :String = ""
        var i:Int = 0
        for char in string{
            if i == 0 || i == 1{
                year.append(contentsOf: String(char))
            }else if i == 2 || i == 3 {
                month.append(contentsOf: String(char))
            }else if i == 4 || i == 5 {
                day.append(contentsOf: String(char))
            }else if i == 6 || i == 7 {
                hour.append(contentsOf: String(char))
            }else if i == 8 || i == 9 {
                minute.append(contentsOf: String(char))
            }
            i += 1
        }
        return String(hour + ":" + minute + " " + day + "/" + month + "/" + year)
    }
    
    func ipByteToStr(ip: [UInt8]) -> String{
        var output: String = ""
        for i in 0..<ip.count {
            output = output + String(ip[i])
            if i != 3 {output = output + "."}
        }
        return output
    }
    
    func xorOk(input: [UInt8]) -> Bool{
        let toXor = [UInt8] (input[0..<input.count-1])
        if xorCalc(input: toXor) == input[input.count-1] {return true}
        return false
    }
    
    func xorCalc(input: [UInt8]) -> UInt8 {
        var output: UInt8 = input[0]
        for i in 1..<input.count{
            output = output ^ input[i]
        }
        return output
    }
    
    func byteArrayToBase64Str(input: [UInt8]) -> String{
        let data = NSData(bytes: input, length: input.count)
        let base64Data = data.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        let newNSString = NSString(data: base64Data as Data, encoding: String.Encoding.utf8.rawValue)!
        return newNSString as String
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }


}
extension String {
    
    func fromBase64() -> [UInt8]? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return [UInt8](data)
    }
}
