//
//  BootpayBio.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/17.
//

import SwiftUI
import Foundation
import WebKit
import Bootpay


@objc public class BootpayBio: NSObject {
    @objc public static let sharedBio = BootpayBio()
    var showBootpay: Binding<Bool>?
    
    public var uuid = ""
    let ver = BootpayBuildConfig.VERSION
    var sk = ""
    var sk_time = 0 // session 유지시간 기본 30분
    var last_time = 0 // 접속 종료 시간
    var time = 0 // 미접속 시간
    var key = ""
    var iv = ""
    var selectedCardQuota = -1
    
    var applicationId: String? // 통계를 위한 파라미터
//    public var ENV_TYPE = BootpayConstants.ENV_SWIFT
    
    var requestType = BioConstants.REQUEST_TYPE_NONE
    var walletList: [WalletData] = []
    
    
    var bioPayload: BootBioPayload?
    var bioVc: BootpayBioController?
    var bioUIModal: BootpayBioUI?
    
    
    @objc public var error: (([String : Any]) -> Void)?
    @objc public var issued: (([String : Any]) -> Void)?
    @objc public var confirm: (([String : Any]) -> Bool)?
    @objc public var cancel: (([String : Any]) -> Void)?
    @objc public var done: (([String : Any]) -> Void)?
    @objc public var close: (() -> Void)?
//    @objc public var easyCancel: (([String : Any]) -> Void)?
    
//    @objc public var easyError: (([String : Any]) -> Void)?
//    @objc public var easySuccess: (([String : Any]) -> Void)?
    
    public func debounceClose() {
        DispatchQueue.main.asyncDeduped(target: self, after: 0.25) { [] in
            BootpayBio.sharedBio.close?()
            
            BootpayBio.sharedBio.error = nil
            BootpayBio.sharedBio.issued = nil
            BootpayBio.sharedBio.close = nil
            BootpayBio.sharedBio.confirm = nil
            BootpayBio.sharedBio.done = nil
            BootpayBio.sharedBio.cancel = nil
//             self?.findPlaces()
        }
        
    }
    
    
    public override init() {
        super.init()
        self.key = getRandomKey(32)
        self.iv = getRandomKey(16)
    }
    
    @objc(requestBioPayment::::)
    public static func requestBioPayment(viewController: UIViewController,
                                      payload: BootBioPayload,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> BootpayBio.Type {
        
        return presentBootpayController(
            payload: payload,
            isPasswordMode: false,
            animated: animated,
            viewController: viewController,
            modalPresentationStyle: modalPresentationStyle
        )
    }
    
    
    @objc(requestUIPasswordPayment::::)
    public static func requestUIPasswordPayment(viewController: UIViewController,
                                      payload: BootBioPayload,
                                      animated: Bool = true,
                                      modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> BootpayBio.Type {
        
        return presentBootpayController(
            payload: payload,
            isPasswordMode: true,
            animated: animated,
            viewController: viewController,
            modalPresentationStyle: modalPresentationStyle
        )
    }
    
    
    fileprivate static func presentBootpayController(payload: BootBioPayload, isPasswordMode: Bool, animated: Bool, viewController: UIViewController, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> BootpayBio.Type {
        sharedBio.bioVc = BootpayBioController()
        sharedBio.bioPayload = payload
        sharedBio.bioVc?.bioWebView.payload = payload
        sharedBio.bioPayload?.isPasswordMode = isPasswordMode
        
        if(modalPresentationStyle == .fullScreen) {
            viewController.navigationController?.pushViewController(sharedBio.bioVc!, animated: animated)
        } else {
            sharedBio.bioVc!.modalPresentationStyle = modalPresentationStyle //or .overFullScreen for transparency
            viewController.present(sharedBio.bioVc!, animated: animated, completion: nil)
        }
        
        return self
    }
    
    
    @objc(transactionConfirmUI)
    public static func transactionConfirm() {
        print("bootpayBio transactionConfirm")
        
        if let webView = sharedBio.bioVc?.bioWebView {
//            let json = BootpayConstants.dicToJsonString(data).replace(target: "'", withString: "\\'")
//            webView.evaluateJavaScript("window.BootPay.transactionConfirm(\(json));")
            webView.transactionConfirm()
        }
    }
    
    @objc(removePaymentWindowUI)
    public static func removePaymentWindow() {
        print("removePaymentWindow")
        
        if sharedBio.bioVc != nil {
//            if(sharedBio.bioVc!.useViewController) {
//                #if os(macOS)
//                    sharedBio.bioVc!.dismiss(nil)
//                #elseif os(iOS)
//                    sharedBio.bioVc!.dismiss(animated: true, completion: nil)
//                #endif
//            } else {
//                sharedBio.bioVc?.view.removeFromSuperview()
//            }
            #if os(macOS)
                sharedBio.bioVc!.dismiss(nil)
            #elseif os(iOS)
                sharedBio.bioVc!.dismiss(animated: true, completion: nil)
            #endif
            sharedBio.bioVc!.navigationController?.popViewController(animated: true)
//            sharedBio.bioVc?.view.removeFromSuperview()
            sharedBio.bioVc = nil
        }
        
        if sharedBio.showBootpay != nil {
//            print("presentationMode dismiss")
            sharedBio.showBootpay?.wrappedValue = false
//            sharedBio.bioUIModal?.presentationMode.wrappedValue.dismiss()
            
        }
         
        sharedBio.bioPayload = BootBioPayload()
        
        
        sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
        sharedBio.walletList = []
        
//        sharedBio.error = nil
//        sharedBio.issued = nil
//        sharedBio.close = nil
//        sharedBio.confirm = nil
//        sharedBio.done = nil
//        sharedBio.cancel = nil
    }
    
    
    public static func goConfirm(_ data: [String : Any]) {
        if let confirm = sharedBio.confirm {
            if(confirm(data)) {
                transactionConfirm()
            } else {
                removePaymentWindow()
            }
        }
    }
}

extension BootpayBio {
    @objc public static func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
        sharedBio.error = action
        return self
    }

    @objc public static func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
        sharedBio.issued = action
        return self
    }
    
    @objc public static func onClose(_ action: @escaping () -> Void) -> Void {
        sharedBio.close = action
    }
    
    @objc public static func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBio.Type {
        sharedBio.confirm = action
        return self
    }
    
    @objc public static func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
        sharedBio.cancel = action
        return self
    }
    
