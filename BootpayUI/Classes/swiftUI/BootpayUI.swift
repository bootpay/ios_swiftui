//
//  BootpayUI.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2021/11/12.
//
import SwiftUI
import Bootpay


#if os(macOS)
public typealias BTViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias BTViewRepresentable = UIViewRepresentable
#endif


public struct BootpayUI: BTViewRepresentable {
    public var payload: Payload

    public init(payload: Payload) {
        self.payload = payload
        Bootpay.shared.payload = payload
    }
     
    
    
    #if os(macOS)
    func makeNSView(context: Context) -> BootpayWebView {
        let webView = BootpayWebView()
        webView.startBootpay()
       return webView
    }

    func updateNSView(_ webView: BootpayWebView, context: Context) {
    }
    #elseif os(iOS)
    // 뷰 객체를 생성하고 초기 상태를 구성합니다. 딱 한 번만 호출됩니다.
    public func makeUIView(context: Context) -> BootpayWebView {
       let webView = BootpayWebView()     
        webView.startBootpay()
       return webView
    }
    
    
    public func updateUIView(_ view: BootpayWebView, context: Context) {
    }
    #endif
    
    func resizeWebview() {
        
    }
    
}

extension BootpayUI {
    
    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.error = action
        return self
    }

    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.issued = action
        return self
    }
    
    public func onClose(_ action: @escaping () -> Void) -> BootpayUI {
        Bootpay.shared.close = action
        return self
    }
    
    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayUI {
        Bootpay.shared.confirm = action
        return self
    }
    
    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.cancel = action
        return self
    }
    
    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayUI {
        Bootpay.shared.done = action
        return self
    }
}
 

 
