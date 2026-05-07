//
//  SettingView.swift
//  morse keyboard
//
//  Created by 이종현 on 5/6/26.
//


import SwiftUI

struct SettingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("soundOn", store: .shared)private var soundOn: Bool = true
    @AppStorage("volume", store: .shared) private var volume: Double = 0.5
    @AppStorage("tone", store: .shared) private var tone: Double = 500.0
    @AppStorage("morseThreshold", store: .shared) private var morseThreshold: Double = 300.0
    @AppStorage("morseInterval", store: .shared) private var morseInterval: Double = 300.0
    @AppStorage("autoSpaceOn", store: .shared) private var autoSpaceOn: Bool = true
    @AppStorage("useSubkey", store: .shared) private var useSubkey: Bool = true

    var isFullAccessOverride: Bool? = nil
    private var hasFullAccess: Bool {
        isFullAccessOverride ?? UIInputViewController().hasFullAccess
    }
            
    var body: some View {
        ZStack{
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            ScrollView {
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
                    else{
                        VStack(spacing:20){
                            Toggle("신호음 켜기", isOn: $soundOn)
                            if soundOn{
                                Divider()
                                VStack(spacing:10){
                                    HStack{
                                        Text("음량")
                                        Spacer()
                                        Text("\(Int(volume*100)) %")
                                            .foregroundColor(.green)
                                            .bold()
                                    }
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                        Slider(value: $volume, in: 0...1, onEditingChanged: { editing in
                                            if !editing{
                                                MorseSoundManager.shared.stopTone()
                                            }
                                        })
                                        .tint(.green)
                                        .onChange(of: volume) { oldValue, newValue in
                                            MorseSoundManager.shared.startTone(volume: Float(newValue))
                                        }
                                        
                                        Image(systemName: "speaker.wave.3.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Divider()
                                VStack(spacing:10){
                                    HStack{
                                        Text("음높이")
                                        Spacer()
                                        Text("\(Int(tone)) Hz")
                                            .foregroundColor(.green)
                                            .bold()
                                    }
                                    HStack {
                                        Image(systemName: "waveform.path.ecg")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                        Slider(value: $tone, in: 400...1000, step: 10, onEditingChanged: { editing in
                                            if !editing{
                                                MorseSoundManager.shared.stopTone()
                                            }
                                        })
                                        .tint(.green)
                                        .onChange(of: tone){oldValue, newValue in
                                            MorseSoundManager.shared.updateFrequencySmoothly(to: newValue)
                                            MorseSoundManager.shared.startTone(volume: Float(volume))
                                        }
                                        Image(systemName: "waveform.path")
                                            .imageScale(.large)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                    }
                    
                    VStack(spacing:10){
                        Toggle("보조 키 사용", isOn: $useSubkey)
                            .onChange(of: useSubkey){oldValue, newValue in
                                if newValue == false{
                                    autoSpaceOn = true
                                }
                            }
                        HStack{
                            Text("스페이스와 삭제 키를 별도로 사용합니다.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                    
                    VStack(spacing:20){
                        Toggle("자동 공백 입력", isOn: $autoSpaceOn)
                            .disabled(useSubkey == false)
                        Divider()
                        VStack(spacing: 10) {
                            HStack {
                                Text("신호 구분 기준")
                                Spacer()
                                Text("\(Int(morseThreshold)) ms")
                                    .foregroundColor(.green)
                                    .bold()
                            }
                            
                            HStack {
                                Text("점(・)")
                                Slider(value: $morseThreshold, in: 100...500, step: 10)
                                    .tint(.green)
                                Text("선(-)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                        }
                        Divider()
                        VStack(spacing: 10) {
                            HStack {
                                Text("문자 구분 기준")
                                Spacer()
                                Text("\(Int(morseInterval)) ms")
                                    .foregroundColor(.green)
                                    .bold()
                            }
                            HStack{
                                Image(systemName: "ellipsis")
                                    .imageScale(.large)
                                    .foregroundStyle(.secondary)
                                
                                Slider(value: $morseInterval, in: 100...500, step: 10)
                                    .tint(.green)
                                
                                Image(systemName: "character")
                                    .imageScale(.large)
                                    .foregroundStyle(.secondary)
                            }
                            HStack{
                                Text("자동 공백 입력 시간은 문자 구분 기준 시간의 3배입니다. (\(String(format: "%.2f", morseInterval/1000*3))초)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                    .modifier(CapsuleRowModifier(colorScheme: colorScheme))
                }
            }
            .animation(.spring(.smooth), value: soundOn)
            .onAppear{
                MorseSoundManager.shared.prepareCleanBuffer(frequency: tone)
            }
        }
    }
}

#Preview {
    SettingView(isFullAccessOverride: true)//.preferredColorScheme(.dark)
}
