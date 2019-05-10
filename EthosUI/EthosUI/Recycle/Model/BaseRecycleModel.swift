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

fileprivate let BACKGROUND_COLOR_HANDLE = VariableHandle<UIColor?>("background_color", nil)

fileprivate let CONTENT_COLOR_HANDLE = VariableHandle<UIColor?>("content_color", nil)

fileprivate let SHADOW_OFFSET_HANDLE = VariableHandle<CGSize>("shadow_offset", CGSize.zero)

fileprivate let SHADOW_RADIUS_HANDLE = VariableHandle<CGFloat>("shadow_radius", 0)

fileprivate let SHADOW_OPACITY_HANDLE = VariableHandle<Float>("shadow_opacity", 0)

fileprivate let CORNER_RADIUS_HANDLE = VariableHandle<CGFloat>("corner_radius", 0)

fileprivate let LEFT_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("left_border_padding", Rect<CGFloat>(def: 0))

fileprivate let TOP_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("top_border_padding", Rect<CGFloat>(def: 0))

fileprivate let RIGHT_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("right_border_padding", Rect<CGFloat>(def: 0))

fileprivate let BOTTOM_BORDER_PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("bottom_border_padding", Rect<CGFloat>(def: 0))

fileprivate let LEFT_BORDER_HANDLE = VariableHandle<Bool>("left_border", false)

fileprivate let TOP_BORDER_HANDLE = VariableHandle<Bool>("top_border", false)

fileprivate let RIGHT_BORDER_HANDLE = VariableHandle<Bool>("right_border", false)

fileprivate let BOTTOM_BORDER_HANDLE = VariableHandle<Bool>("left_border", false)

fileprivate let BORDER_COLOR_HANDLE = VariableHandle<UIColor>("border_color", UIColor(argb: 0x7B868C))

fileprivate let PADDING_HANDLE = VariableHandle<Rect<CGFloat>>("padding", Rect<CGFloat>(def: 0))

fileprivate let SIZE_HANDLE = VariableHandle<CGSize>("size", CGSize.zero)

fileprivate let MIN_HEIGHT_HANDLE = VariableHandle<CGFloat>("min_height", -1)

fileprivate let SHOULD_MEASURE_HANDLE = VariableHandle<CGSize>("should_measure", CGSize.zero)

fileprivate let TAG_HANDLE = VariableHandle<String?>("tag", nil)

fileprivate let SCOPE_HANDLE = VariableHandle<String>("scope", BaseRecycleModel.NO_SCOPE)

fileprivate let SEARCHABLE_HANDLE = VariableHandle<String>("searchable", BaseRecycleModel.NO_QUERY)

fileprivate let CLICK_RESPONSE_HANDLE = VariableHandle<Any?>("click_response", nil)

fileprivate let LONG_CLICK_RESPONSE_HANDLE = VariableHandle<Any?>("long_click_response", nil)


public class BaseRecycleModel: NSObject, NSCoding, NSCopying {
    
    // MARK: - Constants & Types
    public static let ANY_SCOPE = ".*"
    
    public static let NO_SCOPE = "^.*"
    
    public static let ANY_QUERY = ".*"
    
    public static let NO_QUERY = "^.*"
    
    public static let PARENT_CLICK_RESPONSE = "parent.click_response"
    
    public struct BorderDescriptor {
        var show: Bool
        var padding: Rect<CGFloat>
    }
    
    public struct Borders {
        var left: BorderDescriptor
        var top: BorderDescriptor
        var right: BorderDescriptor
        var bottom: BorderDescriptor
    }
    
    // MARK: - Builders & Constructors
    public override init() {
        super.init()
    }
    
    @discardableResult
    public func with(color: UIColor? = nil, content: UIColor? = nil) -> BaseRecycleModel {
        self.backgroundColor = color ?? BACKGROUND_COLOR_HANDLE.def
        self.contentColor = content ?? CONTENT_COLOR_HANDLE.def
        return self
    }
    
    @discardableResult func with(shadowOffset: CGSize? = nil, shadowRadius: CGFloat? = nil,
                                 shadowOpacity: Float? = nil) -> BaseRecycleModel {
        self.shadowOffset = shadowOffset ?? SHADOW_OFFSET_HANDLE.def
        self.shadowRadius = shadowRadius ?? SHADOW_RADIUS_HANDLE.def
        self.shadowOpacity = shadowOpacity ?? SHADOW_OPACITY_HANDLE.def
        return self
    }
    
    @discardableResult public func with(cornerRadius: CGFloat?) -> BaseRecycleModel {
        self.cornerRadius = cornerRadius ?? CORNER_RADIUS_HANDLE.def
        return self
    }
    
