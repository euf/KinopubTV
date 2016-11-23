//
//  TVViewController.swift
//  Kinopub TV
//
//  Created by Peter on 21.09.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AVKit

class TVViewController: UIViewController, TVViewable, Menuretractable {
	
	var playerController: AVPlayerViewController!
	var channels: [TVChannel] = [] {
		didSet {
			collectionView.reloadData()
		}
	}
	
	@IBOutlet var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		loadChannels()
    }
	
//	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//		retractMenu(for: subMenuTopConstraint, and: context)
//	}
	
	private func loadChannels() {
		fetchChannels() { response in
			switch response {
			case .success(let channels):
				if let channels = channels {
					self.channels = channels
				}
				break
			case .error(let error):
				log.error("Error getting channels: \(error)")
				break
			}
		}
	}
}

extension TVViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return channels.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let channel = channels[indexPath.row]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tvCell", for: indexPath) as? TVItemCollectionViewCell {
			cell.channel = channel
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let channel = channels[indexPath.row]
		if let url = channel.stream, let streamURL = URL(string: url) {
			watchChannel(url: streamURL)
		}
		
	}
	
}
