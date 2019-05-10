//
//  UIScrollView_EXT.swift
//  EthosUI
//
//  Created by Etienne Goulet-Lang on 5/9/19.
//  Copyright © 2019 egouletlang. All rights reserved.
//

import Foundation

public extension UIScrollView {
    
    func refreshViewWithTag(_ tag: Int) -> UIRefreshView? {
        return viewWithTag(tag) as? UIRefreshView
    }
    
    func addPullRefresh(options: UIRefreshView.Options = UIRefreshView.Options.buildDefault(),
                        image: UIImage?, refreshCompletion: UIRefreshView.RefreshCompletion?) {
        let refreshViewFrame = CGRect(x: 0, y: -UIRefreshView.Constants.height, width: self.frame.size.width, height: UIRefreshView.Constants.height)
        let refreshView = UIRefreshView(options: options, image: image, frame: refreshViewFrame,
                                        refreshCompletion: refreshCompletion)
        refreshView.tag = UIRefreshView.Constants.pullTag
        addSubview(refreshView)
    }
    
    func addPushRefresh(options: UIRefreshView.Options = UIRefreshView.Options.buildDefault(), image: UIImage?,
                        refreshCompletion: UIRefreshView.RefreshCompletion?) {
        let refreshViewFrame = CGRect(x: 0, y: contentSize.height, width: self.frame.size.width,
                                      height: UIRefreshView.Constants.height)
        let refreshView = UIRefreshView(options: options, image: image, frame: refreshViewFrame,
                                        refreshCompletion: refreshCompletion, down: false)
        refreshView.tag = UIRefreshView.Constants.pushTag
        addSubview(refreshView)
    }
    
    func startPullRefresh() {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pullTag)
        refreshView?.state = .refreshing
    }
    
    func stopPullRefreshEver(_ ever: Bool = false) {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pullTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePullRefresh() {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pullTag)
        refreshView?.removeFromSuperview()
    }
    
    func startPushRefresh() {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pushTag)
        refreshView?.state = .refreshing
    }
    
    func stopPushRefreshEver(_ ever:Bool = false) {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pushTag)
        if ever {
            refreshView?.state = .finish
        } else {
            refreshView?.state = .stop
        }
    }
    
    func removePushRefresh() {
        let refreshView = self.refreshViewWithTag(UIRefreshView.Constants.pushTag)
        refreshView?.removeFromSuperview()
    }
    
    func fixedPullToRefreshViewForDidScroll() {
        let BaseUIRefreshView = self.refreshViewWithTag(UIRefreshView.Constants.pullTag)
        if !UIRefreshView.Constants.fixedTop || BaseUIRefreshView == nil {
            return
        }
        var frame = BaseUIRefreshView!.frame
        if self.contentOffset.y < -UIRefreshView.Constants.height {
            frame.origin.y = self.contentOffset.y
            BaseUIRefreshView!.frame = frame
        } else {
            frame.origin.y = -UIRefreshView.Constants.height
            BaseUIRefreshView!.frame = frame
        }
    }
}
