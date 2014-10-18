import UIKit
import  MultipeerConnectivity

class SongTVC: UITableViewController {

    var manager: MCManager?
    var mediaDict: Dictionary <String, Media>?
    var popDict: Dictionary<String, Int>?
    var topTen: Array<String>?
  
    override func viewDidLoad() {
      super.viewDidLoad()
      mediaDict = Dictionary()
      topTen = []
      popDict = Dictionary()
      manager = MCManager(displayName: UIDevice.currentDevice().name)
      manager!.delegate = self
      manager?.startAdvertising(true)
      manager?.startBrowsing()
    
    }
  
  func updateMediaDictionary(SongList: [String], peerID: MCPeerID){
    for sng in SongList{
      
      if let media: Media = mediaDict![sng]{
        media.appendToOwner(peerID)
      }else{
       mediaDict![sng] = Media(songName: sng, owner: peerID)
      }
      popDict![sng] = mediaDict![sng]!.getPopularity()
   }
    println(mediaDict!.count)
    var mainQueue = NSOperationQueue.mainQueue()
    mainQueue.addOperationWithBlock() {
      self.tableView.reloadData()
    }
    
    let keyArray: [String] = Array(mediaDict!.keys)
    let media = mediaDict![keyArray[0]]
    let sortedArray = sortByPopularity(popDict!)
    //topTen = Array(sortedArray[0...(sortedArray.count-1)*0.1])
    topTen = Array(sortedArray[0...9]).map{
      (m: String) in
       m.componentsSeparatedByString("&")[0]
      }
    }
  
  

  
  
  func sortByPopularity(dict: Dictionary<String, Int>)->Array<String>{
   var myArr = Array(dict.keys)
    var sortedKeys: () = sort(&myArr) {
      var obj1 = dict[$0] // get ob associated w/ key 1
      var obj2 = dict[$1] // get ob associated w/ key 2
      return obj1 > obj2
    }
    return myArr
    
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return topTen!.count
    }

  
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel!.text = topTen![indexPath.row]
        return cell
    }
  
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    let index = tableView.indexPathForSelectedRow()
   if segue.identifier == "toPlay" {
     let vc = segue.destinationViewController as PlayerViewController
     
      vc.SongTitle.text =   topTen![index!.row]
      //manager!.sendSong(, peerID: <#MCPeerID#>)
      
      
      
    }
  }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

  
    // MARK: - Navigation


  

}
