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

	required public init(datasource: NativeAdTableViewDataSource, controller: UIViewController, delegate: UITableViewDelegate) {
		self.datasource = datasource
		self.controller = controller
		self.delegate = delegate

		NSLog("Screen width: \(UIScreen.mainScreen().bounds.size.width) ")

	}

	// Delegate
	@objc
	public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let val = datasource.adStream.isAdAtposition(indexPath.row) {
			val.openAdUrl(controller)
		} else {
			return delegate.tableView!(tableView, didSelectRowAtIndexPath: indexPath);
		}
	}

	@objc
	public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if let heightForHeader = delegate.tableView?(tableView, heightForHeaderInSection: section) {
			return heightForHeader
		} else {
			return -1
		}
	}

	public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

		if let isAd = datasource.adStream.isAdAtposition(indexPath.row) {

			// return 10000;
			// it is an ad, let's handle it

			if (datasource.adStream.adUnitType == .Standard) {
				let cell: NativeAdCell = tableView.dequeueReusableCellWithIdentifier("NativeAdTableViewCell") as! NativeAdCell
				cell.configureAdView(isAd)

				NSLog("Returning NativeAd height: \(cell.frame.height)")

				return cell.frame.height;
			} else {

				let cell: AbstractBigAdUnitTableViewCell = tableView.dequeueReusableCellWithIdentifier("BigNativeAdTableViewCell") as! AbstractBigAdUnitTableViewCell
				cell.configureAdView(isAd)

				NSLog("Image intrisic size: \(cell.adImage?.intrinsicContentSize().width) x \(cell.adImage?.intrinsicContentSize().height)")

				NSLog("Returning BigNative height: \(cell.requiredHeight())")

				return cell.requiredHeight()
			}

		} else {

			// not an ad - let the original datasource handle it

			if let heightForRow = delegate.tableView?(tableView, heightForRowAtIndexPath: indexPath) {
				return heightForRow
			} else {
				return UITableViewAutomaticDimension
			}
		}

	}

	public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return delegate.tableView!(tableView, viewForHeaderInSection: section)
	}

	public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
	}

	@available(iOS 9.0, *)
	public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let canFocus = delegate.tableView?(tableView, canFocusRowAtIndexPath: indexPath) {
			return canFocus
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, didDeselectRowAtIndexPath: indexPath)

	}

	public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
	}

	public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, didEndDisplayingFooterView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
		return delegate.tableView!(tableView, didEndEditingRowAtIndexPath: indexPath)
	}

	public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
		return delegate.tableView!(tableView, didEndDisplayingHeaderView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
		if let canPerform = delegate.tableView?(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender) {
			return canPerform
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, didHighlightRowAtIndexPath: indexPath)
	}

	public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, didUnhighlightRowAtIndexPath: indexPath)
	}

	@available(iOS 9, *)
	public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		delegate.tableView?(tableView, didUpdateFocusInContext: context, withAnimationCoordinator: coordinator)
	}

	public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		if let rowAction = delegate.tableView?(tableView, editActionsForRowAtIndexPath: indexPath) {
			return rowAction
		} else {
			return nil
		}
	}

	public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
		if let editingStyle = delegate.tableView?(tableView, editingStyleForRowAtIndexPath: indexPath) {
			return editingStyle
		} else {
			return UITableViewCellEditingStyle.None
		}
	}

	public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
		if let estimatedHeightForFooter = delegate.tableView?(tableView, estimatedHeightForFooterInSection: section) {
			return estimatedHeightForFooter
		} else {
			return -1
		}
	}

	public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
		if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForHeaderInSection: section) {
			return estimatedHeight
		} else {
			return -1
		}
	}

	public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
		/*if let estimatedHeight = delegate.tableView?(tableView, estimatedHeightForRowAtIndexPath: indexPath) {
		 return estimatedHeight
		 } else {
		 return -1
		 }*/
	}

	public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if let heightForFooter = delegate.tableView?(tableView, heightForFooterInSection: section) {
			return heightForFooter
		} else {
			return -1
		}
	}

	public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
		if let indenLevel = delegate.tableView?(tableView, indentationLevelForRowAtIndexPath: indexPath) {
			return indenLevel
		} else {
			return -1
		}
	}

	public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
		delegate.tableView?(tableView, performAction: action, forRowAtIndexPath: indexPath, withSender: sender)
	}

	public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let shouldHighLight = delegate.tableView?(tableView, shouldHighlightRowAtIndexPath: indexPath) {
			return shouldHighLight
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let ShouldIndent = delegate.tableView?(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath) {
			return ShouldIndent
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		if let shouldShowMenu = delegate.tableView?(tableView, shouldShowMenuForRowAtIndexPath: indexPath) {
			return shouldShowMenu
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willSelectRowAtIndexPath: indexPath) {
			return path
		} else {
			return indexPath
		}
	}
	@available(iOS 9.0, *)
	public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
		if let shouldUpdateFocusInContext = delegate.tableView?(tableView, shouldUpdateFocusInContext: context) {
			return shouldUpdateFocusInContext
		} else {
			return true
		}
	}

	public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
		if let path = delegate.tableView?(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath) {
			return path
		} else {
			return proposedDestinationIndexPath
		}
	}

	public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
		if let title = delegate.tableView?(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath) {
			return title
		} else {
			return nil
		}
	}

	public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return delegate.tableView?(tableView, viewForFooterInSection: section)
	}

	public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, willBeginEditingRowAtIndexPath: indexPath)

	}

	public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		if let path = delegate.tableView?(tableView, willDeselectRowAtIndexPath: indexPath) {
			return path
		} else {
			return indexPath
		}
	}

	public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		delegate.tableView?(tableView, willDisplayCell: cell, forRowAtIndexPath: indexPath)
	}

	public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayFooterView: view, forSection: section)
	}

	public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		delegate.tableView?(tableView, willDisplayHeaderView: view, forSection: section)
	}

}
