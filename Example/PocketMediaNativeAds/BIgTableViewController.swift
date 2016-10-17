import UIKit
import PocketMediaNativeAds

class BigTableViewController: UITableViewController {
  
    var tableViewDataSource : ExampleTableViewDataSource?
    var stream : NativeAdStream?
  
    override func viewDidLoad() {
      self.title = "TableView"
      
      super.viewDidLoad()
      tableViewDataSource = ExampleTableViewDataSource()
      tableViewDataSource!.loadLocalJSON()
      tableView.dataSource = tableViewDataSource
      
      
    var xib = UINib(nibName: "TestSupplied", bundle: nil)
      
      self.refreshControl?.addTarget(self, action: #selector(TableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
      var adPos = [5, 2, 4, 99]
      
      
      
      stream = NativeAdStream(controller: self, mainView: self.tableView, adMargin: 1, firstAdPosition: 1)
      stream!.requestAds("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
    }
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
      tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 180
  }
   
  
  
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        stream!.clearAdStream("894d2357e086434a383a1c29868a0432958a3165", limit: 10)
        refreshControl.endRefreshing()
    }
    
  
    
}