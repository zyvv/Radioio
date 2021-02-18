//
//  UnreachableBadgeView.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/19.
//

import SwiftUI

struct UnreachableBadgeView: View {
    @Binding var unreachable: Bool
    var body: some View {
        Group {
            if unreachable {
                HStack {
                    Spacer()
                    Text("Not connected to the network.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxHeight: 20)
                .background(Color.lightBrown)
            }
        }
    }
}

struct Unreachable: ViewModifier {
    @Binding var unreachable: Bool
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            UnreachableBadgeView(unreachable: $unreachable)
            content
        }
    }
}

extension View {
    func unreachable(_ unreachable: Binding<Bool>) -> some View {
        return self.modifier(Unreachable(unreachable: unreachable))
    }
}
