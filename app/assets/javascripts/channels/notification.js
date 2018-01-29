$(function () {

  'use strict';

  var tabActive = true;

  window.onfocus = function () {
    tabActive = true;
  };

  window.onblur = function () {
    tabActive = false;
  };

  function grantedNotification () {
    App.cable.subscriptions.create({
      channel: "NotificationChannel"
    }, {
      received: function(data) {
        if (!tabActive) {
          var icon = $('.notification_icon').data('url');
          var notification = new Notification(data.title, { body: data.body, icon: icon });
          notification.onclick = function () {
            window.focus();
          };
        }
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
