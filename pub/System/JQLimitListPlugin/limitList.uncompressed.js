/*
 * jQuery Limit List 0.04
 *
 * Copyright (c) 2021-2025 Michael Daum https://michaeldaumconsulting.com
 *
 * Licensed under the GPL licenses http://www.gnu.org/licenses/gpl.html
 *
 */

"use strict";
(function($) {

  // Create the defaults once
  var defaults = {
    max: 5,
    moreText: "more",
    lessText: "less"
  };

  function LimitList(elem, opts) {
    var self = this;

    self.elem = $(elem);
    self.opts = $.extend({}, defaults, self.elem.data(), opts);
    self.init();
  }

  LimitList.prototype.getContentPos = function() {
    var self = this,
        item = self.elem.children().eq(self.opts.max),
        result = 0;

    item.data("_tag", true);
    self.elem.contents().filter(function(index) {
      if ($(this).data("_tag")) {
        result = index;
      }
    });

    return result;
  };

  LimitList.prototype.init = function () {
    var self = this,
        len = self.elem.children().length,
        pos;

    if (len > self.opts.max) {
      self.container = $("<span class='moreContainer' />").appendTo(self.elem).hide();

      pos = self.getContentPos();
      self.elem.contents().filter(function(i) {
        return i >= pos;
      }).appendTo(self.container);

      self.ellipsisElem = $("<span class='ellipsis'> ... </span>").appendTo(self.elem);

      self.moreElem = $("<a />")
        .text(self.opts.moreText)
        .appendTo(self.elem)
        .on("click", function() {
          if (self.container.is(":visible")) {
            self.moreElem.text(self.opts.moreText);
          } else {
            self.moreElem.text(self.opts.lessText);
          }
          self.container.fadeToggle("fast");
        });
    }
  };

  $.fn.limitList = function (opts) {
    return this.each(function () {
      if (!$.data(this, "limitList")) {
        $.data(this, "limitList", new LimitList(this, opts));
      }
    });
  };

  $(function() {
    $(".jqLimitList").livequery(function() {
      $(this).limitList().addClass("inited");
    });
  });

})(jQuery);

