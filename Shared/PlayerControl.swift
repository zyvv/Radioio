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

    #if !os(watchOS)
    private var reachabiltyStore: ReachabilityStore!
    private var reachabiltyCancellable: AnyCancellable?
    #endif
    
    private let context: NSManagedObjectContext = PersistentContainer.context
    
    static let `shared`: PlayerControl = PlayerControl()
        
    init() {
        playingRadio = RadioViewModel.getRecentPlayRadio()
        #if !os(watchOS)
        reachabiltyStore = ReachabilityStore()
        reachabiltyCancellable = reachabiltyStore.$reachable.sink { [unowned self] in
            self.unreachable = !$0
        }
        #endif
        setupPlayerControls()
    }
    
    private func setupPlayerControls() {
        let session = AVAudioSession.sharedInstance()
        do {
            #if !os(macOS)
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio, options: [])
            #endif
        } catch {
            print(error)
        }
    
        #if os(watchOS)
        session.activate(options: []) {[weak self] (success, error) in
            guard let self = self else { return }
            self.player = AVPlayer(playerItem: AVPlayerItem(url: self.playingRadio.url))
            self.setupRemoteTransportControls()
            self.replacePlayerItem(radio: self.playingRadio, isFromInit: true)
        }
        #else
        player = AVPlayer(playerItem: AVPlayerItem(url: playingRadio.url))
        setupRemoteTransportControls()
        replacePlayerItem(radio: playingRadio, isFromInit: true)
        #endif
    }
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] _ in
            if self?.playerStatus == .pause {
                self?.player.play()
                return .success
            }
            return .commandFailed
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            if self?.playerStatus != .pause {
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
    
    private func replacePlayerItem(radio: Radio, isFromInit: Bool = false) {
        if radio.id != playingRadio.id {
            playingRadio = RadioViewModel.getRadioOnDisk(radio: radio)
            playerStatusCancellable?.cancel()
            playerStatusCancellable = nil
            player.replaceCurrentItem(with: nil)
            player = nil
            player = AVPlayer(playerItem: AVPlayerItem(url: radio.url))
            if player.timeControlStatus != .playing {
                player.play()
            }
        } else if playerStatus == .pause && !isFromInit {
            player.play()
        }
        if playerStatusCancellable == nil {
            playerStatusCancellable = Publishers
                .CombineLatest(
                    player.publisher(for: \.timeControlStatus, options: [.initial, .new]),
                    $playingRadio
                )
                .removeDuplicates { $0.0 == $1.0 && $0.1 == $1.1 }
                .receive(on: DispatchQueue.main)
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
        playerStatus == .pause ? player.play() : player.pause()
    }

    func play(radio: Radio) {
        replacePlayerItem(radio: radio)
    }
    
    func radioStatus(radio: Radio) -> PlayerStatus {
        if radio == playingRadio {
            return playerStatus
        }
        return .pause
    }
}
