//
//  BaseRecycleModel.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 4/30/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

public class BaseRecycleModel: NSObject, NSCoding, NSCopying {
    
    public override init() {
        super.init()
    }
    
    // MARK: - NSCoding Functions
    public func encode(with aCoder: NSCoder) {
        self.encodeAppearance(with: aCoder)
        self.encodeBorderAndPadding(with: aCoder)
        self.encodeSize(with: aCoder)
        self.encodeGestures(with: aCoder)
        self.encodeScopeAndSearchable(with: aCoder)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        self.decodeAppearance(coder: aDecoder)
        self.decodeBorderAndPadding(coder: aDecoder)
        self.decodeSize(coder: aDecoder)
        self.decodeGestures(coder: aDecoder)
        self.decodeScopeAndSearchable(coder: aDecoder)
    }
    
    // MARK: - Copy
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = self.newInstance
        copy.state = self.state.clone()
        return copy
    }
    
    
    var id: String {
        return RecycleModels.base.rawValue
    }
    
    var newInstance: BaseRecycleModel {
        return BaseRecycleModel()
    }
    
    var state = ComponentState()
    
}

// MARK: - Appearance
public extension BaseRecycleModel {
    
    fileprivate static let BACKGROUND_COLOR_HANDLE = VariableHandle<UIColor?>("background_color", nil)
    fileprivate static let CONTENT_COLOR_HANDLE = VariableHandle<UIColor?>("content_color", nil)
    fileprivate static let SHADOW_OFFSET_HANDLE = VariableHandle<CGSize>("shadow_offset", CGSize.zero)
    fileprivate static let SHADOW_RADIUS_HANDLE = VariableHandle<CGFloat>("shadow_radius", 0)
    fileprivate static let SHADOW_OPACITY_HANDLE = VariableHandle<Float>("shadow_opacity", 0)
    fileprivate static let CORNER_RADIUS_HANDLE = VariableHandle<CGFloat>("corner_radius", 0)
    
    // MARK: - Handles
    fileprivate var backgroundColorHandle: VariableHandle<UIColor?> {
        return self.state.getHandle(handle: BaseRecycleModel.BACKGROUND_COLOR_HANDLE)
    }
    
    fileprivate var contentColorHandle: VariableHandle<UIColor?> {
        return self.state.getHandle(handle: BaseRecycleModel.CONTENT_COLOR_HANDLE)
    }
    
    fileprivate var shadowOffsetHandle: VariableHandle<CGSize> {
        return self.state.getHandle(handle: BaseRecycleModel.SHADOW_OFFSET_HANDLE)
    }
    
    fileprivate var shadowRadiusHandle: VariableHandle<CGFloat> {
        return self.state.getHandle(handle: BaseRecycleModel.SHADOW_RADIUS_HANDLE)
    }
    
    fileprivate var shadowOpacityHandle: VariableHandle<Float> {
        return self.state.getHandle(handle: BaseRecycleModel.SHADOW_OPACITY_HANDLE)
    }
    
    fileprivate var cornerRadiusHandle: VariableHandle<CGFloat> {
        return self.state.getHandle(handle: BaseRecycleModel.CORNER_RADIUS_HANDLE)
    }
    
    // MARK: - Variables
    var backgroundColor: UIColor? {
        get { return self.backgroundColorHandle.val }
        set { self.backgroundColorHandle.val = newValue }
    }
    
    var contentColor: UIColor? {
        get { return self.contentColorHandle.val }
        set { self.contentColorHandle.val = newValue }
    }
    
    var shadowOffset: CGSize {
        get { return self.shadowOffsetHandle.val }
        set { self.shadowOffsetHandle.val = newValue }
    }
    
    var shadowRadius: CGFloat {
        get { return self.shadowRadiusHandle.val }
        set { self.shadowRadiusHandle.val = newValue }
    }
    
    var shadowOpacity: Float {
        get { return self.shadowOpacityHandle.val }
        set { self.shadowOpacityHandle.val = newValue }
    }
    
    var cornerRadius: CGFloat {
        get { return self.cornerRadiusHandle.val }
        set { self.cornerRadiusHandle.val = newValue }
    }
    
    @discardableResult func with(color: UIColor? = nil, content: UIColor? = nil) -> BaseRecycleModel {
        self.backgroundColor = color ?? BaseRecycleModel.BACKGROUND_COLOR_HANDLE.def
        self.contentColor = content ?? BaseRecycleModel.CONTENT_COLOR_HANDLE.def
        return self
    }
    
