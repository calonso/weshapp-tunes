import Foundation
import MediaPlayer



class MediaManager{
  
  
  
  class func getMedia() -> Array<String> {
    
    var query = MPMediaQuery()
    //query.groupingType = MPMediaGrouping.Album
    var arrayList = query.items as Array<MPMediaItem>
    
    return arrayList.map{
      (m: MPMediaItem) in
      
    
      let song = m.valueForProperty(MPMediaItemPropertyTitle) as String
   
        if let artist = m.valueForKeyPath(MPMediaItemPropertyArtist) as String? {
           return "\(song)&\(artist)"
      }
      else{
          
          return song
      }
      
    }

    
  }
  
  
  
  
  
}

/*
return arrayList.map{
(m:MPMediaItem)-> (String, String) in

let song = m.valueForProperty(MPMediaItemPropertyTitle) as String
let artist = m.valueForKeyPath(MPMediaItemPropertyArtist) as String
return (song,artist)
}

*/