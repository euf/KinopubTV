//
//  UpNextProposalViewController.swift
//  Kinopub TV
//
//  Created by Peter on 19.11.16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AVKit

class UpNextProposalViewController: AVContentProposalViewController {
	
	@IBOutlet var watchButton: UIButton!
	@IBOutlet var thumbnail: UIImageView!
	@IBOutlet var showTitle: UILabel!
	@IBOutlet var episodeTitle: UILabel!
	
	var mainTitle: String? = "Lala"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let cp = contentProposal {
			thumbnail.image = cp.previewImage
			episodeTitle.text = cp.title
			showTitle.text = mainTitle
		}
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		return [watchButton]
	}
	
	override var preferredPlayerViewFrame: CGRect {
		return CGRect(x: 432, y: 20, width: 1056, height: 594)
	}
	
	@IBAction func dismissProposal(_ sender: UIButton) {
		dismissContentProposal(for: .reject, animated: true, completion: nil)
	}
	
	@IBAction func watchNextEpisode(_ sender: UIButton) {
		dismissContentProposal(for: .accept, animated: true, completion: nil)
	}
	
}