    @discardableResult func with(shadowOffset: CGSize? = nil, shadowRadius: CGFloat? = nil,
                                 shadowOpacity: Float? = nil) -> BaseRecycleModel {
        self.shadowOffset = shadowOffset ?? BaseRecycleModel.SHADOW_OFFSET_HANDLE.def
        self.shadowRadius = shadowRadius ?? BaseRecycleModel.SHADOW_RADIUS_HANDLE.def
        self.shadowOpacity = shadowOpacity ?? BaseRecycleModel.SHADOW_OPACITY_HANDLE.def
        return self
    }
    
    @discardableResult func with(cornerRadius: CGFloat?) -> BaseRecycleModel {
        self.cornerRadius = cornerRadius ?? BaseRecycleModel.CORNER_RADIUS_HANDLE.def
        return self
    }

    @discardableResult func withDefaultShadow() -> BaseRecycleModel {
        return self.with(shadowOffset: CGSize(width: 1, height: 3), shadowRadius: 3.0, shadowOpacity: 0.2)
    }
    
    fileprivate func encodeAppearance(with aCoder: NSCoder) {
        backgroundColorHandle.encode(with: aCoder)
        contentColorHandle.encode(with: aCoder)
        shadowOffsetHandle.encode(with: aCoder)
        shadowRadiusHandle.encode(with: aCoder)
        shadowOpacityHandle.encode(with: aCoder)
        cornerRadiusHandle.encode(with: aCoder)
    }
    
    fileprivate func decodeAppearance(coder aDecoder: NSCoder) {
        backgroundColorHandle.decode(coder: aDecoder)
        contentColorHandle.decode(coder: aDecoder)
        shadowOffsetHandle.decode(coder: aDecoder)
        shadowRadiusHandle.decode(coder: aDecoder)
        shadowOpacityHandle.decode(coder: aDecoder)
        cornerRadiusHandle.decode(coder: aDecoder)
    }

}

// MARK: - Borders & Padding
public extension BaseRecycleModel {
    
    struct BorderDescriptor {
        var show: Bool
        var padding: Rect<CGFloat>
    }
    
    struct Borders {
        var left: BorderDescriptor
        var top: BorderDescriptor
        var right: BorderDescriptor
        var bottom: BorderDescriptor
    }

    fileprivate static let LEFT_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("left_border_padding", Rect<CGFloat>(def: 0))
    fileprivate static let TOP_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("top_border_padding", Rect<CGFloat>(def: 0))
    fileprivate static let RIGHT_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("right_border_padding", Rect<CGFloat>(def: 0))
    fileprivate static let BOTTOM_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("bottom_border_padding", Rect<CGFloat>(def: 0))
    fileprivate static let LEFT_BORDER_HANDLE = VariableHandle<Bool>("left_border", false)
    fileprivate static let TOP_BORDER_HANDLE = VariableHandle<Bool>("top_border", false)
    fileprivate static let RIGHT_BORDER_HANDLE = VariableHandle<Bool>("right_border", false)
    fileprivate static let BOTTOM_BORDER_HANDLE = VariableHandle<Bool>("left_border", false)
    fileprivate static let BORDER_COLOR_HANDLE = VariableHandle<UIColor?>("border_color", nil)
    fileprivate static let PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("padding", Rect<CGFloat>(def: 0))
    
