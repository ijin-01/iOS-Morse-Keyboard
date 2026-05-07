//
//  MorseCodeListView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/6/26.
//

import SwiftUI

struct MorseCodeListView: View {
    @Environment(\.colorScheme) var colorScheme
    
    // 모스 부호 데이터 (일부 예시)
    let morseData: [(String, String)] = [
        ("A", "· —"),       ("W", "· — —"),
        ("B", "— · · ·"),   ("X", "— · · —"),
        ("C", "— · — ·"),   ("Y", "— · — —"),
        ("D", "— · ·"),     ("Z", "— — · ·"),
        ("E", "·"),         ("", ""),
        ("F", "· · — ·"),   ("0", "— — — — —"),
        ("G", "— — ·"),     ("1", "· — — — —"),
        ("H", "· · · ·"),   ("2", "· · — — —"),
        ("I", "· ·"),       ("3", "· · · — —"),
        ("J", "· — — —"),   ("4", "· · · · —"),
        ("K", "— · —"),     ("5", "· · · · ·"),
        ("L", "· — · ·"),   ("6", "— · · · ·"),
        ("M", "— —"),       ("7", "— — · · ·"),
        ("N", "— ·"),       ("8", "— — — · ·"),
        ("O", "— — —"),     ("9", "— — — — ·"),
        ("P", "· — — ·"),   ("", ""),
        ("Q", "— — · —"),   (".", "· — · — · —"),
        ("R", "· — ·"),     (",", "— — · · — —"),
        ("S", "· · ·"),     ("?", "· · — — · ·"),
        ("T", "—"),         ("!", "— · — · — —"),
        ("U", "· · —"),     ("/", "— · · — ·"),
        ("V", "· · · —"),   ("", ""),
    ]
    
    // 2열 격자 설정
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(morseData, id: \.0) { item in
                            HStack(spacing: 10) {
                                    Text(item.0)
                                        .font(.system(.headline, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    Text(item.1)
                                        .font(.system(.body, design: .rounded))
                                        .bold()
                                    Spacer()
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 10){
                        Text("Backspace")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundColor(.secondary)
                        Text("· · · · · · · ·")
                            .font(.system(.body, design: .rounded))
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .modifier(CapsuleRowModifier(colorScheme: colorScheme))
            }
        }
    }
}

#Preview {
        MorseCodeListView()//.preferredColorScheme(.dark)
}
