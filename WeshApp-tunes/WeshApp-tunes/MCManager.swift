import Foundation
import MultipeerConnectivity

class MCManager: NSObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
  
  
  
  var peerID: MCPeerID?
  var session: MCSession?
  var browser: MCNearbyServiceBrowser?
  var advertiser:  MCNearbyServiceAdvertiser?
  var hasPeers: Bool?
  
  
  
  init(displayName: String){
    
    super.init()
    
    peerID = MCPeerID(displayName: displayName)
    self.startSession(peerID!)
    
    
  }
  
  /*
  *Send Media List
  */
  func sendMediaList(sngList: [String]){
    
    
    //var msg = msg.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    //println(msg.count)
    
    var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(sngList)
    
    
    
    println("Sending NSData of size \(data.length)")
    
    
    
    
    
    //var msg: AnyObject = NSKeyedUnarchiver.unarchiveObjectWithData(data)!
    
    //var array: Array<MPMediaItem> = msg as Array
    //var array: [String] = msg as [String]
    //println(array[0])
    
    var error : NSError?
    var success = self.session?.sendData(data,
      toPeers: self.session?.connectedPeers,
      withMode: MCSessionSendDataMode.Reliable,
      error: &error)
    
    println(success!)
    
    if error != nil {
      print("Error sending data: \(error?.localizedDescription)")
    }
  }
  /*
   * Send a Selected Song name to Peer
   */
  func sendSong(sng: String, peerID: MCPeerID){
    var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(sng)
    var error : NSError?
    var success = self.session?.sendData(data,
                                        toPeers: [peerID],
                                       withMode: MCSessionSendDataMode.Reliable,
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
      
      if(state.toRaw() == 2){
        browser?.stopBrowsingForPeers()
        println("\(peerID.displayName) is \(state)")
        self.hasPeers = true
        
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.postNotificationName( "MCDidReceiveConnectionNotification", object: nil)
        
        
      }else if(state.toRaw() == 0){
        
        self.hasPeers = false
        
      }
      
      
      
  }
  
  func session(     session: MCSession!,
    didReceiveData data: NSData!,
    fromPeer peerID: MCPeerID!) {
      
      
      var dict: Dictionary = [ "data": data, "peerID": peerID ]
      let notificationCenter = NSNotificationCenter.defaultCenter()
      notificationCenter.postNotificationName( "MCDidReceiveDataNotification", object: nil, userInfo: dict)
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
      println("\(peerID!.displayName) advertising started")
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
      
      println("received invitation from:\(peerID!.displayName) ")
      invitationHandler(true, session)
      
      
  }
  
  
  
  
  
  
  /////////////////// BROWSE ////////////////////////////
  
  func startBrowsing(){
    
    var  serviceType: String = "music"
    browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
    browser?.delegate = self
    browser?.startBrowsingForPeers()
    println("\(peerID!.displayName) is browsing")
    
  }
  
  
  func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!,  withDiscoveryInfo info: [NSObject : AnyObject]!){
    
    
    if(!connected(peerID)){
      
      //Add discovred peer to a session
      browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: -1)
      
      println("peer \(peerID!.displayName) invited to a session.")
    }
    else{
      println("peer  \(peerID!.displayName) is already connected")
      
    }
  }
  
  func browser( browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!){
    println("peer \(peerID?.displayName) lost")
    
  }
  
  
}