    // MARK: - Handles
    fileprivate var leftBorderPaddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseRecycleModel.LEFT_BORDER_PADDING_HANDLE)
    }
    
    fileprivate var topBorderPaddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseRecycleModel.TOP_BORDER_PADDING_HANDLE)
    }
    
    fileprivate var rightBorderPaddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseRecycleModel.RIGHT_BORDER_PADDING_HANDLE)
    }
    
    fileprivate var bottomBorderPaddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseRecycleModel.BOTTOM_BORDER_PADDING_HANDLE)
    }
    
    fileprivate var leftBorderHandle: VariableHandle<Bool> {
        return self.state.getHandle(handle: BaseRecycleModel.LEFT_BORDER_HANDLE)
    }
    
    fileprivate var topBorderHandle: VariableHandle<Bool> {
        return self.state.getHandle(handle: BaseRecycleModel.TOP_BORDER_HANDLE)
    }
    
    fileprivate var rightBorderHandle: VariableHandle<Bool> {
        return self.state.getHandle(handle: BaseRecycleModel.RIGHT_BORDER_HANDLE)
    }
    
    fileprivate var bottomBorderHandle: VariableHandle<Bool> {
        return self.state.getHandle(handle: BaseRecycleModel.BOTTOM_BORDER_HANDLE)
    }
    
    fileprivate var borderColorHandle: VariableHandle<UIColor?> {
        return self.state.getHandle(handle: BaseRecycleModel.BORDER_COLOR_HANDLE)
    }
    
    fileprivate var paddingHandle: VariableHandle<Rect<CGFloat>> {
        return self.state.getHandle(handle: BaseRecycleModel.PADDING_HANDLE)
    }
    
    var borders: Borders {
        get {
            return Borders(
                left: BorderDescriptor(show: leftBorderHandle.val, padding: leftBorderPaddingHandle.val),
                top: BorderDescriptor(show: topBorderHandle.val, padding: topBorderPaddingHandle.val),
                right: BorderDescriptor(show: rightBorderHandle.val, padding: rightBorderPaddingHandle.val),
                bottom: BorderDescriptor(show: bottomBorderHandle.val, padding: bottomBorderPaddingHandle.val)
            )
        }
        set {
            self.leftBorderHandle.val = newValue.left.show
            self.leftBorderPaddingHandle.val = newValue.left.padding
            self.topBorderHandle.val = newValue.top.show
            self.topBorderPaddingHandle.val = newValue.top.padding
            self.rightBorderHandle.val = newValue.right.show
            self.rightBorderPaddingHandle.val = newValue.right.padding
            self.bottomBorderHandle.val = newValue.bottom.show
            self.bottomBorderPaddingHandle.val = newValue.bottom.padding
        }
    }

    var borderColor: UIColor? {
        get { return self.borderColorHandle.val }
        set { self.borderColorHandle.val = newValue }
    }

    var padding: Rect<CGFloat> {
        get { return self.paddingHandle.val }
        set { self.paddingHandle.val = newValue }
    }
    
    @discardableResult func withBorder(left: Bool? = nil, top: Bool? = nil, right: Bool? = nil,
                                       bottom: Bool? = nil) -> BaseRecycleModel {
        self.borders.left.show = left ?? BaseRecycleModel.LEFT_BORDER_HANDLE.def
        self.borders.top.show = top ?? BaseRecycleModel.TOP_BORDER_HANDLE.def
        self.borders.right.show = right ?? BaseRecycleModel.RIGHT_BORDER_HANDLE.def
        self.borders.bottom.show = bottom ?? BaseRecycleModel.BOTTOM_BORDER_HANDLE.def
        return self
    }

    @discardableResult func withBorder(color: UIColor?) -> BaseRecycleModel {
        self.borderColor = color ?? BaseRecycleModel.BORDER_COLOR_HANDLE.def
        return self
    }

    @discardableResult func withBorder(paddingLeft: Rect<CGFloat>? = nil,
                                       paddingTop: Rect<CGFloat>? = nil,
                                       paddingRight: Rect<CGFloat>? = nil,
                                       paddingBottom: Rect<CGFloat>? = nil) -> BaseRecycleModel {
        self.borders.left.padding = paddingLeft ?? BaseRecycleModel.LEFT_BORDER_PADDING_HANDLE.def
        self.borders.top.padding = paddingTop ?? BaseRecycleModel.TOP_BORDER_PADDING_HANDLE.def
        self.borders.right.padding = paddingRight ?? BaseRecycleModel.RIGHT_BORDER_PADDING_HANDLE.def
        self.borders.bottom.padding = paddingBottom ?? BaseRecycleModel.BOTTOM_BORDER_PADDING_HANDLE.def
        return self
    }

    @discardableResult func withDefaultBottomBorder() -> BaseRecycleModel {
        return self.withBorder(bottom: true).withBorder(paddingBottom: nil)
    }

    @discardableResult func withPadding(left: CGFloat? = nil, top: CGFloat? = nil, right: CGFloat? = nil,
                                        bottom: CGFloat? = nil) -> BaseRecycleModel {
        self.padding.left = left ?? BaseRecycleModel.PADDING_HANDLE.def.left
        self.padding.top = top ?? BaseRecycleModel.PADDING_HANDLE.def.top
        self.padding.right = right ?? BaseRecycleModel.PADDING_HANDLE.def.right
        self.padding.bottom = bottom ?? BaseRecycleModel.PADDING_HANDLE.def.bottom
        return self
    }

    fileprivate func encodeBorderAndPadding(with aCoder: NSCoder) {
        leftBorderPaddingHandle.encode(with: aCoder)
        topBorderPaddingHandle.encode(with: aCoder)
        rightBorderPaddingHandle.encode(with: aCoder)
        bottomBorderPaddingHandle.encode(with: aCoder)
        leftBorderHandle.encode(with: aCoder)
        topBorderHandle.encode(with: aCoder)
        rightBorderHandle.encode(with: aCoder)
        bottomBorderHandle.encode(with: aCoder)
        borderColorHandle.encode(with: aCoder)
        paddingHandle.encode(with: aCoder)
    }
    
    fileprivate func decodeBorderAndPadding(coder aDecoder: NSCoder) {
        leftBorderPaddingHandle.decode(coder: aDecoder)
        topBorderPaddingHandle.decode(coder: aDecoder)
        rightBorderPaddingHandle.decode(coder: aDecoder)
        bottomBorderPaddingHandle.decode(coder: aDecoder)
        leftBorderHandle.decode(coder: aDecoder)
        topBorderHandle.decode(coder: aDecoder)
        rightBorderHandle.decode(coder: aDecoder)
        bottomBorderHandle.decode(coder: aDecoder)
        borderColorHandle.decode(coder: aDecoder)
        paddingHandle.decode(coder: aDecoder)
    }

}

