$(function () {

  'use strict';

  function grantedNotification () {
    var socket = new WebSocket("ws://" + location.host + "/events-stream");
    socket.onmessage = function(e) {
      var data = JSON.parse(e.data)
      var icon = $('.icon').data('url')
      new Notification(data.title, { body: data.body, icon: icon });
    };
  }

  function notifyOn () {
    if ("Notification" in window) {
      if (Notification.permission === "granted") {
        grantedNotification();
      }
      else if (Notification.permission !== 'denied') {
        Notification.requestPermission(function (permission) {
          if (permission === "granted") {
            grantedNotification();
          }
        });
      }
    }
  }

  notifyOn();
});
