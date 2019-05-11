//
//  BaseUITableView.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/8/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import EthosText

open class BaseUITableView: UITableView, LifeCycleInterface,
                            EthosUILabel.Delegate,
                            UIGestureRecognizerDelegate,
                            BaseRecycleTVCell.Delegate, BaseRecycleTVCell.CustomCellDelegate {
    
    public typealias Delegate = BaseUITableViewDelegate
    
    public typealias CustomCellDelegate = CustomTVCellDelegate
    
    public static let DEFAULT_SECTION_TITLE = "__Reserved.default_section_title"
    
    public enum SectionType {
        case none
        case row
        case float
    }
    
    // MARK: - Constructors
    public init() {
        super.init(frame: CGRect.zero, style: UITableView.Style.plain)
        self.initialize()
    }
    
    override public init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        (self as LifeCycleInterface).destroy?()
        
    }
    
    // MARK: - UI
    fileprivate var size = CGSize.zero
    
    override open var frame: CGRect {
        didSet {
            if self.size.width != self.frame.size.width {
                (self as LifeCycleInterface).frameWidthUpdate?()
            }
            
            if self.size.height != self.frame.size.height {
                (self as LifeCycleInterface).frameHeightUpdate?()
            }
            
            if self.size != self.frame.size {
                self.size = self.frame.size
                self.frameUpdate()
            }
        }
    }
    
    // MARK: - Configuration
    public var automaticallyHandleRowBorders = true
    
    public var sectionHeaderType: SectionType = .none
    
    public var collapsableSections = false
    
    // MARK: - State
    public var requiredHeight: CGFloat {
        return self.allModelsFlattened.reduce(0) { $0 + $1.size.height }
    }
    
    // MARK: - Sections
    fileprivate var showSectionIndex = false
    
    public var sectionBackgroundColor: UIColor?
    
    fileprivate var sectionTitles = [String]()
    
    fileprivate var collapsedSections = Set([Int]())
    
    // MARK: - Models
    fileprivate var allModels = [[BaseRecycleModel]]()
    
    fileprivate var filteredModels = [[BaseRecycleModel]]()
    
    fileprivate var allModelsFlattened: [BaseRecycleModel] {
        return self.allModels.reduce([], +)
    }
    
    fileprivate var filteredModelsFlattened: [BaseRecycleModel] {
        return self.filteredModels.reduce([], +)
    }
    
    // MARK: - LifeCycleInterface
    open func initialize() {
        dataSource = self
        delegate = self
        self.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.allowsSelection = false
        self.backgroundColor = UIColor.clear
    }
    
    @discardableResult
    open func createLayout() -> LifeCycleInterface { return self }
    
    open func frameWidthUpdate() {
        for m in self.filteredModelsFlattened {
            if m.shouldMeasureHeight {
                let cell = BaseRecycleTVCell.build(id: m.id, width: self.bounds.width, forMeasurement: true)
                m.size.height = cell.sizeThatFits(model: m, forWidth: self.bounds.width).height
                if m.minHeight > 0 {
                    m.size.height = (m.height > m.minHeight) ? m.height : m.minHeight
                }
            }
            
        }
        
        for m in self.allModelsFlattened {
            if m.shouldMeasureHeight {
                let cell = BaseRecycleTVCell.build(id: m.id, width: self.bounds.width, forMeasurement: true)
                m.size.height = cell.sizeThatFits(model: m, forWidth: self.bounds.width).height
                if m.minHeight > 0 {
                    m.size.height = (m.height > m.minHeight) ? m.height : m.minHeight
                }
            }
            
        }
        
        self.reloadData()
    }
    
    open func frameHeightUpdate() {}
    
    open func frameUpdate() {}
    
    open func destroy() {
        for model in self.allModelsFlattened {
            model.cleanUp()
        }
        for model in self.filteredModelsFlattened {
            model.cleanUp()
        }
        allModels.removeAll()
        filteredModels.removeAll()
    }
    
    fileprivate func find(_ model: BaseRecycleModel, in sections: [[BaseRecycleModel]]) -> (Int, Int)? {
        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.firstIndex(of: model), rowIndex != NSNotFound {
                return (rowIndex, sectionIndex)
            }
        }
        return nil
    }
    
    fileprivate func correctHeights(models: [BaseRecycleModel], completion: @escaping () -> Void) {
        if !Thread.isMainThread {
            ThreadHelper.main {
                self.correctHeights(models: models, completion: completion)
            }
            return
        }
        
        for m in models {
            if m.height == 0 && m.shouldMeasureHeight {
                let cell = self.customTVCellDelegate?.getOrBuildCell(tableView: self, model: m,
                                                                     width: self.bounds.width, forMeasurement: true)
                            ?? BaseRecycleTVCell.build(id: m.id, width: self.bounds.width, forMeasurement: true)
                
                
                cell.customRecycleCellDelegate = customTVCellDelegate
                m.size.height = cell.sizeThatFits(model: m, forWidth: self.bounds.width).height
                if m.minHeight > 0 {
                    m.size.height = (m.height > m.minHeight) ? m.height : m.minHeight
                }
            }
        }
        completion()
    }
    
    open func reloadSection(section: String, withAnimations: UITableView.RowAnimation? = nil) {
        if let sectionIndex = self.sectionTitles.firstIndex(of: section), sectionIndex != NSNotFound,
            let models = self.filteredModels.get(sectionIndex) {
            self.reloadModels(models: models, withAnimations: withAnimations)
        }
    }
    
    open func reloadModels(models: [BaseRecycleModel], withAnimations: UITableView.RowAnimation? = nil) {
        let indexPaths = models
            .compactMap { self.find($0, in: filteredModels) }
            .map { IndexPath(row: $0, section: $1) }
        
        // bail if there are no index paths to update
        if indexPaths.count <= 0 {
            return
        }
        
        let animations = withAnimations != nil ? withAnimations! : .none
        ThreadHelper.main {
            // Replace data in table view
            if self.isIndexPathValid(indexPaths.last!) {
                // Disable animations, if required
                if withAnimations == nil {
                    UIView.setAnimationsEnabled(false)
                }
                self.beginUpdates()
                self.reloadRows(at: indexPaths, with: animations)
                self.endUpdates()
                
                // Enable animations, if required
                if withAnimations == nil {
                    UIView.setAnimationsEnabled(true)
                }
            } else {
                self.reloadData()
            }
        }
    }
    
    open func clear() {
        ThreadHelper.checkMain {
            self.sectionTitles.removeAll()
            self.allModels.removeAll()
            self.filter(scope: self.currScope, text: self.currSearch)
        }
    }
    
    open func removeDefaultSection(completion: (() -> Void)? = nil) {
        let sectionTitle = BaseUITableView.DEFAULT_SECTION_TITLE
        guard let sectionIndex = self.sectionTitles.firstIndex(of: sectionTitle), sectionIndex != NSNotFound else {
            return
        }
        
        ThreadHelper.checkMain() {
            self.sectionTitles.remove(at: sectionIndex)
            self.filteredModels.remove(at: sectionIndex)
            self.allModels.remove(at: sectionIndex)
            self.beginUpdates()
            self.deleteSections(IndexSet(integer: sectionIndex), with: .none)
            self.endUpdates()
            completion?()
        }
        
    }
    
    open func setModels(models: [String: [BaseRecycleModel]],
                        clearAll: Bool = true,
                        completion: ((CGFloat)->Void)? = nil,
                        sort: Bool = true) {
        let sortedKeys = (sort == true) ? models.keys.sorted() {$0 < $1} : models.keys.compactMap({ $0 })
        var sortedModels = [[BaseRecycleModel]]()
        sortedKeys.forEach { sortedModels.append(models.get($0)!) }
        self.setModels(models: sortedModels, sections: sortedKeys, clearAll: clearAll,
                       completion: completion)
    }
    
    open func setModels(models: [[BaseRecycleModel]],
                        sections: [String],
                        clearAll: Bool = true,
                        completion: ((CGFloat)->Void)? = nil) {
        self.correctHeights(models: models.reduce([], +)) {
            ThreadHelper.checkMain() {
                if clearAll {
                    self.sectionTitles.removeAll()
                    self.allModels.removeAll()
                }
                
                for (sectionTitle, rows) in zip(sections, models) {
                    var sectionIndex = self.sectionTitles.firstIndex(of: sectionTitle)
                    if sectionIndex == nil || sectionIndex == NSNotFound {
                        sectionIndex = self.sectionTitles.count
                        self.sectionTitles.append(sectionTitle)
                        self.allModels.append([])
                    }
                    self.allModels[sectionIndex!] = rows
                }
                
                self.filter(scope: self.currScope, text: self.currSearch)
                
                if let c = completion {
                    c(self.requiredHeight)
                }
                
            }
        }
    }
    
    open func setModels(models: [BaseRecycleModel],
                        section: String? = nil,
                        completion: ((CGFloat) -> Void)? = nil) {
        self.correctHeights(models: models) {
            ThreadHelper.checkMain() {
                let sectionTitle = section ?? BaseUITableView.DEFAULT_SECTION_TITLE
                
                var sectionIndex = self.sectionTitles.firstIndex(of: sectionTitle)
                if sectionIndex == nil || sectionIndex == NSNotFound {
                    sectionIndex = self.sectionTitles.count
                    self.sectionTitles.append(sectionTitle)
                    self.allModels.append([])
                }
                
                // Ensure we modify models and UI in the same thread
                self.allModels[sectionIndex!] = models
                self.filter(scope: self.currScope, text: self.currSearch)
                
                if let c = completion {
                    c(self.requiredHeight)
                }
                
            }
        }
    }
    
    open func appendModels(models: [(String, [BaseRecycleModel])]) {
        self.correctHeights(models: models.reduce([], {$0 + $1.1})) {
            ThreadHelper.checkMain {
                
                for (section, rows) in models {
                    var sectionIndex = self.sectionTitles.firstIndex(of: section)
                    if sectionIndex == nil || sectionIndex == NSNotFound {
                        sectionIndex = self.sectionTitles.count
                        self.sectionTitles.append(section)
                        self.allModels.append([])
                    }
                    self.allModels[sectionIndex!].append(contentsOf: rows)
                }
                
                self.filter(scope: self.currScope, text: self.currSearch)
            }
        }
    }
    
    open func appendModels(models: [BaseRecycleModel], section: String? = nil) {
        self.correctHeights(models: models) {
            ThreadHelper.checkMain() {
                let sectionTitle = section ?? BaseUITableView.DEFAULT_SECTION_TITLE
                
                var sectionIndex = self.sectionTitles.firstIndex(of: sectionTitle)
                if sectionIndex == nil || sectionIndex == NSNotFound {
                    sectionIndex = self.sectionTitles.count
                    self.sectionTitles.append(sectionTitle)
                    self.allModels.append([])
                }
                
                // Ensure we modify models and UI in the same thread
                self.allModels[sectionIndex!].append(contentsOf: models)
                self.filter(scope: self.currScope, text: self.currSearch)
            }
        }
    }
    
    open func replaceModel(model: BaseRecycleModel, newModels: [BaseRecycleModel],
                           withAnimations: UITableView.RowAnimation? = nil) {
        self.correctHeights(models: newModels) {
            let animations = withAnimations != nil ? withAnimations! : .none
            ThreadHelper.checkMain() {
                // Ensure we modify models and UI in the same thread
                
                if let (rowIndex, sectionIndex) = self.find(model, in: self.allModels) {
                    var indices = [Int]()
                    for i in 0 ..< newModels.count {
                        indices.append(rowIndex + i)
                    }
                    
                    // Remove target model
                    self.allModels[sectionIndex].remove(at: rowIndex)
                    
                    // Append new models
                    for (index, model) in zip(indices, newModels) {
                        self.allModels[sectionIndex].insert(model, at: index)
                    }
                }
                
                guard let (rowIndex, sectionIndex) = self.find(model, in: self.filteredModels) else {
                    return // no need to animate anything
                }
                
                let filteredNewModels = self.filter(set: newModels)
                
                // Prepare index paths for new models
                var indexPaths = [IndexPath]()
                var indices = [Int]()
                for i in 0 ..< filteredNewModels.count {
                    indexPaths.append(IndexPath(row: rowIndex + i, section: sectionIndex))
                    indices.append(rowIndex + i)
                }
                
                // Replace data in models
                self.filteredModels[sectionIndex].remove(at: rowIndex)
                for (index, model) in zip(indices, filteredNewModels) {
                    self.filteredModels[sectionIndex].insert(model, at: index)
                }
                
                // Replace data in table view
                let indexPath = IndexPath(row: rowIndex, section: sectionIndex)
                if self.isIndexPathValid(indexPath) {
                    if withAnimations == nil {
                        UIView.setAnimationsEnabled(false)
                    }
                    self.beginUpdates()
                    self.deleteRows(at: [indexPath], with: animations)
                    self.insertRows(at: indexPaths, with: animations)
                    self.endUpdates()
                    if withAnimations == nil {
                        UIView.setAnimationsEnabled(true)
                    }
                } else {
                    self.reloadData()
                }
            }
        }
    }
    
    open func insertModels(models: [BaseRecycleModel], section: String? = nil) {
        self.correctHeights(models: models) {
            ThreadHelper.checkMain() {
                let sectionTitle = section ?? BaseUITableView.DEFAULT_SECTION_TITLE
                
                var sectionIndex = self.sectionTitles.firstIndex(of: sectionTitle)
                if sectionIndex == nil || sectionIndex == NSNotFound {
                    sectionIndex = 0
                    self.sectionTitles.insert(sectionTitle, at: 0)
                    self.allModels.insert([], at: 0)
                }
                
                self.allModels[sectionIndex!].insert(contentsOf: models, at: 0)
                self.filter(scope: self.currScope, text: self.currSearch)
            }
        }
    }
    
    open func getOrBuildCell(tableView: BaseUITableView, model: BaseRecycleModel) -> BaseRecycleTVCell {
        let width = tableView.bounds.width
        let reuseIdentifier = BaseRecycleTVCell.buildIdentifier(id: model.id, forWidth: width)
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? BaseRecycleTVCell {
            return cell
        }
        
        let cell =  self.customTVCellDelegate?.getOrBuildCell(tableView: tableView, model: model, width: width, forMeasurement: false) ??
            BaseRecycleTVCell.build(id: model.id, width: width, forMeasurement: false)
        cell.delegate = self
        
        return cell
    }
    
    // MARK: - Search -
    private var currSearch: String?
    
    private var currScope: String?
    
    private func equivalent(_ t1: String?,_ t2: String?) -> Bool {
        return ((t1 ?? "") == (t2 ?? ""))
    }
    
    open func filter(scope: String?, text: String?, ignoreIfSameQuery: Bool = false) {
        if ignoreIfSameQuery && self.equivalent(self.currScope, scope) && self.equivalent(self.currSearch, text) {
            return
        }
        self.currScope = scope
        self.currSearch = text
        
        var newFilteredData = [[BaseRecycleModel]]()
        self.allModels.forEach { (rows) in
            var result = rows
            
            if let s = scope, s != "All" {
                let format = "((scope == %@) AND (scope != %@)) OR (scope == %@)"
                let scopePredicate = NSPredicate(format: format,
                                                 argumentArray: [s, BaseRecycleModel.NO_SCOPE, BaseRecycleModel.ANY_SCOPE])
                result = NSArray(array: result).filtered(using: scopePredicate) as! [BaseRecycleModel]
            }
            
            if let t = text, !t.isEmpty {
                let format = "((searchable CONTAINS[cd] %@) AND (searchable != %@)) OR (searchable == %@)"
                let scopePredicate = NSPredicate(format: format,
                                                 argumentArray: [t, BaseRecycleModel.NO_QUERY, BaseRecycleModel.ANY_QUERY])
                result = NSArray(array: result).filtered(using: scopePredicate) as! [BaseRecycleModel]
            }
            
            if automaticallyHandleRowBorders {
                var previousModel: BaseRecycleModel?
                
                for model in result {
                    if model.tag == LabelRecycleModel.SECTION_HEADER_OR_FOOTER_TAG {
                        previousModel?.withBorder(bottom: false).withBorder(paddingBottom: nil)
                    } else {
                        model.withDefaultBottomBorder()
                        previousModel = model
                    }
                }
                
                let contentModels = result.compactMap() { $0.tag != LabelRecycleModel.SECTION_HEADER_OR_FOOTER_TAG ? $0: nil}
                contentModels.last?.withBorder(bottom: false).withBorder(paddingBottom: nil)
            }
            
            newFilteredData.append(result)
        }
        
        self.filteredModels = newFilteredData
        self.reloadData()
    }
    
    fileprivate func filter(set: [BaseRecycleModel]) -> [BaseRecycleModel] {
        var result = set
        
        if let s = self.currScope, s != "All" {
            let format = "((scope == %@) AND (scope != %@)) OR (scope == %@)"
            let scopePredicate = NSPredicate(format: format,
                                             argumentArray: [s, BaseRecycleModel.NO_SCOPE, BaseRecycleModel.ANY_SCOPE])
            result = NSArray(array: result).filtered(using: scopePredicate) as! [BaseRecycleModel]
        }
        
        if let t = self.currSearch, !t.isEmpty {
            let format = "((searchable CONTAINS[cd] %@) AND (searchable != %@)) OR (searchable == %@)"
            let scopePredicate = NSPredicate(format: format,
                                             argumentArray: [t, BaseRecycleModel.NO_QUERY, BaseRecycleModel.ANY_QUERY])
            result = NSArray(array: result).filtered(using: scopePredicate) as! [BaseRecycleModel]
        }
        
        return result
    }
    
    open func getModelByTag(tag: String) -> BaseRecycleModel? {
        return (self.allModelsFlattened.filter() {$0.tag == tag}).first
    }
    
    // MARK: - Delegates -
    /**
     Handles BaseUITableViewDelegate events
     */
    public weak var baseUITableViewDelegate: BaseUITableView.Delegate?
    
    /**
     Handles CustomTVCellDelegate events
     */
    public weak var customTVCellDelegate: BaseUITableView.CustomCellDelegate?
    
    
    // MARK: - UITableViewDataSource Methods -
    
    @objc
    public func selector_headerTapped(_ gestureRecognizer: UIGestureRecognizer) {
        guard let tag = gestureRecognizer.view?.tag else { return }
        
        if collapsedSections.contains(tag) {
            collapsedSections.remove(tag)
        } else {
            collapsedSections.insert(tag)
        }
        
        self.reloadSections(IndexSet(integer: tag), with: .automatic)
    }
    
    // MARK: - CustomTVCellDelegate Methods -
    open func getCellsToRegister() -> [(AnyClass?, String)] {
        return self.customTVCellDelegate?.getCellsToRegister() ?? []
    }
    
    open func getOrBuildCell(tableView: UITableView, model: BaseRecycleModel, width: CGFloat, forMeasurement: Bool) -> BaseRecycleTVCell? {
        return self.customTVCellDelegate?.getOrBuildCell(tableView: tableView, model: model, width: width, forMeasurement: forMeasurement)
    }
    
    // MARK: - BaseTVCellDelegate -
    open func active(view: BaseRecycleView) {}
    
    open func getTableView() -> UITableView? {
        return self
    }
    
    open func tapped(model: BaseRecycleModel, view: BaseRecycleView) {
        self.baseUITableViewDelegate?.tapped(model: model, view: view, tableview: self)
    }
    
    open func longPressed(model: BaseRecycleModel, view: BaseRecycleView) {
        self.baseUITableViewDelegate?.longPressed(model: model, view: view, tableview: self)
    }
    
    // MARK: - ScrollView Delegate -
    
    public var allowConcurrentTouchGestureRecognition = false
    
    public var allowMultipleGestureRecognition = true
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = otherGestureRecognizer as? UITapGestureRecognizer {
            return allowConcurrentTouchGestureRecognition
        }
        return allowMultipleGestureRecognition
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.baseUITableViewDelegate?.newScrollOffset?(offset: scrollView.contentOffset.y, tableview: self)
        
        if let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pullTag) {
            if refreshView.state == .refreshing {
                if scrollView.contentOffset.y > -20 {
                    UIView.animate(withDuration: 0.3) {
                        self.contentInset.top = 0
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.contentInset.top = refreshView.frame.height
                    }
                }
            }
        }
    }
    
    open func addTap(_ view: UIView, selector: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
}


