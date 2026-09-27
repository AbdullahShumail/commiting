(function () {
  var list = document.getElementById("log-list");
  if (!list || typeof LOG === "undefined") return;

  var latest = LOG.slice(-15).reverse();
  latest.forEach(function (entry) {
    var li = document.createElement("li");
    var time = document.createElement("time");
    time.textContent = entry.time;
    var text = document.createElement("span");
    text.textContent = entry.text;
    li.appendChild(time);
    li.appendChild(text);
    list.appendChild(li);
  });

  var count = document.getElementById("log-count");
  if (count) count.textContent = LOG.length;
})();

(function () {
  var year = document.getElementById("year");
  if (year) year.textContent = new Date().getFullYear();
})();
