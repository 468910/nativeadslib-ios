//

//  NativeAdsTableViewDelegate.swift
//  Pods
//
//  Created by Kees Bank on 18/04/16.
//
//

import UIKit

@objc
internal class NativeAdTableViewDelegate: NSObject, UITableViewDelegate {

	internal var controller: UIViewController
	internal var delegate: UITableViewDelegate
	internal var datasource: NativeAdTableViewDataSource

	required internal init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
		self.datasource = datasource
		self.controller = controller
		self.delegate = delegate
		Logger.debug("Screen width: \(UIScreen.mainScreen().bounds.size.width) ")
	}

	// Patching of the delegate. Either replace certain calls to our library or do some checks and call the original implementation of the host
	@objc
	internal func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let val = datasource.adStream.isAdAtposition(indexPath) {
			val.openAdUrl(FullscreenBrowser(parentViewController: controller))
            return
		}
        delegate.tableView?(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: datasource.adStream.normalize(indexPath), inSection: indexPath.section))
	}

	@objc
	internal func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
			return heightForHeader
		}
        return UITableViewAutomaticDimension
	}

	internal func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return UITableViewAutomaticDimension
		}
        // not an ad - let the original datasource handle it
        if let heightForRow = delegate.tableView?(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
            return heightForRow
        }
        return UITableViewAutomaticDimension
	}

	internal func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForHeaderInSection: section)
	}

	internal func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	// Default Value = TRUE/YES
	@available(iOS 9.0, *)
	internal func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return true
		}
        if let canFocus = delegate.tableView?(tableView, canFocusRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
            return canFocus
        }
        return true
	}

	internal func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, didDeselectRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	internal func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	internal func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
	}

	internal func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, didEndEditingRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	internal func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
	}

	internal func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return true
		}
        if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) {
            return canPerform
        }
        return true
	}

	internal func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, didHighlightRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	internal func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) == nil {
			delegate.tableView?(tableView, didUnhighlightRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	@available(iOS 9, *)
	internal func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		delegate.tableView?(tableView, didUpdateFocusInContext: context, withAnimationCoordinator: coordinator)
	}

	internal func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return nil
		}
        if let rowAction = delegate.tableView?(tableView, editActionsForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
            return rowAction
        }
        return nil
	}

	internal func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return UITableViewCellEditingStyle.None
		} else {
			if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
				return editingStyle
			} else {
				return UITableViewCellEditingStyle.None
			}
		}
	}

	internal func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
			return estimatedHeightForFooter
		} else {
			return UITableViewAutomaticDimension
		}
	}

	internal func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
			return estimatedHeight
		} else {
			return UITableViewAutomaticDimension
		}
	}

	internal func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return UITableViewAutomaticDimension
		} else {
			// not an ad - let the original datasource handle it
			if let heightForRow = delegate.tableView?(tableView, heightForRowAtIndexPath: NSIndexPath(forItem: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
				return heightForRow
			} else {
				return UITableViewAutomaticDimension
			}
		}
	}

	internal func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
			return heightForFooter
		} else {
			return UITableViewAutomaticDimension
		}
	}

	internal func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return -1
		} else {
			if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
				return indenLevel
			} else {
				return -1
			}
		}
	}

	internal func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
		delegate.tableView?(tableView, performAction: action, forRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section), withSender: sender)
	}

	internal func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
			return shouldHighLight
		} else {
			return true
		}
	}

	internal func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return true
		} else {
			if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
				return ShouldIndent
			} else {
				return true
			}
		}
	}

	internal func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
			return true
		} else {
			if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
				return shouldShowMenu
			} else {
				return true
			}
		}
	}

	internal func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willSelectRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
			return path
		} else {
			return indexPath
		}
	}

	@available(iOS 9.0, *)
	internal func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
		if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusInContext: context) {
			return shouldUpdateFocusInContext
		} else {
			return true
		}
	}

	internal func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
		if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
			return path
		} else {
			return proposedDestinationIndexPath
		}
	}

	internal func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
		if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
			return title
		} else {
			return nil
		}
	}

	internal func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForFooterInSection: section)
	}

	internal func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
		} else {
			delegate.tableView?(tableView, willBeginEditingRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}

	}

	internal func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willDeselectRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section)) {
			return path
		} else {
			return indexPath
		}
	}

	internal func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if datasource.adStream.isAdAtposition(indexPath) != nil {
		} else {
			delegate.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: NSIndexPath(forRow: self.datasource.adStream.normalize(indexPath), inSection: indexPath.section))
		}
	}

	internal func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
	}

	internal func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
	}
}