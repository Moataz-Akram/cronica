//
//  ConfirmationDialogView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/06/22.
//

import SwiftUI

/// A popup view the displays a confirmation if a given
/// item is saved on Watchlist.
struct ConfirmationDialogView: View {
    @Binding var showConfirmation: Bool
    var message: String
    var image: String?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            HStack {
                if let image {
                    Label(NSLocalizedString(message, comment: ""), systemImage: image)
                        .padding()
                } else {
                    Text(NSLocalizedString(message, comment: ""))
                        .padding()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                
            }
            .background {
                Rectangle().fill(.regularMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
            .shadow(radius: 12)
            .opacity(showConfirmation ? 1 : 0)
            .scaleEffect(showConfirmation ? 1.1 : 1)
            .animation(.linear, value: showConfirmation)
            .onTapGesture {
                withAnimation {
                    showConfirmation = false
                }
            }
            Spacer()
        }
    }
}

struct ConfirmationDialogView_Previews: PreviewProvider {
    @State private static var showConfirmation = true
    static var previews: some View {
        ConfirmationDialogView(showConfirmation: $showConfirmation, message: "This is a preview")
    }
}
