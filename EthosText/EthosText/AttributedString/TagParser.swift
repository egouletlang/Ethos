//
//  TTagParser.swift
//  EthosText
//
//  Created by Etienne Goulet-Lang on 4/17/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil

open class TagParser {
    
    // MARK: - Constants & Types
    fileprivate enum ParsingState {
        case TagClosed
        case TagOpen
    }
    
    fileprivate enum TagComponent: Character {
        case Open = "<"
        case Close = ">"
    }
    
    // MARK: - Builders & Constructors
    @discardableResult open func with(textSize: CGFloat?) -> TagParser {
        self.defaultTextSize = textSize ?? EthosTextConfig.shared.fontSize
        return self
    }
    
    @discardableResult open func with(textColorStr: String?) -> TagParser {
        if let str = textColorStr, let color = UIColor(hexString: str) {
            return self.with(textColor: color)
        }
        return self.with(textColor: nil)
    }
    
    @discardableResult open func with(textColor: UIColor?) -> TagParser {
        self.defaultTextColor = textColor ?? EthosTextConfig.shared.fontColor
        return self
    }
    
    @discardableResult open func with(supportLinks: Bool) -> TagParser {
        self.supportLinks = supportLinks
        return self
    }
    
    // MARK: - State variables
    private var defaultTextSize: CGFloat = EthosTextConfig.shared.fontSize
    
    private var defaultTextColor: UIColor? = EthosTextConfig.shared.fontColor
    
    private var supportLinks: Bool = true
    
    // MARK: - Operators
    open func parse(raw: String) -> (NSMutableAttributedString, [String: NSRange])  {
        
        var tags = [TagDescriptor]()
        
        var taglessString = ""
        var taglessStringIndex = 0
        
        var currentTag = ""
        
        var parsingState = ParsingState.TagClosed
        
        for char in raw {
            switch parsingState {
            case .TagClosed:
                // In this code block we are looking for an open tag
                guard let tagComponent = TagComponent(rawValue: char), tagComponent == .Open else {
                    taglessString.append(char)
                    taglessStringIndex += 1
                    continue
                }
                currentTag = ""
                parsingState = .TagOpen
            case .TagOpen:
                // In this code block we are looking for a close tag
                guard let tagComponent = TagComponent(rawValue: char), tagComponent == .Close else {
                    currentTag.append(char)
                    continue
                }
                
                if let descriptor = TagDescriptor(str: currentTag, index: taglessStringIndex) {
                    tags.append(descriptor)
                }
                
                parsingState = .TagClosed
            }
        }
        
        let pairs = createTagPairs(descriptors: tags)
        let attr = createAttributedString(clean: taglessString, pairs: pairs)
        let links = createLinkMap(pairs: pairs)
        return (attr, links)
    }
    
