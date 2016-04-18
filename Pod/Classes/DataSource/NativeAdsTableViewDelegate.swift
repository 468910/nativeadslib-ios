//
//  NativeAdsTableViewDelegate.swift
//  Pods
//
//  Created by Kees Bank on 18/04/16.
//
//

import UIKit

@objc
public class NativeAdsTableViewDelegate : NSObject, UITableViewDelegate {
  
  public var collection : ReferenceArray
  public var controller : UITableViewController
  public var delegate : UITableViewDelegate
  
  required public init(collection : ReferenceArray, controller: UITableViewController, delegate : UITableViewDelegate){
    self.collection = collection
    self.controller = controller
    self.delegate = delegate
  }
  
  
  // Delegate
  @objc
  public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    print("Is this even invoked")
    if let ad = collection.collection[indexPath.row] as? NativeAd{
      print("Opening url: \(ad.clickURL.absoluteString)")
      // This method will take of opening the ad inside of the app, until we have an iTunes url
      ad.openAdUrl(controller)
    } else{
      print("This is the index of the row thats trying to open" + String(indexPath.row))
      delegate.tableView!(tableView, didSelectRowAtIndexPath: indexPath)
    }
  }
  
  @objc
  public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return delegate.tableView!(tableView, heightForHeaderInSection: section)
  }
  
  public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return delegate.tableView!(tableView, heightForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return delegate.tableView!(tableView, viewForHeaderInSection: section)
  }
  
  public func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
  }
  
  @available(iOS 9.0, *)
  public func tableView(tableView: UITableView, canFocusRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return delegate.tableView!(tableView, canFocusRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, didDeselectRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, didEndDisplayingCell: cell, forRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
    return delegate.tableView!(tableView, didEndDisplayingFooterView: view, forSection: section)
  }
  
  public func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, didEndEditingRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
    return delegate.tableView!(tableView, didEndDisplayingHeaderView: view, forSection: section)
  }
  
  
  public func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return delegate.tableView!(tableView, canPerformAction: action, forRowAtIndexPath: indexPath, withSender: sender)
  }
  
  public func tableView(tableView: UITableView, didHighlightRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, didHighlightRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, didUnhighlightRowAtIndexPath: indexPath)
  }
  
  @available(iOS 9, *)
  public func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    return delegate.tableView!(tableView, didUpdateFocusInContext: context, withAnimationCoordinator: coordinator)
  }
  
  public func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
    return delegate.tableView!(tableView, editActionsForRowAtIndexPath : indexPath)
  }
  
  public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return delegate.tableView!(tableView, editingStyleForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    return delegate.tableView!(tableView, estimatedHeightForFooterInSection: section)
  }
  
  public func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return delegate.tableView!(tableView, estimatedHeightForHeaderInSection: section)
  }
  
  public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return delegate.tableView!(tableView, estimatedHeightForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return delegate.tableView!(tableView, heightForFooterInSection: section)
  }
  
  public func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
    return delegate.tableView!(tableView, indentationLevelForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, performAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    return delegate.tableView!(tableView, performAction: action, forRowAtIndexPath: indexPath, withSender: sender)
  }
  
  public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return delegate.tableView!(tableView, shouldHighlightRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return delegate.tableView!(tableView, shouldIndentWhileEditingRowAtIndexPath: indexPath)
  }
  
  
  public func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return delegate.tableView!(tableView, shouldShowMenuForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    return delegate.tableView!(tableView, willSelectRowAtIndexPath: indexPath)
  }
  
  @available(iOS 9.0, *)
  public func tableView(tableView: UITableView, shouldUpdateFocusInContext context: UITableViewFocusUpdateContext) -> Bool {
    return delegate.tableView!(tableView, shouldUpdateFocusInContext: context)
  }
  
  public func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
    return delegate.tableView!(tableView, targetIndexPathForMoveFromRowAtIndexPath: sourceIndexPath, toProposedIndexPath: proposedDestinationIndexPath)
  }
  
  public func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
    return delegate.tableView!(tableView, titleForDeleteConfirmationButtonForRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return delegate.tableView!(tableView, viewForFooterInSection: section)
  }
  
  public func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, willBeginEditingRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    return delegate.tableView!(tableView, willDeselectRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    return delegate.tableView!(tableView, willDisplayCell : cell, forRowAtIndexPath: indexPath)
  }
  
  public func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    return delegate.tableView!(tableView, willDisplayFooterView: view, forSection : section)
  }
  
  public func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    return delegate.tableView!(tableView, willDisplayHeaderView : view, forSection : section)
  }
  
  
}
