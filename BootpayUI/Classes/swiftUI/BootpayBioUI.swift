//////
//////  BootpayBioUI.swift
//////  BootpayUI
//////
//////  Created by Taesup Yoon on 2021/11/02.
//////
////
//
import SwiftUI

import UIKit
import Alamofire
//import SwiftOTP
import SnapKit
import JGProgressHUD
import LocalAuthentication
import Bootpay


#if os(macOS)
public typealias BTViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias BTViewRepresentable = UIViewRepresentable
#endif


@objc public protocol BootpayBioProtocol {    
    @objc(clickCard:) func clickCard(_ row: Int)
    @objc(lastIndexChanged:) func lastIndexChanged(_ index: Int)
}

public struct BootpayBioUI: BTViewRepresentable { 
    var bioPayload: BootBioPayload?
    
    var isCallbackMessageOnClosed = true

    public init(bioPayload: BootBioPayload) {
        self.bioPayload = bioPayload
        
        Bootpay.shared.ENV_TYPE = BootpayConstants.ENV_SWIFT_UI 
    }
     
    
    
    #if os(macOS)
    func makeNSView(context: Context) -> BootpayWebView {
        let webView = BootpayWebView()
        webView.frame = CGRect.zero
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
       return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) { 
    }
    #elseif os(iOS)
    // 뷰 객체를 생성하고 초기 상태를 구성합니다. 딱 한 번만 호출됩니다.
    public func makeUIView(context: Context) -> BootpayBioView { 
        
        let view = BootpayBioView(
            frame: UIScreen.main.bounds,
            bioPayload: self.bioPayload ?? BootBioPayload()
        )
        return view
    }
    
    
    public func updateUIView(_ view: BootpayBioView, context: Context) {
    }
    #endif
    
}

extension BootpayBioUI {
    
    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        Bootpay.shared.error = action
        return self
    }

    public func onReady(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        Bootpay.shared.ready = action
        return self
    }
    
    public func onClose(_ action: @escaping () -> Void) -> BootpayBioUI {
        Bootpay.shared.close = action
        return self 
    }
    
    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBioUI {
        Bootpay.shared.confirm = action
        return self
    }
    
    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        Bootpay.shared.cancel = action
        return self
    }
    
    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
        Bootpay.shared.done = action
        return self
    }
}
 

 
