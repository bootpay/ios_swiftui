//
//  BootpayBioUIController.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2022/04/27.
//

import SwiftUI
import Bootpay

#if os(macOS)
public typealias BTViewControllerRepresentable = NSViewControllerRepresentable
#elseif os(iOS)
public typealias BTViewControllerRepresentable = UIViewControllerRepresentable
#endif



public struct BootpayBioUIController: BTViewControllerRepresentable {
    public var payload: BootBioPayload
    

    public init(payload: BootBioPayload) {
        self.payload = payload
//        Bootpay.shared.payload = payload
    }
    
    
    #if os(macOS)
    func makeNSViewController(context: Context) -> BootpayBioController {
        BootpayBio.sharedBio.bioVc = BootpayBioController()
        BootpayBio.sharedBio.bioPayload = self.payload
        return BootpayBio.sharedBio.bioVc!
    }

    func updateNSViewController(_ viewController: BootpayBioController, context: Context) {
    }
    #elseif os(iOS)
    public func makeUIViewController(context: Context) -> BootpayBioController {
        BootpayBio.sharedBio.bioVc = BootpayBioController()
        BootpayBio.sharedBio.bioPayload = self.payload
        return BootpayBio.sharedBio.bioVc!
    }

    public  func updateUIViewController(_ viewController: BootpayBioController, context: Context) {
    }
    #endif
}

//
//extension BootpayBioUIController {
//    
//    public func onError(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIController {
//        BootpayBio.sharedBio.error = action
//        return self
//    }
//
//    public func onIssued(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIController {
//        BootpayBio.sharedBio.issued = action
//        return self
//    }
//    
//    public func onClose(_ action: @escaping () -> Void) -> BootpayBioUIController {
//        BootpayBio.sharedBio.close = action
//        return self
//    }
//    
//    public func onConfirm(_ action: @escaping([String : Any]) -> Bool) -> BootpayBioUIController {
//        BootpayBio.sharedBio.confirm = action
//        return self
//    }
//    
//    public func onCancel(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIController {
//        BootpayBio.sharedBio.cancel = action
//        return self
//    }
//    
//    public func onDone(_ action: @escaping ([String : Any]) -> Void) -> BootpayBioUIController {
//        BootpayBio.sharedBio.done = action
//        return self
//    }
//}
// 
