//
//  InputView.swift
//  HP_chars
//
//  Created by Andrei Simvolokov on 16/05/2026.
//

import SwiftUI

enum InputState {
    case loaded(primaryButtonText: String)
    case loading
}

protocol InputViewModelProtocol: ObservableObject {
    var input: String { get set }
    var state: InputState { get }

    func primaryButtonDidTap()
}

struct InputView<
    ViewModel: InputViewModelProtocol
>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var textFieldFocus: Bool

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            textInput
            switch viewModel.state {
            case .loaded(let primaryButtonText):
                primaryButton(text: primaryButtonText)
            case .loading:
                ProgressView()
            }
        }
        .padding(.all, 16)
        .onAppear {
            textFieldFocus = true
        }
    }
    
    @ViewBuilder
    private var textInput: some View {
        TextField("", text: $viewModel.input, axis: .vertical)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused($textFieldFocus)
            .frame(
                idealHeight: .infinity,
                maxHeight: .infinity
            )
    }
    
    @ViewBuilder
    private func primaryButton(text: String) -> some View {
        Button {
            viewModel.primaryButtonDidTap()
        } label: {
            Text(text)
        }
        .buttonStyle(.borderedProminent)
    }
}
