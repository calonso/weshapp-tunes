import Foundation
import MultipeerConnectivity

class Media {
  
 let songName: String?
 //let albumArtwork: ImageURL?
 let artist: String?
 var owners: [MCPeerID]?;



  init(songName:String){
    self.songName = songName
    
  }

 init(songName:String, owner: MCPeerID){
    
  
  }
  
  func appendToOwner(owner: MCPeerID){
    
    owners!.append(owner)
  
  }
  
  func getPopularity()->Int{
    return owners!.count
  }
  
  
  /*
  func getArtist(){
     Artist=
  }
  
  func albumArtwork(){
     albumArtwork=
  }
  */
}