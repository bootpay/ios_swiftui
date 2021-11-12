//
//  bootpay_bio_request.swift
//  Alamofire
//
//  Created by Taesup Yoon on 2021/11/01.
//

import Alamofire
import Bootpay
import JGProgressHUD


class BootpayBioRequest {
    
//    var cardInfoList = [CardInfo]()
    let hud = JGProgressHUD()
    
    func registerBioAble(
        view: UIView,
        token: String,
        bioPayload: BootBioPayload?,
        completionHandler: @escaping(Bool, Any) -> Void) {
            
        var params = [String: Any]()
        params["password_token"] = token
        params["os"] = "ios"
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": bioPayload?.userToken ?? "",
            "Accept": "application/json"
        ]
        
        hud.textLabel.text = "보안 강화중"
        hud.show(in: view)
            
//            self.requ
        
        AF.request("https://api.bootpay.co.kr/app/easy/biometric", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                        if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String, let server_unixtime = data["server_unixtime"] as? CLong {

                            BootpayDefaultHelper.setValue("biometric_secret_key", value: biometric_secret_key)
                            BootpayDefaultHelper.setValue("biometric_device_id", value: biometric_device_id)

                            completionHandler(true, data)

                        }

                    case .failure(_):
                        if let data = response.data {
                            completionHandler(false, data)
//                            if let jsonString = String(data: data, encoding: String.Encoding.utf8),  let json = jsonString.convertToDictionary() {
//
//                                completionHandler(false, json)
//                            }
                        }
                    }

             }
    }
    
    func registerBioOTP(
        view: UIView,
        otp: String,
        bioPayload: BootBioPayload?,
        completionHandler: @escaping(Bool, Any) -> Void
    ) {
        
        var params = [String: Any]()
        params["otp"] = otp
        
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": bioPayload?.userToken ?? "",
            "Accept": "application/json"
        ]
         
        
        hud.textLabel.text = "보안 추가중" 
        hud.show(in: view)
        
        AF.request("https://api.bootpay.co.kr/app/easy/biometric/register", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                     
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                          
                        if let biometric_secret_key = data["biometric_secret_key"] as? String, let biometric_device_id = data["biometric_device_id"] as? String {
                            BootpayDefaultHelper.setValue("biometric_secret_key", value: biometric_secret_key)
                            BootpayDefaultHelper.setValue("biometric_device_id", value: biometric_device_id)
                        }
                        completionHandler(true, data)
                        
                    case .failure(_):
                        if let data = response.data {
                            completionHandler(false, data)
                        }
                    }
        }
    }

    func cardWalletList(bioPayload: BootBioPayload?, completionHandler: @escaping(Bool, Any) -> Void) {
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": bioPayload?.userToken ?? "",
            "Accept": "application/json"
        ]
        
        AF.request("https://api.bootpay.co.kr/app/easy/card/wallet", method: .get, headers: headers)
                 .validate()
                 .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        guard let data = res["data"] as? [String: AnyObject] else { return }
                        guard let user = data["user"] as? [String: AnyObject] else { return }
//                        guard let wallets = data["wallets"] as? [String: AnyObject] else { return }
                        
                        if let use_biometric = user["use_biometric"] as? Int, let use_device_biometric = user["use_device_biometric"] as? Int {
                            BootpayDefaultHelper.setValue("use_biometric", value: use_biometric)
                            BootpayDefaultHelper.setValue("use_device_biometric", value: use_device_biometric)
                        }
                        
                        completionHandler(true, value)
                    case .failure(_):
                        if let data = response.data {
                            completionHandler(false, data)
                        }
                    }
             }
        
