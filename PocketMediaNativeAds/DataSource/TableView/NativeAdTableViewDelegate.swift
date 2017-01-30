//

//  NativeAdsTableViewDelegate.swift
//  Pods
//
//  Created by Kees Bank on 18/04/16.
//
// Interesting source: https://github.com/edopelawi/CascadingTableDelegate/blob/master/Documentation/DefaultReturnValues.md#height-support

import UIKit

/**
 Wraps around a UITableViewDelegate delegate and adds the ad logic.
 Patching of the delegate and replaces some calls if the subject is an ad. Otherwise it'll call the original implementation.
 */
@objc
open class NativeAdTableViewDelegate: NSObject, UITableViewDelegate {
    /// The controller used to contain context.
    open var controller: UIViewController
    /// Original delegate.
    open var delegate: UITableViewDelegate
    /// Instance of NativeAdTableViewDataSource. That is also creating this instance.
    open var datasource: NativeAdTableViewDataSource

    /**
     Initializer.
     - parameter datasource: Instance of NativeAdTableViewDataSource.
     - parameter controller: The controller used to contain context.
     - parameter delegate: Original delegate we are wrapping around.
     */
    public required init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
        self.datasource = datasource
        self.controller = controller
        self.delegate = delegate
    }

    /**
     Tells the delegate that the specified row is now selected.
     */
    @objc
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let val = datasource.getNativeAdListing(indexPath) {
            val.ad.openAdUrl(opener: FullScreenBrowser(delegate: nil, parent: controller))
            return
        }
        delegate.tableView?(tableView, didSelectRowAt: self.datasource.getOriginalPositionForElement(indexPath))
    }

    /**
     Asks the delegate for the height to use for the header of a particular section.
     */
    @objc
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
            return heightForHeader
        }
        if datasource.numberOfSections(in: tableView) > 1 {
            return CGFloat(30)
        }
        return CGFloat(0)
    }

    /**
     Asks the delegate for the height to use for a row in a specified location.
     */
    @objc
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let listing = datasource.getNativeAdListing(indexPath) {
            return UITableViewAutomaticDimension
            /*          This creates a never ending loop with the latest dequeueCell
             let cell = datasource.getAdCell(listing.ad, indexPath: indexPath)
             return cell.frame.size.height
            */
        } else if let heightForRow = delegate.tableView?(tableView, heightForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return heightForRow
        }
        return tableView.rowHeight // Which could be UITableViewAutomaticDimension
    }

    /**
     Asks the delegate for a view object to display in the header of the specified section of the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return delegate.tableView?(tableView, viewForHeaderInSection: section)
    }

    /**
     Tells the delegate that the user tapped the accessory (disclosure) view associated with a given row.
     */
    @objc
    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, accessoryButtonTappedForRowWith: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Asks the delegate whether the cell at the specified index path is itself focusable.
     */
    @objc
    @available(iOS 9.0, *)
    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let canFocus = delegate.tableView?(tableView, canFocusRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return canFocus
        }
        return true
    }

    /**
     Tells the delegate that the specified row is now deselected.
     */
    @objc
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didDeselectRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Tells the delegate that the specified cell was removed from the table.
     */
    @objc
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Tells the delegate that the specified footer view was removed from the table.
     */
    @objc
    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
    }

    /**
     Tells the delegate that the table view has left editing mode.
     */
    @objc
    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if datasource.getNativeAdListing(indexPath!) == nil {
            delegate.tableView?(tableView, didEndEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath!))
        }
    }

    /**
     Tells the delegate that the specified header view was removed from the table.
     */
    @objc
    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
    }

    /**
     Asks the delegate if the editing menu should omit the Copy or Paste command for a given row.
     */
    @objc
    open func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) {
            return canPerform
        }
        return true
    }

    /**
     Tells the delegate that the specified row was highlighted.
     */
    @objc
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didHighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Tells the delegate that the highlight was removed from the row at the specified index path.
     */
    @objc
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, didUnhighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Tells the delegate that a focus update specified by the context has just occurred.
     */
    @objc
    @available(iOS 9, *)
    open func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        delegate.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
    }

    /**
     Asks the delegate for the actions to display in response to a swipe in the specified row.
     */
    @objc
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if datasource.getNativeAdListing(indexPath) != nil {
            return nil
        } else if let rowAction = delegate.tableView?(tableView, editActionsForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return rowAction
        }
        return nil
    }

    /**
     Asks the delegate for the editing style of a row at a particular location in a table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if datasource.getNativeAdListing(indexPath) != nil {
            return UITableViewCellEditingStyle.none
        } else if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return editingStyle
        }
        return UITableViewCellEditingStyle.none
    }

    /**
     Asks the delegate for the estimated height of the footer of a particular section.
     */
    @objc
    open func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
            return estimatedHeightForFooter
        }
        return CGFloat(0)
    }

    /**
     Asks the delegate for the estimated height of the header of a particular section.
     */
    @objc
    open func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
            return estimatedHeight
        }
        return self.tableView(tableView, heightForHeaderInSection: section)
    }

    /**
     Asks the delegate for the estimated height of a row in a specified location.
     */
    @objc
    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if datasource.getNativeAdListing(indexPath) != nil {
            return UITableViewAutomaticDimension
            // not an ad - let the original datasource handle it
        } else if let estimatedHeightForRowAtIndexPath = delegate.tableView?(tableView, estimatedHeightForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return estimatedHeightForRowAtIndexPath
        }
        return UITableViewAutomaticDimension
    }

    /**
     Asks the delegate for the height to use for the footer of a particular section.
     */
    @objc
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
            return heightForFooter
        }
        return UITableViewAutomaticDimension
    }

    /**
     Asks the delegate to return the level of indentation for a row in a given section.
     */
    @objc
    open func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if datasource.getNativeAdListing(indexPath) != nil {
            return -1
        } else if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return indenLevel
        }
        return -1
    }

    /**
     Tells the delegate to perform a copy or paste operation on the content of a given row.
     */
    @objc
    open func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        delegate.tableView?(tableView, performAction: action, forRowAt: self.datasource.getOriginalPositionForElement(indexPath), withSender: sender)
    }

    /**
     Asks the delegate if the specified row should be highlighted.
     */
    @objc
    open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return shouldHighLight
        }
        return true
    }

    /**
     Asks the delegate whether the background of the specified row should be indented while the table view is in editing mode.
     */
    @objc
    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return ShouldIndent
        }
        return true
    }

    /**
     Asks the delegate if the editing menu should be shown for a certain row.
     */
    @objc
    open func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if datasource.getNativeAdListing(indexPath) != nil {
            return true
        } else if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return shouldShowMenu
        }
        return true
    }

    /**
     Tells the delegate that a specified row is about to be selected.
     */
    @objc
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let path = delegate.tableView?(tableView, willSelectRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return path
        }
        return indexPath
    }

    /**
     Asks the delegate whether the focus update specified by the context is allowed to occur.
     */
    @objc
    @available(iOS 9.0, *)
    open func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusIn: context) {
            return shouldUpdateFocusInContext
        }
        return true
    }

    /**
     Asks the delegate to return a new index path to retarget a proposed move of a row.
     */
    @objc
    open func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
            return path
        }
        return proposedDestinationIndexPath
    }

    /**
     Changes the default title of the delete-confirmation button.
     */
    @objc
    open func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return title
        }
        return nil
    }

    /**
     Asks the delegate for the table view’s index path for the preferred focused view.
     */
    @objc
    open func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
        if let path = delegate.indexPathForPreferredFocusedView?(in: tableView) {
            return path
        }
        return nil // TODO: default preferred focus view. instead nil (https://developer.apple.com/reference/uikit/uitableviewdelegate/1614929-indexpathforpreferredfocusedview)
    }

    /**
     Asks the delegate for a view object to display in the footer of the specified section of the table view.
     */
    @objc
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return delegate.tableView?(tableView, viewForFooterInSection: section)
    }

    /**
     Tells the delegate that the table view is about to go into editing mode.
     */
    @objc
    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) != nil {
        }
        delegate.tableView?(tableView, willBeginEditingRowAt: self.datasource.getOriginalPositionForElement(indexPath))
    }

    /**
     Tells the delegate that a specified row is about to be deselected.
     */
    @objc
    open func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let path = delegate.tableView?(tableView, willDeselectRowAt: self.datasource.getOriginalPositionForElement(indexPath)) {
            return path
        }
        return indexPath
    }

    /**
     Tells the delegate the table view is about to draw a cell for a particular row.
     */
    @objc
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if datasource.getNativeAdListing(indexPath) == nil {
            delegate.tableView?(tableView, willDisplay: cell, forRowAt: self.datasource.getOriginalPositionForElement(indexPath))
        }
    }

    /**
     Tells the delegate that a footer view is about to be displayed for the specified section.
     */
    @objc
    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
    }

    /**
     Tells the delegate that a header view is about to be displayed for the specified section.
     */
    @objc
    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
    }
}
