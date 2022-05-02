////
////  BootpayBioUI.swift
////  BootpayUI
////
////  Created by Taesup Yoon on 2022/04/27.
////
//
//import SwiftUI
//import Bootpay
//
//
//public struct BootpayBioUI: BTViewRepresentable {
//    public var bioPayload: BootBioPayload
//
//    public init(payload: BootBioPayload) {
//        self.bioPayload = payload
////        self.bioPayload.userToken = userToken
////        BootpayBio.sharedBio.bioPayload = payload 
//    }
//     
//    
//    
//    #if os(macOS)
//    func makeNSView(context: Context) -> BootpayBioWebView {
//        let webView = BootpayBioWebView()
//        webView.startBootpay()
//       return webView
//    }
//
//    func updateNSView(_ webView: BootpayBioWebView, context: Context) {
//    }
//    #elseif os(iOS)
//    // 뷰 객체를 생성하고 초기 상태를 구성합니다. 딱 한 번만 호출됩니다.
//    public func makeUIView(context: Context) -> BootpayBioWebView {
//       let webView = BootpayBioWebView()
//       webView.startBootpay()
//       return webView
//    }
//    
//    
//    public func updateUIView(_ view: BootpayBioWebView, context: Context) {
//    }
//    #endif
//    
//}
//
//extension BootpayBioUI {
//    
//    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
//        Bootpay.shared.error = action
//        return self
//    }
//
//    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
//        Bootpay.shared.issued = action
//        return self
//    }
//    
//    public func onClose(_ action: @escaping () -> Void) -> BootpayBioUI {
//        Bootpay.shared.close = action
//        return self
//    }
//    
//    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBioUI {
//        Bootpay.shared.confirm = action
//        return self
//    }
//    
//    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
//        Bootpay.shared.cancel = action
//        return self
//    }
//    
//    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUI {
//        Bootpay.shared.done = action
//        return self
//    }
//}
// 
