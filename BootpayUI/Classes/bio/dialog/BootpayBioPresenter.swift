//
//  BootpayBioPresenter.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/11.
//

import Alamofire
import ObjectMapper
import Bootpay


@objc open class BootpayBioPresenter: NSObject {
//    var passwordToken: String?
    var biometricData = BiometricData()
//    var bioPayload: BootBioPayload?
    var bioController: BootpayBioController?
    var bioWebView: BootpayBioWebView?
    var walletList: [WalletData]?
    var selectedCardIndex = -1
//    var requestType = BioConstants.REQUEST_TYPE_NONE
    
    func initPresenter(vc: BootpayBioController, webView: BootpayBioWebView) {
        self.bioController = vc
        self.bioWebView = webView
//        self.bioPayload = payload
        self.bioWebView?.nextJob{ dic in
            if let initToken = dic["initToken"] as? Bool { //초기화 할 필요가 있다면 초기화
                if initToken == true { self.setPasswordToken(""); BootpayBio.sharedBio.bioPayload?.token = "" }
            } else if let token = dic["token"] as? String { // 토큰 값 지정
                self.setPasswordToken(token);
                BootpayBio.sharedBio.bioPayload?.token = token
            }
            if let biometric_device_uuid = dic["biometric_device_uuid"] as? String, let biometric_secret_key = dic["biometric_secret_key"] as? String {
                // 값 지정
                BootpayDefaultHelper.setValue("biometric_device_uuid", value: biometric_device_uuid)
                BootpayDefaultHelper.setValue("biometric_secret_key", value: biometric_secret_key)
            }
//            print(dic)
            //next job
            if let nextType = dic["nextType"] as? Int {
                if(nextType == BioConstants.NEXT_JOB_RETRY_PAY) {
                    self.startPayWithSelectedCard()
                } else if(nextType == BioConstants.NEXT_JOB_ADD_NEW_CARD) {
                    self.addNewCard(nil)
                } else if(nextType == BioConstants.NEXT_JOB_ADD_DELETE_CARD) {
                    self.requestDeleteCard()
                } else if(nextType == BioConstants.REQUEST_PASSWORD_FOR_PAY) {
                    self.requestPasswordForPay()
                } else if(nextType == BioConstants.NEXT_JOB_GET_WALLET_LIST) {
                    if let type = dic["type"] as? Int, type == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY {
                        self.getWalletList(true)
                    } else {
                        self.getWalletList()
                    }
                }
            }
        }
        
    }
    
    func startBioPay() {
        getWalletList()
    }
    
    func goClickCard(_ index: Int) {
        if index < self.walletList?.count ?? 0 {
//            if(requestType != BioConstants.REQUEST_TYPE_NONE) { return }
            self.selectedCardIndex = index
            startPayWithSelectedCard()
            
        } else if index == self.walletList?.count ?? 0 {
            addNewCard(nil)
        } else if index == (self.walletList?.count ?? 0) + 1 {
            requestTotalForPay()
        }
    }
    
    
    func addNewCard(_ type: Int?) {
        if let type = type {
            setRequestType(type)
        } else {
            setRequestType(BioConstants.REQUEST_ADD_CARD)
        }
         
        if(!isShowWebView()) {
            showWebview()
        }
        
        if(!isAblePasswordToken()) {
            requestPasswordToken(BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD)
            return
        }
        
        requestAddCard()
    }
    
    func deleteCard(_ index: Int) {
        if(index >= walletList?.count ?? 0) { return }
            //popup
     
            
        guard let bioController = bioController else { return }
        let okAction = AlertAction(title: OKTitle)
        let alertController = bioController.getAlertViewController(
            type: .alert,
            with: "결제수단 삭제",
            message: "선택하신 결제수단을 삭제하시겠습니까?",
            actions: [okAction], showCancel: true) { (btnTitle) in
                self.selectedCardIndex = index
                let walletId = self.walletList?[self.selectedCardIndex].wallet_id ?? ""
                if !walletId.isEmpty {
                    BootpayBio.sharedBio.bioPayload?.walletId = walletId
                }
                if(!self.isShowWebView()) {
                    self.showWebview()
                }
                
                
                if(!self.isAblePasswordToken()) {
                    self.requestPasswordToken(BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD)
                    return
                }
                
                self.requestDeleteCard()
            }
        bioController.present(alertController, animated: true, completion: nil)
    }
}

