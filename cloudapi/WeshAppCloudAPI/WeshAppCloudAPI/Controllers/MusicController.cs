﻿using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Mvc;
using WeshAppCloudAPI.Models;

namespace WeshAppCloudAPI.Controllers
{
    public class MusicController : Controller
    {
        //Allows search by song artist and track name, and returns album cover art using the Intel Mashery Rdio API
        //Each request for an existing match increments the request count
        //Example: /music/GetAlbumFromTrack?artistName=keisza&songName=so+deep
        public ActionResult GetAlbumFromTrack(string artistName, string songName)
        {
            AlbumTrackMatch albumMatch = MatchRepository.handleAlbumMatch(artistName, songName);
            return Json(albumMatch, JsonRequestBehavior.AllowGet);
        }

        public ActionResult NotifyMyYammerFeed(string artistName, string songName, string usertoken)
        {
            YammerClient.NotifyFeed(MatchRepository.handleAlbumMatch(artistName, songName), usertoken);
            return new HttpStatusCodeResult(HttpStatusCode.OK);
        }

        //Load test data into the match repository
        public ActionResult LoadTestData()
        {
            TestData.LoadTestData();

            return Json(MatchRepository.Repository.Count, JsonRequestBehavior.AllowGet);
        }

        //Just like it says on the tin...
        public ActionResult GetTopTenTracks(bool json = false)
        {
            var results = MatchRepository.GetTopTenTracks();

            if (json)
            {
                return Json(results, JsonRequestBehavior.AllowGet);
            }
            else
            {
                string htmlString = 
                    "<html><head><title>Top ten tracks</title></head><body><ul><li>" + 
                    string.Join("</li><li>", results.Select(m => m.ArtistNameSearch + " - " + m.TrackNameSearch + " #" + m.RequestCount + "<br><img src=\""+m.AlbumCoverURLResult+"\"/>")) + 
                    "</li></ul></body></html>";

                return Content(htmlString, "text/html");
            }
        }

        //Just like it says on the tin...
        public ActionResult GetTopTenArtists(bool json = false)
        {
            var results = MatchRepository.GetTopTenArtists();

            if (json)
            {
                return Json(results, JsonRequestBehavior.AllowGet);
            }
            else
            {
                string htmlString = 
                    "<html><head><title>Top ten artists</title></head><body><ul><li>" + 
                    string.Join("</li><li>", results.Select(m => m.ArtistNameSearch + " #" + m.RequestCount + "<br><img src=\""+m.AlbumCoverURLResult+"\"/>")) + 
                    "</li></ul></body></html>";

                return Content(htmlString, "text/html");
            }
        }
    }
}