//
//  KeyboardView.swift
//  keyboard
//
//  Created by 이종현 on 5/1/26.
//

import SwiftUI

struct KeyboardView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var startTime: Date?
    @State private var duration: Double = 0
    
    // 실시간 처리를 위한 상태 변수
    @State private var morseBuffer: String = ""    // 누적된 .과 -
    @State private var currentLetter: String = ""  // 실시간으로 변역된 알파벳
    @State private var inputStopTimer: Timer? = nil         // 입력 중단 감지 타이머
    @State private var spaceInsertTimer: Timer? = nil         // 입력 중단 감지 타이머
    @State private var deleteTimer: Timer? = nil
    
    private var soundManager = MorseSoundManager.shared
    
    @AppStorage("soundOn", store: .shared) private var soundOn: Bool = true
    @AppStorage("volume", store: .shared) private var volume: Double = 0.5
    @AppStorage("morseThreshold", store: .shared) private var morseThreshold: Double = 300.0
    @AppStorage("morseInterval", store: .shared) private var morseInterval: Double = 300.0
    @AppStorage("autoSpaceOn", store: .shared) private var autoSpaceOn: Bool = true
    @AppStorage("useSubkey", store: .shared) private var useSubkey: Bool = true
    
    // 모스부호 데이터 시트
    let morseCodeMap: [String: String] = [
        ".-": "A",
        "-...": "B",
        "-.-.": "C",
        "-..": "D",
        ".": "E",
        "..-.": "F",
        "--.": "G",
        "....": "H",
        "..": "I",
        ".---": "J",
        "-.-": "K",
        ".-..": "L",
        "--": "M",
        "-.": "N",
        "---": "O",
        ".--.": "P",
        "--.-": "Q",
        ".-.": "R",
        "...": "S",
        "-": "T",
        "..-": "U",
        "...-": "V",
        ".--": "W",
        "-..-": "X",
        "-.--": "Y",
        "--..": "Z",
        "-----": "0",
        ".----": "1",
        "..---": "2",
        "...--": "3",
        "....-": "4",
        ".....": "5",
        "-....": "6",
        "--...": "7",
        "---..": "8",
        "----.": "9",
        ".-.-.-": ".",
        "--..--": ",",
        "..--..": "?",
        "-.-.--": "!",
        "-..-.": "/",
        "........": "Backspace"
    ]
    
    var body: some View {
        VStack(spacing: 15) {
            // 상단 디스플레이: 실시간 번역 결과 표시
            HStack {
                Text(morseBuffer)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.blue)
                
                Text(currentLetter)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(minWidth: 40)
                
                if morseBuffer != ""{
                    Text("\(Int(duration * 1000)) ms").font(.caption2).foregroundColor(.secondary)
                }
            }
            .frame(minHeight: 50)
            
            HStack{
                if useSubkey{
                    Spacer()
                    
                    Button{
                        morseBuffer = ""
                        currentLetter = ""
                        
                        inputStopTimer?.invalidate()
                        spaceInsertTimer?.invalidate()
                        
                        NotificationCenter.default.post(name: NSNotification.Name("spaceKey"), object: nil)
                    }label: {
                        Image(systemName: "space")
                            .foregroundColor(.primary)
                            .bold()
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(colorScheme == .dark ? Color(UIColor.systemGray3) : .white)
                    
                    Spacer()
                }
                Button { } label: {
                    Circle()
                        .fill(colorScheme == .dark ? Color(UIColor.systemGray3).opacity(0.001) : .white.opacity(0.001))
                        .frame(width: 120, height: 100)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if startTime == nil {
                                        startTime = Date()
                                        inputStopTimer?.invalidate() // 새로운 터치가 시작되면 타이머 중단
                                        
                                        if soundOn {
                                            soundManager.startTone(volume: Float(volume))
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    soundManager.stopTone()
                                    
                                    if let start = startTime {
                                        let elapsed = Date().timeIntervalSince(start)
                                        self.duration = elapsed
                                        
                                        // 1. 기호 추가 및 실시간 번역
                                        updateMorseBuffer(ms: elapsed * 1000)
                                        
                                        // 2. 입력 중단 감지 타이머 시작 (0.6초~0.8초 권장)
                                        startFinalizeTimer()
                                        
                                        startTime = nil
                                    }
                                }
                        )
                }
                .buttonStyle(.glassProminent)
                .tint(colorScheme == .dark ? Color(UIColor.systemGray3) : .white)
                if useSubkey{
                    Spacer()
                    
                    Button{
                        
                    }label: {
                        Image(systemName: "delete.left")
                            .foregroundColor(.primary)
                            .bold()
                            .frame(width: 50, height: 50)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged{_ in
                                        morseBuffer = ""
                                        currentLetter = ""
                                        
                                        inputStopTimer?.invalidate()
                                        spaceInsertTimer?.invalidate()
                                        deleteTimer?.invalidate()
                                        
                                        NotificationCenter.default.post(name: NSNotification.Name("deleteKey"), object: nil)
                                        
                                        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                                            // 3. 이후 0.1초 간격으로 반복 삭제
                                            deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                                                NotificationCenter.default.post(name: NSNotification.Name("deleteKey"), object: nil)
                                            }
                                        }
                                    }
                                    .onEnded{_ in
                                        deleteTimer?.invalidate()
                                        deleteTimer = nil
                                    }
                            )
                    }
                    .buttonStyle(.glassProminent)
                    .tint(colorScheme == .dark ? Color(UIColor.systemGray3) : .white)
                    
                    Spacer()
                }
            }
        }
        .background(Color.clear)
    }
    
    // 기호를 추가하고 즉시 번역 결과를 업데이트
    private func updateMorseBuffer(ms: Double) {
        let symbol = ms < morseThreshold ? "." : "-"
        morseBuffer += symbol
        
        // 실시간 변역 결과 업데이트
            if let match = morseCodeMap[morseBuffer] {
                // 백스페이스 기호(⌫)를 화면에 미리 보여줌
                if match == "Backspace"{
                    currentLetter = "⌫"
                    NotificationCenter.default.post(name: NSNotification.Name("deleteWordKey"), object: nil)
                    
                    morseBuffer = ""
                    currentLetter = ""
                }
                else{
                    currentLetter = match
                }
            } else {
                currentLetter = ""
            }
        }
    
    private func startFinalizeTimer() {
        inputStopTimer?.invalidate()
        spaceInsertTimer?.invalidate()
        
        // 사용자가 입력을 멈춘 지 0.5초가 지나면 현재 글자를 확정 입력
        inputStopTimer = Timer.scheduledTimer(withTimeInterval: morseInterval/1000, repeats: false) { _ in
            confirmInput()
        }
    }
    
    private func confirmInput() {
        // 유효한 글자가 있을 때만 전송
        if let letter = morseCodeMap[morseBuffer] {
            if letter != "Backspace"{
                NotificationCenter.default.post(name: NSNotification.Name("addKey"), object: letter)
                
                if autoSpaceOn{
                    startSpaceTimer()
                }
            }
        }
        
        // 다음 글자를 위해 초기화
        morseBuffer = ""
        currentLetter = ""
    }
    
    private func startSpaceTimer() {
        spaceInsertTimer?.invalidate()
        // morseInterval의 3배 정도 시간이 지나면 공백을 추가 (취향에 따라 조절 가능)
        let spaceInterval = (morseInterval / 1000.0) * 3
        
        spaceInsertTimer = Timer.scheduledTimer(withTimeInterval: spaceInterval, repeats: false) { _ in
            NotificationCenter.default.post(name: NSNotification.Name("addKey"), object: " ")
        }
    }
}

#Preview {
    KeyboardView()//.preferredColorScheme(.dark)
}
