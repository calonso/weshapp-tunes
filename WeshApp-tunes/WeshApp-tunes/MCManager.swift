import Foundation
import MultipeerConnectivity

class MCManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
  
  
  
  var peerID: MCPeerID?
  var session: MCSession?
  var browser: MCNearbyServiceBrowser?
  var advertiser:  MCNearbyServiceAdvertiser?
  var hasPeers: Bool?
  var delegate:SongTVC?
  
  
  init(displayName: String){
    
    super.init()
    
    peerID = MCPeerID(displayName: displayName)
    self.startSession(peerID!)
    
    
  }
  
  /*
  *Send Media List
  */
  func sendMediaList(sngList: NSArray){
  
    //println("sending \(sngList)")
    var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(sngList)
    var error : NSError?
    var success = self.session?.sendData(data,
                                      toPeers: self.session?.connectedPeers,
                                     withMode: MCSessionSendDataMode.Unreliable,
                                        error: &error)
    
    
    if error != nil {
      print("Error sending data: \(error?.localizedDescription)")
    }
  }
  
 /*
  * Send a Selected Song name to Peer
  */
  func sendSong(sng: Array<String>, peerID: MCPeerID){
  
    println("Message is \(sng) and  \(peerID.displayName)")
    var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(sng)
    var error : NSError?
    var success = self.session?.sendData(data,
                                        toPeers: [peerID],
                                       withMode: MCSessionSendDataMode.Unreliable,
                                          error: &error)
    if error != nil {
      print("Error sending data: \(error?.localizedDescription)")
    }
  }
  
  func connected(p: MCPeerID)->Bool{
    var peerNames = session!.connectedPeers.filter({peer in peer.displayName == p.displayName})
    return peerNames.count > 1
  }
   ////////////// SESSION ///////////////////////
  private func startSession(peerID: MCPeerID){
    session = MCSession(peer: peerID)
    session?.delegate = self
  }
  
  
  
  
  func session(  session: MCSession!,
    peer peerID: MCPeerID!,
    didChangeState state: MCSessionState) {
      
      switch state {
        case MCSessionState.NotConnected:
           self.hasPeers = false
        
        case MCSessionState.Connecting:
            println("\(self.peerID!.displayName) connecting to \(peerID.displayName)")
        
        case MCSessionState.Connected:
        
          browser!.stopBrowsingForPeers()
          println("\(self.peerID!.displayName) is connected to \(peerID.displayName)")
          self.hasPeers = true
          
          self.sendMediaList(MediaManager.getMedia())
 
          var mainQueue = NSOperationQueue.mainQueue()
          mainQueue.addOperationWithBlock() { 
          
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.postNotificationName( "connection", object: nil)

          }
      }

     
      
      
  }
  
  func session(     session: MCSession!,
        didReceiveData data: NSData!,
            fromPeer peerID: MCPeerID!) {
              println("data size \(data.length)")
          var msg: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data)!
          
       
              println( "Array received")

              var songList: Array<String> = msg as Array<String>
              
              
           if(songList.count > 1){
              var mainQueue = NSOperationQueue.mainQueue()
              mainQueue.addOperationWithBlock() {
              self.delegate!.updateMediaDictionary(songList, peerID: peerID)
                }
            }else{
            
              println(MediaManager.getURL( songList[0]) )
            }
            
          
          
                            //println("Data received \(songList)")
          
           
           
    
    /*
    
      var dict: Dictionary = [ "data": data, "peerID": peerID ]
    
    var mainQueue = NSOperationQueue.mainQueue()
    mainQueue.addOperationWithBlock() {
      let notificationCenter = NSNotificationCenter.defaultCenter()
      
      notificationCenter.postNotificationName( "MCDidReceiveDataNotification", object: nil, userInfo: dict)
      }
  */
  }

  func session(                          session: MCSession!,
    didStartReceivingResourceWithName resourceName: String!,
    fromPeer peerID: MCPeerID!,
    withProgress progress: NSProgress!) {
      
  }
  
  func session(                           session: MCSession!,
    didFinishReceivingResourceWithName resourceName: String!,
    fromPeer peerID: MCPeerID!,
    atURL localURL: NSURL!,
    withError error: NSError!) {
      
  }
  
  func session(     session: MCSession!,
    didReceiveStream stream: NSInputStream!,
    withName streamName: String!,
    fromPeer peerID: MCPeerID!) {
      
  }
  
  
  
  
  
  
  
  /////////////////// AVERTISE ////////////////////////////
  func startAdvertising(shouldAdvertise: Bool, serviceType: String = "music"){
    if(shouldAdvertise){
      advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
      advertiser?.startAdvertisingPeer()
      //println("\(peerID!.displayName) advertising started")
    }
    else{
      advertiser?.stopAdvertisingPeer()
    }
    advertiser?.delegate = self
  }
  
  func advertiser(           advertiser: MCNearbyServiceAdvertiser!,
    didReceiveInvitationFromPeer peerID: MCPeerID!,
    withContext context: NSData!,
    invitationHandler: ((Bool, MCSession!) -> Void)!){
      
      //println("received invitation from:\(peerID!.displayName) ")
      invitationHandler(true, session)
      
      
  }
  
  
  
  
  
  
  /////////////////// BROWSE ////////////////////////////
  
  func startBrowsing(){
    
    var  serviceType: String = "music"
    browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
    browser?.delegate = self
    browser?.startBrowsingForPeers()
    //println("\(peerID!.displayName) is browsing")
    
  }
  
  
  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!,  withDiscoveryInfo info: [NSObject : AnyObject]!){
    
    
    if(!connected(peerID)){
      
      //Add discovred peer to a session
      browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: -1)
      
      //println("peer \(peerID!.displayName) invited to a session.")
    }
    else{
      println("peer  \(peerID!.displayName) is already connected")
      
    }
  }
  
  func browser( browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
    println("peer \(peerID?.displayName) lost")
    
  }
  
  
}