    // MARK: - Helper methods
    // MARK: AttributedString
    private func createAttributedString(clean: String,
                                        pairs: [(TagDescriptor, TagDescriptor)]) -> NSMutableAttributedString {
        
        let attr = NSMutableAttributedString(string: clean)
        var range = NSMakeRange(0, clean.count)
        
        // Add Default Font
        var font = EthosTextConfig.shared.regularFont.withSize(defaultTextSize)
        attr.addAttributes(self.createParagraphStyle(font: font), range: range)
        
        if let baseColor = defaultTextColor {
            attr.addAttributes(self.createTextColorStyle(color: baseColor), range: range)
        }
        
        for pair in pairs {
            range = NSMakeRange(pair.0.index, pair.1.index - pair.0.index)
            
            switch (pair.0.tag) {
            case .Bold, .Italic, .Tiny, .Small, .Large, .Huge:
                font = self.getBaseFont(index: pair.0.index, pairs: pairs)
                attr.addAttributes(self.createParagraphStyle(font: font), range: range)
            default:
                break
            }
        }
        
        for pair in pairs {
            range = NSMakeRange(pair.0.index, pair.1.index - pair.0.index)
            
            switch (pair.0.tag) {
            case .Underline:
                attr.addAttributes(self.createUnderlineStyle(), range: range)
            case .Link:
                if !supportLinks { continue }
                attr.addAttributes(self.createUnderlineStyle(), range: range)
                attr.addAttributes(self.createTextColorStyle(color: EthosTextConfig.shared.linkColor), range: range)
            case .Left:
                font = self.getBaseFont(index: pair.0.index, pairs: pairs)
                attr.addAttributes(self.createParagraphStyle(font: font, align: .left), range: range)
            case .Center:
                font = self.getBaseFont(index: pair.0.index, pairs: pairs)
                attr.addAttributes(self.createParagraphStyle(font: font, align: .center), range: range)
            case .Right:
                font = self.getBaseFont(index: pair.0.index, pairs: pairs)
                attr.addAttributes(self.createParagraphStyle(font: font, align: .right), range: range)
            case .Font:
                guard let color = pair.0.color else { continue }
                attr.addAttributes(self.createTextColorStyle(color: color), range: range)
            default:
                break
            }
        }
        
        return attr
    }
    // MARK: Style
    private func createParagraphStyle(font: UIFont, align: NSTextAlignment = .left) -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1
        style.minimumLineHeight = font.lineHeight
        style.maximumLineHeight = font.lineHeight
        style.alignment = align
        
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: style
        ]
    }
    
    private func createUnderlineStyle() -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    private func createTextColorStyle(color: UIColor) -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.foregroundColor: color
        ]
    }
    
    // MARK: Tags
    private func createTagPairs(descriptors: [TagDescriptor]) -> [(TagDescriptor, TagDescriptor)] {
        var pairs = [(TagDescriptor, TagDescriptor)]()
        
        var stacks = [String: [TagDescriptor]]()
        for descriptor in descriptors {
            if descriptor.isOpen {
                if stacks.get(descriptor.tag.rawValue) == nil {
                    stacks[descriptor.tag.rawValue] = []
                }
                stacks[descriptor.tag.rawValue]?.append(descriptor)
            } else {
                guard let open = stacks[descriptor.tag.rawValue]?.removeLast() else {
                    continue
                }
                
                pairs.append((open, descriptor))
            }
        }
        
        return pairs.sorted { (p1, p2) -> Bool in
            return p1.0.index <= p2.0.index && // Sort by lowest index
                (p1.1.index - p1.0.index) >= (p2.1.index - p2.0.index) // Sort by span
        }
    }
    
    private func getOpenTags(index: Int, pairs: [(TagDescriptor, TagDescriptor)]) -> [(TagDescriptor, TagDescriptor)] {
        return pairs.filter() { $0.0.index <= index && index < $0.1.index }
    }
    
    // MARK: Overlapping tags
    private func getTextSizeModifier(index: Int, pairs: [(TagDescriptor, TagDescriptor)]) -> CGFloat {
        let openTags = self.getOpenTags(index: index, pairs: pairs)
        
        let modifier = -4 * openTags.filter() { $0.0.tag == .Tiny }.count +
                       -2 * openTags.filter() { $0.0.tag == .Small }.count +
                        2 * openTags.filter() { $0.0.tag == .Large }.count +
                        4 * openTags.filter() { $0.0.tag == .Huge }.count
        
        return CGFloat(modifier)
    }
    
    private func getBaseFont(index: Int, pairs: [(TagDescriptor, TagDescriptor)]) -> UIFont {
        let openTags = self.getOpenTags(index: index, pairs: pairs)
        
        var baseFont = EthosTextConfig.shared.regularFont
        if openTags.filter({ $0.0.tag == .Bold }).count > 0 {
            baseFont = EthosTextConfig.shared.boldFont
        } else if openTags.filter({ $0.0.tag == .Italic }).count > 0 {
            baseFont = EthosTextConfig.shared.italicFont
        }
        
        return baseFont.withSize(defaultTextSize + getTextSizeModifier(index: index, pairs: pairs))
    }
    
    // MARK: Links
    private func createLinkMap(pairs: [(TagDescriptor, TagDescriptor)]) -> [String: NSRange] {
        var ret = [String: NSRange]()
        pairs.filter() { $0.0.tag == .Link }
            .forEach { (pair) in
                guard let url = pair.0.link else { return }
                ret[url] = NSMakeRange(pair.0.index, pair.1.index - pair.0.index)
        }
        return ret
    }
    
}
