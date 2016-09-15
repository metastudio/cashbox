$(function () {

  'use strict';

  function grantedNotification () {
    App.cable.subscriptions.create({
      channel: "NotificationChannel"
    }, {
      received: function(data) {
        var icon = $('.notification_icon').data('url')
        new Notification(data.title, { body: data.body, icon: icon });
      }
    });
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
