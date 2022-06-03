//
//  BootpayBioWebView.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/14.
//

import WebKit
import Bootpay
 

@objc open class BootpayBioWebView: BTView, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
//    public var requestType = BioConstants.REQUEST_TYPE_NONE
    var webview: WKWebView!
    var payload: BootBioPayload?
    
    var beforeUrl = ""
    var isFirstLoadFinish = false
    var isStartBootpay = false
    
    
    @objc public var onNextJob: (([String : Any]) -> Void)?
     
    
    @objc public func nextJob(_ action: @escaping ([String : Any]) -> Void) {
        onNextJob = action
    }
    
    
    init() {
//        super.init(frame: CGRect(x: 0,
//                                 y: 0,
//                                 width: UIScreen.main.bounds.size.width,
//                                 height: UIScreen.main.bounds.size.height
//               ))
//        self.backgroundColor = .white
        
        #if os(macOS)
        super.init(frame: NSScreen.main!.frame)
        #elseif os(iOS)
//        super.init()
        super.init(frame: UIScreen.main.bounds)
        #endif
//        super.init()
        
        initComponent()
    }
    
    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
//    func resizeFrame() {
//        if let pg = payload?.pg {
//            if(pg == "kcp") {
//                self.webview.frame = CGRect(x: 0,
//                                         y: 0,
//                                         width: UIScreen.main.bounds.size.width,
//                                            height: self.frame.height - 160
//                )
//            }
//            return
//        }
//
//        self.webview.frame = CGRect(x: 0,
//                                 y: 0,
//                                 width: UIScreen.main.bounds.size.width,
//                                 height: self.frame.height - 160
//        )
//    }
     
    
    func initComponent() {
        HTTPCookieStorage.shared.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always  // 현대카드 등 쿠키설정 이슈 해결을 위해 필요
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: BootpayConstant.BRIDGE_NAME)
//        webview = WKWebView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 80), configuration: configuration)
        #if os(macOS)
            webview = WKWebView(frame: self.bounds, configuration: configuration)

        //            webview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         
        #elseif os(iOS)
        
        webview = WKWebView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: UIScreen.main.bounds.width,
                                          height: UIScreen.main.bounds.height), configuration: configuration)

        #endif
         
        self.addSubview(webview)
        webview.uiDelegate = self
        webview.navigationDelegate = self
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        let constrains = [
            webview.topAnchor.constraint(equalTo: self.safeTopAnchor),
            webview.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            webview.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
            webview.trailingAnchor.constraint(equalTo: self.trailingAnchor),
 
            ]
        NSLayoutConstraint.activate(constrains)
        
        if(self.payload == nil) {
            self.payload = BootpayBio.sharedBio.bioPayload
        }
        Bootpay.shared.webview = webview
//        BootpayBio.sharedBio.bioVc?.bioWebView = webview
    }
    
    func startBootpay() {
        if let url = URL(string: BioConstants.CDN_URL) {
//        if let url = URL(string: "https://www.google.com") {
            webview.load(URLRequest(url: url))
            self.isStartBootpay = true
        }
    }
    
    func requestPasswordToken()  {
//        if let type = type { requestType = type }
//        else { requestType = BioConstants.REQUEST_PASSWORD_TOKEN }
        
        requestScript()
    }
    
    func requestAddCard()  {
//        requestType = BioConstants.REQUEST_ADD_CARD
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_ADD_CARD
        requestScript()
    }
    
    func requestDeleteCard(_ token: String, payload: BootBioPayload) {
        payload.token = token
        self.payload = payload
        
//        requestType = BioConstants.REQUEST_DELETE_CARD
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_DELETE_CARD
        requestScript()
    }
    
