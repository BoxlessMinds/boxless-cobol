/* The COBOL Museum - shared page furniture.
   Injects the header, breadcrumb, prev/next doors and footer; loads the
   exhibit images (leaving the "being restored" placeholder if a file is
   missing); and runs the light switch. */
(function () {
  "use strict";

  var TOUR = [
    { id: "index", file: "index.html", title: "The Grand Lobby" },
    { id: "origins", file: "origins.html", title: "Hall of Origins" },
    { id: "punch-cards", file: "punch-cards.html", title: "The Punch Card Room" },
    { id: "divisions", file: "divisions.html", title: "The Four Divisions Wing" },
    { id: "pictures", file: "pictures.html", title: "Hall of PICtures" },
    { id: "verbs", file: "verbs.html", title: "The Verbose Hall" },
    { id: "vault", file: "vault.html", title: "The Vault" },
    { id: "y2k", file: "y2k.html", title: "The Y2K Bunker" },
    { id: "timeline", file: "timeline.html", title: "The Timeline Corridor" },
    { id: "workshop", file: "workshop.html", title: "The Living Workshop" },
    { id: "gift-shop", file: "gift-shop.html", title: "The Gift Shop" },
    { id: "resources", file: "resources.html", title: "The Reading Room" },
    { id: "quiz", file: "quiz.html", title: "Exit Survey: The Docent Quiz" }
  ];

  var page = document.body.getAttribute("data-page") || "";
  var idx = -1;
  for (var i = 0; i < TOUR.length; i++) {
    if (TOUR[i].id === page) { idx = i; }
  }

  function store(key, value) {
    try {
      if (value === undefined) { return localStorage.getItem(key); }
      localStorage.setItem(key, value);
    } catch (e) { /* private mode: theme just won't be remembered */ }
    return null;
  }

  /* ---------- header ---------- */
  var nav = [
    ["index.html#floor-plan", "Floor Plan", ""],
    ["origins.html", "Guided Tour", ""],
    ["workshop.html", "Workshop", "workshop"],
    ["resources.html", "Reading Room", "resources"],
    ["quiz.html", "Quiz", "quiz"]
  ];
  var header = document.getElementById("site-header");
  if (header) {
    var links = nav.map(function (n) {
      var cur = n[2] && n[2] === page ? ' aria-current="page"' : "";
      return '<a href="' + n[0] + '"' + cur + ">" + n[1] + "</a>";
    }).join("");
    header.outerHTML =
      '<header class="site-header"><div class="wrap">' +
      '<a class="brand" href="index.html"><span class="brand-mark"' +
      ' aria-hidden="true"></span><span class="brand-text">The COBOL Museum' +
      "<small>EST. 1959 &middot; STILL RUNNING</small></span></a>" +
      '<nav class="site-nav" aria-label="Museum">' + links + "</nav>" +
      '<button class="light-switch" type="button" aria-pressed="false">' +
      '<span class="toggle" aria-hidden="true"></span>' +
      '<span class="label">Lights off</span></button>' +
      "</div></header>" +
      (idx > 0 ? '<div class="wrap breadcrumb">You are here: ' +
        '<a href="index.html">Lobby</a> &rsaquo; Gallery ' + idx + " of " +
        (TOUR.length - 1) + " &rsaquo; " + TOUR[idx].title + "</div>" : "");
  }

  /* ---------- light switch ---------- */
  var root = document.documentElement;
  function isDark() {
    var t = root.getAttribute("data-theme");
    if (t) { return t === "dark"; }
    return window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches;
  }
  function syncSwitch() {
    var btn = document.querySelector(".light-switch");
    if (!btn) { return; }
    var dark = isDark();
    btn.setAttribute("aria-pressed", dark ? "true" : "false");
    btn.querySelector(".label").textContent = dark ? "Lights on" : "Lights off";
    btn.title = dark ? "Back to the manila daylight"
                     : "Lights off in the Vault (green-screen mode)";
  }
  document.addEventListener("click", function (e) {
    var btn = e.target.closest && e.target.closest(".light-switch");
    if (!btn) { return; }
    var next = isDark() ? "light" : "dark";
    root.setAttribute("data-theme", next);
    store("museum-theme", next);
    syncSwitch();
  });
  syncSwitch();

  /* ---------- doors + footer ---------- */
  var footer = document.getElementById("site-footer");
  if (footer) {
    var doors = "";
    if (idx >= 0) {
      var prev = TOUR[idx - 1], next = TOUR[idx + 1];
      doors = '<div class="wrap"><nav class="doors" aria-label="Guided tour">' +
        (prev ? '<a class="door prev" href="' + prev.file + '"><small>&larr; ' +
          "Previous gallery</small><span>" + prev.title + "</span></a>" : "") +
        (next ? '<a class="door next" href="' + next.file + '"><small>Next ' +
          "gallery &rarr;</small><span>" + next.title + "</span></a>"
          : '<a class="door next" href="index.html"><small>Tour complete' +
          "</small><span>Back to the Lobby</span></a>") +
        "</nav></div>";
    }
    footer.outerHTML = doors +
      '<footer class="site-footer"><div class="wrap">' +
      "<span>The COBOL Museum &middot; part of the boxless-cobol playground." +
      " Admission free. Coffee from 1959.</span>" +
      '<span><a href="resources.html">Reading Room (resources)</a> &middot; ' +
      '<a href="https://github.com/BoxlessMinds/boxless-cobol/blob/main/museum/IMAGE-PROMPTS.md">Image prompts</a> &middot; ' +
      '<a href="https://github.com/BoxlessMinds/boxless-cobol/blob/main/tutorials/README.md">Lessons</a></span>' +
      "</div></footer>";
  }

  /* ---------- exhibit images ---------- */
  var frames = document.querySelectorAll(".frame[data-file]");
  Array.prototype.forEach.call(frames, function (frame) {
    var alt = frame.getAttribute("data-alt") || "";
    frame.setAttribute("role", "img");
    frame.setAttribute("aria-label", alt + " (image " +
      frame.getAttribute("data-prompt") + " not yet added)");
    var img = new Image();
    img.alt = alt;
    img.decoding = "async";
    img.loading = "lazy";
    img.onload = function () {
      frame.classList.add("loaded");
      frame.removeAttribute("role");
      frame.removeAttribute("aria-label");
    };
    img.src = "assets/img/" + frame.getAttribute("data-file");
    frame.appendChild(img);
  });

  /* ---------- print helper (badge, cheat sheet, bookmarks) ---------- */
  document.addEventListener("click", function (e) {
    var btn = e.target.closest && e.target.closest("[data-print-target]");
    if (!btn) { return; }
    document.body.setAttribute("data-print", btn.getAttribute("data-print-target"));
    window.print();
  });
  window.addEventListener("afterprint", function () {
    document.body.removeAttribute("data-print");
  });
})();