    @discardableResult public func withDefaultShadow() -> BaseRecycleModel {
        return self.with(shadowOffset: CGSize(width: 1, height: 3), shadowRadius: 3.0, shadowOpacity: 0.2)
    }
    
    @discardableResult public func withBorder(left: Bool? = nil, top: Bool? = nil, right: Bool? = nil,
                                              bottom: Bool? = nil) -> BaseRecycleModel {
        self.borders.left.show = left ?? LEFT_BORDER_HANDLE.def
        self.borders.top.show = top ?? TOP_BORDER_HANDLE.def
        self.borders.right.show = right ?? RIGHT_BORDER_HANDLE.def
        self.borders.bottom.show = bottom ?? BOTTOM_BORDER_HANDLE.def
        return self
    }

    @discardableResult public func withBorder(color: UIColor?) -> BaseRecycleModel {
        self.borderColor = color ?? BORDER_COLOR_HANDLE.def
        return self
    }
    
    @discardableResult public func withBorder(paddingLeft: Rect<CGFloat>? = nil, paddingTop: Rect<CGFloat>? = nil,
                                              paddingRight: Rect<CGFloat>? = nil,
                                              paddingBottom: Rect<CGFloat>? = nil) -> BaseRecycleModel {
        self.borders.left.padding = paddingLeft ?? LEFT_BORDER_PADDING_HANDLE.def
        self.borders.top.padding = paddingTop ?? TOP_BORDER_PADDING_HANDLE.def
        self.borders.right.padding = paddingRight ?? RIGHT_BORDER_PADDING_HANDLE.def
        self.borders.bottom.padding = paddingBottom ?? BOTTOM_BORDER_PADDING_HANDLE.def
        return self
    }
    
    @discardableResult public func withDefaultBottomBorder() -> BaseRecycleModel {
        return self.withBorder(bottom: true).withBorder(paddingBottom: nil)
    }
    
    @discardableResult public func withPadding(left: CGFloat? = nil, top: CGFloat? = nil, right: CGFloat? = nil,
                                               bottom: CGFloat? = nil) -> BaseRecycleModel {
        self.padding.left = left ?? PADDING_HANDLE.def.left
        self.padding.top = top ?? PADDING_HANDLE.def.top
        self.padding.right = right ?? PADDING_HANDLE.def.right
        self.padding.bottom = bottom ?? PADDING_HANDLE.def.bottom
        return self
    }

    @discardableResult public func with(size: CGSize) -> BaseRecycleModel {
        self.size = size
        self.shouldMeasureWidth = false
        self.shouldMeasureHeight = false
        return self
    }
    
    @discardableResult public func with(height: CGFloat) -> BaseRecycleModel {
        self.size.height = height
        self.shouldMeasureHeight = false
        return self
    }
    
    @discardableResult public func with(minHeight: CGFloat) -> BaseRecycleModel {
        self.minHeight = height
        return self
    }
    
    @discardableResult public func with(width: CGFloat) -> BaseRecycleModel {
        self.size.width = width
        self.shouldMeasureWidth = false
        return self
    }
    
    @discardableResult public func resetSize() -> BaseRecycleModel {
        self.size = CGSize.zero
        self.shouldMeasureWidth = true
        self.shouldMeasureHeight = true
        return self
    }

    @discardableResult public func with(tag: String?) -> BaseRecycleModel {
        self.tag = tag ?? TAG_HANDLE.def
        return self
    }
    
    @discardableResult public func with(scope: String?) -> BaseRecycleModel {
        self.scope = scope ?? SCOPE_HANDLE.def
        return self
    }
    
    @discardableResult public func with(searchable: String?) -> BaseRecycleModel {
        self.searchable = searchable ?? SEARCHABLE_HANDLE.def
        return self
    }
    
    @discardableResult public func anyScope() -> BaseRecycleModel {
        return self.with(scope: BaseRecycleModel.ANY_SCOPE)
    }
    
    @discardableResult public func noScope() -> BaseRecycleModel {
        return self.with(scope: BaseRecycleModel.NO_SCOPE)
    }
    
    @discardableResult public func alwaysVisible() -> BaseRecycleModel {
        return self.with(searchable: BaseRecycleModel.ANY_QUERY)
    }
    
    @discardableResult public func neverVisible() -> BaseRecycleModel {
        return self.with(searchable: BaseRecycleModel.NO_QUERY)
    }

    @discardableResult public func with(click: Any?) -> BaseRecycleModel {
        self.clickResponse = click ?? CLICK_RESPONSE_HANDLE.def
        return self
    }
    
    @discardableResult public func with(longClick: Any?) -> BaseRecycleModel {
        self.longClickResponse = longClick ?? LONG_CLICK_RESPONSE_HANDLE.def
        return self
    }

    
    // MARK: - Variables
    public var id: String {
        return RecycleModels.base.rawValue
    }
    
