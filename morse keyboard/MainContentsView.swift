//
//  MainContentsView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/2/26.
//

import SwiftUI

struct MainContentsView: View {
    @Environment(\.colorScheme) var colorScheme

    var isFullAccessOverride: Bool? = nil
    private var hasFullAccess: Bool {
        isFullAccessOverride ?? UIInputViewController().hasFullAccess
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                VStack(spacing: 30) {
                    if !hasFullAccess{
                        VStack(spacing: 10){
                            HStack{
                                Text("전체 접근 허용")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold)) // 크기와 굵기 조절
                                    .foregroundStyle(.tertiary)
                            }
                            HStack{
                                Text("소리를 켜려면 전체 접근을 허용하세요")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                        .onTapGesture {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    
                    NavigationLink(destination: SettingView()){
                        HStack{
                            Text("설정")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    VStack(spacing:20){
                        NavigationLink( destination: MorseCodeListView()){
                            HStack{
                                Text("모스 부호 일람")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                        Link(destination: URL(string: "https://morse.withgoogle.com/learn/")!) {
                            HStack{
                                Text("모스 부호 연습하기")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                }
            }
//            .navigationTitle("홈")
        }
    }
}

#Preview {
    MainContentsView(isFullAccessOverride:false)//.preferredColorScheme(.dark)
}
