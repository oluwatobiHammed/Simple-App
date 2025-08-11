//
//  NetworkManager.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

struct NetworkManager {
    
    let router = Router<Endpoints>()
    var isDebugModeEnabled: Bool {
        get {
            guard let debugModeState = Bundle.main.object(
                forInfoDictionaryKey:
                    "DebugModeState"
            ) as? NSString, debugModeState.boolValue else {
                return false
            }
            return debugModeState.boolValue
        }
    }
    
    
    func getPictures() async throws -> [Pictures] {
        let (data, response, error) = await router.request(.getPictures)
        
        if error != nil {
            throw  NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
        
        if let response = response as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.noData.rawValue]
                    )
                }
                do {
                    
                    let jsonData = try JSONSerialization.jsonObject(
                        with: responseData,
                        options: .mutableContainers
                    )
                    if isDebugModeEnabled { print(jsonData) }
                    
                    guard let pics = try? [Pictures].decode(data: responseData) else {
                        throw NSError(
                            domain: "",
                            code: response.statusCode,
                            userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                        )
                    }
                  
                    return pics
                }catch {
                    
                    
                    throw NSError(
                        domain: "",
                        code: response.statusCode,
                        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.unableToDecode.rawValue]
                    )
                }
            case .failure(let networkFailureError):
                throw networkFailureError
            }
        } else {
            throw NSError(
                domain: "",
                code: URLError.Code.notConnectedToInternet.rawValue,
                userInfo: [NSLocalizedDescriptionKey : "Please check your network connection."]
            )
        }
        
    }
}


func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<Error>{
   switch response.statusCode {
   case 200...299: return .success
   case 404: return .success
   case 401...500: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.authenticationError.rawValue]
    )
   )
   case 501...599: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.badRequest.rawValue]
    )
   )
   case 600: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.outdated.rawValue]
    )
   )
   default: return .failure(
    NSError(
        domain: "",
        code: response.statusCode,
        userInfo: [NSLocalizedDescriptionKey : NetworkResponse.failed.rawValue]
    )
   )
   }
}
