//
//  Untitled.swift
//  morse keyboard
//
//  Created by 이종현 on 5/2/26.
//

/*
import AVFoundation

class MorseSoundManager {
    static let shared = MorseSoundManager()
    
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private let sampleRate: Double = 44100.0
    private var toneBuffer: AVAudioPCMBuffer?
    private var targetVolume: Float = 0.5
    private var currentFrequency: Double = 600.0
    
    private init() {
        setupEngine()
        prepareCleanBuffer()
        // [중요] 초기화 시 엔진과 세션을 미리 시작해둡니다.
        startEngineOnce()
    }
    
    private func setupEngine() {
        audioEngine.attach(playerNode)
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        
        // 믹서 노드에서 미리 볼륨을 확보해둡니다.
        audioEngine.mainMixerNode.outputVolume = 1.0
    }
    
    private func startEngineOnce() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession.setActive(true)
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
        } catch {
            print("엔진 시작 실패: \(error)")
        }
    }
    
    func prepareCleanBuffer(frequency: Double = 600.0) {
        self.currentFrequency = frequency
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCapacity = AVAudioFrameCount(sampleRate * 0.2) // 루프 안정성을 위해 조금 더 길게 설정
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return }
        buffer.frameLength = frameCapacity
        
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(frameCapacity) {
            data[i] = sinf(Float(2.0 * .pi * frequency * Double(i) / sampleRate))
        }
        self.toneBuffer = buffer
        
        if playerNode.isPlaying{
            playerNode.stop()
            startTone(volume: playerNode.volume)
        }
    }
    
    func startTone(volume: Float = 1.0) {
        self.targetVolume = volume
        
        // 1. 세션이나 엔진을 매번 켜지 않고 이미 켜져 있는지 확인만 합니다.
        if !audioEngine.isRunning { startEngineOnce() }
        
        // 2. 이전에 남아있던 페이드 아웃 지연 작업을 취소할 필요 없이 즉시 볼륨 설정
        playerNode.volume = targetVolume
        
        // 3. 이미 재생 중이라면 스케줄링을 건너뛰어 지연을 방지합니다.
        if !playerNode.isPlaying {
            guard let buffer = toneBuffer else { return }
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            playerNode.play()
        }
    }
    
    func stopTone() {
        // [핵심] 정지하지 않고 볼륨만 0으로 만듭니다.
        // 노드를 stop()하고 다시 play()하는 과정에서 발생하는 수 밀리초의 지연을 제거합니다.
        playerNode.volume = 0.0
        
        // 엔진을 물리적으로 끄지 않습니다. 키보드가 닫힐 때까지 유지하여 다음 입력을 즉각 처리합니다.
    }
}
*/


import AVFoundation

class MorseSoundManager: NSObject { // 타이머 사용을 위해 NSObject 상속
    static let shared = MorseSoundManager()
    
    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    // 피치 조절을 위한 노드 추가
    private var pitchControl = AVAudioUnitTimePitch()
    
    private let sampleRate: Double = 44100.0
    private var toneBuffer: AVAudioPCMBuffer?
    
    private override init() {
        super.init()
        setupEngine()
        prepareCleanBuffer(frequency: 600.0)
        startEngineOnce()
    }
    
    private func setupEngine() {
        audioEngine.attach(playerNode)
        audioEngine.attach(pitchControl)
        
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // 연결 구조: Player -> Pitch Control -> Mixer
        audioEngine.connect(playerNode, to: pitchControl, format: format)
        audioEngine.connect(pitchControl, to: audioEngine.mainMixerNode, format: format)
        
        audioEngine.mainMixerNode.outputVolume = 1.0
    }

    // 주파수를 직접 바꾸는 대신 'Pitch' 값을 조절하여 음을 변화시킴
    // 600Hz를 기준으로 배율을 조정하면 끊김이 전혀 없습니다.
    func updateFrequencySmoothly(to newFrequency: Double) {
        let baseFrequency: Float = 600.0
        // 피치는 'Cent' 단위입니다 (1옥타브 = 1200 cents)
        let cents = 1200.0 * log2(Float(newFrequency) / baseFrequency)
        pitchControl.pitch = cents
    }

    func startTone(volume: Float = 1.0) {
        if !audioEngine.isRunning { startEngineOnce() }
        playerNode.volume = volume
        
        if !playerNode.isPlaying {
            guard let buffer = toneBuffer else { return }
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            playerNode.play()
        }
    }

    @objc func stopTone() {
        playerNode.volume = 0.0
    }
    
    private func startEngineOnce() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            if !audioEngine.isRunning { try audioEngine.start() }
        } catch { print("Error: \(error)") }
    }

    func prepareCleanBuffer(frequency: Double = 600.0) {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCapacity = AVAudioFrameCount(sampleRate * 0.4) // 루프 안정성을 위해 약간 길게
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return }
        buffer.frameLength = frameCapacity
        
        let data = buffer.floatChannelData![0]
        for i in 0..<Int(frameCapacity) {
            // 사인파 생성
            data[i] = sinf(Float(2.0 * .pi * frequency * Double(i) / sampleRate))
        }
        self.toneBuffer = buffer
    }
}
