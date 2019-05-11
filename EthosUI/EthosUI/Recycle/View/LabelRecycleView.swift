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
import EthosText

open class LabelRecycleView: BaseRecycleView {
    
    //MARK: - UI -
    open var titleLabel = EthosUILabel(frame: CGRect.zero)
    
    open var subtitleLabel = EthosUILabel(frame: CGRect.zero)
    
    open var detailsLabel = EthosUILabel(frame: CGRect.zero)
    
    // MARK: - Lifecycle -
    @discardableResult
    override open func createLayout() -> LifeCycleInterface {
        super.createLayout()
        self.addTap(self, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        
        titleLabel.createLayout()
        self.addTap(titleLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(titleLabel)
        
        subtitleLabel.createLayout()
        self.addTap(subtitleLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(subtitleLabel)
        
        detailsLabel.createLayout()
        self.addTap(detailsLabel, selector: #selector(BaseRecycleView.selector_containerTapped(_:)))
        self.contentView.addSubview(detailsLabel)
        return self
    }
    
    override open func frameUpdate() {
        super.frameUpdate()
        
        let titleMargins = (self.model as? LabelRecycleModel)?.titleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableTitleWidth = (self.rightEdge() - self.leftEdge()) - titleMargins.left - titleMargins.right
        let titleSize = titleLabel.sizeThatFits(CGSize(width: availableTitleWidth,
                                                       height: CGFloat.greatestFiniteMagnitude))
        
        let subTitleMargins = (self.model as? LabelRecycleModel)?.subtitleMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableSubTitleWidth = (self.rightEdge() - self.leftEdge()) - subTitleMargins.left - subTitleMargins.right
        let subTitleSize = subtitleLabel.sizeThatFits(CGSize(width: availableSubTitleWidth,
                                                             height: CGFloat.greatestFiniteMagnitude))
        
        let detailsMargins = (self.model as? LabelRecycleModel)?.detailsMargins ?? Rect<CGFloat>(0, 0, 0, 0)
        
        let availableDetailsWidth = (self.rightEdge() - self.leftEdge()) - detailsMargins.left - detailsMargins.right
        let detailsSize = detailsLabel.sizeThatFits(CGSize(width: availableDetailsWidth,
                                                           height: CGFloat.greatestFiniteMagnitude))
        
        // Sizes are set
        titleLabel.frame.size = CGSize(width: availableTitleWidth, height: titleSize.height)
        subtitleLabel.frame.size = CGSize(width: availableSubTitleWidth, height: subTitleSize.height)
        detailsLabel.frame.size = CGSize(width: availableDetailsWidth, height: detailsSize.height)
        
        // Center Horizontally in parent
        titleLabel.frame.origin.x = self.leftEdge() + titleMargins.left
        subtitleLabel.frame.origin.x = self.leftEdge() + subTitleMargins.left
        detailsLabel.frame.origin.x = self.leftEdge() + detailsMargins.left
        
        let totalHeight = titleSize.height + titleMargins.bottom +
            subTitleSize.height + subTitleMargins.top +
            detailsSize.height + detailsMargins.top
        
        // Center Vertically in parent
        titleLabel.frame.origin.y = (self.contentView.frame.height - totalHeight) / 2
        subtitleLabel.frame.origin.y = titleLabel.frame.maxY + titleMargins.bottom + subTitleMargins.top
        detailsLabel.frame.origin.y = subtitleLabel.frame.maxY + subTitleMargins.bottom + detailsMargins.top
    }
    
    override open func setData(model: BaseRecycleModel) {
        super.setData(model: model)
        if let m = model as? LabelRecycleModel {
            titleLabel.labelDescriptor = m.title
            subtitleLabel.labelDescriptor = m.subtitle
            detailsLabel.labelDescriptor = m.details
        }
    }
    
    // MARK: - Gestures -
    open override var addTap: Bool {
        return false
    }
    
    override open func selector_containerTapped(_ sender: UITapGestureRecognizer) {
        if  self.titleLabel.willConsumeLocationTap(sender.location(in: titleLabel)) ||
            self.subtitleLabel.willConsumeLocationTap(sender.location(in: subtitleLabel)) ||
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
    
    private func adjustHeight(label: EthosUILabel, descriptor: LabelDescriptor, size: inout CGSize) {
        if descriptor.numberOfLines > 0 {
            label.labelDescriptor = descriptor.clone().removeNewLines()
            let singleLineHeight = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude,
                                                             height: CGFloat.greatestFiniteMagnitude)).height
            let estimatedHeight = singleLineHeight * CGFloat(descriptor.numberOfLines)
            size.height = size.height > estimatedHeight ? estimatedHeight : size.height
        }
    }
    
    // MARK: - Sizing -
    open override func sizeThatFits(model: BaseRecycleModel, forWidth w: CGFloat) -> CGSize {
        guard let m = model as? LabelRecycleModel else { return super.sizeThatFits(model: model, forWidth: w) }
        
        titleLabel.labelDescriptor = m.title
        subtitleLabel.labelDescriptor = m.subtitle
        detailsLabel.labelDescriptor = m.details
        
        let availableTitleWidth = w - m.titleMargins.left - m.titleMargins.right
        var titleSize = titleLabel.sizeThatFits(CGSize(width: availableTitleWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let availableSubtitleWidth = w - m.subtitleMargins.left - m.subtitleMargins.right
        var subtitleSize = subtitleLabel.sizeThatFits(CGSize(width: availableSubtitleWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let availableDetailsWidth = w - m.detailsMargins.left - m.detailsMargins.right
        var detailsSize = detailsLabel.sizeThatFits(CGSize(width: availableDetailsWidth, height: CGFloat.greatestFiniteMagnitude))
        
        self.adjustHeight(label: titleLabel, descriptor: m.title, size: &titleSize)
        self.adjustHeight(label: subtitleLabel, descriptor: m.subtitle, size: &subtitleSize)
        self.adjustHeight(label: detailsLabel, descriptor: m.details, size: &detailsSize)
        
        var reqWidth: CGFloat = max(titleSize.width, max(subtitleSize.width, detailsSize.width))
        
        var reqHeight = (m.titleMargins.top + titleSize.height + m.titleMargins.bottom) +
                        (m.subtitleMargins.top + subtitleSize.height + m.subtitleMargins.bottom) +
                        (m.detailsMargins.top + detailsSize.height + m.detailsMargins.bottom)
        
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
        subtitleLabel.delegate = self.labelDelegate
        detailsLabel.delegate = self.labelDelegate
    }
    
}
