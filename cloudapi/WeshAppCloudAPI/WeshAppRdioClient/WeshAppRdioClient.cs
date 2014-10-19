using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WeshAppRdioClient
{
    public class WeshAppRdioClient
    {
        private RdioClient _client;

        public WeshAppRdioClient()
        {
            string key = "vz4tpmcw252qkyq2t6pbn8sq";
            string secret = "sMeydTCPDS";
            //Setup API client here
            //Provide API key
            _client = new RdioClient(new OAuth.Consumer(key, secret));
        }

        public bool getAlbumURL(string artistName, string trackName, out string albumImageURL, out string embedURL)
        {
            albumImageURL = string.Empty;
            embedURL = string.Empty;

            Dictionary<string, string> parameters = new Dictionary<string,string>();
            parameters["types"] = string.Format("{0}", "Track");

            try
            {
                //Try specific search first
                string query = string.Format("{0}", "\"" + trackName + "\" " + artistName);
                parameters["query"] = query;
                if(searchAndParseResult(ref albumImageURL, ref embedURL, parameters))
                {
                    return true;
                }

                //General search second
                parameters["query"] = trackName;
                if (searchAndParseResult(ref albumImageURL, ref embedURL, parameters))
                {
                    return true;
                }
            }
            catch 
            {  
                //Oh nooos, eat the exception
            }

            return false;
        }

        private bool searchAndParseResult(ref string albumImageURL, ref string embedURL, Dictionary<string, string> parameters)
        {
            string jsonResult = _client.Call("search", parameters);
            if (!string.IsNullOrEmpty(jsonResult))
            {
                JObject response = JObject.Parse(jsonResult);
                var matchCount = (int)response["result"]["number_results"];
                if (matchCount > 0)
                {
                    var match = response["result"]["results"][0];
                    albumImageURL = (string)match["icon400"];
                    embedURL = (string)match["embedUrl"];
                    return true;
                }
            }
            return false;
        }


    }
}
