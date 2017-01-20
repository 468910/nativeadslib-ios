//
//  UITableViewDataSourceWrapper.swift
//  PocketMediaNativeAds
//
//  Created by Iain Munro on 20/01/2017.
//  Copyright © 2017 PocketMedia. All rights reserved.
//

import Foundation

/**
 This procol defines what Apple requires us to implement. Based on https://developer.apple.com/reference/uikit/uitableviewdatasource
 This makes sure we don't miss a method. Because all methods should be implemented, even the optional ones.
 */
public protocol UITableViewDataSourceWrapper {
    /**
     Required. Asks the data source for a cell to insert in a particular location of the table view.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    /**
     Asks the data source to return the number of sections in the table view.
     */
    func numberOfSections(in tableView: UITableView) -> Int
    /**
     Required. Tells the data source to return the number of rows in a given section of a table view.
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    /**
     Asks the data source to return the titles for the sections for a table view.
    */
    func sectionIndexTitles(for tableView: UITableView) -> [String]?
    /**
     Asks the data source to return the index of the section having the given title and section title index.
    */
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int
    /**
     Asks the data source for the title of the header of the specified section of the table view.
    */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    /**
    Asks the data source for the title of the footer of the specified section of the table view.
    */
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    /**
     Asks the data source to commit the insertion or deletion of a specified row in the receiver.
    */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    /**
     Asks the data source to verify that the given row is editable.
    */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    /**
     Asks the data source whether a given row can be moved to another location in the table view.
    */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    /**
     Tells the data source to move a row at a specific location in the table view to another location.
    */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}
