////
////  BootpayBio.swift
////  bootpayBio
////
////  Created by Taesup Yoon on 2021/05/17.
////
//
//import Foundation
//import WebKit
//
//@objc public class BootpayBio: NSObject {
//    @objc public static let sharedBio = BootpayBio()
//    var bioPayload: BootBioPayload?
//    var bioVc: BootpayBioController?
//
//    @objc(requestPayment::::)
//    public static func requestBioPayment(viewController: UIViewController,
//                                      payload: BootBioPayload,
//                                      _ animated: Bool = true,
//                                      _ modalPresentationStyle: UIModalPresentationStyle = .fullScreen) -> BootpayBio.Type {
//
//        sharedBio.bioVc = BootpayBioController()
//        sharedBio.bioVc?.bioPayload = payload
////        sharedBio.bioVc?.send
//
//
//        return self
//    }
//}
