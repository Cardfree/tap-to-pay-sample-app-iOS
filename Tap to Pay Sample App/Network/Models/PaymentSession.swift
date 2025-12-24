//
//  PaymentSession.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import Foundation

struct PaymentSessionRequest: Encodable {
    let storeId: String?
    let clientIpAddress: String
}

struct PaymentSessionResponse: Decodable {
    let type: String
    let merchantId: Int
    let storeId: Int
    let paymentLocationId: String
    let clientIpAddress: String
    let key: String
    let validated: Bool
    let paymentMethod: String
}
