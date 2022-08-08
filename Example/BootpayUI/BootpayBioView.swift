//
//  BioView.swift
//  BootpayUI_Example
//
//  Created by Taesup Yoon on 2021/10/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import SwiftUI
import Alamofire
import Bootpay
import BootpayUI


let _unique_user_id = "123456abcdffffe2345678901234561324516789122123"


struct BootpayBioView: View {
    @ObservedObject private var viewModel = ViewModel()
    let _user = BootUser()
    private var _bioPayload = BootBioPayload()
    private var _bioTheme = BioThemeData()
//    private var _payload = Payload()
    @State private var showingBootpay = false
    
    
    
   var body: some View {
       GeometryReader { geometry in
           VStack {
//               if(self.viewModel.showingBootpay == false) {
               Button("생체인증 결제 테스트") {
                   bootpayStart(isPasswordMode: false)
               }.padding()
               Button("비밀번호 간편결제 테스트") {
                   bootpayStart(isPasswordMode: true)
               }.padding()
//               Button("비밀번호 일반결제 테스트") {
//                   bootpayDefaultStart()
//               }
               .sheet(isPresented: self.$viewModel.showingBootpay) {
                   BootpayBioUI(
                    payload: self._bioPayload,
                    userToken: self.viewModel.easyPayUserToken,
                    showBootpay: self.$viewModel.showingBootpay,
                    bioTheme: self._bioTheme
                   )
                       .onError{ data in
                           print("-- error \(data)")
                       }.onIssued{ data in
                           print("-- ready \(data)")
                       }
                       .onConfirm { data in
                           print("-- confirm  \(data)")
                           return true
                       }
                       .onCancel { data in
                           print("-- cancel  \(data)")
                       }
                       .onDone { data in
                           print("-- done \(data)")
                       }
                       .onClose {
                           print("-- close")
                       }
                       .edgesIgnoringSafeArea(.all)
               }
               
           }.frame(width: geometry.size.width, height: geometry.size.height)
       }
   }
     
    
    func bootpayStart(isPasswordMode: Bool) {
        
        _user.id = _unique_user_id
        _user.area = "서울"
        _user.gender = 1
        _user.email = "test1234@gmail.com"
        _user.phone = "01012344567"
        _user.birth = "1988-06-10"
        _user.username = "홍길동"
        
        #if os(macOS)
        _payload.applicationId = "5b8f6a4d396fa665fdc2b5e7" //web application id
        #elseif os(iOS)
        _bioPayload.applicationId = "5b8f6a4d396fa665fdc2b5e9" //ios application id
        #endif

        _bioPayload.pg = "나이스페이"

        _bioPayload.price = 1000
        _bioPayload.orderId = String(NSTimeIntervalSince1970)
        //                        payload.name = "테스트 아이템"
        _bioPayload.orderName = "Touch ID 인증 결제 테스트"

        _bioPayload.names = ["플리츠레이어 카라숏원피스", "블랙 (COLOR)", "55 (SIZE)"]
           
        _bioPayload.user = _user
        _bioPayload.isPasswordMode = isPasswordMode

        _bioPayload.extra = BootExtra()
        _bioPayload.extra?.cardQuota = "6"
        _bioPayload.extra?.displaySuccessResult = true
        
//        _bioTheme.bgColor = UIColor.init(red: 253 / 255, green: 250 / 255, blue: 247 / 255, alpha: 1)
//        _bioTheme.textColor = UIColor.init(red: 40 / 255, green: 40 / 255, blue: 40 / 255, alpha: 1)
//        _bioTheme.priceColor = UIColor.init(red: 1, green: 160 / 255, blue: 197 / 255, alpha: 1)
//        _bioTheme.cardText1Color = UIColor.init(red: 1, green: 160 / 255, blue: 197 / 255, alpha: 1)
//
//        _bioTheme.card2Color = UIColor.init(red: 246 / 255, green: 202 / 255, blue: 217 / 255, alpha: 1)
//        _bioTheme.cardIconColor = UIColor.init(red: 246 / 255, green: 202 / 255, blue: 217 / 255, alpha: 1)
//
//        _bioTheme.buttonBgColor = UIColor.init(red: 244 / 255, green: 215 / 255, blue: 130 / 255, alpha: 1.0)
//        _bioTheme.logoImageView = UIImageView(image: UIImage.init(named: "logo"))
        
          

        let p1 = BootBioPrice()
        let p2 = BootBioPrice()
        let p3 = BootBioPrice()

        p1.name = "상품가격"
        p1.price = 89000

        p2.name = "쿠폰적용"
        p2.price = -2500

        p3.name = "배송비"
        p3.price = 2500

        _bioPayload.prices = [p1, p2, p3]
        viewModel.getUserToken(user: _user)
    }
}
 
