//
//  BaseUITableViewController.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/9/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation
import EthosUtil
import EthosImage

open class BaseUITableViewController: BaseUIViewController, BaseUITableView.Delegate,
                                      BaseUITableView.CustomCellDelegate, UISearchControllerDelegate,
                                      UISearchBarDelegate, UISearchResultsUpdating {
    
    // MARK: - UI Components -
    public let tableView = BaseUITableView(frame: CGRect.zero)
    public let segmentViewBackground = BaseUIView(frame: CGRect.zero)
    public let segmentView = UISegmentedControl(frame: CGRect.zero)
    public let searchController = UISearchController(searchResultsController: nil)
    
    @discardableResult
    override open func createLayout() -> LifeCycleInterface {
        super.createLayout()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        self.definesPresentationContext = false
        
        self.view.addSubview(tableView)
        tableView.customTVCellDelegate = self
        tableView.baseUITableViewDelegate = self
        
        // Configure Tableview
        tableView.backgroundColor = defaultTableViewBackgroundColor()
        tableView.sectionIndexColor = EthosUIConfig.shared.primaryColor
        tableView.sectionBackgroundColor = defaultTableViewSectionBackgroundColor()
        
        ThreadHelper.background {
            self.tableView.setModels(models: self.createModels())
        }
        
        // Configure Search Controller
        searchController.hidesNavigationBarDuringPresentation = shouldHideNavigationBarDuringSearch()
        searchController.dimsBackgroundDuringPresentation = shouldDimBackgroundDuringPresentation()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        
        // Configure Search Bar
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.tintColor = UIColor(argb: 0xAAAAAA)
        
        var image: UIImage? = UIImage()
//        var image = ImageHelper.centerImage(imageRef: UIImage(),
//                                                 size: CGSize(width: 400, height: 400),
//                                                 insets: UIEdgeInsets.zero)
        image = ImageHelper.addBackgroundColor(img: image, color: UIColor(argb: 0xC9C9C9))
        searchController.searchBar.backgroundImage = image
        searchController.searchBar.barTintColor = UIColor(argb: 0xC9C9C9)
        
        // Configure Segmented Control
        self.segmentViewBackground.backgroundColor = UIColor(argb: 0xC9C9C9)
        self.segmentView.tintColor = UIColor(argb: 0xAAAAAA)
        
        // Add Search Bar if required
        if addSearchBarHeader() {
            // We used to set the search bar to be the tableview header.. but the frame of that
            // component is affected by the presence of sectionIndex. This is a way to support
            // both section indices and a fullscreen search bar. Notice the view is added
            // directly to the tableview
            self.tableView.addSubview(searchController.searchBar)
            self.tableView.contentOffset = CGPoint(x: 0, y: 44)
            let view = BaseUIView(frame: CGRect.zero)
            view.shouldRespondToTouch = false
            tableView.tableHeaderView = view
            searchController.delegate = self
        }
        
        // Add the scopes if required
        if let scopes = self._getScopes() {
            if addDedicatedSegmentControl() {
                self.view.addSubview(segmentViewBackground)
                self.segmentViewBackground.addSubview(segmentView)
                segmentView.addTarget(self, action: #selector(BaseUITableViewController.selector_segmentedControlValueChanged(_:)), for:.valueChanged)
                scopes.forEach { (title) in
                    segmentView.insertSegment(withTitle: title, at: segmentView.numberOfSegments, animated: false)
                }
                segmentView.selectedSegmentIndex = 0
            } else {
                searchController.searchBar.scopeButtonTitles = scopes
                searchController.searchBar.selectedScopeButtonIndex = 0
            }
            filter()
        }
        
        return self
    }
    
    override open func frameUpdate() {
        super.frameUpdate()
        
        let top: CGFloat = self.effectiveTopLayoutGuide
        self.segmentViewBackground.frame = CGRect(x: 0, y: top, width: self.view.bounds.width,
                                                  height: 50)
        self.segmentView.frame = self.segmentViewBackground.bounds.insetBy(dx: 20, dy: 8)
        
        
        let tableviewTop = self.segmentViewBackground.superview != nil ?
            self.segmentViewBackground.frame.maxY : top
        
        self.tableView.frame = getTableViewFrame(top: tableviewTop)
        
        tableView.tableHeaderView?.frame.size = CGSize(width: self.view.frame.width,
                                                       height: searchController.searchBar.frame.height)
        
    }
    
    open func getTableViewFrame(top: CGFloat) -> CGRect {
        return CGRect(
            x: 0, y: top,
            width: self.view.bounds.width,
            height: self.effectiveBottomLayoutGuide - top)
    }
    
    // MARK: - TableView Models -
    fileprivate var initialModels = [BaseRecycleModel]()
    
    open var isSearchActive = false
    
    /**
     - returns: A list of models to display when the view controller first loads
     */
    open func createModels() -> [BaseRecycleModel] {
        return self.initialModels
    }
    
    open func refreshModels() -> [BaseRecycleModel] {
        return self.createModels()
    }
    
    /**
     Uses sets the models using createModels(..)
     */
    open func updateModels() {
        if Thread.isMainThread {
            ThreadHelper.background {
                self.updateModels()
            }
            return
        }
        self.tableView.setModels(models: self.createModels())
    }
    
    // MARK: - Configuration -
    /**
     Return true to add a search bar header, defaults to false
     */
    open func addSearchBarHeader() -> Bool {
        return false
    }
    
    /**
     Return true to add a search bar header, defaults to false
     */
    open func addDedicatedSegmentControl() -> Bool {
        return false
    }
    
    /**
     Return true to add the "All" segment in the segmented control, defaults to true
     */
    open func addAllInSegmentControl() -> Bool {
        return true
    }
    
    open func addPullToRefresh(image: UIImage? = nil, options: UIRefreshView.Options = UIRefreshView.Options.buildDefault(), refreshCompletion: (() -> Void)? = nil) {
        
        let callback: () -> Void = refreshCompletion ?? { [weak self] in
            guard let s = self else { return }
            s.tableView.clear()
            s.tableView.setModels(models: s.refreshModels())
            s.tableView.stopPullRefreshEver()
        }
        
        tableView.addPullRefresh(options: options, image: image, refreshCompletion: callback)
    }
    
    /**
     return the scopes that should show up in the search interface
     - important: override me
     */
    open func getScopes() -> [String]? {
        return nil
    }
    
    /**
     Return Search Scopes
     */
    private func _getScopes() -> [String]? {
        var scopes = self.getScopes()
        var addAll = self.addAllInSegmentControl()
        
        for s in scopes ?? [] {
            if s.lowercased() == "all" {
                addAll = false
            }
        }
        
        if addAll {
            scopes?.insert("All", at: 0)
        }
        
        return scopes
    }
    
    /**
     return whether the search bar should take over the navigation bar area
     */
    open func shouldHideNavigationBarDuringSearch() -> Bool {
        return !addDedicatedSegmentControl()
    }
    
    /**
     return whether the search bar should dim the tableview area
     */
    open func shouldDimBackgroundDuringPresentation() -> Bool {
        return false
    }
    
    /**
     Return the background color, defaults to clear
     */
    open func defaultTableViewBackgroundColor() -> UIColor {
        return EthosUIConfig.shared.tableviewBackgroundColor
    }
    
    /**
     Return the background color, defaults to clear
     */
    open func defaultTableViewSectionBackgroundColor() -> UIColor {
        return EthosUIConfig.shared.tableviewSectionBackgroundColor
    }
    
    // MARK: - Filtering -
    
    /**
     returns the currently active scope
     */
    fileprivate func getScope() -> String? {
        if self.segmentView.superview != nil {
            return segmentView.titleForSegment(at: segmentView.selectedSegmentIndex)
        } else {
            let index = searchController.searchBar.selectedScopeButtonIndex
            return searchController.searchBar.scopeButtonTitles?[index]
        }
    }
    
    /**
     returns the latest search query
     */
    fileprivate func getSearchText() -> String? {
        return searchController.searchBar.text
    }
    
    fileprivate func filter() {
        self.tableView.filter(scope: getScope(), text: getSearchText(), ignoreIfSameQuery: true)
    }
    
    // MARK: - BaseUITableViewDelegate methods -
    /**
     Called when a tableview model with a clickResponse object is tapped
     - important: override me
     */
    open func tapped(model: BaseRecycleModel, view: BaseRecycleView, tableview: BaseUITableView) {}
    
    /**
     Called when a tableview model with a clickResponse object is long pressed
     - important: override me
     */
    open func longPressed(model: BaseRecycleModel, view: BaseRecycleView, tableview: BaseUITableView) {}
    
    // MARK: - CustomTVCellDelegate methods -
    /**
     Instantiate custom TVCells
     - important: override me
     - returns: return nil for a non-custom model
     */
    open func getOrBuildCell(tableView: UITableView, model: BaseRecycleModel, width: CGFloat, forMeasurement: Bool) -> BaseRecycleTVCell? {
        return nil
    }
    
    /**
     Register your custom model class
     - important: override me
     - returns: return a list of tuples with the following format (Class, identifier)
     */
    open func getCellsToRegister() -> [(AnyClass?, String)] {
        return []
    }
    
    public func willPresentSearchController(_ searchController: UISearchController) {
        if self._getScopes() == nil {
            
            let time = DispatchTime.now() + Double(Int64(0.01 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time) {
                UIView.animate(withDuration: 0.29) {
                    self.tableView.contentInset.top = -self.searchController.searchBar.frame.height
                }
            }
        }
    }
    
    public func willDismissSearchController(_ searchController: UISearchController) {
        if self._getScopes() == nil {
            UIView.animate(withDuration: 0.3) {
                self.tableView.contentInset.top = 0
                self.tableView.contentOffset.y -= self.searchController.searchBar.frame.height
            }
        }
    }
    
    // MARK: - Search Bar Delegate -
    open func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filter()
    }
    
    open func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = true
        self.frameUpdate()
    }
    
    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isSearchActive = false
        self.frameUpdate()
    }
    
    // MARK: - UISearchResultsUpdating Method -
    open func updateSearchResults(for searchController: UISearchController) {
        filter()
    }
    
    @objc
    open func selector_segmentedControlValueChanged(_ segment: UISegmentedControl) {
        filter()
    }
    
    open func dismissSearch() {
        if self.searchController.isActive {
            self.dismiss(animated: false, completion: nil)
            self.searchController.isActive = false
            self.searchController.searchBar.showsCancelButton = false
            self.searchController.setEditing(false, animated: false)
            self.filter()
        }
    }
    
}
