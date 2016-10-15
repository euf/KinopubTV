//
//  EpisodeCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 13/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage

class EpisodeCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet var thumbnail: UIImageView!
	@IBOutlet var title: UILabel!
	@IBOutlet var episodeTitleConstraint: NSLayoutConstraint!
	@IBOutlet var watchedImage: UIImageView!
	@IBOutlet var progressBar: UIProgressView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		reset()
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		reset()
	}
	
	func reset() {
		progressBar.isHidden = true
		watchedImage.isHidden = true
		title.text = ""
	}
	
	func update(episode: Video) {
		progressBar.isHidden = true // Default value
		if let number = episode.number, let title = episode.title {
			let titleArray = title.components(separatedBy: " / ")
			if titleArray.count > 1 {
				let multilineTitle: String = titleArray.reduce("", {$0 + $1 + "\n"})
				self.title.text = "\(number). \(multilineTitle)"
			} else {
				self.title.text = "\(number). \(title)"
			}
		}
		if let thumbnail = episode.thumbnail {
			if let URL = NSURL(string: thumbnail) {
				self.thumbnail.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
			}
		}
		
		if let watching = episode.watching {
			updateWatchStatus(watch: watching, episode: episode)
		}
	}
	
	func updateWatchStatus(watch: Watching, episode: Video) {
		guard let status = watch.status else {return}
		watchedImage.isHidden = status == .watched ? false : true
		if status == .watching {
			if let duration = episode.duration, duration > 0, let time = watch.time {
				progressBar.isHidden = false
				let progressed: Float = Float(time) / Float(duration)
				progressBar.setProgress(progressed, animated: true)
			} else {
				progressBar.isHidden = true
			}
		} else {
			progressBar.isHidden = true
		}
	}
	
	func toggleWatchStatus(status: Int) {
		watchedImage.isHidden = status == 1 ? false : true
		progressBar.isHidden = true // Always true, because this method only cares about watched/unwatched.
	}
}
