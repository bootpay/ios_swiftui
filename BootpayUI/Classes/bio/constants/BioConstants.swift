//
//  BioConstants.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2022/03/10.
//

import Foundation
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


//extension UIButton {
//    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
//        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        context.setFillColor(color.cgColor)
//        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
//
//        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        self.setBackgroundImage(backgroundImage, for: state)
//    }
//}


struct BioConstants {
    static let CDN_URL = "https://webview.bootpay.co.kr/4.0.6";
//    static let BRIDGE_NAME = "Bootpay_Bio_iOS"
 
    public static let REQUEST_TYPE_NONE = -1
    public static let REQUEST_PASSWORD_TOKEN = 10 //최초요청시 - 비밀번호 설정하기
    public static let REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD = 11 //카드 등록 전 토큰이 없을 때
    public static let REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY = 12 //생체인증 결제 전 토큰이 없을 때
    public static let REQUEST_BIOAUTH_FOR_BIO_FOR_PAY = 13 //생체인증 결제 전 기기등록이 안 됬을때
    
    public static let REQUEST_ADD_BIOMETRIC = 15 //생체인식 정보등록
    public static let REQUEST_ADD_BIOMETRIC_FOR_PAY = 16 //결제 전 생체인식 정보등록
    
    public static let REQUEST_ADD_BIOMETRIC_NONE = 17 //생체인식 정보등록 수행 후 NONE 처리 (이벤트가 재귀함수 호출되지 않도록)
    public static let REQUEST_ADD_CARD = 20 //카드 등록
    public static let REQUEST_ADD_CARD_NONE = 21  //카드 등록 수행 후 NONE 처리 (이벤트가 재귀함수 호출되지 않도록)
    public static let REQUEST_BIO_FOR_PAY = 30 //결제를 위해 생체인증 진행
    public static let REQUEST_PASSWORD_FOR_PAY = 40 //비밀번호로 결제 진행
    public static let REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY = 41 //비밀번호 결제 전 토큰이 없을 때
    
    public static let REQUEST_TOTAL_PAY = 50 //통합결제
    
    public static let REQUEST_PASSWORD_TOKEN_DELETE_CARD = 60 //카드 삭제
    public static let REQUEST_DELETE_CARD = 61 //카드 삭제
    
    
    public static let NEXT_JOB_RETRY_PAY = 100
    public static let NEXT_JOB_ADD_NEW_CARD = 101
    public static let NEXT_JOB_ADD_DELETE_CARD = 102
    public static let NEXT_JOB_GET_WALLET_LIST = 103
    
    
//    public static let REQUEST_TYPE_VERIFY_PASSWORD = 1 // 생체인식 활성화용도
//    public static let REQUEST_TYPE_VERIFY_PASSWORD_FOR_PAY = 2 //비밀번호로 결제 용도
//    public static let REQUEST_TYPE_REGISTER_CARD = 3 //카드 생성
//    public static let REQUEST_TYPE_PASSWORD_CHANGE = 4 //카드 삭제
//    public static let REQUEST_TYPE_ENABLE_DEVICE = 5 //해당 기기 활성화
//
//    public static let REQUEST_TYPE_ENABLE_OTHER = 6 //통합결제
//    public static let REQUEST_TYPE_PASSWORD_PAY = 7 //카드 간편결제 (비밀번호) - 생체인증 정보가 기기에 없을때
    
    
    
    static func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
    static func getPGCss(payload: BootBioPayload) -> String {
        guard let pg = payload.pg else { return "" }
        if(pg == "inicis") {
            return "body { background-color: white }"
        }
            
//        if(payload.p)
        return ""
    }
    
    static func getCssScript(payload: BootBioPayload) -> String {
        let pgCss = getPGCss(payload: payload)
        if(pgCss.isEmpty) { return "" }
        let source = """
             var style = document.createElement('style');
             style.innerHTML = '\(pgCss)';
             document.head.appendChild(style);
           """
 
        return source
    }
    
    static func getJSBeforePayStart(payload: BootBioPayload) -> [String] {
        var array = [String]()
        array.append(close())
        if(BootpayBuildConfig.DEBUG) {
            array.append("Bootpay.setEnvironmentMode('development', 'gosomi.bootpay.co.kr');")
            array.append("BootpaySDK.setEnvironmentMode('development', 'gosomi.bootpay.co.kr');")
        }
        
        #if os(iOS)
        array.append("Bootpay.setDevice('IOS');")
        array.append("Bootpay.setLogLevel(4);")
        array.append("Bootpay.setVersion('\(BootpayBuildConfig.VERSION)', 'ios')")
        array.append("BootpaySDK.setDevice('IOS');")
        array.append("BootpaySDK.setLogLevel(4);")
        array.append("BootpaySDK.setUUID('\(Bootpay.getUUID())');")
//        let cssScript = getCssScript(payload: payload)
//        if cssScript.count > 0 {
//            array.append(cssScript)
//        }
        #endif
//        array.append(getAnalyticsData())
//        if(quickPopup) { array.append("BootPay.startQuickPopup();") }
        return array
    }
    
//    static func getAnalyticsData() -> String {
//        return "window.BootPay.setAnalyticsData({"
//            + "sk: '\(Bootpay.getSk())', "
//            + "sk_time: \(Bootpay.getSkTime()), "
//            + "uuid: '\(Bootpay.getUUId())'"
//            + "});"
//    }
        
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
    
