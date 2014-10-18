﻿using Newtonsoft.Json.Linq;
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

        public string getAlbumURL(string artistName, string trackName)
        {
            string albumURL = string.Empty;

            Dictionary<string, string> parameters = new Dictionary<string,string>();
            parameters["query"] = string.Format("{0}", trackName);
            parameters["types"] = string.Format("{0}", "Track");

            try
            {

                string jsonResult = _client.Call("search", parameters);
                if(!string.IsNullOrEmpty(jsonResult))
                {
                    JObject response = JObject.Parse(jsonResult);
                    var match = response["result"]["results"][0];
                    albumURL = (string)match["icon400"];
                }
            }
            catch 
            {  
                //Oh nooos, eat the exception
            }

            return albumURL;
        }
    }
}
