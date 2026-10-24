/* The Y2K Bunker: the rollover clock.
   Counts down to midnight on 31 Dec 1999, then shows what a two-digit
   year does to a simple age calculation, and two ways to fix it. */
(function () {
  "use strict";

  var clock = document.getElementById("y2k-clock");
  var btn = document.getElementById("y2k-go");
  var reset = document.getElementById("y2k-reset");
  var out = document.getElementById("y2k-out");
  var fixBox = document.getElementById("y2k-fix");
  if (!clock || !btn || !out) { return; }

  var BIRTH = 65; // born 1965
  var reduce = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var timer = null;

  function pad(n) { return (n < 10 ? "0" : "") + n; }
  function age(yy) { return yy - BIRTH; }

  function line(label, code, value, bad) {
    return "<dt>" + label + "</dt><dd><code>" + code + "</code> &rarr; " +
      (bad ? '<span class="warn">' + value + "</span>" : "<b>" + value + "</b>") +
      "</dd>";
  }

  function before() {
    clock.className = "clock";
    clock.textContent = "31-12-99  23:59:55";
    out.innerHTML = '<dl class="readout">' +
      line("CURRENT-YY", "PIC 99", "99") +
      line("BIRTH-YY", "PIC 99", "65") +
      line("Age", "COMPUTE AGE = CURRENT-YY - BIRTH-YY", age(99) + " years old") +
      "</dl>";
    if (fixBox) { fixBox.hidden = true; }
  }

  function after() {
    clock.className = "clock ok";
    clock.textContent = "01-01-00  00:00:00";
    var raw = age(0);
    out.innerHTML = '<dl class="readout">' +
      line("CURRENT-YY", "PIC 99", "00 (was 99, plus one, and there's no room for 100)") +
      line("Age", "COMPUTE AGE = 00 - 65", raw, true) +
      line("Age stored in PIC 99", "no S, so the sign is dropped", "65", true) +
      "</dl><p class=\"warn\">Happy New Year! According to the computer, " +
      "you are either minus 65 or 65 and eligible for a pension. " +
      "Your bank interest just ran backwards for a century.</p>";
    if (fixBox) { fixBox.hidden = false; }
  }

  btn.addEventListener("click", function () {
    clearInterval(timer);
    btn.disabled = true;
    if (reduce) { after(); btn.disabled = false; return; }
    var s = 55;
    before();
    timer = setInterval(function () {
      s++;
      if (s >= 60) {
        clearInterval(timer);
        after();
        btn.disabled = false;
        return;
      }
      clock.textContent = "31-12-99  23:59:" + pad(s);
    }, 700);
  });
  if (reset) {
    reset.addEventListener("click", function () {
      clearInterval(timer);
      btn.disabled = false;
      before();
    });
  }
  before();
})();