// MARK: - Size
public extension BaseRecycleModel {
    
    fileprivate static let NO_MIN_HEIGHT: CGFloat = -1
    
    fileprivate static let SIZE_HANDLE = VariableHandle<CGSize>("size", CGSize.zero)
    fileprivate static let MIN_HEIGHT_HANDLE = VariableHandle<CGFloat>("min_height", NO_MIN_HEIGHT)
    fileprivate static let SHOULD_MEASURE = VariableHandle<CGSize>("should_measure", CGSize.zero)

    fileprivate var sizeHandle: VariableHandle<CGSize> {
        return self.state.getHandle(handle: BaseRecycleModel.SIZE_HANDLE)
    }
    
    fileprivate var minHeightHandle: VariableHandle<CGFloat> {
        return self.state.getHandle(handle: BaseRecycleModel.MIN_HEIGHT_HANDLE)
    }
    
    fileprivate var shouldMeasureHandle: VariableHandle<CGSize> {
        return self.state.getHandle(handle: BaseRecycleModel.SHOULD_MEASURE)
    }
    
    var size: CGSize {
        get { return self.sizeHandle.val }
        set { self.sizeHandle.val = newValue }
    }

    var height: CGFloat {
        return self.size.height
    }

    var width: CGFloat {
        return self.size.width
    }

    var minHeight: CGFloat {
        get { return self.minHeightHandle.val }
        set { self.minHeightHandle.val = newValue }
    }

    var shouldMeasureHeight: Bool {
        get { return self.shouldMeasureHandle.val.height == 0 }
        set { self.shouldMeasureHandle.val.height = newValue ? 0 : 1 }
    }
    
    var shouldMeasureWidth: Bool {
        get { return self.shouldMeasureHandle.val.width == 0 }
        set { self.shouldMeasureHandle.val.width = newValue ? 0 : 1 }
    }

    // MARK: - Size -
    @discardableResult func with(size: CGSize) -> BaseRecycleModel {
        self.size = size
        self.shouldMeasureWidth = false
        self.shouldMeasureHeight = false
        return self
    }

    @discardableResult func with(height: CGFloat) -> BaseRecycleModel {
        self.size.height = height
        self.shouldMeasureHeight = false
        return self
    }

    @discardableResult func with(minHeight: CGFloat) -> BaseRecycleModel {
        self.minHeight = height
        return self
    }

    @discardableResult func with(width: CGFloat) -> BaseRecycleModel {
        self.size.width = width
        self.shouldMeasureWidth = false
        return self
    }

    @discardableResult func resetSize() -> BaseRecycleModel {
        self.size = CGSize.zero
        self.shouldMeasureWidth = true
        self.shouldMeasureHeight = true
        return self
    }

    func getContainerHeight() -> CGFloat {
        return self.padding.top + self.height + self.padding.bottom
    }

    fileprivate func encodeSize(with aCoder: NSCoder) {
        sizeHandle.encode(with: aCoder)
        minHeightHandle.encode(with: aCoder)
        shouldMeasureHandle.encode(with: aCoder)
    }
    
    fileprivate func decodeSize(coder aDecoder: NSCoder) {
        sizeHandle.decode(coder: aDecoder)
        minHeightHandle.decode(coder: aDecoder)
        shouldMeasureHandle.decode(coder: aDecoder)
    }
}

// MARK: - Searching & Filtering
public extension BaseRecycleModel {

    static let ANY_SCOPE = ".*"
    static let NO_SCOPE = "^.*"
    static let ANY_QUERY = ".*"
    static let NO_QUERY = "^.*"
    
