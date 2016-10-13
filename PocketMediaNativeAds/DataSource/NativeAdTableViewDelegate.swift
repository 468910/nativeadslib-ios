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
  
    internal static let heightForStandardAdUnit : CGFloat = 80

	required public init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
		self.datasource = datasource
		self.controller = controller
		self.delegate = delegate
	}

	// Patching of the delegate. Either replace certain calls to our library or do some checks and call the original implementation of the host
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let val = datasource.getNativeAdListing(indexPath) {
			val.openAdUrl(FullscreenBrowser(parentViewController: controller))
            return
		}
        delegate.tableView?(tableView, didSelectRowAt: IndexPath(row: datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
	}

	@objc
	public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
			return heightForHeader
		}
        return tableView.rowHeight
	}

	public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if datasource.getNativeAdListing(indexPath) != nil {
			return NativeAdTableViewDelegate.heightForStandardAdUnit
		} else if let heightForRow = delegate.tableView?(tableView, heightForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return heightForRow
        }
        /* Instead of returning AutomaticDimension dont bother with esimatedHeight just return the
           tableview rowHeight
        */
        return tableView.rowHeight
        
	}

	public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForHeaderInSection: section)
	}

	public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, accessoryButtonTappedForRowWith: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	// Default Value = TRUE/YES
	@available(iOS 9.0, *)
	public func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let canFocus = delegate.tableView?(tableView, canFocusRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return canFocus
        }
        return true
	}

	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didDeselectRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
	}

	public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
		if datasource.getNativeAdListing(indexPath!) == nil {
			delegate.tableView?(tableView, didEndEditingRowAt: IndexPath(row: self.datasource.normalize(indexPath!), section: (indexPath! as NSIndexPath).section))
		}
	}

	public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingHeaderView: view, forSection: section)
	}

	public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAt: indexPath, withSender: sender) {
            return canPerform
        }
        return true
	}

	public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didHighlightRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, didUnhighlightRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	@available(iOS 9, *)
	public func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		delegate.tableView?(tableView, didUpdateFocusIn: context, with: coordinator)
	}

	public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		if datasource.getNativeAdListing(indexPath) != nil {
			return nil
		} else if let rowAction = delegate.tableView?(tableView, editActionsForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return rowAction
        }
        return nil
	}

	public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if datasource.getNativeAdListing(indexPath) != nil {
			return UITableViewCellEditingStyle.none
        } else if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return editingStyle
		}
        return UITableViewCellEditingStyle.none
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
			return estimatedHeightForFooter
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
			return estimatedHeight
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		if datasource.getNativeAdListing(indexPath) != nil {
			return UITableViewAutomaticDimension
        // not an ad - let the original datasource handle it
		} else if let estimatedHeightForRowAtIndexPath = delegate.tableView?(tableView, estimatedHeightForRowAt: IndexPath(item: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return estimatedHeightForRowAtIndexPath
        }
		return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
			return heightForFooter
		}
        return UITableViewAutomaticDimension
	}

	public func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
		if datasource.getNativeAdListing(indexPath) != nil {
			return -1
		} else if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return indenLevel
        }
        return -1
	}

	public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
		delegate.tableView?(tableView, performAction: action, forRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section), withSender: sender)
	}

	public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
			return shouldHighLight
		}
		return true
	}

	public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return ShouldIndent
        }
        return true
	}

	public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
		if datasource.getNativeAdListing(indexPath) != nil {
			return true
		} else if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
            return shouldShowMenu
        }
        return true
	}

	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		if let path = delegate.tableView?(tableView, willSelectRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
			return path
		}
		return indexPath
	}

	@available(iOS 9.0, *)
	public func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
		if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusIn: context) {
			return shouldUpdateFocusInContext
		}
		return true
	}

	public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAt: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
			return path
		}
        return proposedDestinationIndexPath
	}

	public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
			return title
		}
        return nil
	}

	public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForFooterInSection: section)
	}

	public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) != nil {
		}
        delegate.tableView?(tableView, willBeginEditingRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
	}

	public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
		if let path = delegate.tableView?(tableView, willDeselectRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section)) {
			return path
		}
		return indexPath
	}

	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if datasource.getNativeAdListing(indexPath) == nil {
			delegate.tableView?(tableView, willDisplay: cell, forRowAt: IndexPath(row: self.datasource.normalize(indexPath), section: (indexPath as NSIndexPath).section))
		}
	}

	public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
	}

	public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
	}
}
