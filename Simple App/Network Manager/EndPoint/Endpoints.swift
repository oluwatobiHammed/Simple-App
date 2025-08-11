//
//  B2BEndpoints.swift
//  Simple App
//
//  Created by Oluwatobi Oladipupo on 2025-08-11.
//

import Foundation

enum Endpoints:EndPointType {
    case getPictures
    
    
    var baseURL: URL {
     
        guard let url = URL(string: kAPI.Base_URL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .getPictures:
            return kAPI.Endpoints.list
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
            
        case .getPictures:
            return .requestHeaders(bodyEncoding: .urlEncoding)
        }
        
    }
}
