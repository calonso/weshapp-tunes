using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WeshAppCloudAPI.Models
{
    public class AlbumTrackMatch
    {
        public string ArtistNameSearch;
        public string TrackNameSearch;
        public string AlbumCoverURLResult;
        public string AlbumCoverBase64Result;
        public string RdioEmbedURL;
        public int RequestCount = 1;
    }
}