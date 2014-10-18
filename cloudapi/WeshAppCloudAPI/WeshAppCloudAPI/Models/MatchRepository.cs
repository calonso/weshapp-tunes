using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using WeshAppRdioClient;

namespace WeshAppCloudAPI.Models
{
    public static class MatchRepository
    {
        private static WeshAppRdioClient.WeshAppRdioClient _rdioClient = new WeshAppRdioClient.WeshAppRdioClient();

        static MatchRepository() 
        {
            Repository = new Dictionary<string, AlbumTrackMatch>();
        }

        public static Dictionary<string, AlbumTrackMatch> Repository;

        public static AlbumTrackMatch handleAlbumMatch(string artistName, string songName)
        {
            string cacheKey = getCacheKey(artistName, songName);
            if (Repository.ContainsKey(cacheKey))
            {
                return MatchRepository.Repository[cacheKey];
            }
            else
            {
                AlbumTrackMatch apiResult = searchForAlbum(artistName, songName);
                if (apiResult != null && !MatchRepository.Repository.ContainsKey(cacheKey))
                {
                    MatchRepository.Repository[cacheKey] = apiResult;
                    return apiResult;
                }
            }

            //TODO - Replace with empty result
            //return new AlbumTrackMatch();
            return getSampleSong();
        }

        private static AlbumTrackMatch searchForAlbum(string artistName, string songName)
        {
            string albumURL = _rdioClient.getAlbumURL(artistName, songName);
            if (!string.IsNullOrEmpty(albumURL))
            {
                string base64Image = getBase64ImageFromURL(albumURL);
                return new AlbumTrackMatch
                {
                    ArtistNameSearch = artistName,
                    TrackNameSearch = songName,
                    AlbumCoverBase64Result = base64Image,
                    AlbumCoverURLResult = albumURL
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

        private static AlbumTrackMatch getSampleSong()
        {
            byte[] test = System.IO.File.ReadAllBytes("c:\\testimage.jpg");
            string base64stringTest = Convert.ToBase64String(test);
            return new AlbumTrackMatch
            {
                ArtistNameSearch = "artist",
                TrackNameSearch = "song",
                AlbumCoverURLResult = "http://somethinghere/albumcover.jpg",
                AlbumCoverBase64Result = base64stringTest//ImageToBase64(i, System.Drawing.Imaging.ImageFormat.Png)
            };
        }
    }
}