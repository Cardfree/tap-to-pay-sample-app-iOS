//
//  ContentView.swift
//  Tap to Pay Sample App
//
//  Created by Allan Cheng on 12/23/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @Binding var deeplinkURL: URL?
        
    var body: some View {
        ZStack {
            // Background color
            Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
            
            VStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Environment")
                        .font(.headline)
                    
                    Picker("", selection: $viewModel.selectedEnvironment) {
                        ForEach(AppEnvironment.allCases) { env in
                            Text(env.displayName).tag(env)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                .cornerRadius(8)
                
                Form {
                    Section(header: Text("Payment Info")) {
                        TextField("Amount", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                        TextField("Store ID", text: $viewModel.storeId)
                        TextField("Order ID (Optional)", text: $viewModel.orderId)
                    }
                    
                    Section(header: Text("Result")) {
                        Text(viewModel.resultText)
                            .foregroundColor(viewModel.isResultError ? .red : .blue)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: viewModel.submit) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.horizontal)
                        } else {
                            Text("Send Request")
                                .bold()
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)
                    Spacer()
                }
            }
        }
        .task {
            viewModel.initIpAddress()
        }
        .onChange(of: deeplinkURL) { _, newURL in
            guard let url = newURL else { return }
            viewModel.handleDeepLink(url)
        }
    }
}

#Preview {
    ContentView(deeplinkURL: .constant(nil))
}
