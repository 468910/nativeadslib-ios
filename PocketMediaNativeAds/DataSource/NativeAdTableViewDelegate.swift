//

//  NativeAdsTableViewDelegate.swift
//  Pods
//
//  Created by Kees Bank on 18/04/16.
//
//

import UIKit

@objc
public class NativeAdTableViewDelegate: NSObject, UITableViewDelegate {

	public var controller: UIViewController
	public var delegate: UITableViewDelegate
	public var datasource: NativeAdTableViewDataSource

    internal static let heightForStandardAdUnit: CGFloat = 80

	required public init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
		self.datasource = datasource
		self.controller = controller
		self.delegate = delegate
	}

	// Patching of the delegate. Either replace certain calls to our library or do some checks and call the original implementation of the host
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let val = datasource.getNativeAdListing(indexPath) {
			val.ad.openAdUrl(FullscreenBrowser(parentViewController: controller))
            return
		}
        delegate.tableView?(tableView, didSelectRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
	}

	@objc
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
			return heightForHeader
		}
        return tableView.rowHeight
	}

	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if datasource.getNativeAdListing(indexPath) != nil {
			return NativeAdTableViewDelegate.heightForStandardAdUnit
		} else if let heightForRow = delegate.tableView?(tableView, heightForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return heightForRow
        }
        /* Instead of returning AutomaticDimension dont bother with esimatedHeight just return the
           tableview rowHeight
        */
        return tableView.rowHeight

	}

	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForHeaderInSection: section)
	}

	public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	// Default Value = TRUE/YES
	@available(iOS 9.0, *)
	public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let canFocus = delegate.tableView?(tableView, canFocusRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return canFocus
        }
        return true
	}

	public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didDeselectRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath?) {
		if datasource.getNativeAdListing(indexPath!) == nil {
			delegate.tableView?(tableView, didEndEditingRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath!))
		}
	}

	public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) {
            return canPerform
        }
        return true
	}

	public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didHighlightRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didUnhighlightRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	@available(iOS 9, *)
	public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		delegate.tableView?(tableView, didUpdateFocusInContext: context, withAnimationCoordinator: coordinator)
	}

	public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		if datasource.getNativeAdListing(indexPath) != nil {
			return nil
		} else if let rowAction = delegate.tableView?(tableView, editActionsForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return rowAction
        }
        return nil
	}

	public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		if datasource.getNativeAdListing(indexPath) != nil {
			return UITableViewCellEditingStyle.None
        } else if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return editingStyle
		}
        return UITableViewCellEditingStyle.None
	}

	public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
			return estimatedHeightForFooter
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
			return estimatedHeight
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if datasource.getNativeAdListing(indexPath) != nil {
			return UITableViewAutomaticDimension
        // not an ad - let the original datasource handle it
		} else if let estimatedHeightForRowAtIndexPath = delegate.tableView?(tableView, estimatedHeightForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return estimatedHeightForRowAtIndexPath
        }
		return UITableViewAutomaticDimension
	}

	public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
			return heightForFooter
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
		if datasource.getNativeAdListing(indexPath) != nil {
			return -1
		} else if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return indenLevel
        }
        return -1
	}

	public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
		delegate.tableView?(tableView, performAction: action, forRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath), withSender: sender)
	}

	public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
			return shouldHighLight
		}
		return true
	}

	public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return ShouldIndent
        }
        return true
	}

	public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
            return shouldShowMenu
        }
        return true
	}

	public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willSelectRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
			return path
		}
		return indexPath
	}

	@available(iOS 9.0, *)
	public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
		if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusInContext: context) {
			return shouldUpdateFocusInContext
		}
		return true
	}

	public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
		if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
			return path
		}
        return proposedDestinationIndexPath
	}

	public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
		if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
			return title
		}
        return nil
	}

	public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForFooterInSection: section)
	}

	public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) != nil {
		}
        delegate.tableView?(tableView, willBeginEditingRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
	}

	public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willDeselectRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath)) {
			return path
		}
		return indexPath
	}

	public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: self.datasource.getOriginalPositionForElement(indexPath))
		}
	}

	public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
	}
}
