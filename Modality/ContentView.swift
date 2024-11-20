//
//  ContentView.swift
//  Modality
//
//  Created by Rune Madsen on 11/19/24.
//

import SwiftUI

struct ContentView: View {
    @State private var presentingSheetIndex: Int? = nil

    struct AnyPresentationSizing: PresentationSizing {
        private let _proposedSize: (PresentationSizingRoot, PresentationSizingContext) -> ProposedViewSize

        init<S: PresentationSizing>(_ base: S) {
            self._proposedSize = base.proposedSize
        }

        func proposedSize(for root: PresentationSizingRoot, context: PresentationSizingContext) -> ProposedViewSize {
            _proposedSize(root, context)
        }
    }

    struct CustomPresentationSizingContext: PresentationSizing {
        let width: CGFloat
        let height: CGFloat

        func proposedSize(for root: PresentationSizingRoot, context: PresentationSizingContext) -> ProposedViewSize {
            .init(width: width, height: height)
        }
    }

    struct SheetOption {
        let title: String
        let content: String
        let sizing: AnyPresentationSizing
    }

    func createCustomSheetOption(width: CGFloat, height: CGFloat) -> SheetOption {
        let title = "Present Custom Sheet: \(Int(width)) w / \(Int(height)) h"
        let content = "Sheet using .custom presentation sizing"
        let sizing = AnyPresentationSizing(CustomPresentationSizingContext(width: width, height: height))
        return SheetOption(title: title, content: content, sizing: sizing)
    }

    // MARK: - Sheet Options Array
    var sheetOptions: [SheetOption] {
        [
            SheetOption(
                title: "Present Form Sheet",
                content: "Sheet using .form presentation sizing",
                sizing: AnyPresentationSizing(.form)
            ),
            SheetOption(
                title: "Present Page Sheet",
                content: "Sheet using .page presentation sizing",
                sizing: AnyPresentationSizing(.page)
            ),
            SheetOption(
                title: "Present Fitted Sheet",
                content: "Sheet using .fitted presentation sizing",
                sizing: AnyPresentationSizing(.fitted)
            ),
            createCustomSheetOption(width: 800, height: 600),
            createCustomSheetOption(width: 600, height: 1200),
            createCustomSheetOption(width: 1200, height: 1200),
            createCustomSheetOption(width: 2000, height: 2000) // oversized on purpose to get an iOS modal like presentation
        ]
    }

    var body: some View {
        List(sheetOptions.indices, id: \.self) { index in
            Button {
                presentingSheetIndex = index
            } label: {
                Text(sheetOptions[index].title)
            }
        }
        .navigationTitle("Sheet Options")
        .frame(maxWidth: 400, maxHeight: .infinity)
        .sheet(isPresented: Binding(
            get: { presentingSheetIndex != nil },
            set: { if !$0 { presentingSheetIndex = nil } }
        )) {
            if let index = presentingSheetIndex {
                PresentedView(sheetOption: sheetOptions[index])
            }
        }
    }
}

struct PresentedView: View {
    let sheetOption: ContentView.SheetOption

    var body: some View {
        VStack {
            Spacer()
            Text(sheetOption.content)
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationSizing(sheetOption.sizing)
    }
}

#Preview {
    ContentView()
}