    static func getJSTotalPay(payload: BootBioPayload) -> String {
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
        payload.user?.setEncodedValueAll()
        
        
        return [
            "Bootpay.requestPayment(",
            getPayloadJson(payload),
            ")",
            ".then( function (data) {",
            confirm(),
            "else { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSPasswordToken(payload: BootBioPayload) -> String {
        return [
            "BootpaySDK.requestPasswordToken('",
            payload.userToken ,
            "')",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSChangePassword(payload: BootBioPayload) -> String {
        return [
            "BootpaySDK.requestChangePassword('",
            payload.userToken ,
            "')",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSAddCard(payload: BootBioPayload) -> String {
        return [
            "BootpaySDK.requestAddCard('",
            payload.userToken ,
            "')",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSPasswordPay( payload: BootBioPayload) -> String {
        payload.authenticateType = "token"
        if(payload.token.count == 0) {
            payload.token = BootpayDefaultHelper.getString(key: "password_token")
        }
        if(payload.price < 50000) {
            if(payload.extra == nil) { payload.extra = BootExtra() }
            payload.extra?.cardQuota = "0"
        }
        
        return [
            "BootpaySDK.requestWalletPayment(",
            getPayloadJson(payload),
            ")",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSBioOTPPay(payload: BootBioPayload) -> String {
        payload.authenticateType = "otp"
        if(BootpayBio.sharedBio.selectedCardQuota != -1 && payload.price >= 50000) {
            if(payload.extra == nil) {
                payload.extra = BootExtra()
            }
            if(BootpayBio.sharedBio.selectedCardQuota == 0) {
                payload.extra?.cardQuota = "\(BootpayBio.sharedBio.selectedCardQuota)"
            } else {
                payload.extra?.cardQuota = "\(BootpayBio.sharedBio.selectedCardQuota + 1)"
            }
        } else if(payload.price < 50000) {
            payload.extra?.cardQuota = "0"
        }
        
        return [
            "BootpaySDK.requestWalletPayment(",
            getPayloadJson(payload),
            ")",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSBiometricAuthenticate(payload: BootBioPayload) -> String{
//        createBiometricAuthenticate
        let payload = [
            "userToken": payload.userToken,
            "os": "ios",
            "token": payload.token
        ]
        
        return [
            "BootpaySDK.createBiometricAuthenticate(",
            getDicToJson(payload),
            ")",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    static func getJSDestroyWallet(payload: BootBioPayload) -> String {
        
        let payload = [
            "authenticate_type": "password",
            "user_token": payload.userToken,
            "wallet_id": payload.walletId,
            "token": payload.token
        ]
        
        return [
            "BootpaySDK.destroyWallet(",
            getDicToJson(payload),
            ")",
            ".then( function (data) {",
            easySuccess(),
            "}, function (data) {",
            cancel(),
            easyError(),
            "})"
        ].reduce("", +)
    }
    
    
    static func easySuccess() -> String {
        return "webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data);"
    }
    
    static func easyError() -> String {
        return "else { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func confirm() -> String {
        return "if (data.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func done() -> String {
        return "else if (data.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func issued() -> String {
        return "else if (data.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func error() -> String {
        return "else if (data.event === 'error') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func cancel() -> String {
        return "if (data.event === 'cancel') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }"
    }
    
    static func close() -> String {
        return "document.addEventListener('bootpayclose', function (e) { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage('close'); });"
    }
//    private static String easyError() { return " else { Android.easyError(JSON.stringify(res)); }"; }
    
     
//
//    static func confirm() -> String {
//        return ".confirm(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
//    }
//
//    static func ready() -> String {
//        return ".ready(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
//    }
//
//    static func cancel() -> String {
//        return ".cancel(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
//    }
//
//    static func done() -> String {
//        return ".done(function (data) {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage(data);})"
//    }
//
//    static func close() -> String {
//        return ".close(function () {webkit.messageHandlers.\(BootpayConstants.BRIDGE_NAME).postMessage('close');})"
//    }
        
    static private func getPayloadJson(_ payload: BootBioPayload) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(payload), encoding: .utf8)!
    }
    
    static private func getDicToJson(_ dic: [String:String]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return String(data: try! encoder.encode(dic), encoding: .utf8)!
    }
}
