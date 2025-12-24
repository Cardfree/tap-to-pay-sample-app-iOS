//
//  ApiClient.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import Foundation
import UIKit

final class ApiClient {
    func createSession(
        request: PaymentSessionRequest,
        environment: AppEnvironment
    ) async throws -> [PaymentSessionResponse] {
        guard let url = URL(string: environment.apiEndpoint) else {
            throw AppError.invalidEndpoint
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("client \(environment.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("ExternalApp", forHTTPHeaderField: "Source")
        urlRequest.setValue("iOS", forHTTPHeaderField: "Device-OS")
        urlRequest.setValue(UUID().uuidString, forHTTPHeaderField: "Correlation-ID")
        urlRequest.setValue(modelIdentifier(), forHTTPHeaderField: "Device-Model")
        urlRequest.setValue(await UIDevice.current.systemVersion, forHTTPHeaderField: "Device-OS-Version")
        if let deviceIdentifier = await UIDevice.current.identifierForVendor {
            urlRequest.setValue(deviceIdentifier.uuidString, forHTTPHeaderField: "Device-Identifier")
        }
        urlRequest.httpBody = try JSONEncoder().encode(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.failure(errorDescription: nil)
            }

            if (200...299).contains(httpResponse.statusCode) {
                return try JSONDecoder().decode([PaymentSessionResponse].self, from: data)
            } else {
                throw ApiErrorMapper.map(
                    statusCode: httpResponse.statusCode,
                    data: data
                )
            }
        } catch let error as AppError {
            throw error
        } catch let error {
            throw AppError.failure(errorDescription: error.localizedDescription)
        }
    }
    
    func fetchExternalIP() async -> String? {
        guard let url = URL(string: "https://api.ipify.org?format=json") else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(IPResponse.self, from: data)
            return response.ip
        } catch {
            return nil
        }
    }
    
    private func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
}
