import Foundation
import MediaPlayer



class MediaManager {
  
  class func getMedia() -> Array<String> {
    
    let pred = MPMediaPropertyPredicate(value: MPMediaType.Music.toRaw() as AnyObject!, forProperty: MPMediaItemPropertyMediaType as String!, comparisonType: MPMediaPredicateComparison.EqualTo)
    
    var query = MPMediaQuery()
    query.addFilterPredicate(pred)
    //query.groupingType = MPMediaGrouping.Album
    var arrayList = query.items as Array<MPMediaItem>
    
    return arrayList.map{
      (m: MPMediaItem) in
      
    
      let song = m.valueForProperty(MPMediaItemPropertyTitle) as String
   
        if let artist = m.valueForProperty(MPMediaItemPropertyArtist) as String? {
           return "\(song)&\(artist)"
      } else {
        return song
      }
    }
  }
  
  class func getURL(songName: String)->NSURL{
    var songNamePred = MPMediaPropertyPredicate(value: songName,
                                                  forProperty: MPMediaItemPropertyTitle )
    var query = MPMediaQuery()
    query.addFilterPredicate(songNamePred)
    var items: Array<MPMediaItem> = query.items as Array<MPMediaItem>

    return items[0].valueForProperty(MPMediaItemPropertyAssetURL) as NSURL
  }
}
