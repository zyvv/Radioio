//
//  PlayerControl.swift
//  Radioio
//
//  Created by 张洋威 on 2020/7/15.
//

import Foundation
import AVKit
import MediaPlayer
import Combine
import CoreData

class PlayerControl: ObservableObject {
    
    enum PlayerStatus: Int {
        case pause = 0
        case loading
        case playing
    }
        
    @Published private(set) var playingRadio: Radio
    
    @Published private(set) var playerStatus: PlayerStatus = .pause
    
    @Published private(set) var unreachable: Bool = false
    
    private var player: AVAudioPlayer!
    private var playerStatusCancellable: AnyCancellable?

    private var reachabiltyStore: ReachabilityStore!
    private var reachabiltyCancellable: AnyCancellable?
    
    private let context: NSManagedObjectContext = PersistentContainer.context
        
    init() {
        playingRadio = RadioViewModel.getRecentPlayRadio()
        reachabiltyStore = ReachabilityStore()
        reachabiltyCancellable = reachabiltyStore.$reachable.sink { [unowned self] in
            self.unreachable = !$0
        }
        setupPlayerControls()
        replacePlayerItem(radio: playingRadio)
    }
    
    private func setupPlayerControls() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        #endif
//        do {
//            let data = try Data(contentsOf: playingRadio.url)
//            player = try AVAudioPlayer(data: data)
////            player = try AVAudioPlayer(contentsOf: playingRadio.url)
//        } catch {
//            print(error.localizedDescription)
//        }
        
//        player = AVPlayer(playerItem: AVPlayerItem(url: playingRadio.url))
        setupRemoteTransportControls()
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            if self?.player.isPlaying == false {
                self?.player.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget {[weak self] _ in
            if self?.player.isPlaying == true {
                self?.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlaying(isPause: Bool) {
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String : Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 0 : 1
        nowPlayingInfo[MPMediaItemPropertyTitle] = playingRadio.name
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func replacePlayerItem(radio: Radio) {
        if playingRadio.id == radio.id { return }
        playingRadio = RadioViewModel.getRadioOnDisk(radio: radio)
        playerStatusCancellable?.cancel()
        playerStatusCancellable = nil
        player.pause()
        try? player = AVAudioPlayer(contentsOf: radio.url)
//        player = AVPlayer(playerItem: AVPlayerItem(url: radio.url))
        if playerStatusCancellable == nil {
            playerStatusCancellable = Publishers
                .CombineLatest(
                    player.publisher(for: \.isPlaying, options: [.initial, .new]),
                    $playingRadio
                )
                .removeDuplicates { $0.0 == $1.0 && $0.1 == $1.1 }
                .sink { [unowned self] playerStatus, radio in
                    print("status:\(playerStatus), radio:\(radio.name)")
                    if playerStatus {
                        self.playerStatus = .playing
//                        self.playerStatus = PlayerStatus(rawValue: playerStatus.rawValue)!
                    } else {
                        self.playerStatus = .pause
                    }
//                    self.playerStatus = PlayerStatus(rawValue: playerStatus.rawValue)!
                    self.updateNowPlaying(isPause: self.playerStatus == .pause)
                    if playerStatus {
                        self.updateRadioLastPlayTime(radio: radio)
                    }
                }
        }
    }
    
    private func updateRadioLastPlayTime(radio: Radio) {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        let predicate = NSPredicate(format: "id_ = \(radio.id)")
        request.predicate = predicate
        if let radio = try? context.fetch(request).first {
            radio.lastPlayTime = Date()
            try? context.save()
        }
    }
    
    func favouriteRadio(radio: Radio) -> Bool {
        let request = NSFetchRequest<Radio>.init(entityName: "Radio")
        let predicate = NSPredicate(format: "id_ = \(radio.id)")
        request.predicate = predicate
        if let r = try? context.fetch(request).first {
            r.favourite = !r.favourite
            r.favouriteTime = Date()
            try? context.save()
            return r.favourite
        }
        return radio.favourite
    }
    
    func toggle() {
        if player.isPlaying == true {
            player.pause()
        } else {
            player.play()
        }
//        player.isPlaying == true ? player.pause() : player.play()
//        playerStatus == .pause ? play() : pause()
    }

    func play(radio: Radio) {
        replacePlayerItem(radio: radio)
//        play()
    }
    
    func radioStatus(radio: Radio) -> PlayerStatus {
        if radio == playingRadio {
            return playerStatus
        }
        return .pause
    }
}
