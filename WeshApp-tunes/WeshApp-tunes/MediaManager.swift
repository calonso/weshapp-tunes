import Foundation
import MediaPlayer



class MediaManager{
  
  
  
  class func getMedia() -> Array<String> {
    
    var query = MPMediaQuery()
    //query.groupingType = MPMediaGrouping.Album
    var arrayList = query.items as Array<MPMediaItem>
    
    return arrayList.map{
      (m:MPMediaItem) in m.valueForProperty(MPMediaItemPropertyTitle) as String
    }

    
  }
  
  
  
  
  
}

