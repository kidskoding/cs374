// Shared quiz component.
// Multiple choice: <div class="q mcq" data-answer="2"> ... <div class="opts"><button>..</button>...</div> <p class="fb"></p> <p class="why">..</p></div>
//   data-answer is the 0-based index of the right button.
// Fill-in: <div class="q fill"> ... <input data-answer="12|twelve"> ... <button class="check">Check</button> <p class="fb"></p> <p class="why">..</p></div>
//   Several inputs allowed; "|" separates accepted answers; spaces and case are ignored.
(function () {
  const norm = s => s.replace(/\s+/g, "").toLowerCase();
  const qs = [...document.querySelectorAll(".q")];
  const solved = new Set();
  const score = document.getElementById("score");
  const update = () => { if (score) score.textContent = `${solved.size} / ${qs.length} correct`; };
  const finish = (q, ok, msg) => {
    const fb = q.querySelector(".fb");
    fb.textContent = msg; fb.className = "fb " + (ok ? "good" : "bad");
    if (ok) { q.classList.add("done"); solved.add(q); update(); }
  };
  qs.forEach(q => {
    if (q.classList.contains("mcq")) {
      const right = Number(q.dataset.answer);
      q.querySelectorAll(".opts button").forEach((b, i) => b.addEventListener("click", () => {
        if (q.classList.contains("done")) return;
        b.classList.add(i === right ? "right" : "wrong");
        finish(q, i === right, i === right ? "Yes." : "Not that one. Try again.");
      }));
    } else {
      const inputs = [...q.querySelectorAll("input")];
      const check = () => {
        let ok = true;
        inputs.forEach(inp => {
          const good = inp.dataset.answer.split("|").some(a => norm(a) === norm(inp.value));
          inp.classList.toggle("right", good); inp.classList.toggle("wrong", !good && inp.value !== "");
          ok = ok && good;
        });
        finish(q, ok, ok ? "Yes." : "Red boxes are off. Fix them and check again.");
      };
      q.querySelector(".check").addEventListener("click", check);
      inputs.forEach(inp => inp.addEventListener("keydown", e => { if (e.key === "Enter") check(); }));
    }
  });
  update();
})();
