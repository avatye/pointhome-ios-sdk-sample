//
//  AcceptedAgeService.swift
//  PointHomeSample
//
//  Created by 임재혁 on 7/18/24.
//

import UIKit
import AvatyePointHome

class SingleTonTest {
    static let shared = SingleTonTest()
    
    var testKey: Bool = false
}

class AcceptedAgeService{
    
    init(){}
    
    func AgeCheckService(userKey: String) async throws -> acceptedUserModel{
        
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 5초 단위로 변환.
    
        if let firstCharacter = userKey.first, firstCharacter.isNumber{
            let model = acceptedUserModel(usable: true)
            return model
        } else {
            let model = acceptedUserModel(usable: true)
            return model
        }
    }
    
    func AgeCheckCompletion(userKey: String, completion: @escaping (Result<acceptedUserModel, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            if let firstCharacter = userKey.first, firstCharacter.isNumber{
                let model = acceptedUserModel(usable: true)
                completion(.success(model))
            }else{
                let model = acceptedUserModel(usable: false, message: "dddd\\nddddd")
                completion(.success(model))
            }
        }
    }
    
}
