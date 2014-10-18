using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WeshAppCloudAPI.Models;

namespace WeshAppCloudAPI.Controllers
{
    public class MusicController : Controller
    {

        // GET: Music
        public ActionResult GetAlbumFromTrack(string artistName, string songName)
        {
            AlbumTrackMatch albumMatch = MatchRepository.handleAlbumMatch(artistName, songName);
            return Json(albumMatch, JsonRequestBehavior.AllowGet);
        }
    }
}