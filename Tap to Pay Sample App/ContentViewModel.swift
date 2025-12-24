//
//  ContentViewModel.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import Foundation
import SwiftUI

@MainActor
final class ContentViewModel: ObservableObject {
    
    // MARK: - Inputs
    @Published var amount: String = ""
    @Published var storeId: String = ""
    @Published var orderId: String = ""
    @Published var selectedEnvironment: AppEnvironment = AppEnvironment.development
    
    // MARK: - Outputs
    @Published var resultText: String = ""
    @Published var isResultError: Bool = true
    @Published var isLoading: Bool = false
    
    private var ipAddress: String?
    private let apiClient: ApiClient
    
    enum ResultCode: String {
        case failed = "failed"
        case userCanceled = "user_canceled"
        case systemCanceled = "system_canceled"
        case badRequest = "bad_request"
        case success = "success"
    }
    
    // MARK: - Init
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    // MARK: - IP Address
    private func fetchIpAddress() async {
        let ipAddress = await apiClient.fetchExternalIP()
        if let ipAddress = ipAddress, !ipAddress.isEmpty {
            self.ipAddress = ipAddress
        }
    }
    
    func initIpAddress() {
        Task {
            do {
                await fetchIpAddress()
            }
        }
    }
    
    // MARK: - Submit Action
    func submit() {
        // Validate return url
        let scheme = Bundle.main.object(forInfoDictionaryKey: "DEEPLINK_SCHEME") as? String ?? ""
        let host = Bundle.main.object(forInfoDictionaryKey: "DEEPLINK_HOST") as? String ?? ""
        let returnUrl = "\(scheme)://\(host)"
        guard URL(string: returnUrl) != nil else {
            resultText = "Invalid return URL"
            return
        }
        
        // Validate amount input
        guard isValidCurrency(amount) else {
            resultText = "Invalid amount"
            return
        }
        
        // Validate store ID input
        guard !storeId.isEmpty else {
            resultText = "Store ID is required"
            return
        }
        
        isLoading = true
        resultText = ""
    
        Task {
            do {
                // Get IP Address
                if ipAddress == nil {
                    await fetchIpAddress()
                }
                
                guard let ipAddress = ipAddress else {
                    isResultError = true
                    resultText = "Failed to get IP address"
                    isLoading = false
                    return
                }
                
                // Build request
                let request = PaymentSessionRequest(
                    storeId: storeId,
                    clientIpAddress: ipAddress
                )
                
                // Call API
                let response = try await apiClient.createSession(request: request, environment: selectedEnvironment)
                
                // Validate response
                guard !response.isEmpty else {
                    isResultError = true
                    resultText = "Unexpected server response"
                    isLoading = false
                    return
                }
                let session = response[0]
                // Build universal link
                let orderIdParam = orderId.isEmpty ? "" : "&orderId=\(orderId)"
                let scheme = Bundle.main.object(forInfoDictionaryKey: "DEEPLINK_SCHEME") as? String ?? ""
                let host = Bundle.main.object(forInfoDictionaryKey: "DEEPLINK_HOST") as? String ?? ""
                let returnUrl = "\(scheme)://\(host)"
                let link = "\(selectedEnvironment.universalLinkBase)?paymentSessionId=\(session.key)&storeId=\(session.storeId)&amount=\(amount)&returnUrl=\(returnUrl)\(orderIdParam)"
                
                guard let url = URL(string: link) else {
                    isResultError = true
                    resultText = "Invalid universal link"
                    isLoading = false
                    return
                }
                
                // Launch the Tap to Pay app
                guard await UIApplication.shared.open(url) else {
                    isResultError = true
                    resultText = "Failed to open universal link"
                    isLoading = false
                    return
                }
            } catch let error as AppError {
                isResultError = true
                resultText = error.localizedDescription
            } catch {
                isResultError = true
                resultText = error.localizedDescription
            }
            
            isLoading = false
        }
    }
    
    //MARK: - Return results
    func handleDeepLink(_ url: URL) {
        // Parse the deeplink
        let query = Dictionary(
            uniqueKeysWithValues: URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .map { ($0.name, $0.value ?? "") } ?? []
        )
        var result: String = ""
        if let resultValue = query["result"], let resultCode = ResultCode(rawValue: resultValue){
            switch resultCode {
            case .success:
                isResultError = false
                result += "Result: Success\n"
            case .badRequest:
                isResultError = true
                result += "Result: Bad Request\n"
            case .userCanceled:
                isResultError = true
                result += "Result: User Canceled\n"
            case .systemCanceled:
                isResultError = true
                result += "Result: System Canceled. Possibly network issues\n"
            case .failed:
                isResultError = true
                result += "Result: Card transaction failed\n"
            }
        } else {
            isResultError = true
            result += "Result: Unknown\n"
        }
        if let responseCode = query["responseCode"] {
            result += "Response Code: \(responseCode)\n"
        }
        if let responseMessage = query["responseMessage"] {
            result += "Response Message: \(responseMessage)\n"
        }
        if let gatewayTransactionId = query["gatewayTransactionId"] {
            result += "Gateway Transaction ID: \(gatewayTransactionId)\n"
        }
        if let clientTransactionId = query["clientTransactionId"] {
            result += "Client Transaction ID: \(clientTransactionId)\n"
        }
        resultText = result
    }
    
    //MARK: - Validator
    func isValidCurrency(_ input: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal      // or .currency if you want symbols
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        return formatter.number(from: input) != nil
    }
}
