using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using WeshAppRdioClient;

namespace WeshAppCloudAPI.Models
{
    //Repository for album track matches
    public static class MatchRepository
    {
        private static WeshAppRdioClient.WeshAppRdioClient _rdioClient = new WeshAppRdioClient.WeshAppRdioClient();

        static MatchRepository() 
        {
            Repository = new Dictionary<string, AlbumTrackMatch>(StringComparer.OrdinalIgnoreCase);
        }

        public static Dictionary<string, AlbumTrackMatch> Repository;

        //Main entry-point
        //Input: search by artist name (ex: blur) and song name (ex: coffee and tv)
        public static AlbumTrackMatch handleAlbumMatch(string artistName, string songName)
        {
            string cacheKey = getCacheKey(artistName, songName);
            if (Repository.ContainsKey(cacheKey))
            {
                var match = MatchRepository.Repository[cacheKey];
                match.RequestCount++;
                return match;
            }
            else
            {
                var apiResult = albumSearchHandler(artistName, songName);
                if (apiResult != null && !MatchRepository.Repository.ContainsKey(cacheKey))
                {
                    MatchRepository.Repository[cacheKey] = apiResult;
                    return apiResult;
                }
            }

            return new AlbumTrackMatch();
        }

        private static AlbumTrackMatch albumSearchHandler(string artistName, string songName)
        {
            string embedURL;
            string albumImageURL;
            
            if (_rdioClient.getAlbumURL(artistName, songName, out albumImageURL, out embedURL))
            {
                string base64Image = getBase64ImageFromURL(albumImageURL);
                return new AlbumTrackMatch
                {
                    ArtistNameSearch = artistName,
                    TrackNameSearch = songName,
                    AlbumCoverBase64Result = base64Image,
                    AlbumCoverURLResult = albumImageURL,
                    RdioEmbedURL = embedURL
                };
            }
            else
            {
                return null;
            }
        }

        private static string getBase64ImageFromURL(string albumURL)
        {
            string base64ImageString = string.Empty;

            try
            {
                byte[] imageData;
                using (WebClient client = new WebClient())
                {
                    imageData = client.DownloadData(albumURL);
                }
                base64ImageString = Convert.ToBase64String(imageData);
            }
            catch
            {
                //Eat the exception
            }

            return base64ImageString;
        }

        private static string getCacheKey(string artistName, string songName)
        {
            return string.Format("{0}|{1}", artistName, songName);
        }

        public static IOrderedEnumerable<AlbumTrackMatch> GetTopTenTracks()
        {
            IOrderedEnumerable<AlbumTrackMatch> results = null;

            if (MatchRepository.Repository.Count > 0)
            {
                results = MatchRepository.Repository
                    .OrderByDescending(match => match.Value.RequestCount)
                    .OrderBy(match => match.Value.TrackNameSearch)
                    .Take(10)
                    .Select(match => match.Value)
                    .OrderByDescending(match => match.RequestCount);
            }

            return results;
        }

        public static IOrderedEnumerable<AlbumTrackMatch> GetTopTenArtists()
        {
            IOrderedEnumerable<AlbumTrackMatch> results = null;

            if (MatchRepository.Repository.Count > 0)
            {
                results = MatchRepository.Repository
                    .GroupBy(match => match.Value.ArtistNameSearch)
                    .Select(gmatch => new AlbumTrackMatch
                    {
                        ArtistNameSearch = gmatch.First().Value.ArtistNameSearch,
                        RequestCount = gmatch.Sum(rc => rc.Value.RequestCount),
                        AlbumCoverURLResult = gmatch.First().Value.AlbumCoverURLResult
                    })
                    .OrderByDescending(m => m.RequestCount);
            }

            return results;
        }
    }
}