extension BaseUITableView: UITableViewDataSource {
    
    open func getCount(section: Int) -> Int {
        return filteredModels.get(section)?.count ?? 0
    }
    
    open func getModel(row: Int, section: Int) -> BaseRecycleModel? {
        return filteredModels.get(section)?.get(row)
    }
    
}

extension BaseUITableView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let simpleTableView = tableView as? BaseUITableView {
            return simpleTableView.collapsedSections.contains(section) ? 0 : simpleTableView.getCount(section: section)
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let genericTableView = tableView as? BaseUITableView {
            if let model = genericTableView.getModel(row: indexPath.row, section: indexPath.section) {
                let cell = genericTableView.getOrBuildCell(tableView: genericTableView, model: model)
                cell.setData(model: model, forWidth: tableView.bounds.width)
                cell.frameUpdate()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredModels.count
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // Add space around the title to make it more clickable
        return (self.showSectionIndex && self.sectionTitles.count > 1) ? self.sectionTitles.compactMap() {"   \($0)"} : nil
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let genericTableView = tableView as? BaseUITableView {
            if let model = genericTableView.getModel(row: indexPath.row, section: indexPath.section) {
                let height = model.getContainerHeight()
                return height >= 2 ? height : 2
            }
            
        }
        return 2
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let genericTableView = tableView as? BaseUITableView {
            if let model = genericTableView.getModel(row: indexPath.row, section: indexPath.section) {
                let height = model.getContainerHeight()
                return height >= 2 ? height : 2
            }
            
        }
        return 2
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.sectionTitles.get(section), title != BaseUITableView.DEFAULT_SECTION_TITLE,
            (self.filteredModels.get(section)?.count ?? 0) > 0 else {
                return nil
        }
        
        switch (sectionHeaderType) {
        case .row:
            let headerView = BaseUIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            headerView.backgroundColor = self.sectionBackgroundColor ?? UIColor.clear
            
            let label = EthosUILabel(frame: CGRect.zero)
            label.labelDescriptor = TextHelper.parse(title)
            label.sizeToFit()
            label.center = headerView.center
            label.frame.origin.x = 10
            
            headerView.addSubview(label)
            if collapsableSections {
                headerView.tag = section
                self.addTap(headerView, selector: #selector(BaseUITableView.selector_headerTapped(_:)))
            }
            
            return headerView
            
        case .float:
            let headerView = BaseUIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            
            let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            headerView.addSubview(backgroundView)
            
            let label = EthosUILabel(frame: CGRect.zero)
            label.labelDescriptor = TextHelper.parse(title.addColor("#ffffff"))
            label.sizeToFit()
            label.center = headerView.center
            headerView.addSubview(label)
            
            backgroundView.clipsToBounds = true
            backgroundView.frame = label.frame.insetBy(dx: -8, dy: -6)
            backgroundView.layer.cornerRadius = backgroundView.frame.size.height / 2
            
            if collapsableSections {
                headerView.tag = section
                self.addTap(headerView, selector: #selector(BaseUITableView.selector_headerTapped(_:)))
            }
            
            return headerView
        default:
            return nil
            
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = self.sectionTitles.get(section), title != BaseUITableView.DEFAULT_SECTION_TITLE,
            (self.filteredModels.get(section)?.count ?? 0) > 0 else {
                return 0
        }
        switch (sectionHeaderType) {
        case .row:
            return 30
        case .float:
            return 40
        default:
            return 0
            
        }
    }
    
}
