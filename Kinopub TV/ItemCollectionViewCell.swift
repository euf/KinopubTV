//
//  ItemCollectionViewCell.swift
//  Kinopub TV
//
//  Created by Peter on 28/12/15.
//  Copyright © 2015 Peter Tikhomirov. All rights reserved.
//

import UIKit
import AlamofireImage

class ItemCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var poster: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var year: UILabel!
	@IBOutlet weak var posterSeparatorConstraint: NSLayoutConstraint!
	var data: Item? {
		didSet {
			prepareCell()
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	private func prepareCell() {
		title.text = data?.title
		if let y = data?.year {
			year.text = String(y)
		} else {year.text = ""}
		if let p = data?.posters, let medium = p.medium {
			if let URL = NSURL(string: medium) {
				poster.af_setImage(withURL: URL as URL, placeholderImage: nil, filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.2), runImageTransitionIfCached: true, completion: nil)
				poster.isUserInteractionEnabled = true
			}
		}
	}

	
	
	/// Вытворяет всякие фокусы с "фокусом" )) Для наших плакатов в списке фильмов увеличивает их и прячет название.
	/// На самом деле анимация сильно подтормаживает интерфейс лучше ее отключить.
	///
	/// - parameter context:     UIFocusUpdateContext
	/// - parameter coordinator: UIFocusAnimationCoordinator
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if (self == context.nextFocusedView) {
			self.title.isHidden = true
			
//			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
//				self.poster.transform = CGAffineTransform(scaleX: 1.06,y: 1.06)
//				self.title.isHidden = true
//				}, completion:nil)
		}
		else if (self == context.previouslyFocusedView) {
			self.title.isHidden = false
			
//			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 3, options: .curveEaseIn, animations: {
//				self.poster.transform = CGAffineTransform.identity
//				}, completion: { done in
//					self.title.isHidden = false
//			})
		}
	}
	
    override func prepareForReuse() {
        //TODO: здесь можно подставлять какой-нибудь placeholder
        self.poster.image = nil
    }

}
