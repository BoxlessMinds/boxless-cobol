/* Exit Survey: the Docent Quiz.
   Ten questions from the galleries. 7 or more right earns a printable
   badge. The visitor's name stays on the page; it is never stored. */
(function () {
  "use strict";

  var QUESTIONS = [
    { q: "What does COBOL stand for?",
      a: ["Computer Operated Business Language", "COmmon Business-Oriented Language",
          "Code Of Business Operations and Logistics"], ok: 1,
      why: "COmmon Business-Oriented Language. See the Hall of Origins." },
    { q: "In fixed-format COBOL, what goes in column 7?",
      a: ["The indicator, such as * for a comment", "The program name", "The first letter of every statement"],
      ok: 0, why: "Column 7 is the indicator area: * makes the line a comment." },
    { q: "What happens to code typed past column 72?",
      a: ["The compiler reports an error", "It wraps onto the next line", "It is silently ignored"],
      ok: 2, why: "Silently ignored. That's why the repo enforces the 72-column rule." },
    { q: "Which division declares every variable?",
      a: ["PROCEDURE", "DATA", "IDENTIFICATION"], ok: 1,
      why: "The DATA DIVISION, before any code runs." },
    { q: "In PIC 9(5)V99, what does the V take up in storage?",
      a: ["One byte", "Two bytes", "Nothing: the point is only implied"], ok: 2,
      why: "V is an implied decimal point and takes no space." },
    { q: "How many bytes does PIC X(30) always use?",
      a: ["30", "Only as many as the text needs", "31, for the end marker"], ok: 0,
      why: "Always 30. Short values are padded with spaces." },
    { q: "Which verb is COBOL's version of a switch statement?",
      a: ["PERFORM", "EVALUATE", "UNSTRING"], ok: 1,
      why: "EVALUATE. The repo's library uses EVALUATE TRUE to pick a function." },
    { q: "In December 1960, what did the two-machine demo show?",
      a: ["The same COBOL program ran on two makers' computers",
          "Two computers could talk over a phone line", "COBOL ran faster than FORTRAN"],
      ok: 0, why: "Portability: one program, an RCA 501 and a UNIVAC II." },
    { q: "Why did old programs store years as PIC 99?",
      a: ["COBOL couldn't count past 99", "To save expensive storage", "It was required by law"],
      ok: 1, why: "Storage was costly, and two characters per date added up." },
    { q: "Why was 1 January 2000 so quiet?",
      a: ["The problem was made up", "Computers were switched off for the night",
          "Programmers fixed the code in advance"], ok: 2,
      why: "Nothing happened because they fixed it." }
  ];

  var form = document.getElementById("quiz-form");
  var result = document.getElementById("quiz-result");
  var badgeArea = document.getElementById("badge-area");
  if (!form || !result) { return; }

  function esc(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  form.innerHTML = QUESTIONS.map(function (item, n) {
    return '<div class="question" id="q' + n + '"><fieldset><legend>' +
      (n + 1) + ". " + esc(item.q) + "</legend>" +
      item.a.map(function (ans, k) {
        return '<label><input type="radio" name="q' + n + '" value="' + k + '"> ' +
          esc(ans) + "</label>";
      }).join("") + '</fieldset><p class="feedback" aria-live="polite"></p></div>';
  }).join("") +
    '<div class="btn-row"><button class="btn" type="submit">Hand in my survey</button>' +
    '<button class="btn secondary" type="reset">Start again</button></div>';

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    var score = 0, unanswered = 0;
    QUESTIONS.forEach(function (item, n) {
      var box = document.getElementById("q" + n);
      var pick = form.querySelector('input[name="q' + n + '"]:checked');
      var fb = box.querySelector(".feedback");
      box.classList.remove("right", "wrong");
      if (!pick) { unanswered++; fb.textContent = "Not answered. " + item.why; return; }
      var right = +pick.value === item.ok;
      if (right) { score++; }
      box.classList.add(right ? "right" : "wrong");
      fb.textContent = (right ? "Correct. " : "Not quite. ") + item.why;
    });
    var msg = "<h2>You scored " + score + " out of " + QUESTIONS.length + "</h2>";
    if (score >= 7) {
      msg += "<p>Congratulations! You are a <b>Certified COBOL Visitor</b>. " +
        "Type your name to engrave your badge.</p>";
      badgeArea.hidden = false;
    } else {
      msg += "<p>So close. You need 7 to earn the badge. " +
        (unanswered ? unanswered + " question(s) were left blank. " : "") +
        "The answers are shown above, and the galleries are always open.</p>";
      badgeArea.hidden = true;
    }
    result.innerHTML = msg;
    result.scrollIntoView({ behavior: "smooth", block: "start" });
  });

  form.addEventListener("reset", function () {
    Array.prototype.forEach.call(form.querySelectorAll(".question"), function (b) {
      b.classList.remove("right", "wrong");
      b.querySelector(".feedback").textContent = "";
    });
    result.innerHTML = "";
    badgeArea.hidden = true;
  });

  var nameIn = document.getElementById("badge-name");
  var who = document.getElementById("badge-who");
  var date = document.getElementById("badge-date");
  if (nameIn && who) {
    nameIn.addEventListener("input", function () {
      who.textContent = nameIn.value.trim() || "Your Name Here";
    });
  }
  if (date) {
    var d = new Date();
    date.textContent = d.getFullYear() + "-" + ("0" + (d.getMonth() + 1)).slice(-2) +
      "-" + ("0" + d.getDate()).slice(-2) + " (four-digit year, naturally)";
  }
})();
