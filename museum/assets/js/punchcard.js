/* The Punch Card Room: "Punch Your Own Card".
   Draws a line of text as an 80-column card using the IBM 029 keypunch
   (Hollerith) codes, shades the fixed-format zones, and explains what
   the compiler would make of each zone. */
(function () {
  "use strict";

  var ROWS = ["12", "11", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

  // Character -> list of punched rows (IBM 029 code).
  var CODES = {
    "&": ["12"], "-": ["11"], "0": ["0"], "/": ["0", "1"],
    ".": ["12", "3", "8"], "<": ["12", "4", "8"], "(": ["12", "5", "8"],
    "+": ["12", "6", "8"], "|": ["12", "7", "8"],
    "$": ["11", "3", "8"], "*": ["11", "4", "8"], ")": ["11", "5", "8"],
    ";": ["11", "6", "8"], ",": ["0", "3", "8"], "%": ["0", "4", "8"],
    "_": ["0", "5", "8"], ">": ["0", "6", "8"], "?": ["0", "7", "8"],
    ":": ["2", "8"], "#": ["3", "8"], "@": ["4", "8"], "'": ["5", "8"],
    "=": ["6", "8"], "\"": ["7", "8"], "!": ["11", "2", "8"]
  };
  var i;
  for (i = 1; i <= 9; i++) {
    CODES[String(i)] = [String(i)];
    CODES["ABCDEFGHI"[i - 1]] = ["12", String(i)];
    CODES["JKLMNOPQR"[i - 1]] = ["11", String(i)];
    if (i >= 2) { CODES["STUVWXYZ"[i - 2]] = ["0", String(i)]; }
  }

  function zone(col) {
    if (col <= 6) { return "z-seq"; }
    if (col === 7) { return "z-ind"; }
    if (col <= 11) { return "z-a"; }
    if (col <= 72) { return ""; }
    return "z-id";
  }

  function esc(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  var input = document.getElementById("card-input");
  var card = document.getElementById("card");
  var out = document.getElementById("card-readout");
  if (!input || !card || !out) { return; }

  function render() {
    var raw = input.value.replace(/\t/g, "    ");
    var text = raw.toUpperCase();
    var html = '<div class="pc-row pc-chars" aria-hidden="true">';
    var col, ch, cls;
    for (col = 1; col <= 80; col++) {
      ch = text.charAt(col - 1) || " ";
      cls = zone(col);
      if (col > 72 && ch !== " ") { cls += " over"; }
      html += '<span class="' + cls + '">' + (ch === " " ? "" : esc(ch)) + "</span>";
    }
    html += "</div>";
    ROWS.forEach(function (row) {
      html += '<div class="pc-row" aria-hidden="true">';
      for (col = 1; col <= 80; col++) {
        ch = text.charAt(col - 1) || " ";
        var punched = (CODES[ch] || []).indexOf(row) >= 0;
        cls = zone(col) + (punched ? " hole" : "");
        html += '<span class="' + cls + '">' +
          (punched || row === "12" || row === "11" ? "" : row) + "</span>";
      }
      html += "</div>";
    });
    card.innerHTML = html;

    // Readout: what the compiler sees.
    var seq = raw.slice(0, 6), ind = raw.charAt(6) || " ";
    var areaA = raw.slice(7, 11), areaB = raw.slice(11, 72);
    var past = raw.slice(72);
    var indText = {
      " ": "blank: an ordinary line of code",
      "*": "<b>*</b>: the whole line is a comment",
      "/": "<b>/</b>: a comment that also starts a new page in the listing",
      "-": "<b>-</b>: this line continues the one above",
      "D": "<b>D</b>: a debugging line"
    }[ind.toUpperCase()] || "<span class=\"warn\">'" + esc(ind) +
      "' is not a valid indicator</span>";
    var items = [];
    items.push("<dt>Columns 1-6, sequence area</dt><dd>" +
      (seq.trim() ? "'" + esc(seq) + "' (ignored by the compiler; it numbered the cards)"
                  : "empty (fine: nobody numbers cards any more)") + "</dd>");
    items.push("<dt>Column 7, indicator</dt><dd>" + indText + "</dd>");
    items.push("<dt>Columns 8-11, Area A</dt><dd>" +
      (areaA.trim() ? "'" + esc(areaA) + "': division, section and paragraph names and 01 levels start here"
                    : "empty: so this line is a statement (Area B)") + "</dd>");
    items.push("<dt>Columns 12-72, Area B</dt><dd>" +
      (areaB.trim() ? esc(areaB.trim().slice(0, 60)) : "empty") + "</dd>");
    if (past.length) {
      items.push('<dt>Columns 73+</dt><dd class="warn">"' + esc(past) +
        '": silently ignored. The compiler never sees it. ' +
        "This is the bug the repo's 72-column rule protects you from." +
        (raw.length > 80 ? " (And anything past 80 would not fit on the card at all.)" : "") +
        "</dd>");
    } else {
      items.push("<dt>Columns 73-80</dt><dd>empty: nothing lost</dd>");
    }
    out.innerHTML = "<p>Line length: <b>" + raw.length + "</b> characters.</p><dl class=\"readout\">" +
      items.join("") + "</dl>";
  }

  input.addEventListener("input", render);
  Array.prototype.forEach.call(document.querySelectorAll("[data-card-sample]"),
    function (btn) {
      btn.addEventListener("click", function () {
        input.value = btn.getAttribute("data-card-sample");
        render();
        input.focus();
      });
    });
  render();
})();
