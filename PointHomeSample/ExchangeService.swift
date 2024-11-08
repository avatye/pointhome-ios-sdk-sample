//
//  ExchangeService.swift
//  PointHomeSample
//
//  Created by 임재혁 on 3/15/24.
//
//
import UIKit

enum exchangeType{
    case verify
    case rollback
}

class ExchangeService {
    
    func serverAction(transactionID: String, type: exchangeType) async throws -> String{
        
        print("exchangeService serverAction")
        
        func basicToken()->String{
            guard let appId = PHSelectInit.shared.appId,
                  let appSecretKey = PHSelectInit.shared.appSecretKey else{
                return "Basic " + String(format: "%@:%@", "16a99b26a7f64be4b512f4e82d972a5a", "a27984cf4bca4194").data(using: String.Encoding.utf8)!.base64EncodedString()
            }
            print("exchangeService appId \(appId) appSecretKey \(appSecretKey)")
            print("exchangeService basic Token \(String(format: "%@:%@", appId, appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString())")
            return "Basic " + String(format: "%@:%@", appId, appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString()
                
        }
        
        let urlString: String
        switch type {
        case .verify:
            if PHSelectInit.shared.modTage == 0{
                urlString = "https://api-qa.reward.avatye.com/shop/exchange/verifyV3"
            }else{
                urlString = "https://api.reward.avatye.com/shop/exchange/verifyV3"
            }
        case .rollback:
            if PHSelectInit.shared.modTage == 0 {
                urlString = "https://api-qa.reward.avatye.com/shop/exchange/rollbackV2"
            }else{
                urlString = "https://api.reward.avatye.com/shop/exchange/rollbackV2"
            }
        }
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "transacionID Parsing Error", code: 0, userInfo: nil)
        }
        
        let requestBody = ["transactionID": transactionID]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw NSError(domain: "transacionID Parsing Error", code: 0, userInfo: nil)
        }
        
        print("requestBody \(requestBody)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(basicToken(), forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        if let responseString = String(data: data, encoding: .utf8){
            print("exchangeService 응답 : \(responseString)")
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let resultCode = jsonObject["resultCode"] as? String else{
            throw NSError(domain: "JSON Parsing Error", code: 0, userInfo: nil)
        }
        
        print("exchangeService resultCode 응답 : \(resultCode)")
        
//        await Task.sleep(5 * 1_000_000_000) // 초 단위로 변환하기 위해 1_000_000_000을 곱함
//        
//        print("exchangeService resultCode 응답 5초 후 : \(resultCode)")
        
        return resultCode
        
    }
    
    func exchangeCompletion(transactionID: String, type: exchangeType, completion: @escaping (Result<String, Error>) -> Void) {
        
        print("exchangeService serverAction")
        
        func basicToken() -> String {
            guard let appId = PHSelectInit.shared.appId,
                  let appSecretKey = PHSelectInit.shared.appSecretKey else {
                return "Basic " + String(format: "%@:%@", "16a99b26a7f64be4b512f4e82d972a5a", "a27984cf4bca4194").data(using: String.Encoding.utf8)!.base64EncodedString()
            }
            print("exchangeService appId \(appId) appSecretKey \(appSecretKey)")
            print("exchangeService basic Token \(String(format: "%@:%@", appId, appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString())")
            return "Basic " + String(format: "%@:%@", appId, appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString()
        }
        
        let urlString: String
        switch type {
        case .verify:
            if PHSelectInit.shared.modTage == 0 {
                urlString = "https://api-qa.reward.avatye.com/shop/exchange/verifyV3"
            } else {
                urlString = "https://api.reward.avatye.com/shop/exchange/verifyV3"
            }
        case .rollback:
            if PHSelectInit.shared.modTage == 0 {
                urlString = "https://api-qa.reward.avatye.com/shop/exchange/rollbackV2"
            } else {
                urlString = "https://api.reward.avatye.com/shop/exchange/rollbackV2"
            }
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "transactionID Parsing Error", code: 0, userInfo: nil)))
            return
        }
        
        let requestBody = ["transactionID": transactionID]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "transactionID Parsing Error", code: 0, userInfo: nil)))
            return
        }
        
        print("requestBody \(requestBody)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(basicToken(), forHTTPHeaderField: "Authorization")
        
        // 비동기 작업을 completion handler로 처리
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("exchangeService 응답: \(responseString)")
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let resultCode = jsonObject["resultCode"] as? String else {
                completion(.failure(NSError(domain: "JSON Parsing Error", code: 0, userInfo: nil)))
                return
            }
            
            print("exchangeService resultCode 응답: \(resultCode)")
            
            // 성공적으로 처리되었음을 completion으로 반환
            completion(.success(resultCode))
            
        }.resume() // URLSession의 dataTask는 resume()으로 실행됩니다.
    }}
