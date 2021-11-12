//
//  BootpayBioWebView.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/14.
//

import Bootpay
import WebKit


class BootpayBioWebView: BootpayWebView {
    public var requestType = BootpayBioConstants.REQUEST_TYPE_VERIFY_PASSWORD
    
    override func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name == BootpayConstants.BRIDGE_NAME) {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    Bootpay.shared.close?()
//                    Bootpay.removePaymentWindow()
                }
                return
            }
            guard let action = body["action"] as? String else { return } 
             
            if action == "BootpayCancel" {
                Bootpay.shared.cancel?(body)
            } else if action == "BootpayError" {
                Bootpay.shared.error?(body)
            } else if action == "BootpayBankReady" {
                Bootpay.shared.ready?(body)
            } else if action == "BootpayConfirm" {
                print("bio goConfirm")
                Bootpay.goConfirm(body)
            } else if action == "BootpayDone" {
                Bootpay.shared.done?(body)
            } else if action == "BootpayEasyCancel" {
                //결제수단 등록 취소
                Bootpay.shared.easyCancel?(body)
            } else if action == "BootpayEasyError" {
                //결제수단 등록 실패, 결제 요청 실패
                Bootpay.shared.easyError?(body)
            } else if action == "BootpayEasySuccess" {
                //결제수단 등록 완료
                Bootpay.shared.easySuccess?(body)
            }
        } 
    }
    
    
    func registerCard(_ bioPayload: BootBioPayload) {
        let script = BootpayBioConstants.registerCardScript(bioPayload: bioPayload)
        doJavascript(script)
    }
    
    func verifyPassword(_ bioPayload: BootBioPayload) {
        let script = BootpayBioConstants.verifyPasswordScript(self, bioPayload: bioPayload)
        doJavascript(script)
    }
    
    func changePassword(_ bioPayload: BootBioPayload) {
        let script = BootpayBioConstants.changePasswordScript(bioPayload: bioPayload)
        doJavascript(script)
    }
} 
