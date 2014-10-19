using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WeshAppCloudAPI.Models
{
    public class TestData
    {
        //song name, artist name
        public static Dictionary<string, string> Data = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "So Deep", "Kiesza"},
            { "Peanut Butter", "Alison Valentine"},
            { "Ice Cream Truck", "Sundrenched"},
            { "In The Shade", "Adultrock" },
            { "Hold", "Ruddyp & Taquwami" }
        };

        public static void LoadTestData()
        {
            MatchRepository.Repository.Clear();

            //Perform the searches
            foreach (var song in WeshAppCloudAPI.Models.TestData.Data)
            {
                MatchRepository.handleAlbumMatch(song.Value, song.Key);
            }

            Random dice = new Random();
            //Randomize request count
            foreach (var song in MatchRepository.Repository)
            {
                song.Value.RequestCount = dice.Next(1, 100);
            }
        }
    }
}