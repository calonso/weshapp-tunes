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

      let mediaArray: Array<String> = sng.componentsSeparatedByString("&")
      let songTitle = mediaArray[0]
      
      if let media: Media = mediaDict![songTitle]{
      
        media.appendToOwner(peerID)
        
        if(mediaArray.count>1){
          media.artist = mediaArray[1]
        }
      
        popDict![songTitle] =  popDict![songTitle]! + 1
      }
      else{
        var media = Media(songName: songTitle, owner: peerID)
        if(mediaArray.count>1){
          media.artist = mediaArray[1]
        }
        mediaDict![songTitle] = media
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
      
      println(songTitle)
      println(mediaDict!.count)
      if let m = mediaDict![songTitle]?{
     
       manager!.sendSong( [songTitle], peerID:m.owners![0])
        
      } else {
        println("\(songTitle) not found")
      }
    }
  }
}
