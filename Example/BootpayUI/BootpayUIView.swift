//
//  BootpayUIView.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2022/05/24.
//  Copyright © 2022 CocoaPods. All rights reserved.
//


import SwiftUI
import WebKit
import Bootpay

struct BootpayUIView: View {
//    @State private var showModal = false
    @State private var showingBootpay = false
    @State private var payload = Payload()
    private enum PaymentAuthMode {
        case clientKey
        case legacyApplicationId
        case missingKey
    }
       
    var body: some View {
        GeometryReader { geometry in
            VStack {
                
                if(self.showingBootpay) {
                    BootpayUI(payload: payload, requestType: BootpayConstant.REQUEST_TYPE_PAYMENT)
                        .onCancel { data in
                            print("-- cancel: \(data)")
                        }
                        .onIssued { data in
                            print("-- ready: \(data)")
                        }
                        .onConfirm { data in
                            print("-- confirm: \(data)")
                            return true //재고가 있어서 결제를 최종 승인하려 할 경우
//                            return true //재고가 없어서 결제를 승인하지 않을때
//                            return false
                        }
                        .onDone { data in
                            print("-- done: \(data)")
                        }
                        .onError { data in
                            print("-- error: \(data)")
                            self.showingBootpay = false
                        }
                        .onClose {
                            print("-- close")
                            self.showingBootpay = false
                        }
                } else {
                    VStack(spacing: 12) {
                        Button("부트페이 결제테스트 (client_key)") {
                            requestPayment(authMode: .clientKey)
                        }
                        Button("레거시 결제테스트 (application_id)") {
                            requestPayment(authMode: .legacyApplicationId)
                        }
                        Button("키 없음 테스트 (NEED_CLIENT_KEY)") {
                            requestPayment(authMode: .missingKey)
                        }
                    }.sheet(isPresented: self.$showingBootpay) {
                    }
                }
            }.frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func requestPayment(authMode: PaymentAuthMode) {
        let nextPayload = Payload()
        applyAuth(to: nextPayload, mode: authMode)
        nextPayload.pg = "웰컴페이먼츠"
        nextPayload.method = "디지털카드"

        nextPayload.price = 1000
        nextPayload.orderId = String(NSTimeIntervalSince1970)
        nextPayload.orderName = "테스트 아이템"

        nextPayload.extra = BootExtra()
//        nextPayload.extra?.separatelyConfirmed = false
//        nextPayload.extra?.cardQuota = "6"

        let user = BootUser()
        user.username = "테스트 유저"
        user.phone = "01012345678"
        nextPayload.user = user
        payload = nextPayload
        showingBootpay = true
    }

    private func applyAuth(to payload: Payload, mode: PaymentAuthMode) {
        switch mode {
        case .clientKey:
            payload.clientKey = BootpayConfig.clientKey
        case .legacyApplicationId:
            payload.applicationId = BootpayConfig.applicationId
        case .missingKey:
            break // NEED_CLIENT_KEY 검증용
        }
    }
}
 
