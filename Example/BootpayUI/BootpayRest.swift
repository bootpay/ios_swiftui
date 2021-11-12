//
//  BootpayRest.swift
//  bootpayBio
//
//  Created by Taesup Yoon on 2021/05/17.
//
 
import Alamofire
import Bootpay


class BootpayRest {

//    @Published var userToken = ""
    
    @available(*, deprecated, message: "이 로직은 서버사이드에서 수행되어야 합니다. rest_application_id와 prviate_key는 보안상 절대로 노출되어서 안되는 값입니다. 개발자의 부주의로 고객의 결제가 무단으로 사용될 경우, 부트페이는 책임이 없음을 밝힙니다.")
    public func getUserToken(restApplicationId: String, privateKey: String, user: BootUser, completionHandler: @escaping(Bool, String) -> Void) {
        getRestToken(
            restApplicationId: restApplicationId,
            privateKey: privateKey,
            user: user,
            completionHandler: completionHandler)
    }
    
    @available(*, deprecated, message: "이 로직은 서버사이드에서 수행되어야 합니다. rest_application_id와 prviate_key는 보안상 절대로 노출되어서 안되는 값입니다. 개발자의 부주의로 고객의 결제가 무단으로 사용될 경우, 부트페이는 책임이 없음을 밝힙니다.")
    private func getRestToken(restApplicationId: String, privateKey: String, user: BootUser, completionHandler: @escaping(Bool, String) -> Void) {
        
        var params = [String: Any]()
        params["application_id"] = restApplicationId
        params["private_key"] = privateKey

        let finalBody = try! JSONSerialization.data(withJSONObject: params)

        let url = URL(string: "https://api.bootpay.co.kr/request/token.json")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
             
           do {
               let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
               guard let jsonObject = object else { return }
            
               print(jsonObject)
               
               if(jsonObject["code"] as? Int == 0) {
               
                   if let data = (jsonObject["data"] as? [String: Any]), let token = data["token"] as? String {
                       
                       self.getEasyPayUserToken(token: token, user: user, completionHandler: completionHandler)
                   }
               }
               
           } catch let e as NSError {
               print("An error has occured while parsing JSON Obejt : \(e.localizedDescription)")
           }
        }.resume()
    }
    
    @available(*, deprecated, message: "이 로직은 서버사이드에서 수행되어야 합니다. rest_application_id와 prviate_key는 보안상 절대로 노출되어서 안되는 값입니다. 개발자의 부주의로 고객의 결제가 무단으로 사용될 경우, 부트페이는 책임이 없음을 밝힙니다.")
    private func getEasyPayUserToken(token: String, user: BootUser, completionHandler: @escaping(Bool, String) -> Void) {
        
        print(token)
        
        var params = [String: Any]()
        params["user_id"] = user.userId
        params["email"] = user.email
        params["name"] = user.username
        params["gender"] = user.gender
        params["birth"] = user.birth
        params["phone"] = user.phone
         
        let finalBody = try! JSONSerialization.data(withJSONObject: params)
        
        let url = URL(string: "https://api.bootpay.co.kr/request/user/token")
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            do {
                let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                guard let jsonObject = object else { return }
                print(jsonObject)
                
                if(jsonObject["code"] as? Int == 0) {

                    if let data = (jsonObject["data"] as? [String: Any]), let token = data["user_token"] as? String {

//                        self.userToken = token
                        
                        completionHandler(true, token)
                        return
//                           self.getEasyPayUserToken(token: token, user: user)
                    }
                }
                        
                completionHandler(false, "")
//                   print(jsonObject)
                
            } catch let e as NSError {
                print("An error has occured while parsing JSON Obejt : \(e.localizedDescription)")
                completionHandler(false, "")
            }
        }.resume()
        
    }
    
}
 