//biz logic
extension BootpayBioPresenter {
    func startPayWithSelectedCard() {
        let walletId = self.walletList?[self.selectedCardIndex].wallet_id ?? ""
        if !walletId.isEmpty {
            BootpayBio.sharedBio.bioPayload?.walletId = walletId
//            self.bioWebView.
        }
        
        if(BootpayBio.sharedBio.bioPayload?.isPasswordMode == true) {
            setRequestType(BioConstants.REQUEST_PASSWORD_FOR_PAY)
            requestPasswordForPay()
            return;
        }
        
        
        setRequestType(BioConstants.REQUEST_BIO_FOR_PAY)
        if(!isAblePasswordToken()) {
            requestPasswordToken(BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY)
            return
        }
        if(isAbleBioAuthDevice()) {
            goBioForPay()
            return
        } else if(nowAbleBioAuthDevice()){
            //기기활성화 먼저 해야함
            goBioForEnableDevice()
            return
        }
        
        setRequestType(BioConstants.REQUEST_PASSWORD_FOR_PAY)
        goPasswordPayByBioLockedout()
//        requestPasswordForPay()
    }
    
    func setRequestType(_ type: Int) {
        BootpayBio.sharedBio.requestType = type 
//        self.requestType = type
//        self.bioWebView?.requestType = type
    }
}

//ui dispatcher
extension BootpayBioPresenter {
    func showCardView(_ walletList: [WalletData]) {
//        if(!walletList.isEmpty) {
//            bioController?.setWalletList(walletList)
//        }
        bioController?.setWalletList(walletList)
        bioController?.showCardView()
        bioController?.hideWebView()
    }
    
    func showWebview() {
        bioController?.hideCardView()
        bioController?.showWebView()
    }
    
    func isShowCardView() -> Bool {
        return bioController?.isShowCardView() ?? false
    }
    
    func isShowWebView() -> Bool {
        return bioController?.isShowWebView() ?? false
    }
    
    func isAblePasswordToken() -> Bool {
        let passwordToken = BootpayDefaultHelper.getString(key: "password_token")
        if passwordToken.count > 0 {
            return true
        }
        return false
    }
    
    func isAbleBioAuthDevice() -> Bool {
        return didAbleBioAuthDevice() && nowAbleBioAuthDevice()
    }
    
    func nowAbleBioAuthDevice() -> Bool {
        return BioMetricAuthenticator.canAuthenticate()
    }
    
    func didAbleBioAuthDevice() -> Bool {
        return self.biometricData.biometric_confirmed && BootpayDefaultHelper.getString(key: "biometric_secret_key").count > 0
    }
    
    func setPasswordToken(_ token: String) {
        BootpayDefaultHelper.setValue("password_token", value: token)
    }
    
//    func setBioAbleDevice(_ able: String) {
//        BootpayDefaultHelper.setValue("bio_active", value: able)
//    }
    
    func getPasswordToken() -> String {
        return BootpayDefaultHelper.getString(key: "password_token")
//        return BootpayDefaultHelper.getString(key: "token")
    }
    
    func initDeviceBioInfo() {
        self.setPasswordToken("")
//        self.setBioAbleDevice("")
    }
    
}

//api
extension BootpayBioPresenter {
    