    public var newInstance: BaseRecycleModel {
        return BaseRecycleModel()
    }
    
    private var state = ComponentState()
    
    public func getHandle<T>(handle: VariableHandle<T>) -> VariableHandle<T> {
        return self.state.getHandle(handle: handle)
    }
    
    public var backgroundColor: UIColor? {
        get { return self.getHandle(handle: BACKGROUND_COLOR_HANDLE).val }
        set { self.getHandle(handle: BACKGROUND_COLOR_HANDLE).val = newValue }
    }
    
    public var contentColor: UIColor? {
        get { return self.getHandle(handle: CONTENT_COLOR_HANDLE).val }
        set { self.getHandle(handle: CONTENT_COLOR_HANDLE).val = newValue }
    }
    
    public var shadowOffset: CGSize {
        get { return self.getHandle(handle: SHADOW_OFFSET_HANDLE).val }
        set { self.getHandle(handle: SHADOW_OFFSET_HANDLE).val = newValue }
    }
    
    public var shadowRadius: CGFloat {
        get { return self.getHandle(handle: SHADOW_RADIUS_HANDLE).val }
        set { self.getHandle(handle: SHADOW_RADIUS_HANDLE).val = newValue }
    }
    
    public var shadowOpacity: Float {
        get { return self.getHandle(handle: SHADOW_OPACITY_HANDLE).val }
        set { self.getHandle(handle: SHADOW_OPACITY_HANDLE).val = newValue }
    }
    
    public var cornerRadius: CGFloat {
        get { return self.getHandle(handle: CORNER_RADIUS_HANDLE).val }
        set { self.getHandle(handle: CORNER_RADIUS_HANDLE).val = newValue }
    }
    
    public var borders: Borders {
        get {
            return Borders(
                left: BorderDescriptor(show: self.getHandle(handle: LEFT_BORDER_HANDLE).val,
                                       padding: self.getHandle(handle: LEFT_BORDER_PADDING_HANDLE).val),
                top: BorderDescriptor(show: self.getHandle(handle: TOP_BORDER_HANDLE).val,
                                      padding: self.getHandle(handle: TOP_BORDER_PADDING_HANDLE).val),
                right: BorderDescriptor(show: self.getHandle(handle: RIGHT_BORDER_HANDLE).val,
                                        padding: self.getHandle(handle: RIGHT_BORDER_PADDING_HANDLE).val),
                bottom: BorderDescriptor(show: self.getHandle(handle: BOTTOM_BORDER_HANDLE).val,
                                         padding: self.getHandle(handle: BOTTOM_BORDER_PADDING_HANDLE).val)
            )
        }
        set {
            self.getHandle(handle: LEFT_BORDER_HANDLE).val = newValue.left.show
            self.getHandle(handle: LEFT_BORDER_PADDING_HANDLE).val = newValue.left.padding
            self.getHandle(handle: TOP_BORDER_HANDLE).val = newValue.top.show
            self.getHandle(handle: TOP_BORDER_PADDING_HANDLE).val = newValue.top.padding
            self.getHandle(handle: RIGHT_BORDER_HANDLE).val = newValue.right.show
            self.getHandle(handle: RIGHT_BORDER_PADDING_HANDLE).val = newValue.right.padding
            self.getHandle(handle: BOTTOM_BORDER_HANDLE).val = newValue.bottom.show
            self.getHandle(handle: BOTTOM_BORDER_PADDING_HANDLE).val = newValue.bottom.padding
        }
    }
    
    public var borderColor: UIColor {
        get { return self.getHandle(handle: BORDER_COLOR_HANDLE).val }
        set { self.getHandle(handle: BORDER_COLOR_HANDLE).val = newValue }
    }
    
    public var padding: Rect<CGFloat> {
        get { return self.getHandle(handle: PADDING_HANDLE).val }
        set { self.getHandle(handle: PADDING_HANDLE).val = newValue }
    }
    
    public var size: CGSize {
        get { return self.getHandle(handle: SIZE_HANDLE).val }
        set { self.getHandle(handle: SIZE_HANDLE).val = newValue }
    }
    
    public var height: CGFloat {
        return self.size.height
    }
    
    public var width: CGFloat {
        return self.size.width
    }
    
    public var minHeight: CGFloat {
        get { return self.getHandle(handle: MIN_HEIGHT_HANDLE).val }
        set { self.getHandle(handle: MIN_HEIGHT_HANDLE).val = newValue }
    }
    
