//
//  CapsuleRowModifier.swift
//  morse keyboard
//
//  Created by 이종현 on 5/6/26.
//

import SwiftUI

struct CapsuleRowModifier: ViewModifier{
    var colorScheme: ColorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(colorScheme == .dark ? Color(UIColor.systemGray5) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .shadow(color: Color.black.opacity(0.01), radius: 5)
            .padding(.horizontal)
    }
}
