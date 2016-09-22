$(function () {

  "use strict";

  $(document).ready(function () {
    $(".btn.new_account").on("ajax:success", function (e, data) {
      $(".new_account_form").empty();
      $(".previous_buttons").addClass("hidden");
      $(".next_step_wrapper").addClass("hidden");
      $(".new_account_form").append(data);
      $("#new_bank_account").on("ajax:success", function (e, data) {
        if (data["status"] === "error") {
          $.each(data["errors"], function (key, value) {
            formHasErrors("#new_bank_account");
            addErrorOnField(
              "#new_bank_account",
              ".bank_account_" + key,
              value
            );
          });
        } else {
          $(".new_account_form").empty();
          $(".next_step_wrapper").removeClass("hidden");
        }
      });
    });
    $(".btn.new_category").on("ajax:success", function (e, data) {
      $(".new_category_form").empty();
      $(".previous_buttons").addClass("hidden");
      $(".next_step_wrapper").addClass("hidden");
      $(".new_category_form").append(data);
      $("#new_category").on("ajax:success", function (e, data) {
        if (data["status"] === "error") {
          $.each(data["errors"], function (key, value) {
            formHasErrors("#new_category");
            addErrorOnField(
              "#new_category",
              ".category_" + key,
              value
            );
          });
        } else {
          $(".new_category_form").empty();
          $(".next_step_wrapper").removeClass("hidden");
        }
      });
    });
  });

  function addErrorOnField (form, field, message) {
    var input_wrapper = $(form).find(field);
    input_wrapper.addClass("has-error");
    if (input_wrapper.find("span.has-error").length === 0) {
      $("<span class='help-block has-error'></span>").appendTo(input_wrapper)
        .append(message);
    }
  }

  function formHasErrors (form) {
    if ($(form).find(".error_notification").length === 0 ) {
      $("<div class='error_notification'>Please review the problems below:</div>")
        .insertBefore(form + " .form-inputs");
    }
  }
});