    fileprivate static let TAG_HANDLE = VariableHandle<String?>("tag", nil)
    fileprivate static let SCOPE_HANDLE = VariableHandle<String>("scope", BaseRecycleModel.NO_SCOPE)
    fileprivate static let SEARCHABLE_HANDLE = VariableHandle<String>("searchable", BaseRecycleModel.NO_QUERY)
    
    fileprivate var tagHandle: VariableHandle<String?> {
        return self.state.getHandle(handle: BaseRecycleModel.TAG_HANDLE)
    }
    
    fileprivate var scopeHandle: VariableHandle<String> {
        return self.state.getHandle(handle: BaseRecycleModel.SCOPE_HANDLE)
    }
    
    fileprivate var searchableHandle: VariableHandle<String> {
        return self.state.getHandle(handle: BaseRecycleModel.SEARCHABLE_HANDLE)
    }

    var tag: String? {
        get { return self.tagHandle.val }
        set { self.tagHandle.val = newValue }
    }

    var scope: String {
        get { return self.scopeHandle.val }
        set { self.scopeHandle.val = newValue }
    }

    var searchable: String {
        get { return self.searchableHandle.val }
        set { self.searchableHandle.val = newValue }
    }

    @discardableResult func with(tag: String?) -> BaseRecycleModel {
        self.tag = tag ?? BaseRecycleModel.TAG_HANDLE.def
        return self
    }

    @discardableResult func with(scope: String?) -> BaseRecycleModel {
        self.scope = scope ?? BaseRecycleModel.SCOPE_HANDLE.def
        return self
    }

    @discardableResult func with(searchable: String?) -> BaseRecycleModel {
        self.searchable = searchable ?? BaseRecycleModel.SEARCHABLE_HANDLE.def
        return self
    }

    @discardableResult func anyScope() -> BaseRecycleModel {
        return self.with(scope: BaseRecycleModel.ANY_SCOPE)
    }

    @discardableResult func noScope() -> BaseRecycleModel {
        return self.with(scope: BaseRecycleModel.NO_SCOPE)
    }

    @discardableResult func alwaysVisible() -> BaseRecycleModel {
        return self.with(searchable: BaseRecycleModel.ANY_QUERY)
    }

    @discardableResult func neverVisible() -> BaseRecycleModel {
        return self.with(searchable: BaseRecycleModel.NO_QUERY)
    }

    fileprivate func encodeScopeAndSearchable(with aCoder: NSCoder) {
        tagHandle.encode(with: aCoder)
        scopeHandle.encode(with: aCoder)
        searchableHandle.encode(with: aCoder)
    }
    
    fileprivate func decodeScopeAndSearchable(coder aDecoder: NSCoder) {
        tagHandle.decode(coder: aDecoder)
        scopeHandle.decode(coder: aDecoder)
        searchableHandle.decode(coder: aDecoder)
    }
    
}

// MARK: - Gesture
public extension BaseRecycleModel {

    static let PARENT_CLICK_RESPONSE = "parent.click_response"

    fileprivate static let CLICK_RESPONSE_HANDLE = VariableHandle<Any?>("click_response", nil)
    fileprivate static let LONG_CLICK_RESPONSE_HANDLE = VariableHandle<Any?>("long_click_response", nil)
    
    fileprivate var clickResponseHandle: VariableHandle<Any?> {
        return self.state.getHandle(handle: BaseRecycleModel.CLICK_RESPONSE_HANDLE)
    }
    
    fileprivate var longClickResponseHandle: VariableHandle<Any?> {
        return self.state.getHandle(handle: BaseRecycleModel.LONG_CLICK_RESPONSE_HANDLE)
    }
    
    var clickResponse: Any? {
        get { return self.clickResponseHandle.val }
        set { self.clickResponseHandle.val = newValue }
    }

    var longClickResponse: Any? {
        get { return self.longClickResponseHandle.val }
        set { self.longClickResponseHandle.val = newValue }
    }

    @discardableResult func with(click: Any?) -> BaseRecycleModel {
        self.clickResponse = click ?? BaseRecycleModel.CLICK_RESPONSE_HANDLE.def
        return self
    }

    @discardableResult func with(longClick: Any?) -> BaseRecycleModel {
        self.longClickResponse = longClick ?? BaseRecycleModel.LONG_CLICK_RESPONSE_HANDLE.def
        return self
    }

    fileprivate func encodeGestures(with aCoder: NSCoder) {
        clickResponseHandle.encode(with: aCoder)
        longClickResponseHandle.encode(with: aCoder)
    }
    
    fileprivate func decodeGestures(coder aDecoder: NSCoder) {
        clickResponseHandle.decode(coder: aDecoder)
        longClickResponseHandle.decode(coder: aDecoder)
    }
}
