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
    
    private var player: AVPlayer!
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
        player = AVPlayer(playerItem: AVPlayerItem(url: playingRadio.url))
        setupRemoteTransportControls()
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if self.player.rate == 0.0 {
                self.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if self.player.rate == 1.0 {
                self.pause()
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
        if radio.id != playingRadio.id {
            playingRadio = RadioViewModel.getRadioOnDisk(radio: radio)
            playerStatusCancellable?.cancel()
            playerStatusCancellable = nil
            player = AVPlayer(playerItem: AVPlayerItem(url: radio.url))
        }
        if playerStatusCancellable == nil {
            playerStatusCancellable = Publishers
                .CombineLatest(
                    player.publisher(for: \.timeControlStatus, options: [.initial, .new]),
                    $playingRadio
                )
                .removeDuplicates { $0.0 == $1.0 && $0.1 == $1.1 }
                .sink { [unowned self] playerStatus, radio in
                    self.playerStatus = PlayerStatus(rawValue: playerStatus.rawValue)!
                    self.updateNowPlaying(isPause: self.playerStatus == .pause)
                    if playerStatus == .playing {
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
        playerStatus == .pause ? play() : pause()
    }

    func play(radio: Radio) {
        replacePlayerItem(radio: radio)
        play()
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }
    
    func radioStatus(radio: Radio) -> PlayerStatus {
        if radio == playingRadio {
            return playerStatus
        }
        return .pause
    }
}