    @objc public static func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
        sharedBio.done = action
        return self
    }
    
    
    
//    @objc public static func onEasyError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
//        sharedBio.easyError = action
//        return self
//    }
    
//    @objc public static func onEasyCancel(_ action: @escaping ([String : Any]) -> Void) -> Bootpay.Type {
//        shared.easyCancel = action
//        return self
//    }
    
//    @objc public static func onEasySuccess(_ action: @escaping ([String : Any]) -> Void) -> BootpayBio.Type {
//        sharedBio.easySuccess = action
//        return self
//    }
}

extension BootpayBio {
    public static func getUUId() -> String {
        if sharedBio.uuid == "" { sharedBio.uuid = BootpayDefaultHelper.getString(key: "uuid") }
        return sharedBio.uuid
    }
    
    public static func getSk() -> String {
        if sharedBio.sk == "" { return BootpayDefaultHelper.getString(key: "sk") }
        return sharedBio.sk
    }
    
    public static func getSkTime() -> Int {
        if sharedBio.sk_time == 0 { return BootpayDefaultHelper.getInt(key: "sk_time") }
        return sharedBio.sk_time
    }
    
    public static func loadSessionValues() {
        loadUuid()
        loadSkTime()
    }
    
    @objc public static func getUUID() -> String {
        var uuid = BootpayDefaultHelper.getString(key: "uuid")
        if uuid == "" {
            uuid = UUID().uuidString
            BootpayDefaultHelper.setValue("uuid", value: uuid)
        }
        return uuid
    }
     
    
    fileprivate static func loadUuid() {
        sharedBio.uuid = BootpayDefaultHelper.getString(key: "uuid")
        if sharedBio.uuid == "" {
            sharedBio.uuid = UUID().uuidString
            BootpayDefaultHelper.setValue("uuid", value: sharedBio.uuid)
        }
    }
    
    
    fileprivate static func loadLastTime() {
        sharedBio.last_time = BootpayDefaultHelper.getInt(key: "last_time")
    }
    
    fileprivate static func loadSkTime() {
        func updateSkTime(time: Int) {
            sharedBio.sk_time = time
            sharedBio.sk = "\(sharedBio.uuid)_\(sharedBio.sk_time)"
            BootpayDefaultHelper.setValue("sk", value: sharedBio.sk)
            BootpayDefaultHelper.setValue("sk_time", value: sharedBio.sk_time)
        }
        
        loadLastTime()
        let currentTime = currentTimeInMiliseconds()
        if sharedBio.last_time != 0 && Swift.abs(sharedBio.last_time - currentTime) >= 30 * 60 * 1000 {
            sharedBio.time = currentTime - sharedBio.last_time
            sharedBio.last_time = currentTime
            BootpayDefaultHelper.setValue("time", value: sharedBio.time)
            BootpayDefaultHelper.setValue("last_time", value: sharedBio.last_time)
            updateSkTime(time: currentTime)
        } else if sharedBio.sk_time == 0 {
            updateSkTime(time: currentTime)
        }
    }
    
    fileprivate static func currentTimeInMiliseconds() -> Int {
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
    
    fileprivate func getRandomKey(_ size: Int) -> String {
        let keys = "abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var result = ""
        for _ in 0..<size {
            let ran = Int(arc4random_uniform(UInt32(keys.count)))
            let index = keys.index(keys.startIndex, offsetBy: ran)
            result += String(keys[index])
        }
        return result
    }
        
    static func getSessionKey() -> String {
        return "\(sharedBio.key.toBase64())##\(sharedBio.iv.toBase64())"
    }
    
    static func stringify(_ json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
}
