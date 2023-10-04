//
//  Constants.swift
//  Wavclouds
//
//  Created by Enoch Tamulonis on 10/3/23.
//

import Foundation

enum Environment: String {
    case development
    case production
}

struct Constants {
    static var currentEnvironment: Environment {
        guard let rawValue = ProcessInfo.processInfo.environment["APP_ENV"],
              let environment = Environment(rawValue: rawValue.lowercased()) else {
            return .development // Default to development if not specified
        }
        return environment
    }
    static var baseUrl: String {
        switch currentEnvironment {
        case .development:
            return "http://localhost:3000"
        case .production:
            return "https://www.wavclouds.com"
        }
    }
}
