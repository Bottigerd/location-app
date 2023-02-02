//
//  config.swift
//  SwiftUI-UserLocation
//
//  Created by Amir Al-Sheikh on 2/1/23.
//

import Foundation
enum Configuration {
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    enum Keys {
        static let apiKey = "API_KEY"
    }

    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey:key) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found")
        }
        return dict
    }()
    
    static let apiKey: String =  {
        guard let apiKeyString = Configuration.infoDictionary[Keys.apiKey] as? String else{
            fatalError("API Key not set in plist")
        }
        return apiKeyString
    }()
}