    func getWalletList(_ requestBioPay: Bool = false) {
        
        
        let headers: HTTPHeaders = [
            "Bootpay-Device-UUID": Bootpay.getUUID(),
            "Bootpay-User-Token": BootpayBio.sharedBio.bioPayload?.userToken ?? "",
            "Accept": "application/json"
        ]
        
        print("getWalletList: \(headers)")
        
        AF.request("https://api.bootpay.co.kr/v2/sdk/easy/wallet", method: .get, headers: headers)
                 .validate()
                 .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        
                        let dic = value as! NSDictionary
                        
                        self.biometricData = Mapper<BiometricData>().map(JSON: dic.object(forKey: "biometric") as! [String : Any]) ?? BiometricData()
                        
//                        print(self.biometricData)
//                        if(self.requestType == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
//                            self.requestBioForPay()
//                            return
//                        }
                        if(requestBioPay == true) {
                            self.requestBioForPay()
                            return
                        }
                        
                        self.walletList = Mapper<WalletData>().mapArray(JSONObject: dic.object(forKey: "wallets")) ?? []
                        
                        if(self.biometricData.biometric_confirmed == false) {
                            //기기 초기화
                            if(self.walletList!.isEmpty) {
                                BootpayDefaultHelper.setValue("biometric_secret_key", value: "")
                            }
                            self.initDeviceBioInfo()
                        }
                        
//                        if(self.walletList!.isEmpty) {
//                            self.addNewCard(nil)
//                        } else {
//                            self.showCardView(self.walletList!)
//                        }
                        self.showCardView(self.walletList!)
                    case .failure(_):
                        if let data = response.data {
                            if let jsonString = String(data: data, encoding: String.Encoding.utf8), let json = jsonString.convertToDictionary() {
                                
                                if let code = json["error_code"] as? String, let msg = json["message"] as? String {
                                    self.bioController?.showAlert(title: "에러코드: \(code)", message: msg)
                                }
                            }
                        }
                    }
             }
    }
    
    func requestPasswordToken(_ type: Int?) {
        if let type = type { setRequestType(type) }
        
        if(!isShowWebView()) {
            showWebview()
        }
        
        bioWebView?.requestPasswordToken()
    }
    
    func requestDeleteCard() {
        setRequestType(BioConstants.REQUEST_DELETE_CARD)
        bioWebView?.requestDeleteCard(getPasswordToken(), payload: BootpayBio.sharedBio.bioPayload!)
    }
    
    func requestAddCard() {
        setRequestType(BioConstants.REQUEST_ADD_CARD)
        bioWebView?.requestAddCard()
    }
    
    func requestBioForPay() {
        let secretKey = BootpayDefaultHelper.getString(key: "biometric_secret_key")
        let serverUnixtime = biometricData.server_unixtime
        let otp = getOTPValue(secretKey, serverTime: serverUnixtime)
        setRequestType(BioConstants.REQUEST_BIO_FOR_PAY)
        bioWebView?.requestBioForPay(otp, payload: BootpayBio.sharedBio.bioPayload!)
    }
    
    func requestPasswordForPay() {
        if(!isAblePasswordToken()) {
            requestPasswordToken(BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY)
            return
        }
        
        if(!isShowWebView()) {
            showWebview()
        }
        setRequestType(BioConstants.REQUEST_PASSWORD_FOR_PAY)
        bioWebView?.requestPasswordForPay(getPasswordToken(), payload: BootpayBio.sharedBio.bioPayload!)
    }
    
    func requestTotalForPay() {
        if(!isShowWebView()) {
            showWebview()
        }
        setRequestType(BioConstants.REQUEST_TOTAL_PAY)
        bioWebView?.requestTotalForPay(payload: BootpayBio.sharedBio.bioPayload!)
    }
    
    //생체인식 정보 등록
    func requestAddBioData(_ type: Int?) {
        if let type = type { setRequestType(type) }
        else { setRequestType(BioConstants.REQUEST_ADD_BIOMETRIC) }
        
        if(!isShowWebView()) {
            showWebview()
        }
        bioWebView?.requestAddBioData(getPasswordToken(), payload: BootpayBio.sharedBio.bioPayload!) 
    }
    
    func goBioForEnableDevice() {
        setRequestType(BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY)
        goBiometricAuth()
    }
    
    func goBioForPay() {
        setRequestType(BioConstants.REQUEST_BIO_FOR_PAY)
        goBiometricAuth()
    }
    
    func goPasswordPayByBioLockedout() {
        guard let bioController = bioController else { return }
        let okAction = AlertAction(title: OKTitle)
        let alertController = bioController.getAlertViewController(
            type: .alert,
            with: "인식 실패",
            message: "Touch ID 인식을 진행할 수 없어, 비밀번호 인증방식으로 결제합니다.",
            actions: [okAction], showCancel: true) { (btnTitle) in                                
                if btnTitle == OKTitle {
                    self.requestPasswordForPay()
                } else {
                    
                }
            }
        bioController.present(alertController, animated: true, completion: nil)
    }
}

