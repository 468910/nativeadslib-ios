//
//  NativeAdTableViewDatasource.swift
//  PocketMediaNativeAds
//
//  Created by Kees Bank on 20/09/16.
//
//

import XCTest
import UIKit
@testable import PocketMediaNativeAds

class baseMockedNativeAdDataSource: NativeAdTableViewDataSource {
    var returngetNativeAdListing: Bool = false
    var getNativeAdListingCalled: Bool = false
    var isGetAdCellForTableViewCalled: Bool = false
    var ad: NativeAd?
    
    override func getNativeAdListing(_ indexPath: NSIndexPath) -> NativeAd? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
            return ad
        }
        return nil
    }
    
    override func getAdCell(_ nativeAd: NativeAd) -> NativeAdCell {
        isGetAdCellForTableViewCalled = true
        return NativeAdCell()
    }
    
    func setupAd() {
        let data = testHelpers.getNativeAdData()!
        self.ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")
        
    }
}

class nonImplementedDatasource: NSObject, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}

class baseMockedDelegate: NSObject, UITableViewDelegate {
    
}

open class NativeAdTableViewDatasourceTest: XCTestCase {
    
    var subject: baseMockedNativeAdDataSource!
    var originalDataSource: UITableViewDataSource!
    var tableView: UITableView!
    var controller: UIViewController!
    
    override open func setUp() {
        super.setUp()
    }
    
    func setUpDataSource(_ mockedDatasource: UITableViewDataSource) {
        controller = UIViewController()
        tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
        controller.view = tableView
        
        tableView.delegate = baseMockedDelegate()
        
        originalDataSource = mockedDatasource
        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }

        tableView.dataSource = originalDataSource
        subject = baseMockedNativeAdDataSource(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))
        
    }
    
    func testcellForRowAtIndexPath() {
        class mockedDatasource: ExampleTableViewDataSource {
            open var calledCellForRowAtIndexPath: Bool = false
            @objc override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                calledCellForRowAtIndexPath = true
                return UITableViewCell()
            }
        }
        
        setUpDataSource(mockedDatasource())
        let view = UITableView()
        
        // Test If Original IndexPathForRowAtIndexPath gets called
        subject.returngetNativeAdListing = false
        let indexPath = IndexPath(item: 0, section: 0)
        subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        let result = (originalDataSource as! mockedDatasource).calledCellForRowAtIndexPath
        XCTAssert(result == true, "cellForRowAtIndexPath has been called in the original DataSource")
        
        // Test if NativeAdCell gets returned
        subject.returngetNativeAdListing = true
        subject.setupAd()
        subject.tableView(tableView, cellForRowAtIndexPath: indexPath)
        XCTAssert(subject.isGetAdCellForTableViewCalled == true, "isGetAdCellForTableViewHasBeenCalled")
        
    }
    
    func testTitleForHeaderInSection() {
        class mockedDataSource: ExampleTableViewDataSource {
            open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }
        
        setUpDataSource(mockedDataSource())
        
        var result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")
        
        setUpDataSource(nonImplementedDatasource())
        
        result = subject.tableView(tableView, titleForHeaderInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")
        
    }
    
    func testTitleForFooterInSection() {
        class mockedDataSource: ExampleTableViewDataSource {
            open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
                return "This is an amazing Title"
            }
        }
        
        setUpDataSource(mockedDataSource())
        
        var result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == "This is an amazing Title", "Called original TitleForHeaderInSection")
        
        setUpDataSource(nonImplementedDatasource())
        
        result = subject.tableView(tableView, titleForFooterInSection: 0)
        XCTAssert(result == nil, "There is no title for the NativeAdDataSource")
        
    }
    
    func testCommitEditingStyle() {
        class mockedDataSource: ExampleTableViewDataSource {
            var commitEditingStyleHasBeenCalled : Bool = false
            open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
                commitEditingStyleHasBeenCalled = true
            }
        }
        /*
         setUpDataSource(mockedDataSource())
         subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Insert, forRowAtIndexPath: NSIndexPath(forItem: 1, inSection: 1))
         XCTAssert((originalDataSource as! mockedDataSource!).commitEditingStyleHasBeenCalled == true, "Called original commitEditingStyle")
         */
        
        setUpDataSource(nonImplementedDatasource())
      if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:commit:forRowAt:)))) {
            XCTFail("tableView:commitEditingStyle shouldnt be implemented")
        }
        
        
    }

    func testmoveRowAtIndexPath() {
        class mockedDataSource: ExampleTableViewDataSource {
          var moveRowAtIndexPathHasBeenCalled = false
          open func tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
            moveRowAtIndexPathHasBeenCalled = true
          }
        }
      
        setUpDataSource(mockedDataSource())
        subject.tableView(tableView, moveRowAtIndexPath: IndexPath(), toIndexPath: IndexPath())
        XCTAssert((originalDataSource as! mockedDataSource).moveRowAtIndexPathHasBeenCalled == true, "MoveRowAtIndexPathHasBeenCalled")
      
      setUpDataSource(nonImplementedDatasource())
      if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:moveRowAt:to:)))) {
        XCTFail("tableView:commitEditingStyle shouldnt be implemented")
      }
    }

    func testsectionForSectionIndexTitle(){
      
        class mockedDataSource: ExampleTableViewDataSource {
           var sectionForSectionIndexTitleHasBeenCalled = false
          open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
            sectionForSectionIndexTitleHasBeenCalled = true
            return 0
          }
        }
          
          setUpDataSource(mockedDataSource())
          subject.tableView(tableView, sectionForSectionIndexTitle: "yay", atIndex: 0)
          XCTAssert((originalDataSource as! mockedDataSource).sectionForSectionIndexTitleHasBeenCalled == true, "Section for Section Index title has been called!")
      
      setUpDataSource(nonImplementedDatasource())
      if (originalDataSource.responds(to: #selector(UITableViewDataSource.sectionIndexTitles(`for`:)))) {
        XCTFail("tableView:commitEditingStyle shouldnt be implemented")
      }
      
      var result = subject.tableView(tableView, sectionForSectionIndexTitle: "yay", atIndex: 1)
      XCTAssert(result == 0, "Section for section index title has been called")
      
    }
  
    func testcanEditRowAtIndexPath() {
      class mockedDataSource : ExampleTableViewDataSource {
        var canEditRowAtIndexPathHasBeenCalled = false
       open func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        canEditRowAtIndexPathHasBeenCalled = true
        return true
      }
      }
      
      
      
      
      setUpDataSource(mockedDataSource())
      subject.tableView(tableView, canEditRowAtIndexPath: IndexPath(forItem: 1, inSection: 0))
       XCTAssert((originalDataSource as! mockedDataSource).canEditRowAtIndexPathHasBeenCalled == true, "CanEditRowAtIndexPath has been called!")
      
      setUpDataSource(nonImplementedDatasource())
      if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canEditRowAt:)))) {
        XCTFail("tableView:commitEditingStyle shouldnt be implemented")
      }
      var result = subject.tableView(tableView, canEditRowAtIndexPath: IndexPath())
      XCTAssert(result == true, "Can Edit Row At IndexPath returns default value which is TRUE")

      
    }
    func testcanMoveAtIndexPath() {
      class mockedDataSource : ExampleTableViewDataSource {
      var canMoveRowAtIndexPathHasBeenCalled = false
       open func tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        canMoveRowAtIndexPathHasBeenCalled = true
        return true
        }
      }
      
      setUpDataSource(mockedDataSource())
      subject.tableView(tableView, canMoveRowAtIndexPath: IndexPath())
      XCTAssert((originalDataSource as! mockedDataSource).canMoveRowAtIndexPathHasBeenCalled == true, "canMoveRowAtIndexPathHasBeenCalled has been called!")
      
      setUpDataSource(nonImplementedDatasource())
      if (originalDataSource.responds(to: #selector(UITableViewDataSource.tableView(_:canMoveRowAt:)))) {
        XCTFail("tableView:commitEditingStyle shouldnt be implemented")
      }
      
      var result = subject.tableView(tableView, canMoveRowAtIndexPath: IndexPath())
      XCTAssert(result == true, "Can Move Row At Index Path returns default value which is True")

      
    }
  
  
  func testcommitEditingStyle() {
    class mockedDataSource : ExampleTableViewDataSource {
      var commitEditingStyleHasBeenCommited = false
     open func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath) {
         commitEditingStyleHasBeenCommited = true
      }
    }
    
    setUpDataSource(mockedDataSource())
    subject.tableView(tableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: IndexPath())
    XCTAssert((originalDataSource as! mockedDataSource).commitEditingStyleHasBeenCommited == true, "CommitEditingStyle has been called!")
    

    
  }
  
  func testGetAdCellForTableView(){
    class xMocked: NativeAdTableViewDataSource {
      var returngetNativeAdListing: Bool = false
      var getNativeAdListingCalled: Bool = false
      var isGetAdCellForTableViewCalled: Bool = false
      var ad: NativeAd?
      
      override func getNativeAdListing(_ indexPath: NSIndexPath) -> NativeAd? {
        getNativeAdListingCalled = true
        if returngetNativeAdListing {
          return ad
        }
        return nil
      }
      
      func setupAd() {
        let data = testHelpers.getNativeAdData()!
        self.ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")
        
      }
    }
      controller = UIViewController()
      tableView = UITableView(frame: CGRect(), style: UITableViewStyle.plain)
      controller.view = tableView
      
      tableView.delegate = baseMockedDelegate()
      
      originalDataSource = nonImplementedDatasource()
    
        if let ExampleOriginalDataSource = originalDataSource as? ExampleTableViewDataSource {
            ExampleOriginalDataSource.loadLocalJSON()
        }
      tableView.dataSource = originalDataSource
      
      let localsubject = xMocked(controller: controller, tableView: tableView, adPosition: MarginAdPosition(margin: 2))
    
        let data = testHelpers.getNativeAdData()!
        let ad = try! NativeAd(adDictionary: data, adPlacementToken: "test")

        let result = localsubject.getAdCell(ad)
        XCTAssert(result is NativeAdCell, "Succesfully return NativeAdCell")
    
  }
  

  
  
  
}
