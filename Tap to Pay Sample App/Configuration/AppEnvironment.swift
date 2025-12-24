//
//  AppEnvironment.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import Foundation

enum AppEnvironment: String, CaseIterable, Identifiable {
    case development
    case uat
    case production

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .development: return "DEV"
        case .uat: return "UAT"
        case .production: return "PROD"
        }
    }

    var apiEndpoint: String {
        switch self {
        case .development:
            return "https://dev-payments.cardfree.net/v1/payment/session"
        case .uat:
            return "https://uat-payments.cardfree.net/v1/payment/session"
        case .production:
            return "https://payments.cardfree.com/v1/payment/session"
        }
    }

    var universalLinkBase: String {
        switch self {
        case .development:
            return "https://dev-mobile.cardfree.net/pay/tap-to-pay"
        case .uat:
            return "https://uat-mobile.cardfree.net/pay/tap-to-pay"
        case .production:
            return "https://mobile.cardfree.com/pay/tap-to-pay"
        }
    }
    
    var apiKey: String {
        switch self {
        case .development:
            return Bundle.main.object(forInfoDictionaryKey: "DEV_API_KEY") as? String ?? "REPLACE_ME"
        case .uat:
            return Bundle.main.object(forInfoDictionaryKey: "UAT_API_KEY") as? String ?? "REPLACE_ME"
        case .production:
            return Bundle.main.object(forInfoDictionaryKey: "PRD_API_KEY") as? String ?? "REPLACE_ME"
        }
    }
}