//bio
extension BootpayBioPresenter {
    func goBiometricAuth() {
        BioMetricAuthenticator.shared.allowableReuseDuration = nil
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { [weak self] (result) in
           
        switch result {
            case .success( _):
//            self?.setBioAbleDevice("active")
            //1. 기기 인증이냐
            //2. 결제냐
            if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_BIOMETRIC) {
                self?.requestAddBioData(nil)
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_BIOAUTH_FOR_BIO_FOR_PAY) {
                self?.requestAddBioData(BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY)
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_BIO_FOR_PAY) {
                self?.requestBioForPay()
            }
            break
               
            case .failure(let error):
                switch error {
                   // device does not support biometric (face id or touch id) authentication
                case .biometryNotAvailable:
                    self?.showErrorAlert(message: error.message())
                   // No biometry enrolled in this device, ask user to register fingerprint or face
                    break
                case .biometryNotEnrolled:
                    self?.showGotoSettingsAlert(message: error.message())
                   // show alternatives on fallback button clicked
                    break
                case .fallback:
                    print("fallback")
                    break
                case .biometryLockedout:
                    print("biometryLockedout")
                    self?.goPasswordPayByBioLockedout()
                    break
                case .canceledBySystem:
                    print("canceledBySystem")
                    self?.goPasswordPayByBioLockedout()
                    break
                case  .canceledByUser:
                    print("canceledByUser")
                    BootpayBio.removePaymentWindow()
                    break
                   // show error for any other reason
                default:
                    self?.showErrorAlert(message: error.message())
                   break
                }
            }
        }
    }
    
    func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
        if let data = biometricSecretKey.base32DecodedData {
            if let totp = TOTP(secret: data, digits: 8, timeInterval: 30, algorithm: .sha512) {
                if let otpString = totp.generate(secondsPast1970: serverTime) {
                    return otpString;
                }
            }
        }
        return "";
    }
}



//bio
extension BootpayBioPresenter {
    
    func showAlert(title: String, message: String) {
        guard let bioController = bioController else { return }
        
        let okAction = AlertAction(title: OKTitle)
        let alertController = bioController.getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: false) { (button) in
        }
        bioController.present(alertController, animated: true, completion: nil)
    }
    
//    func showDeleteAlert(title: String, message: String, OKTitle: String = "초기화", wallet_id: String) {
//        guard let bioController = bioController else { return }
//
//        let okAction = AlertAction(title: OKTitle)
//        let alertController = bioController.getAlertViewController(type: .alert, with: title, message: message, actions: [okAction], showCancel: true) { (button) in
//            if(button == OKTitle) {
////                self.goDeleteCardAll(wallet_id: wallet_id)
//            }
////            self.dismiss()
//        }
//        bioController.present(alertController, animated: true, completion: nil)
//    }
    
    func showLoginSucessAlert() {
        print("showLoginSucessAlert")
        showAlert(title: "Success", message: "Login successful")
    }
    
    func showErrorAlert(message: String) {
        
        print("showErrorAlert")
        showAlert(title: "Error", message: message)
    }
    
    func showGotoSettingsAlert(message: String) {
        
        guard let bioController = bioController else { return }
        
        let settingsAction = AlertAction(title: "Go to settings")
        
        let alertController = bioController.getAlertViewController(type: .alert, with: "Error", message: message, actions: [settingsAction], showCancel: true, actionHandler: { (buttonText) in
            if buttonText == CancelTitle { return }
            
            // open settings
            #if swift(>=4.2)
            let url = URL(string: UIApplication.openSettingsURLString)
            #else
            let url = URL(string: UIApplicationOpenSettingsURLString)
            #endif
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:])
            }
            
        })
        bioController.present(alertController, animated: true, completion: nil)
    }
}
