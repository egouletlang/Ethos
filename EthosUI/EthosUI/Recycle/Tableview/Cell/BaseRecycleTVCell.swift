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

open class BaseRecycleTVCell: UITableViewCell, LifeCycleInterface, BaseRecycleView.Delegate,
                              CustomRecycleCellDelegate {
    
    public typealias Delegate = BaseRecycleTVCellDelegate
    
    public typealias CustomCellDelegate = CustomTVCellDelegate
    
    // MARK: - Constructor
    convenience init(modelIdentifier: RecycleModels) {
        self.init(reuseIdentifier: modelIdentifier.rawValue)
    }
    
    public init(reuseIdentifier: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        self.createLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var content: BaseRecycleView = { self.cell }()
    
    open var cell: BaseRecycleView {
        return BaseRecycleView(frame: CGRect.zero)
    }
    
    // MARK: - State
    override open var canBecomeFocused: Bool {
        return false
    }
    
    // MARK: - LifeCycleInterface Methods
    open func createLayout() {
        self.backgroundColor = UIColor.clear
        self.contentView.addSubview(content)
        content.delegate = self
    }
    
    open func frameUpdate() {
        content.frameUpdate()
    }
    
    // MARK: - ReusableComponentInterface Methods
    override open func prepareForReuse() {
        super.prepareForReuse()
        content.prepareForReuse()
    }
    
    // MARK: - Size
    open func getHeight(model: BaseRecycleModel) -> CGFloat {
        let h = model.getContainerHeight()
        // The minimum height is 2, otherwise the tableview crashes
        return (h > 2) ? h : 2
    }
    
    open func sizeThatFits(model: BaseRecycleModel, forWidth w: CGFloat) -> CGSize {
        let avaialbleWidth = w - model.padding.left - model.padding.right
        return CGSize(width: w, height: cell.sizeThatFits(model: model, forWidth: avaialbleWidth).height)
    }
    
    // MARK: - Model
    open func setData(model: BaseRecycleModel, forWidth width: CGFloat) {
        content.setData(model: model)
        content.frame.size = CGSize(width: width, height: self.getHeight(model: model))
    }
    
    // MARK: - Delegates
    public weak var delegate: Delegate?
    
    public weak var customRecycleCellDelegate: CustomRecycleCellDelegate?
    
    // MARK: - BaseRowView.Delegate Methods
    open func active(view: BaseRecycleView) {
        self.delegate?.active(view: view)
    }
    
    open func tapped(model: BaseRecycleModel, view: BaseRecycleView) {
        self.delegate?.tapped(model: model, view: view)
    }
    
    open func longPressed(model: BaseRecycleModel, view: BaseRecycleView) {
        self.delegate?.longPressed(model: model, view: view)
    }
    
    // MARK: - CustomRecycleCellDelegate Methods
    open func getCellsToRegister() -> [(AnyClass?, String)] {
        return self.customRecycleCellDelegate?.getCellsToRegister() ?? []
    }
}
