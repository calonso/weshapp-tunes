using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;

namespace WeshAppCloudAPI.Models
{
    public class YammerClient
    {
        public static void NotifyFeed(AlbumTrackMatch match, string usertoken)
        {
            string messagebody = string.Format("body=I'm listening to {1} by {0} using WeshApp Tunes&og_image={2}&og_url={3}&og_title={0} - {1}", 
                match.ArtistNameSearch, 
                match.TrackNameSearch, 
                match.AlbumCoverURLResult, 
                match.RdioEmbedURL);
            
            //Example: body=I'm listening to Coffee and TV by Blur using WeshApp&og_image=http://img00.cdn2-rdio.com/album/7/e/2/000000000002b2e7/3/square-200.jpg&og_url=https://rd.io/e/QitiMo8/&og_title=Blur - Coffee and TV
            PostData(messagebody, usertoken);
        }

        private static void PostData(string messageBody, string userToken)
        {
            using(WebClient client = new WebClient())
            {
                client.Headers.Add(string.Format("Authorization: Bearer {0}", userToken));
                string result = client.UploadString("https://www.yammer.com/api/v1/messages.json", messageBody);
            }
        }
    }
}