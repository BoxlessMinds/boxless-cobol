/* Hall of PICtures: the PIC Decoder.
   Expands a PICTURE string, works out its category and size in bytes,
   and shows how a value would be stored or printed. It covers the common
   symbols (9 X A V S Z $ , . + - * B 0 / CR DB) and DISPLAY, COMP-3 and
   COMP usage. Anything else is "not yet acquired". */
(function () {
  "use strict";

  var picIn = document.getElementById("pic-input");
  var valIn = document.getElementById("pic-value");
  var out = document.getElementById("pic-readout");
  if (!picIn || !valIn || !out) { return; }

  function esc(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  }
  function show(s) { // make spaces visible
    return "<code>[" + esc(s).replace(/ /g, "&middot;") + "]</code>";
  }
  function count(arr, sym) {
    return arr.filter(function (c) { return c === sym; }).length;
  }

  function parseValue(text) {
    var m = /^\s*([+-]?)(\d*)(?:\.(\d*))?\s*$/.exec(text);
    if (!m || (m[2] === "" && (m[3] || "") === "")) { return null; }
    return { neg: m[1] === "-", int: m[2].replace(/^0+/, ""), dec: m[3] || "" };
  }

  // Fit a value into intPos.decPos digits, COBOL style: truncate, never round.
  function fit(v, intPos, decPos, notes) {
    var intD = v.int;
    if (intD.length > intPos) {
      notes.push("High-order truncation: the leading digits " +
        esc(intD.slice(0, intD.length - intPos)) + " fell off the left end. " +
        "COBOL does this silently unless you add ON SIZE ERROR.");
      intD = intD.slice(intD.length - intPos);
    }
    while (intD.length < intPos) { intD = "0" + intD; }
    var decD = v.dec.slice(0, decPos);
    if (/[1-9]/.test(v.dec.slice(decPos))) {
      notes.push("Extra decimal places were cut off, not rounded. " +
        "Use ROUNDED if you want rounding.");
    }
    while (decD.length < decPos) { decD += "0"; }
    return { int: intD, dec: decD };
  }

  function decode() {
    var raw = picIn.value.trim().toUpperCase().replace(/^PIC(TURE)?\s+(IS\s+)?/, "");
    var parts = raw.split(/\s+/);
    var pic = (parts.shift() || "").replace(/\.$/, "");
    var usage = parts.join(" ").replace(/^USAGE\s+(IS\s+)?/, "").replace(/\.$/, "");
    if (!pic) { out.innerHTML = "<p>Type a PIC clause to begin.</p>"; return; }

    var expanded = pic.replace(/(.)\((\d{1,3})\)/g, function (_, c, n) {
      return new Array(Math.min(+n, 200) + 1).join(c);
    });
    var suffix = "";
    if (/(CR|DB)$/.test(expanded)) {
      suffix = expanded.slice(-2);
      expanded = expanded.slice(0, -2);
    }
    var syms = expanded.split("");
    var bad = syms.filter(function (c) { return "9XAVSZ$,.+-*B0/".indexOf(c) < 0; });
    if (bad.length || /\(/.test(expanded)) {
      out.innerHTML = '<p class="warn">Exhibit not yet acquired: this decoder ' +
        "doesn't know the symbol <code>" + esc(bad[0] || "(") + "</code>. " +
        "Try 9, X, A, V, S, Z, $, comma, period, +, -, *, B, 0, /, CR or DB.</p>";
      return;
    }

    var notes = [], rows = [], v = parseValue(valIn.value);
    var isAlnum = /^[XA9]+$/.test(expanded) && /[XA]/.test(expanded);
    var isNumeric = /^S?[9V]+$/.test(expanded) && count(syms, "V") <= 1 && !suffix;

    if (isAlnum) {
      var len = syms.length;
      var cat = /^A+$/.test(expanded) ? "Alphabetic (letters and spaces only)"
                                       : "Alphanumeric (any characters)";
      var text = valIn.value.slice(0, len);
      if (valIn.value.length > len) {
        notes.push("Too long: the right-hand end was chopped off to fit " + len +
          " characters.");
      }
      while (text.length < len) { text += " "; }
      if (/^A+$/.test(expanded) && /[^A-Za-z ]/.test(text)) {
        notes.push("A PIC A field should only hold letters and spaces.");
      }
      rows.push(["Category", cat]);
      rows.push(["Size", len + " byte" + (len === 1 ? "" : "s")]);
      rows.push(["Stored as", show(text) + " (padded on the right with spaces)"]);
    } else if (isNumeric) {
      var signed = syms[0] === "S";
      var vAt = syms.indexOf("V");
      var intPos = count(vAt < 0 ? syms : syms.slice(0, vAt), "9");
      var decPos = vAt < 0 ? 0 : count(syms.slice(vAt), "9");
      var digits = intPos + decPos;
      var size, how;
      if (/^(COMP-3|COMPUTATIONAL-3|PACKED-DECIMAL)$/.test(usage)) {
        size = Math.floor(digits / 2) + 1;
        how = "COMP-3 (packed decimal: two digits per byte, sign in the last half-byte)";
      } else if (/^(COMP|COMPUTATIONAL|BINARY|COMP-4|COMP-5)$/.test(usage)) {
        size = digits <= 4 ? 2 : digits <= 9 ? 4 : 8;
        how = usage + " (binary)";
      } else if (usage === "" || usage === "DISPLAY") {
        size = digits;
        how = "DISPLAY (one character per digit)";
      } else {
        out.innerHTML = '<p class="warn">Exhibit not yet acquired: usage ' +
          "<code>" + esc(usage) + "</code>. Try DISPLAY, COMP-3 or COMP.</p>";
        return;
      }
      rows.push(["Category", "Numeric" + (signed ? ", signed" : ", unsigned")]);
      rows.push(["Digits", intPos + " before the point, " + decPos + " after"]);
      rows.push(["Usage", how]);
      rows.push(["Size", size + " byte" + (size === 1 ? "" : "s") +
        (vAt >= 0 ? ". The V takes no space: the point is only implied." : "")]);
      if (v) {
        if (v.neg && !signed && /[1-9]/.test(v.int + v.dec)) {
          notes.push("No S in the picture, so the minus sign is simply lost. " +
            "The field now holds a positive number.");
        }
        var neg = v.neg && signed && /[1-9]/.test(v.int + v.dec);
        var f = fit(v, intPos, decPos, notes);
        var all = f.int + f.dec;
        rows.push(["Digits held", "<code>" + esc(f.int) +
          (decPos ? "<b>^</b>" + esc(f.dec) : "") + "</code>" +
          (decPos ? " (^ marks the implied point)" : "") +
          (signed ? (neg ? ", negative" : ", positive") : "")]);
        if (/COMP-3|PACKED/.test(how)) {
          var nib = (all.length % 2 === 0 ? "0" : "") + all +
            (signed ? (neg ? "D" : "C") : "F");
          var bytes = nib.match(/../g).join(" ");
          rows.push(["In memory (hex)", "<code>" + bytes + "</code> (last half-byte: " +
            (signed ? (neg ? "D = negative" : "C = positive") : "F = unsigned") + ")"]);
        } else if (/DISPLAY/.test(how) && signed) {
          var last = +all.charAt(all.length - 1);
          var zone = neg ? "}JKLMNOPQR".charAt(last) : "{ABCDEFGHI".charAt(last);
          rows.push(["On a mainframe", "<code>" + esc(all.slice(0, -1) + zone) +
            "</code>. The sign hides inside the last digit (" + esc(zone) + " = " +
            (neg ? "-" : "+") + last + "). This is called an overpunch."]);
        }
      } else {
        notes.push("Type a number like 1234.5 or -42 to see it stored.");
      }
    } else {
      // Numeric-edited picture: format for printing.
      var res = edit(syms, suffix, v, notes);
      if (!res) {
        out.innerHTML = '<p class="warn">Exhibit not yet acquired: this ' +
          "combination of symbols isn't one the decoder can print.</p>";
        return;
      }
      var plen = syms.filter(function (c) { return c !== "V"; }).length + suffix.length;
      rows.push(["Category", "Numeric edited (for printing, not for arithmetic)"]);
      rows.push(["Size", plen + " characters (every symbol except V prints something)"]);
      if (v) { rows.push(["Prints as", show(res)]); }
      else { notes.push("Type a number like 1234.5 or -42 to see it printed."); }
    }

    out.innerHTML = "<p>Expanded picture: <code>" + esc(expanded + suffix) +
      "</code></p><dl class=\"readout\">" + rows.map(function (r) {
        return "<dt>" + r[0] + "</dt><dd>" + r[1] + "</dd>";
      }).join("") + "</dl>" + notes.map(function (n) {
        return '<p class="warn">' + n + "</p>";
      }).join("");
  }

  function edit(syms, suffix, v, notes) {
    var p = syms.indexOf(".");
    if (p < 0) { p = syms.indexOf("V"); }
    var intS = p < 0 ? syms : syms.slice(0, p);
    var decS = p < 0 ? [] : syms.slice(p + 1);
    var fl = null;
    ["$", "+", "-"].forEach(function (c) { if (count(intS, c) >= 2) { fl = c; } });
    var digitSyms = function (a) {
      return a.filter(function (c) { return c === "9" || c === "Z" || c === "*"; }).length;
    };
    var intPos = digitSyms(intS) + (fl ? count(intS, fl) - 1 : 0);
    var decPos = digitSyms(decS) + (fl ? count(decS, fl) : 0);
    if (intPos + decPos === 0) { return null; }
    if (!v) { return ""; }
    var neg = v.neg && /[1-9]/.test(v.int + v.dec);
    var hasSign = fl === "+" || fl === "-" || /[+-]/.test(syms.join("")) || suffix;
    if (neg && !hasSign) {
      notes.push("No sign symbol in the picture, so the minus sign does not print.");
    }
    var f = fit(v, intPos, decPos, notes);
    var star = syms.indexOf("*") >= 0;
    var zero = !/[1-9]/.test(f.int + f.dec);
    var out = [], d = 0, started = false, firstFl = false;
    var signCh = function (c) { return c === "+" ? (neg ? "-" : "+") : (neg ? "-" : " "); };
    var blank = star ? "*" : " ";

    intS.forEach(function (c) {
      var ch;
      if (c === fl) {
        if (!firstFl) { firstFl = true; out.push({ fl: true, ch: " " }); return; }
        ch = f.int.charAt(d++);
        if (!started && ch === "0") { out.push({ fl: true, ch: " " }); }
        else { started = true; out.push({ ch: ch }); }
      } else if (c === "9") {
        started = true; out.push({ ch: f.int.charAt(d++) });
      } else if (c === "Z" || c === "*") {
        ch = f.int.charAt(d++);
        if (!started && ch === "0") { out.push({ ch: c === "*" ? "*" : " " }); }
        else { started = true; out.push({ ch: ch }); }
      } else if (c === ",") {
        out.push(started ? { ch: "," } : { fl: !!fl && firstFl, ch: blank });
      } else if (c === "B") { out.push({ ch: " " });
      } else if (c === "0" || c === "/") { out.push({ ch: c });
      } else if (c === "$") { out.push({ ch: "$" });
      } else if (c === "+" || c === "-") { out.push({ ch: signCh(c) });
      } else if (c === "S") { /* S is not used in edited pictures */ }
    });
    if (fl) {
      var at = -1;
      out.forEach(function (o, k) { if (o.fl && o.ch === " ") { at = k; } });
      if (at < 0) { at = 0; }
      if (!(zero && decPos === 0)) {
        out[at] = { ch: fl === "$" ? "$" : signCh(fl) };
      }
    }
    var s = out.map(function (o) { return o.ch; }).join("");
    var dd = 0;
    var point = p >= 0 && syms[p] === "." ? "." : "";
    var decOut = decS.map(function (c) {
      if (c === "9" || c === "Z" || c === "*" || c === fl) { return f.dec.charAt(dd++); }
      if (c === "+" || c === "-") { return signCh(c); }
      if (c === "B") { return " "; }
      return c;
    }).join("");
    var cr = suffix ? (neg ? suffix : "  ") : "";
    var result = s + point + decOut + cr;
    // An all-Z (or all-*) picture holding zero prints as blanks (or stars).
    var allSuppress = syms.every(function (c) {
      return "9".indexOf(c) < 0;
    }) && !fl;
    if (zero && allSuppress && /[Z*]/.test(syms.join(""))) {
      result = result.replace(/./g, star ? "*" : " ");
      if (star && point) { result = result.slice(0, s.length) + "." +
        result.slice(s.length + 1); }
    }
    return result;
  }

  picIn.addEventListener("input", decode);
  valIn.addEventListener("input", decode);
  Array.prototype.forEach.call(document.querySelectorAll("[data-pic]"),
    function (btn) {
      btn.addEventListener("click", function () {
        picIn.value = btn.getAttribute("data-pic");
        valIn.value = btn.getAttribute("data-val");
        decode();
      });
    });
  decode();
})();
