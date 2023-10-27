import { commerceApp_ } from './commerce_app.js';
import { phxApp_ } from './phx_app.js';
import { Socket } from "./phoenix.js"

window.commerceApp = commerceApp_
window.phxApp = phxApp_


const route_list = [
  { html: "register.html", title: "Register", route: "/register" },
  { html: "login.html", title: "Login", route: "/login" },


]

route_list.forEach((v, i) => {
  phxApp.route_names.push(v)
})


phxApp.navigateTo();

const socket = new Socket("/socket", { params: { token: window.userToken } });

window.socket = socket;
socket.connect();

var buildFreshUrl = function(link) {
  var date = Math.round(Date.now() / 1000).toString();
  var url = link.href.replace(/(\&|\\?)vsn=\d*/, '');
  var newLink = document.createElement('link');
  var onComplete = function() {
    if (link.parentNode !== null) {
      link.parentNode.removeChild(link);
    }
  };

  newLink.onerror = onComplete;
  newLink.onload = onComplete;
  link.setAttribute('data-pending-removal', '');
  newLink.setAttribute('rel', 'stylesheet');
  newLink.setAttribute('type', 'text/css');
  newLink.setAttribute('href', url + (url.indexOf('?') >= 0 ? '&' : '?') + 'vsn=' + date);
  link.parentNode.insertBefore(newLink, link.nextSibling);

  return newLink;
};

var repaint = function() {
  var browser = navigator.userAgent.toLowerCase();
  if (browser.indexOf('chrome') > -1) {
    setTimeout(function() { document.body.offsetHeight; }, 25);
  }
};

var cssStrategy = function() {
  var reloadableLinkElements = window.parent.document.querySelectorAll(
    'link[rel=stylesheet]:not([data-no-reload]):not([data-pending-removal])'
  );

  [].slice
    .call(reloadableLinkElements)
    .filter(function(link) { return link.href })
    .forEach(function(link) { buildFreshUrl(link) });

  repaint();
};

var pageStrategy = function(chan) {
  chan.off('assets_change');
  window.top.location.reload();
};


var reloadStrategies = {
  css: cssStrategy,
  page: pageStrategy
};
const rsocket = new Socket("/phoenix/live_reload/socket", { params: { token: window.userToken } });
rsocket.connect();
var chan = rsocket.channel('phoenix:live_reload', {})
chan.on('assets_change', function(msg) {
  var reloadStrategy = reloadStrategies[msg.asset_type] || reloadStrategies.page;
  setTimeout(function() { reloadStrategy(chan); }, 1000);
});
chan.join();



$(document).on("click", "a.navi", function(event) {
  event.preventDefault();
  setTimeout(() => {
    if ($(this).attr("href").includes("#")) {

    } else {
      phxApp.navigateTo($(this).attr("href"))
    }
  }, 200)

});