    public var shouldMeasureHeight: Bool {
        get { return self.getHandle(handle: SHOULD_MEASURE_HANDLE).val.height == 0 }
        set { self.getHandle(handle: SHOULD_MEASURE_HANDLE).val.height = newValue ? 0 : 1 }
    }
    
    public var shouldMeasureWidth: Bool {
        get { return self.getHandle(handle: SHOULD_MEASURE_HANDLE).val.width == 0 }
        set { self.getHandle(handle: SHOULD_MEASURE_HANDLE).val.width = newValue ? 0 : 1 }
    }
    
    public var tag: String? {
        get { return self.getHandle(handle: TAG_HANDLE).val }
        set { self.getHandle(handle: TAG_HANDLE).val = newValue }
    }
    
    public var scope: String {
        get { return self.getHandle(handle: SCOPE_HANDLE).val }
        set { self.getHandle(handle: SCOPE_HANDLE).val = newValue }
    }
    
    public var searchable: String {
        get { return self.getHandle(handle: SEARCHABLE_HANDLE).val }
        set { self.getHandle(handle: SEARCHABLE_HANDLE).val = newValue }
    }
    
    public var clickResponse: Any? {
        get { return self.getHandle(handle: CLICK_RESPONSE_HANDLE).val }
        set { self.getHandle(handle: CLICK_RESPONSE_HANDLE).val = newValue }
    }
    
    public var longClickResponse: Any? {
        get { return self.getHandle(handle: LONG_CLICK_RESPONSE_HANDLE).val }
        set { self.getHandle(handle: LONG_CLICK_RESPONSE_HANDLE).val = newValue }
    }
    
    public func getContainerHeight() -> CGFloat {
        return self.padding.top + self.height + self.padding.bottom
    }
    
    // MARK: - NSCoding Functions
    public func encode(with aCoder: NSCoder) {
        self.getHandle(handle: BACKGROUND_COLOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: CONTENT_COLOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SHADOW_OFFSET_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SHADOW_RADIUS_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SHADOW_OPACITY_HANDLE).encode(with: aCoder)
        self.getHandle(handle: CORNER_RADIUS_HANDLE).encode(with: aCoder)
        self.getHandle(handle: LEFT_BORDER_PADDING_HANDLE).encode(with: aCoder)
        self.getHandle(handle: TOP_BORDER_PADDING_HANDLE).encode(with: aCoder)
        self.getHandle(handle: RIGHT_BORDER_PADDING_HANDLE).encode(with: aCoder)
        self.getHandle(handle: BOTTOM_BORDER_PADDING_HANDLE).encode(with: aCoder)
        self.getHandle(handle: LEFT_BORDER_HANDLE).encode(with: aCoder)
        self.getHandle(handle: TOP_BORDER_HANDLE).encode(with: aCoder)
        self.getHandle(handle: RIGHT_BORDER_HANDLE).encode(with: aCoder)
        self.getHandle(handle: BOTTOM_BORDER_HANDLE).encode(with: aCoder)
        self.getHandle(handle: BORDER_COLOR_HANDLE).encode(with: aCoder)
        self.getHandle(handle: PADDING_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SIZE_HANDLE).encode(with: aCoder)
        self.getHandle(handle: MIN_HEIGHT_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SHOULD_MEASURE_HANDLE).encode(with: aCoder)
        self.getHandle(handle: TAG_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SCOPE_HANDLE).encode(with: aCoder)
        self.getHandle(handle: SEARCHABLE_HANDLE).encode(with: aCoder)
        self.getHandle(handle: CLICK_RESPONSE_HANDLE).encode(with: aCoder)
        self.getHandle(handle: LONG_CLICK_RESPONSE_HANDLE).encode(with: aCoder)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init()
        self.getHandle(handle: BACKGROUND_COLOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: CONTENT_COLOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SHADOW_OFFSET_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SHADOW_RADIUS_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SHADOW_OPACITY_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: CORNER_RADIUS_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: LEFT_BORDER_PADDING_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: TOP_BORDER_PADDING_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: RIGHT_BORDER_PADDING_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: BOTTOM_BORDER_PADDING_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: LEFT_BORDER_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: TOP_BORDER_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: RIGHT_BORDER_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: BOTTOM_BORDER_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: BORDER_COLOR_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: PADDING_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SIZE_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: MIN_HEIGHT_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SHOULD_MEASURE_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: TAG_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SCOPE_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: SEARCHABLE_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: CLICK_RESPONSE_HANDLE).decode(coder: aDecoder)
        self.getHandle(handle: LONG_CLICK_RESPONSE_HANDLE).decode(coder: aDecoder)
    }
    
    // MARK: - Copy
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = self.newInstance
        copy.state = self.state.clone()
        return copy
    }
    
    // MARK: - Clean up
    public func cleanUp() {}
    
}
