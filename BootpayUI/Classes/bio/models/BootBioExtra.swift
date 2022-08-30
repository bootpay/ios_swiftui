//
//  BootBioExtra.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2022/08/30.
//

import ObjectMapper


public class BootBioExtra: NSObject, Mappable, Codable {
    
    
    public override init() {
        super.init()
        self.appScheme = self.externalURLScheme()
//        self.appScheme = (self.externalURLScheme() ?? "") + "://"
    }
    public required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    func externalURLScheme() -> String? {
        guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String else { return nil }

        return externalURLScheme
    }
    
    public func mapping(map: Map) {
        cardQuota <- map["card_quota"]
        sellerName <- map["seller_name"]
        deliveryDay <- map["delivery_day"]
        locale <- map["locale"]
        offerPeriod <- map["offer_period"]
        
        displayCashReceipt <- map["display_cash_receipt"]
        depositExpiration <- map["deposit_expiration"]
        appScheme <- map["app_scheme"]
        useCardPoint <- map["use_card_point"]
        directCard <- map["direct_card"]
        
        useOrderId <- map["use_order_id"]
        internationalCardOnly <- map["international_card_only"]
        phoneCarrier <- map["phone_carrier"]
        directAppCard <- map["direct_app_card"]
        directSamsungpay <- map["direct_samsungpay"]
        testDeposit <- map["test_deposit"]
        enableErrorWebhook <- map["enable_error_webhook"]
        separatelyConfirmed <- map["separately_confirmed"]
        separatelyConfirmedBio <- map["separately_confirmed_bio"]
        confirmOnlyRestApi <- map["confirm_only_rest_api"]
        openType <- map["open_type"]
        redirectUrl <- map["redirect_url"]
        displaySuccessResult <- map["display_success_result"]
        displayErrorResult <- map["display_error_result"]
        useWelcomepayment <- map["use_welcomepayment"]
        disposableCupDeposit <- map["disposable_cup_deposit"]
        timeout <- map["timeout"]
        commonEventWebhook <- map["common_event_webhook"]
        
        enableCardCompanies <- map["enable_card_companies"]
        exceptCardCompanies <- map["except_card_companies"]
        enableEasyPayments <- map["enable_easy_payments"]
        firstSubscriptionComment <- map["first_subscription_comment"]
        confirmGraceSeconds <- map["confirm_grace_seconds"]
    }
    
    @objc public var cardQuota: String? //할부허용 범위 (5만원 이상 구매시)
    @objc public var sellerName: String? //노출되는 판매자명 설정
    @objc public var deliveryDay: Int = 1 //배송일자
    @objc public var locale = "ko" //결제창 언어지원
    @objc public var offerPeriod: String? //결제창 제공기간에 해당하는 string 값, 지원하는 PG만 적용됨
    @objc public var displayCashReceipt = true // 현금영수증 보일지 말지.. 가상계좌 KCP 옵션
    @objc public var depositExpiration = "" //가상계좌 입금 만료일자 설정
    @objc public var appScheme: String? //모바일 앱에서 결제 완료 후 돌아오는 옵션 ( 아이폰만 적용 )
    @objc public var useCardPoint = true //카드 포인트 사용 여부 (토스만 가능)
    @objc public var directCard = "" //해당 카드로 바로 결제창 (토스만 가능)
    @objc public var useOrderId = false //가맹점 order_id로 PG로 전송
    @objc public var internationalCardOnly = false //해외 결제카드 선택 여부 (토스만 가능)
    @objc public var phoneCarrier: String? //본인인증 시 고정할 통신사명, SKT,KT,LGT 중 1개만 가능
    @objc public var directAppCard = false //카드사앱으로 direct 호출
    @objc public var directSamsungpay = false //삼성페이 바로 띄우기
    @objc public var testDeposit = false //가상계좌 모의 입금
    @objc public var enableErrorWebhook = false //결제 오류시 Feedback URL로 webhook
//    @objc public var popup = true //네이버페이 등 특정 PG 일 경우 popup을 true로 해야함
    @objc public var separatelyConfirmed = true // confirm 이벤트를 호출할지 말지, false일 경우 자동승인, 간편결제에선 적용되지 않음
    @objc public var separatelyConfirmedBio = false // 중요 - 간편결제에서 true면 무조건 서버 승인(분리승인), false면 바로 승인
    @objc var separatelyConfirmedValue = false //separatelyConfirmed 또는 separatelyConfirmedBio 값으로 적용, 내부적으로 사용됨
    
