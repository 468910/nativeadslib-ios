//

//  NativeAdsTableViewDelegate.swift
//  Pods
//
//  Created by Kees Bank on 18/04/16.
//
//

import UIKit

@objc
open class NativeAdTableViewDelegate: NSObject, UITableViewDelegate {

    open var controller: UIViewController
    open var delegate: UITableViewDelegate
    open var datasource: NativeAdTableViewDataSource

    public required init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
        self.datasource = datasource
        self.controller = controller
        self.delegate = delegate
    }

    // Patching of the delegate. Either replace certain calls to our library or do some checks and call the original implementation of the host
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let val = datasource.getNativeAdListing(indexPath) {
            val.ad.openAdUrl(FullscreenBrowser(parentViewController: controller))
            return
        }
        delegate.tableView?(tableView, didSelectRowAt: self.datasource.getOriginalPositionForElement(indexPath))
    }

    @objc
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
            return heightForHeader
        }
        return tableView.rowHeight
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let listing = datasource.getNativeAdListing(indexPath) {
            let cell = datasource.getAdCell(listing.ad)
            return cell.frame.size.height
        } else if let heightForRow = delegate.tableView?(tableView, heightForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return heightForRow
        }
        /* Instead of returning AutomaticDimension dont bother with esimatedHeight just return the
         tableview rowHeight
         */
        return tableView.rowHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate.tableView?(tableView, viewForHeaderInSection: section)
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, accessoryButtonTappedForRowWith: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    // Default Value = TRUE/YES
    @available(iOS 9.0, *)
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let canFocus = delegate.tableView?(tableView, canFocusRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return canFocus
        }
        return true
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didDeselectRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if datasource.getNativeAdListing(indexPath!) == nil {
            delegate.tableView?(tableView, didEndEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath!))
        }
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }

    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) {
            return canPerform
        }
        return true
    }

    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didHighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didUnhighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    @available(iOS 9, *)
    open func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        delegate.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }

    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if datasource.getNativeAdListing(indexPath) != nil {
            return nil
        } else if let rowAction = delegate.tableView?(tableView, editActionsForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return rowAction
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if datasource.getNativeAdListing(indexPath) != nil {
            return UITableViewCellEditingStyle.none
        } else if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return editingStyle
        }
        return UITableViewCellEditingStyle.none
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
            return estimatedHeightForFooter
        }
        return UITableViewAutomaticDimension
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
            return estimatedHeight
        }
        return UITableViewAutomaticDimension
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if datasource.getNativeAdListing(indexPath) != nil {
            return UITableViewAutomaticDimension
            // not an ad - let the original datasource handle it
        } else if let estimatedHeightForRowAtIndexPath = delegate.tableView?(tableView, estimatedHeightForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return estimatedHeightForRowAtIndexPath
        }
        return UITableViewAutomaticDimension
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
            return heightForFooter
        }
        return UITableViewAutomaticDimension
    }

    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if datasource.getNativeAdListing(indexPath) != nil {
            return -1
        } else if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return indenLevel
        }
        return -1
    }

    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        delegate.tableView?(tableView, performAction: action, forRowAt: self.datasource.getOriginalPositionForElement(indexPath), withSender: sender)
    }

    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return shouldHighLight
        }
        return true
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return ShouldIndent
        }
        return true
    }

    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return shouldShowMenu
        }
        return true
    }

    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let path = delegate.tableView?(tableView, willSelectRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return path
        }
        return indexPath
    }

    @available(iOS 9.0, *)
    open func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusIn: context) {
            return shouldUpdateFocusInContext
        }
        return true
    }

    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
            return path
        }
        return proposedDestinationIndexPath
    }

    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return title
        }
        return nil
    }
    
    open func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        if let path = delegate.indexPathForPreferredFocusedView?(in: tableView) {
            return path
        }
        return nil//TODO: default preferred focus view. instead nil (https://developer.apple.com/reference/uikit/uitableviewdelegate/1614929-indexpathforpreferredfocusedview)
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegate.tableView?(tableView, viewForFooterInSection: section)
    }

    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) != nil {
        }
        delegate.tableView?(tableView, willBeginEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath))
    }

    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let path = delegate.tableView?(tableView, willDeselectRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return path
        }
        return indexPath
    }

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, willDisplay: cell, forRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
}
