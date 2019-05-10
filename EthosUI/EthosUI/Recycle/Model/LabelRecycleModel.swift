//
//  LabelRecycleModel.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosText

fileprivate let TITLE_DESCRIPTOR_HANDLE = VariableHandle<LabelDescriptor>("title_descriptor", LabelDescriptor())

fileprivate let TITLE_MARGINS_HANDLE = VariableHandle<Rect<CGFloat>>("title_margins", Rect<CGFloat>(def: 0))

fileprivate let SUBTITLE_DESCRIPTOR_HANDLE = VariableHandle<LabelDescriptor>("subtitle_descriptor", LabelDescriptor())

fileprivate let SUBTITLE_MARGINS_HANDLE = VariableHandle<Rect<CGFloat>>("subtitle_margins", Rect<CGFloat>(def: 0))

fileprivate let DETAILS_DESCRIPTOR_HANDLE = VariableHandle<LabelDescriptor>("details_descriptor", LabelDescriptor())

fileprivate let DETAILS_MARGINS_HANDLE = VariableHandle<Rect<CGFloat>>("details_margins", Rect<CGFloat>(def: 0))

public class LabelRecycleModel: BaseRecycleModel {
    
    // MARK: - Constants & Types -
    public static let DEFAULT_IOS_ROW_HEIGHT: CGFloat = 50
    
    public static let SECTION_HEADER_OR_FOOTER_TAG = "__RESERVED.header_or_footer"
    
    // MARK: - Constructor -
    public override init() {
        super.init()
    }
    
    // MARK: - Identifier -
    override public var id: String {
        return RecycleModels.label.rawValue
    }
    
    open class func isLabelRowModel(id: String) -> Bool {
        return id == RecycleModels.label.rawValue
    }
    
    // MARK: - Variables
    public var title: LabelDescriptor {
        get { return self.getHandle(handle: TITLE_DESCRIPTOR_HANDLE).val }
        set { self.getHandle(handle: TITLE_DESCRIPTOR_HANDLE).val = newValue }
    }
    
    public var titleMargins: Rect<CGFloat> {
        get { return self.getHandle(handle: TITLE_MARGINS_HANDLE).val }
        set { self.getHandle(handle: TITLE_MARGINS_HANDLE).val = newValue }
    }
    
    public var subtitle: LabelDescriptor {
        get { return self.getHandle(handle: SUBTITLE_DESCRIPTOR_HANDLE).val }
        set { self.getHandle(handle: SUBTITLE_DESCRIPTOR_HANDLE).val = newValue }
    }
    
    public var subtitleMargins: Rect<CGFloat> {
        get { return self.getHandle(handle: SUBTITLE_MARGINS_HANDLE).val }
        set { self.getHandle(handle: SUBTITLE_MARGINS_HANDLE).val = newValue }
    }
    
    public var details: LabelDescriptor {
        get { return self.getHandle(handle: DETAILS_DESCRIPTOR_HANDLE).val }
        set { self.getHandle(handle: DETAILS_DESCRIPTOR_HANDLE).val = newValue }
    }
    
    open var detailsMargins: Rect<CGFloat> {
        get { return self.getHandle(handle: DETAILS_MARGINS_HANDLE).val }
        set { self.getHandle(handle: DETAILS_MARGINS_HANDLE).val = newValue }
    }
    
    @discardableResult
    public func with(title li: LabelDescriptor?) -> LabelRecycleModel {
        self.title = li ?? TITLE_DESCRIPTOR_HANDLE.def
        return self
    }
    
    @discardableResult
    public func with(title: String? = nil, textSize: CGFloat? = nil, textColor: String? = nil) -> LabelRecycleModel {
        let labeInformation = TextHelper.parse(title, textSize: textSize, textColor: textColor, allowLinks: true)
        return self.with(title: labeInformation)
    }
    
    @discardableResult
    public func with(titleLineCount: Int) -> LabelRecycleModel {
        return self
    }
    
    @discardableResult
    public func with(titleMargins m: Rect<CGFloat>? = nil) -> LabelRecycleModel {
        self.titleMargins = m ?? TITLE_MARGINS_HANDLE.def
        return self
    }
    
    @discardableResult
    public func with(subtitle li: LabelDescriptor?) -> LabelRecycleModel {
        self.subtitle = li ?? SUBTITLE_DESCRIPTOR_HANDLE.def
        return self
    }
    
    @discardableResult
    public func with(subtitle: String? = nil, textSize: CGFloat? = nil, textColor: String? = nil) -> LabelRecycleModel {
        let labeInformation = TextHelper.parse(subtitle, textSize: textSize, textColor: textColor, allowLinks: true)
        return self.with(subtitle: labeInformation)
    }
    
    @discardableResult
    public func with(subtitleLineCount: Int) -> LabelRecycleModel {
        return self
    }
    
    @discardableResult
    public func with(subtitleMargins m: Rect<CGFloat>? = nil) -> LabelRecycleModel {
        self.subtitleMargins = m ?? SUBTITLE_MARGINS_HANDLE.def
        return self
    }
    
    @discardableResult
    public func with(details li: LabelDescriptor?) -> LabelRecycleModel {
        self.details = li ?? DETAILS_DESCRIPTOR_HANDLE.def
        return self
    }
    
    @discardableResult
    public func with(details: String? = nil, textSize: CGFloat? = nil, textColor: String? = nil) -> LabelRecycleModel {
        let labeInformation = TextHelper.parse(details, textSize: textSize, textColor: textColor, allowLinks: true)
        return self.with(details: labeInformation)
    }
    
    @discardableResult
    public func with(detailsLineCount: Int) -> LabelRecycleModel {
        return self
    }
    
    @discardableResult
    public func with(detailsMargins m: Rect<CGFloat>? = nil) -> LabelRecycleModel {
        self.detailsMargins = m ?? DETAILS_MARGINS_HANDLE.def
        return self
    }
    
    @discardableResult
    override public func withDefaultBottomBorder() -> BaseRecycleModel {
        let minMargin = min(min(self.titleMargins.left, self.subtitleMargins.left), self.detailsMargins.left)
        self.borders.bottom.show = true
        self.borders.bottom.padding = Rect<CGFloat>(self.padding.left + minMargin, 0, 0, 0)
        return self
    }
    
    @discardableResult
    public func withDefaultIOSRowHeight() -> LabelRecycleModel {
        self.with(height: LabelRecycleModel.DEFAULT_IOS_ROW_HEIGHT)
        return self
    }
    
    
    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        
        self.getHandle(handle: TITLE_DESCRIPTOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: TITLE_MARGINS_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SUBTITLE_DESCRIPTOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SUBTITLE_MARGINS_HANDLE).encode(with: aCoder)
        self.getHandle(handle: DETAILS_DESCRIPTOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: DETAILS_MARGINS_HANDLE).encode(with: aCoder)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.getHandle(handle: TITLE_DESCRIPTOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: TITLE_MARGINS_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SUBTITLE_DESCRIPTOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SUBTITLE_MARGINS_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: DETAILS_DESCRIPTOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: DETAILS_MARGINS_HANDLE).decode(coder: aDecoder)
        
    }
    
    // MARK: - NSCopying Methods -
    public override var newInstance: BaseRecycleModel {
        return LabelRecycleModel()
    }
    
}