    @objc public var confirmOnlyRestApi = false //REST API로만 승인 처리
    @objc public var openType = "redirect" //페이지 오픈 type, [iframe, popup, redirect] 중 택 1
    @objc public var useBootpayInappSdk = true //native app에서는 redirect를 완성도있게 지원하기 위한 옵션
    @objc public var redirectUrl: String? = "https://api.bootpay.co.kr/v2" //open_type이 redirect일 경우 페이지 이동할 URL (  오류 및 결제 완료 모두 수신 가능 )
    @objc public var displaySuccessResult = false //결제 완료되면 부트페이가 제공하는 완료창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var displayErrorResult = true //결제가 실패하면 부트페이가 제공하는 실패창으로 보여주기 ( open_type이 iframe, popup 일때만 가능 )
    @objc public var useWelcomepayment = false //웰컴 재판모듈 진행시 true
    
    
    @objc public var disposableCupDeposit: Int = 0 //배달대행 플랫폼을 위한 컵 보증급 가격
    @objc public var timeout: Int = 30 //결제만료 시간 (분단위)
    @objc public var commonEventWebhook = false //창닫기, 결제만료 웹훅 추가
    
    @objc public var enableCardCompanies: [String]? //https://developers.nicepay.co.kr/manual-code-partner.php '01,02,03,04,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,39,40,41,42'
    @objc public var exceptCardCompanies: [String]? //제외할 카드사 리스트 ( enable_card_companies가 우선순위를 갖는다 )
    @objc public var enableEasyPayments: [String]? //노출될 간편결제 리스트
    
    @objc public var firstSubscriptionComment: String? //자동결제 price > 0 조건일 때 첫 결제 관련 메세지
    
    @objc public var confirmGraceSeconds: Int = 10 //결제승인 유예시간 ( 승인 요청을 여러번하더라도 승인 이후 특정 시간동안 계속해서 결제 response_data 를 리턴한다 )
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(cardQuota, forKey: .cardQuota)
        try container.encodeIfPresent(sellerName, forKey: .sellerName)
        try container.encodeIfPresent(deliveryDay, forKey: .deliveryDay)
        try container.encodeIfPresent(locale, forKey: .locale)
        try container.encodeIfPresent(offerPeriod, forKey: .offerPeriod)
        try container.encodeIfPresent(displayCashReceipt, forKey: .displayCashReceipt)
        try container.encodeIfPresent(depositExpiration, forKey: .depositExpiration)
        try container.encodeIfPresent(appScheme, forKey: .appScheme)
        try container.encodeIfPresent(useCardPoint, forKey: .useCardPoint)
        try container.encodeIfPresent(directCard, forKey: .directCard)
        try container.encodeIfPresent(useOrderId, forKey: .useOrderId)
        try container.encodeIfPresent(internationalCardOnly, forKey: .internationalCardOnly)
        try container.encodeIfPresent(phoneCarrier, forKey: .phoneCarrier)
        try container.encodeIfPresent(directAppCard, forKey: .directAppCard)
        try container.encodeIfPresent(directSamsungpay, forKey: .directSamsungpay)
        try container.encodeIfPresent(testDeposit, forKey: .testDeposit)
        try container.encodeIfPresent(enableErrorWebhook, forKey: .enableErrorWebhook)
        try container.encodeIfPresent(separatelyConfirmedValue, forKey: .separatelyConfirmed)
        try container.encodeIfPresent(confirmOnlyRestApi, forKey: .confirmOnlyRestApi)
        try container.encodeIfPresent(openType, forKey: .openType)
        try container.encodeIfPresent(useBootpayInappSdk, forKey: .useBootpayInappSdk)
        try container.encodeIfPresent(redirectUrl, forKey: .redirectUrl)
        try container.encodeIfPresent(displaySuccessResult, forKey: .displaySuccessResult)
        try container.encodeIfPresent(displayErrorResult, forKey: .displayErrorResult)
        try container.encodeIfPresent(useWelcomepayment, forKey: .useWelcomepayment)
        
        try container.encodeIfPresent(disposableCupDeposit, forKey: .disposableCupDeposit)
        try container.encodeIfPresent(timeout, forKey: .timeout)
        try container.encodeIfPresent(commonEventWebhook, forKey: .commonEventWebhook)
        
        try container.encodeIfPresent(enableCardCompanies, forKey: .enableCardCompanies)
        try container.encodeIfPresent(exceptCardCompanies, forKey: .exceptCardCompanies)
        try container.encodeIfPresent(enableEasyPayments, forKey: .enableEasyPayments)
        try container.encodeIfPresent(firstSubscriptionComment, forKey: .firstSubscriptionComment)
        try container.encodeIfPresent(confirmGraceSeconds, forKey: .confirmGraceSeconds)
    }
    
}
