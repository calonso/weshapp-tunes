import UIKit
import  MultipeerConnectivity

class SongTVC: UITableViewController {
  
  var streamer : SongInputStreamer?

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
      println(sng)
      let mediaArray: Array<String> = sng.componentsSeparatedByString("&")
      let songTitle = mediaArray[0]
      
      
      if let media: Media = mediaDict![songTitle]{
      
        media.appendToOwner(peerID)
        if(mediaArray.count>1){
          media.artist = mediaArray[1]
       
        }
      
      popDict![songTitle] =  popDict![sng]! + 1
      }else{
        
        
       var media = Media(songName: songTitle, owner: peerID)
        if(mediaArray.count>1){
          media.artist = mediaArray[1]
        
        }
       popDict![songTitle] =  1
      }
    
   }
    var mainQueue = NSOperationQueue.mainQueue()
    mainQueue.addOperationWithBlock() {
      self.tableView.reloadData()

    }
    
    let keyArray: [String] = Array(mediaDict!.keys)
    let sortedArray = sortByPopularity(popDict!)
    topTen = Array(sortedArray[0...9])
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
     
        let songTitle = topTen![index!.row]
        vc.songTitle = songTitle
      
        if let m = mediaDict![songTitle]?{
         // println(m.artist)
          
    }else{
        //println("\(songTitle) not found")
    }
        
          //manager!.sendSong( [songTitle], peerID:m!.owners![0])
    
      
      
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