//        return ["":""]
    }
 
    func cardPayRequest(
        view: UIView,
        bioPayload: BootBioPayload?,
        token: String?,
        walletId: String,
        serverTime: Int,
        completionHandler: @escaping(Bool, Any) -> Void
    ) {
//        if cardInfoList.count == 0 {
//            print("등록된 카드가 없습니다")
//            return
//        }
        guard let bioPayload = bioPayload else {
            print("bioPayload 값이 없습니다")
            return
        }
        if bioPayload.name?.count == 0 {
            print("bioPayload.name 값이 없습니다")
            return
        }
//        guard let application_id = bioPayload.application_id else {
//            print("bioPayload.application_id 값이 없습니다")
//            return
//        }

        var params = [String: Any]()
        if let token = token {
            params["password_token"] = token
        } else {
            params["otp"] = BootpayBioConstants.getOTPValue(
                BootpayDefaultHelper.getString(key: "biometric_secret_key"),
                serverTime: serverTime)
        }

//        params["wallet_id"] = cardInfoList[selectedCardIndex].wallet_id
        params["wallet_id"] = walletId
        params["request_data"] = [
            "application_id": bioPayload.applicationId,
            "order_id": bioPayload.orderId,
            "price": bioPayload.price,
            "name": bioPayload.name ?? ""
        ]

        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": bioPayload.userToken ?? "",
            "Accept": "application/json"
        ]

        hud.textLabel.text = "결제 요청중"
        hud.show(in: view)

        AF.request("https://api.bootpay.co.kr/app/easy/card/request", method: .post, parameters: params, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                    switch response.result {
                    case .success(let value):
                        completionHandler(true, value)
                    case .failure(_):
                        
                        if let data = response.data {
                            completionHandler(false, data)
                        }
                    }
        }
    }


    func deleteWalletRequest(
        view: UIView,
        userToken: String,
        walletId: String,
        completionHandler: @escaping(Bool, Any) -> Void
    ){
        let headers: HTTPHeaders = [
            "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
            "BOOTPAY-USER-TOKEN": userToken,
            "Accept": "application/json"
        ]
        
        hud.textLabel.text = "초기화 진행중"
        hud.show(in: view)
        
        AF.request("https://api.bootpay.co.kr/app/easy/card/wallet/\(walletId)", method: .delete, headers: headers)
                 .validate()
                 .responseJSON { response in
                    self.hud.dismiss(afterDelay: 0.5)
                     
                    switch response.result {
                    case .success(let value):
                        guard let res = value as? [String: AnyObject] else { return }
                        
                        completionHandler(true, res)
                        
                    case .failure(_):
                        if let data = response.data {
                            completionHandler(false, data)
//                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
//
//                                completionHandler(false, json)
//
//                            }
                        }
                    }
        }
    }
    
    func transactionConfirmRequest(
        view: UIView,
        bioPayload: BootBioPayload,
        data: [String: Any],
        completionHandler: @escaping(Bool, Any) -> Void) {
            
            guard let  data = data["data"] as? [String: Any], let receipt_id = data["receipt_id"] as? String else { return }
        
            var params = [String: Any]()
            params["receipt_id"] = receipt_id
                    
            let headers: HTTPHeaders = [
                "BOOTPAY-DEVICE-UUID": Bootpay.getUUID(),
                "BOOTPAY-USER-TOKEN": bioPayload.userToken ?? "",
                "Accept": "application/json"
            ]
            
            hud.textLabel.text = "결제 승인중"
            hud.show(in: view)
            
            AF.request("https://api.bootpay.co.kr/app/easy/confirm", method: .post, parameters: params, headers: headers)
                     .validate()
                     .responseJSON { response in
                        self.hud.dismiss(afterDelay: 0.5)
                        
                        switch response.result {
                        case .success(let value):
                            guard let res = value as? [String: AnyObject] else { return }
                            completionHandler(true, res)
//                            Bootpay.shared.done?(res)
//                            self.sendable?.onDone(data: res)
                        case .failure(_):
                            if let data = response.data {
                                completionHandler(false, data)
//                                if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
//                                    completionHandler(false, json)
//                                }
                            }
                        }
            }
    }
}