//    func requestAddBioData() {
//
//        requestType = BioConstants.REQUEST_BIO_FOR_PAY
//        requestScript()
//    }
    
    func requestBioForPay(_ otp: String, payload: BootBioPayload) {
//        requestType = BioConstants.REQUEST_BIO_FOR_PAY
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_BIO_FOR_PAY
        
        payload.token = otp
        self.payload = payload
//        self.payload?.authenticateType = "otp"
        requestScript()
    }
    
    func requestPasswordForPay(_ token: String, payload: BootBioPayload) {
        payload.token = token
        self.payload = payload
        
//        requestType = BioConstants.REQUEST_PASSWORD_FOR_PAY
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_PASSWORD_FOR_PAY
        requestScript()
    }
    
    func requestScript() {
        if isFirstLoadFinish == false {
            startBootpay()
        } else {
            callInjectedJavaScript()
        }
    }
    
    func requestAddBioData(_ token: String, payload: BootBioPayload) {
//        requestType = BioConstants.REQUEST_ADD_BIOMETRIC
        payload.token = token
        self.payload = payload
//        self.payload =
        requestScript()
    }
    
    func requestTotalForPay(payload: BootBioPayload) {
        payload.userToken = ""
//        requestType = BioConstants.REQUEST_TOTAL_PAY
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TOTAL_PAY
        requestScript()
        
    }
    
    func callInjectedJavaScript() {
        guard let payload = self.payload else { return }
        var scriptPay = ""
        if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN ||
           BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD ||
           BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY ||
           BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY ||
           BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD) {
            scriptPay = BioConstants.getJSPasswordToken(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_CARD) {
            scriptPay = BioConstants.getJSAddCard(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_BIO_FOR_PAY) {
            scriptPay = BioConstants.getJSBioOTPPay(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_FOR_PAY) {
            scriptPay = BioConstants.getJSPasswordPay(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_BIOMETRIC ||
                  BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
            scriptPay = BioConstants.getJSBiometricAuthenticate(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_TOTAL_PAY) {
            scriptPay = BioConstants.getJSTotalPay(payload: payload)
        } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_DELETE_CARD) {
            scriptPay = BioConstants.getJSDestroyWallet(payload: payload)
        }
        
//        print("scriptPay: \(scriptPay), requestType: \(BootpayBio.sharedBio.requestType)")
         
        if(!scriptPay.isEmpty) { webview.evaluateJavaScript(scriptPay, completionHandler: nil) }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          
        if isFirstLoadFinish == false && self.isStartBootpay == true {
            isFirstLoadFinish = true
            
            let scriptList = BioConstants.getJSBeforePayStart(payload: self.payload!)
            for script in scriptList {
//                print(script)
                webView.evaluateJavaScript(script, completionHandler: nil)
            }
            callInjectedJavaScript()
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url =  navigationAction.request.url else { return decisionHandler(.allow) }
        beforeUrl = url.absoluteString
        
//        print(url.absoluteString)
        updateBlindViewIfNaverLogin(webView, url.absoluteString)
        
        if(isItunesURL(url.absoluteString)) {
            startAppToApp(url)
            decisionHandler(.cancel)
        } else if(!url.absoluteString.starts(with: "http")) {
            startAppToApp(url)
//            decisionHandler(.allow)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        let popupView = WKWebView(frame: CGRect(x: 0, y: 0, width: webView.frame.width, height: webView.frame.height), configuration: configuration)
        #if os(iOS)
        popupView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #endif
        popupView.navigationDelegate = self
        popupView.uiDelegate = self

        self.addSubview(popupView)
        return popupView
    }
    
    
    public func webViewDidClose(_ webView: WKWebView) {
      
        webView.removeFromSuperview()
    }
     
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        print("action = \(message.body), type = \(BootpayBio.sharedBio.requestType)")
        if(message.name == BootpayConstant.BRIDGE_NAME) {
            guard let body = message.body as? [String: Any] else {
                if message.body as? String == "close" {
                    self.onClose()
                } else {
//                    self.onEasySuccess(data: message.body)
                    
                    let dic = convertStringToDictionary(text: message.body as! String)
                    guard let dic = dic else {
                        self.onEasySuccess(data: message.body)
                        return
                    }
                    parseBootpayEvent(data: dic)
                }
                return
            }
            
            parseBootpayEvent(data: body)
            
            
//            guard let event = body["event"] as? String else {
//                self.onEasySuccess(data: body)
//                return
//            }
//
//            if event == "cancel" {
//                onCancel(data: body)
//            } else if event == "error" {
//                onError(data: body)
//            } else if event == "issued" {
//                onIssued(data: body)
//            } else if event == "confirm" {
//                onConfirm(data: body)
//
//            } else if event == "done" {
//                onDone(data: body)
//            }
        }
    }
    
    
    func parseBootpayEvent(data: [String: Any]) {
        var isRedirect = false
        if(payload?.extra?.openType == "redirect") { isRedirect = true }
        
        guard let event = data["event"] as? String else {
            self.onEasySuccess(data: data)
            return
        }
        
        if event == "cancel" {
            onCancel(data: data, isRedirect: isRedirect)
        } else if event == "error" {
            onError(data: data, isRedirect: isRedirect)
        } else if event == "issued" {
            onIssued(data: data, isRedirect: isRedirect)
        } else if event == "confirm" {
            onConfirm(data: data)
        } else if event == "done" {
            onDone(data: data, isRedirect: isRedirect)
        } else if event == "close" {
            //결과페이지에서 닫기 버튼 클릭시
            onClose()
        }
    }
    
    
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}
 
extension BootpayBioWebView {
    
    func updateBlindViewIfNaverLogin(_ webView: WKWebView, _ url: String) {
        if(url.starts(with: "https://nid.naver.com")) { //show
            webView.evaluateJavaScript("document.getElementById('back').remove();")
        }
    }
    
    internal func doJavascript(_ script: String) {
        webview.evaluateJavaScript(script, completionHandler: nil)
    }
    
    internal func loadUrl(_ urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            webview.load(request)
        }
    }
    
    func naverLoginBugFix() {
        //네아로 로그인일 경우 요청
        if(beforeUrl.starts(with: "naversearchthirdlogin://")) {
            //방법1. 네아로 로그인을 부트페이가 중간에서 개입할 수 없기때문에, 중간에서 강제로 호출
            if let value = getQueryStringParameter(url: beforeUrl, param: "session") {
                if let url = URL(string: "https://nid.naver.com/login/scheme.redirect?session=\(value)") {
                    self.webview.load(URLRequest(url: url))
                }
            }
            
            //방법2. 네아로 로그인을 부트페이가 중간에서 개입할 수 없기때문에, 대안으로 브라우저에 노출된 이벤트를 실행시킨다
//            self.popupWV?.evaluateJavaScript("document.getElementById('appschemeLogin_again').click()", completionHandler: nil)
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func startAppToApp(_ url: URL) {
        #if os(iOS)
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        #endif
    }
    
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
    
    func transactionConfirm() {
        let script = [
            "Bootpay.confirm()",
            ".then( function (data) {",
            "if (data.event === 'confirm') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "else if(data.event === 'issued') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "else if(data.event === 'done') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "}, function (data) {",
            "if(data.event === 'error') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "else if(data.event === 'cancel') { webkit.messageHandlers.\(BootpayConstant.BRIDGE_NAME).postMessage(data); }",
            "})"
        ].reduce("", +)
        
        
        webview.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension BootpayBioWebView {
    func onError(data: [String: Any], isRedirect: Bool) {
        print("onError: \(data)")
        
//        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
//        BootpayBio.sharedBio.error?(data)
//        if(payload?.extra?.displayErrorResult != true && isRedirect) {
//            BootpayBio.sharedBio.close?()
//            BootpayBio.removePaymentWindow()
//        } else {
//            BootpayBio.removePaymentWindow()
//        }
        
//
        if let error_code = data["error_code"], error_code as! String == "USER_PW_TOKEN_NOT_FOUND" || error_code as! String == "USER_PW_TOKEN_EXPIRED" {
            
            
            let dic = [
                "nextType": BioConstants.REQUEST_PASSWORD_FOR_PAY,
                "initToken": true
            ] as [String : Any]
            onNextJob?(dic)  // error_code을때가 있어 강제 예외처리

        } else if let error_code = data["error_code"], error_code as! String == "PASSWORD_TOKEN_STOP" {
            BootpayBio.sharedBio.debounceClose()
//            BootpayBio.sharedBio.close?()
            BootpayBio.removePaymentWindow()
        } else {
            let dic = [
                "type": BioConstants.REQUEST_TYPE_NONE,
                "initToken": true
            ] as [String : Any]
            onNextJob?(dic)  // error_code을때가 있어 강제 예외처리
            
            BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
            BootpayBio.sharedBio.error?(data)
            if(payload?.extra?.displayErrorResult != true && isRedirect) {
                BootpayBio.sharedBio.debounceClose()
//                BootpayBio.sharedBio.close?()
                BootpayBio.removePaymentWindow()
            } else {
                BootpayBio.removePaymentWindow()
            }
        }
    }
    
    func onClose() {
//        print("close")
        
        if([BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY,
            BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD,
            BioConstants.REQUEST_ADD_CARD,
            BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY].contains(BootpayBio.sharedBio.requestType)) {
            var dic = [
                "type": BootpayBio.sharedBio.requestType
            ] as [String : Any]
            
            if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY ||
               BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY) {
                dic["nextType"] = BioConstants.NEXT_JOB_RETRY_PAY
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD) {
                dic["nextType"] = BioConstants.NEXT_JOB_ADD_NEW_CARD
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD) {
                dic["nextType"] = BioConstants.NEXT_JOB_ADD_DELETE_CARD
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_ADD_CARD) {
                dic["nextType"] = BioConstants.NEXT_JOB_GET_WALLET_LIST
            } else if(BootpayBio.sharedBio.requestType == BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY) {
                dic["nextType"] = BioConstants.REQUEST_PASSWORD_FOR_PAY
            }
            
            onNextJob?(dic)
        } else {
            if(BioConstants.REQUEST_BIO_FOR_PAY != BootpayBio.sharedBio.requestType) {
                BootpayBio.sharedBio.debounceClose()
//                BootpayBio.sharedBio.close?()
                BootpayBio.removePaymentWindow()
            }
        }
    }
    
    func onIssued(data: [String: Any], isRedirect: Bool) {
//        print("onIssued: \(data)")
        
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
        BootpayBio.sharedBio.issued?(data)
        
        if(payload?.extra?.displaySuccessResult != true && isRedirect) {
            BootpayBio.sharedBio.debounceClose()
//            BootpayBio.sharedBio.close?()
            BootpayBio.removePaymentWindow()
        }
    }
    
    
    func onConfirm(data: [String: Any]) {
//        print("onConfirm: \(data)")
        
        if let confirm = BootpayBio.sharedBio.confirm {
            if(confirm(data)) {
                transactionConfirm()
//                        Bootpay.confirm(data: body)
            }
        }
    }
    
    func onCancel(data: [String: Any], isRedirect: Bool) {
//        print("onCancel: \(data)")
        
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
        BootpayBio.sharedBio.cancel?(data)
        
        if(isRedirect) {
            BootpayBio.sharedBio.debounceClose()
//            BootpayBio.sharedBio.close?()
            BootpayBio.removePaymentWindow()
        }
        
//        if let error_code = data["error_code"] as? String {
//            //카드 추가시 닫기
//            if(error_code == "RC_CLOSE_WINDOW") {
//                BootpayBio.sharedBio.close?()
//                BootpayBio.removePaymentWindow()
//                return
//            }
//        }
    }
    
    
    func onDone(data: [String: Any], isRedirect: Bool) {
//        print("onDone: \(data)")
        BootpayBio.sharedBio.done?(data)
        if(payload?.extra?.displaySuccessResult != true && isRedirect) {
            BootpayBio.sharedBio.debounceClose()
//            BootpayBio.sharedBio.close?()
            BootpayBio.removePaymentWindow()
        }
    }
    
    
    func onEasyError(data: [String: Any]) {
        print("onEasyError: \(data)")
        let dic = [
            "type": BioConstants.REQUEST_TYPE_NONE,
            "initToken": true
        ] as [String : Any]
        
        onNextJob?(dic)  // error_code을때가 있어 강제 예외처리
//
        BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
        BootpayBio.sharedBio.error?(data)
        
//        if let error_code = data["error_code"], error_code as! String == "USER_PW_TOKEN_NOT_FOUND" || error_code as! String == "USER_PW_TOKEN_EXPIRED" {
//            let dic = [
//                "nextType": BioConstants.REQUEST_PASSWORD_FOR_PAY,
//                "initToken": true
//            ] as [String : Any]
//            onNextJob?(dic)  // error_code을때가 있어 강제 예외처리
//
//        } else {
//            BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
//            BootpayBio.sharedBio.error?(data)
//        }
        
    }
    
    //onEasuSuccess 먼저 수행 후 onEasyError로 보내주자
    func onEasySuccess(data: Any?) {
//        print("onEasySuccess: \(data)")
        
        if([BioConstants.REQUEST_PASSWORD_TOKEN,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_ADD_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_DELETE_CARD,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_BIO_FOR_PAY,
            BioConstants.REQUEST_PASSWORD_TOKEN_FOR_PASSWORD_FOR_PAY
           ].contains(BootpayBio.sharedBio.requestType)) {
            let dic = [
                "type": BootpayBio.sharedBio.requestType,
                "token": data as? String ?? ""
            ] as [String : Any]
            onNextJob?(dic)
        } else if(BioConstants.REQUEST_ADD_BIOMETRIC_FOR_PAY == BootpayBio.sharedBio.requestType) {
            if var dic = data as? [String:Any] {
                dic["type"] = BootpayBio.sharedBio.requestType
                dic["nextType"] = BioConstants.NEXT_JOB_GET_WALLET_LIST
                
//                print("wallet data = \(dic)")
                onNextJob?(dic)
            }
        } else {
            if(BioConstants.REQUEST_PASSWORD_FOR_PAY == BootpayBio.sharedBio.requestType) {
                let dic = [
                    "initToken": true
                ] as [String : Any]
                onNextJob?(dic)
            }
            if(BioConstants.REQUEST_ADD_CARD != BootpayBio.sharedBio.requestType) {
                BootpayBio.sharedBio.requestType = BioConstants.REQUEST_TYPE_NONE
            }
             
            BootpayBio.sharedBio.done?(data as? [String:Any] ?? [String:Any]())
        }
    }
}
