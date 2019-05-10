//
//  BaseRecycleTVCell.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class BaseRecycleTVCell: UITableViewCell, LifeCycleInterface, BaseRecycleView.Delegate,
                                CustomRecycleCellDelegate {
    
    public typealias Delegate = BaseRecycleTVCellDelegate
    
    public typealias CustomCellDelegate = CustomTVCellDelegate
    
    // MARK: - Constructor
    public init(reuseIdentifier: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.createLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    public var cell: BaseRecycleView {
        return BaseRecycleView(frame: CGRect.zero)
    }
    
    // MARK: - State
    override open var canBecomeFocused: Bool {
        return false
    }
    
    // MARK: - LifeCycleInterface Methods
    public func createLayout() {
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(cell)
        cell.delegate = self
    }
    
    public func frameUpdate() {
        cell.frameUpdate()
    }
    
    // MARK: - ReusableComponentInterface Methods
    open override func prepareForReuse() {
        super.prepareForReuse()
        cell.prepareForReuse()
    }
    
    // MARK: - Size
    public func getHeight(model: BaseRecycleModel) -> CGFloat {
        let h = model.getContainerHeight()
        // The minimum height is 2, otherwise the tableview crashes
        return (h > 2) ? h : 2
    }
    
    public func sizeThatFits(model: BaseRecycleModel, forWidth w: CGFloat) -> CGSize {
        let avaialbleWidth = w - model.padding.left - model.padding.right
        return CGSize(width: w, height: cell.sizeThatFits(model: model, forWidth: avaialbleWidth).height)
    }
    
    // MARK: - Model
    public func setData(model: BaseRecycleModel, forWidth width: CGFloat) {
        cell.setData(model: model)
        cell.frame.size = CGSize(width: width, height: self.getHeight(model: model))
    }
    
    // MARK: - Delegates
    open weak var delegate: Delegate?
    
    open weak var customRecycleCellDelegate: CustomRecycleCellDelegate?
    
    // MARK: - BaseRowView.Delegate Methods
    public func active(view: BaseRecycleView) {
        self.delegate?.active(view: view)
    }
    
    public func tapped(model: BaseRecycleModel, view: BaseRecycleView) {
        self.delegate?.tapped(model: model, view: view)
    }
    
    public func longPressed(model: BaseRecycleModel, view: BaseRecycleView) {
        self.delegate?.longPressed(model: model, view: view)
    }
    
    // MARK: - CustomRecycleCellDelegate Methods
    public func getCellsToRegister() -> [(AnyClass?, String)] {
        return self.customRecycleCellDelegate?.getCellsToRegister() ?? []
    }
}
