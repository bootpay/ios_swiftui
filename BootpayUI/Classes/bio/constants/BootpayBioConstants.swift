//
//  BootpayBioConstants.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/14.
//

import Bootpay

let kBiometryNotAvailableReason = "Biometric authentication is not available for this device."

/// ****************  Touch ID  ****************** ///

let kTouchIdAuthenticationReason = "지문 센서를 터치해 주세요."
let kTouchIdAuthenticationReasonForNewCard = "카드 등록을 위해, 지문 센서를 터치해 주세요."
let kTouchIdAuthenticationReasonForDeleteCard = "등록된 카드를 삭제하시려면, 지문 센서를 터치해 주세요."
let kTouchIdPasscodeAuthenticationReason = "실패한 횟수가 너무 많아 이제 Touch ID가 잠겼습니다. Touch ID를 잠금 해제하려면 암호를 입력하세요."

/// Error Messages Touch ID
let kSetPasscodeToUseTouchID = "Touch ID를 사용하려면, 설정 → Touch ID 및 암호로 이동하여 '암호 켜기'를 진행해주세요."
let kNoFingerprintEnrolled = "기기에 등록된 지문이 없습니다. 설정 → Touch ID 및 암호로 이동하여 지문을 등록하세요."
let kDefaultTouchIDAuthenticationFailedReason = "Touch ID가 지문을 인식하지 못했습니다. 등록 된 지문으로 다시 시도하세요."

/// ****************  Face ID  ****************** ///

let kFaceIdAuthenticationReason = "인증을 위해 얼굴을 인식해주세요."
let kFaceIdPasscodeAuthenticationReason = "실패한 시도가 너무 많아 이제 Face ID가 잠겼습니다. Face ID를 잠금 해제하려면 비밀번호를 입력하세요."

/// Error Messages Face ID
let kSetPasscodeToUseFaceID = "Face ID를 사용하려면, 설정 → Face ID 및 암호로 이동하여 '암호 켜기'를 진행해주세요."
let kNoFaceIdentityEnrolled = "기기에 등록 된 얼굴이 없습니다. 설정 → Face ID 및 암호로 이동하여 얼굴을 등록하세요."
let kDefaultFaceIDAuthenticationFailedReason = "Face ID does not recognize your face. Please try again with your enrolled face."


struct BootpayBioConstants {
    
    public static let REQUEST_TYPE_VERIFY_PASSWORD = 1 // 생체인식 활성화용도
    public static let REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY = 2 //비밀번호로 결제 용도
    public static let REQUEST_TYPE_REGISTER_CARD = 3 //카드 생성
    public static let REQUEST_TYPE_PASSWORD_CHANGE = 4 //카드 삭제
    public static let REQUEST_TYPE_ENABLE_DEVICE = 5 //해당 기기 활성화
    
    public static let REQUEST_TYPE_ENABLE_OTHER = 6 //통합결제
    public static let REQUEST_TYPE_PASSWORD_PAY = 7 //카드 간편결제 (비밀번호) - 생체인증 정보가 기기에 없을때
        
    public static let fontColor = UIColor.black
    public static let bgColor = UIColor.init(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
     
    static func easyCancel() -> String {
        return ".easyCancel(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func easyError() -> String {
        return ".easyError(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func easySuccess() -> String {
        return ".easySuccess(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
}

extension BootpayBioConstants {
    static public func verifyPasswordScript(_ bioWebview: BootpayBioWebView, bioPayload: BootBioPayload) -> String {
        guard let userToken = bioPayload.userToken else { return "" }
        
        var msg = "이 기기에서 Touch ID 결제를 활성화합니다"
        if(bioWebview.requestType == BootpayBioConstants.REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY) { msg = "비밀번호 입력방식으로 결제를 진행합니다" }
                   
        let array = [
            "BootPay.verifyPassword({",
            "userToken: '\(userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '\(msg)'",
            "})",
            easyCancel(),
            easyError(),
            easySuccess()
        ]
        return array.reduce("", +)
    }
    
    static public func registerCardScript(bioPayload: BootBioPayload) -> String {
        guard let userToken = bioPayload.userToken else { return "" }
        
        let msg = "새로운 카드를 등록합니다"
                   
        let array = [
            "BootPay.registerCard({",
            "userToken: '\(userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '\(msg)'",
            "})",
            easyCancel(),
            easyError(),
            easySuccess()
        ]
        return array.reduce("", +)
    }
    
    static public func changePasswordScript(bioPayload: BootBioPayload) -> String {
        guard let userToken = bioPayload.userToken else { return "" }
        
        let msg = "비밀번호를 찾습니다"
                   
        let array = [
            "BootPay.changePassword({",
            "userToken: '\(userToken)',",
            "deviceId: '\(Bootpay.getUUID())',",
                "message: '\(msg)'",
            "})",
            easyCancel(),
            easyError(),
            easySuccess()
        ]
        return array.reduce("", +)
    }
    
    static public func getOTPValue(_ biometricSecretKey: String, serverTime: Int) -> String {
        if let data = biometricSecretKey.base32DecodedData {
            if let totp = TOTP(secret: data, digits: 8, timeInterval: 30, algorithm: .sha512) {
                if let otpString = totp.generate(secondsPast1970: serverTime) {
                    return otpString;
                }
            }
        }
        return "";
    }
    
    private static func getURLSchema() -> String{
        guard let schemas = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String:Any]],
            let schema = schemas.first,
            let urlschemas = schema["CFBundleURLSchemes"] as? [String],
            let urlschema = urlschemas.first
            else {
                return ""
        }
        return urlschema
    }
    
    static public func getJSPay(payload: BootBioPayload, isPasswordPay: Bool) -> String {
        if let extra = payload.extra {
            if extra.appScheme != nil {
                //가맹점이 설정한 appScheme 값을 그대로 둔다
            } else {
                extra.appScheme = getURLSchema()
                payload.extra = extra
            }
        } else {
            let extra = BootExtra()
            extra.appScheme = getURLSchema()
            payload.extra = extra
        }
        if(isPasswordPay == true) {
            payload.method = "easy_card"
        } else {
//            payload.userToken = ""
        }
        
        payload.userInfo?.setEncodedValueAll()
         
        
        return [
            "BootPay.request(",
            getPayloadJson(payload),
            ")",
            error(),
            confirm(),
            ready(),
            cancel(),
            done(),
            close()
        ].reduce("", +)
    }
    
    static func error() -> String {
        return ".error(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func confirm() -> String {
        return ".confirm(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func ready() -> String {
        return ".ready(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func cancel() -> String {
        return ".cancel(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func done() -> String {
        return ".done(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
    }
    
    static func close() -> String {
        return ".close(function () {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage('close');})"
    }
    
    
    static private func getPayloadJson(_ payload: BootBioPayload) -> String {
        let encoder = JSONEncoder()
    //        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
}

