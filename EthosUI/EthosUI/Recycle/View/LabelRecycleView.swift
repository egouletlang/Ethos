//
//  LabelRecycleView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/10/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

open class LabelRecycleView: BaseRecycleView {
    
    //MARK: - UI -
    open var titleLabel = EthosUILabel(frame: CGRect.zero)
    open var subTitleLabel = EthosUILabel(frame: CGRect.zero)
    open var detailsLabel = EthosUILabel(frame: CGRect.zero)
    
    // MARK: - Lifecycle -
    override open func createLayout() {
        super.createLayout()
        self.addTap(self, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        
        titleLabel.createLayout()
        self.addTap(titleLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(titleLabel)
        
        subTitleLabel.createLayout()
        self.addTap(subTitleLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(subTitleLabel)
        
        detailsLabel.createLayout()
        self.addTap(detailsLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(detailsLabel)
    }
    
    override open func frameUpdate() {
        super.frameUpdate()
        
        let titleMargins = (self.model as? LabelRecycleModel)?.titleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableTitleWidth = (self.rightEdge() - self.leftEdge()) - titleMargins.left - titleMargins.right
        let titleSize = titleLabel.sizeThatFits(CGSize(width: availableTitleWidth,
                                                       height: CGFloat.greatestFiniteMagnitude))
        
        let subTitleMargins = (self.model as? LabelRecycleModel)?.subtitleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableSubTitleWidth = (self.rightEdge() - self.leftEdge()) - subTitleMargins.left - subTitleMargins.right
        let subTitleSize = subTitleLabel.sizeThatFits(CGSize(width: availableSubTitleWidth,
                                                             height: CGFloat.greatestFiniteMagnitude))
        
        let detailsMargins = (self.model as? LabelRecycleModel)?.detailsMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableDetailsWidth = (self.rightEdge() - self.leftEdge()) - detailsMargins.left - detailsMargins.right
        let detailsSize = detailsLabel.sizeThatFits(CGSize(width: availableDetailsWidth,
                                                           height: CGFloat.greatestFiniteMagnitude))
        
        // Sizes are set
        titleLabel.frame.size = CGSize(width: availableTitleWidth, height: titleSize.height)
        subTitleLabel.frame.size = CGSize(width: availableSubTitleWidth, height: subTitleSize.height)
        detailsLabel.frame.size = CGSize(width: availableDetailsWidth, height: detailsSize.height)
        
        // Center Horizontally in parent
        titleLabel.frame.origin.x = self.leftEdge() + titleMargins.left
        subTitleLabel.frame.origin.x = self.leftEdge() + subTitleMargins.left
        detailsLabel.frame.origin.x = self.leftEdge() + detailsMargins.left
        
        let totalHeight = titleSize.height + titleMargins.bottom +
            subTitleSize.height + subTitleMargins.top +
            detailsSize.height + detailsMargins.top
        
        // Center Vertically in parent
        titleLabel.frame.origin.y = (self.contentView.frame.height - totalHeight) / 2
        subTitleLabel.frame.origin.y = titleLabel.frame.maxY + titleMargins.bottom + subTitleMargins.top
        detailsLabel.frame.origin.y = subTitleLabel.frame.maxY + subTitleMargins.bottom + detailsMargins.top
    }
    
    override open func setData(model: BaseRecycleModel) {
        super.setData(model: model)
        if let m = model as? LabelRecycleModel {
            titleLabel.labelDescriptor = m.title
            subTitleLabel.labelDescriptor = m.subtitle
            detailsLabel.labelDescriptor = m.details
        }
    }
    
    // MARK: - Gestures -
    open override var addTap: Bool {
        return false
    }
    
    override open func selector_containerTapped(_ sender: UITapGestureRecognizer) {
        if  self.titleLabel.willConsumeLocationTap(sender.location(in: titleLabel)) ||
            self.subTitleLabel.willConsumeLocationTap(sender.location(in: subTitleLabel)) ||
            self.detailsLabel.willConsumeLocationTap(sender.location(in: detailsLabel)) {
            return
        }
        super.selector_containerTapped(sender)
    }
    
    // MARK: - Layout Helper -
    /**
     The min x value of the label component
     */
    open func leftEdge() -> CGFloat {
        return 0
    }
    
    /**
     The max x value of the label component
     */
    open func rightEdge() -> CGFloat {
        return self.contentView.frame.width
    }
    
    // MARK: - Sizing -
    open override func sizeThatFits(model: BaseRecycleModel, forWidth w: CGFloat) -> CGSize {
        
        if let m = model as? LabelRecycleModel {
            titleLabel.labelDescriptor = m.title
            subTitleLabel.labelDescriptor = m.subtitle
            detailsLabel.labelDescriptor = m.details
        }
        
        
        let titleMargins = (model as? LabelRecycleModel)?.titleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        let availableTitleWidth = w - titleMargins.left - titleMargins.right
        var titleSize = titleLabel.sizeThatFits(CGSize(width: availableTitleWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let subTitleMargins = (model as? LabelRecycleModel)?.subtitleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        let availableSubTitleWidth = w - subTitleMargins.left - subTitleMargins.right
        var subTitleSize = subTitleLabel.sizeThatFits(CGSize(width: availableSubTitleWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let detailsMargins = (model as? LabelRecycleModel)?.detailsMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        let availableDetailsWidth = w - detailsMargins.left - detailsMargins.right
        var detailsSize = detailsLabel.sizeThatFits(CGSize(width: availableDetailsWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if let m = model as? LabelRecycleModel {
//            if m.titleNumberOfLines > 0 {
//                titleLabel.labelDescriptor = m.title.clone().removeNewLines()
//                let titleLineHeight = titleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
//                                                                     height: CGFloat.greatestFiniteMagnitude)).height + 4 // not sure why the frame height is not correctly calculated. i emperically measured this value... need to figure out how to calculate it
//                let estTitleLineHeight = titleLineHeight * CGFloat(m.titleNumberOfLines)
//                titleSize.height = titleSize.height > estTitleLineHeight ? estTitleLineHeight : titleSize.height
//            }
//
//            if m.subTitleNumberOfLines > 0 {
//                subTitleLabel.labelDescriptor = m.subTitle.clone().removeNewLines()
//                let subTitleLineHeight = subTitleLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
//                                                                           height: CGFloat.greatestFiniteMagnitude)).height + 4
//                let estSubtitleLineHeight = subTitleLineHeight * CGFloat(m.subTitleNumberOfLines)
//                subTitleSize.height = subTitleSize.height > estSubtitleLineHeight ? estSubtitleLineHeight : subTitleSize.height
//            }
//
//            if m.detailsNumberOfLines > 0 {
//                detailsLabel.labelDescriptor = m.details.clone().removeNewLines()
//                let detailsLineHeight = detailsLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
//                                                                         height: CGFloat.greatestFiniteMagnitude)).height + 4
//                let estDetailLineHeight = detailsLineHeight * CGFloat(m.detailsNumberOfLines)
//                detailsSize.height = detailsSize.height > estDetailLineHeight ? estDetailLineHeight : detailsSize.height
//            }
        }
        
        var reqWidth: CGFloat = max(titleSize.width, max(subTitleSize.width, detailsSize.width))
        var reqHeight = (titleMargins.top + titleSize.height + titleMargins.bottom) +
            (subTitleMargins.top + subTitleSize.height + subTitleMargins.bottom) +
            (detailsMargins.top + detailsSize.height + detailsMargins.bottom)
        
        if model.width > 0 {
            reqWidth = reqWidth > model.height ? reqWidth : model.width
        } else if model.width == -1 {
            reqWidth = w
        }
        
        if model.height != 0 {
            reqHeight = reqHeight > model.height ? reqHeight : model.height
        }
        
        return CGSize(width: reqWidth, height: reqHeight)
        
    }

    public override func labelDelegateDidSet() {
        super.labelDelegateDidSet()
        titleLabel.delegate = self.labelDelegate
        subTitleLabel.delegate = self.labelDelegate
        detailsLabel.delegate = self.labelDelegate

    }
    
}
