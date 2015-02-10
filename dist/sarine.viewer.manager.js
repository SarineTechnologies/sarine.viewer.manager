/*! sarine.viewer.manager - v0.0.3 -  Tuesday, February 10th, 2015, 1:56:45 PM */
(function() {
  var ViewerManger;

  ViewerManger = (function() {
    var addViewer, bindElementToSelector, fromTag, getPath, jsons, loadTemplate, logicPath, logicRoot, stoneViews, template, toTag, viewers;

    viewers = [];

    stoneViews = void 0;

    fromTag = void 0;

    toTag = void 0;

    stoneViews = void 0;

    template = void 0;

    jsons = void 0;

    logicRoot = void 0;

    logicPath = void 0;

    ViewerManger.prototype.bind = Error;

    getPath = function(src) {
      var arr;
      arr = src.split("/");
      arr.pop();
      return arr.join("/");
    };

    function ViewerManger(option) {
      fromTag = option.fromTag, toTag = option.toTag, stoneViews = option.stoneViews, template = option.template, jsons = option.jsons, logicRoot = option.logicRoot;
      logicRoot = stoneViews.viewersBaseUrl + "{version}/js/";
      jsons = stoneViews.viewersBaseUrl + "{version}/jsons/";
      viewers = [];
      this.bind = option.template ? loadTemplate : bindElementToSelector;
    }

    bindElementToSelector = function(selector) {
      var arrDefer, defer;
      defer = $.Deferred();
      arrDefer = [];
      $(selector).find(fromTag).each((function(_this) {
        return function(i, v) {
          var toElement, type;
          toElement = $("<" + toTag + ">");
          type = $(v).attr("viewer");
          toElement.data("type", type);
          toElement.data("version", $(v).attr("version"));
          toElement.addClass("viewer " + type);
          toElement.attr("id", "viewr_" + i);
          $(v).replaceWith(toElement);
          return arrDefer.push(addViewer(type, toElement));
        };
      })(this));
      $.when.apply($, arrDefer).then(function() {
        return defer.resolve();
      });
      return defer;
    };

    loadTemplate = function(selector) {
      var defer, deferArr;
      defer = $.Deferred();
      deferArr = [];
      $("<div>").load(template, function(a, b, c) {
        $(selector).prepend($(a).each((function(_this) {
          return function(i, v) {
            if (v.tagName === "SCRIPT" && v.src) {
              deferArr.push($.Deferred());
              v.src = v.src.replace(getPath(location.origin + location.pathname), getPath(template));
              $.getScript(v.src, function() {
                deferArr.pop();
                if (deferArr.length === 0) {
                  return bindElementToSelector(selector).then(function() {
                    return defer.resolve();
                  });
                }
              });
              $(v).remove();
            }
            if (v.tagName === "LINK" && v.href) {
              return v.href = v.href.replace(getPath(location.origin + location.pathname), getPath(template));
            }
          };
        })(this)));
        if (deferArr.length === 0) {
          return bindElementToSelector(selector).then(defer.resolve);
        }
      });
      return defer.then(function() {
        return $(document).trigger("loadTemplate");
      });
    };

    addViewer = function(type, toElement) {
      var data, defer;
      defer = $.Deferred();
      data = void 0;
      $.ajaxSetup({
        async: false
      });
      $.getJSON(jsons.replace("{version}", toElement.data("version") || "v1") + type + ".json", (function(_this) {
        return function(d) {
          return data = d;
        };
      })(this));
      $.ajaxSetup({
        async: true
      });
      $.getScript(logicRoot.replace("{version}", toElement.data("version") || "v1") + data.name + (location.hash.indexOf("debug") === 1 ? ".bundle.js" : ".bundle.min.js"), function() {
        var inst;
        inst = eval(data.instance);
        viewers.push(new inst($.extend({
          src: stoneViews.viewers[type],
          element: toElement
        }, data.args)));
        return defer.resolve();
      });
      return defer;
    };

    ViewerManger.prototype.getViewers = function() {
      return viewers;
    };

    ViewerManger.prototype.first_init = function() {
      var defer;
      defer = $.Deferred();
      viewers.forEach(function(v) {
        return v.first_init();
      });
      $.when(viewers.map(function(v) {
        return v.first_init_defer;
      })).done(defer.resolve);
      return defer;
    };

    ViewerManger.prototype.full_init = function() {
      var defer;
      defer = $.Deferred();
      viewers.forEach(function(v) {
        return v.full_init();
      });
      $.when.apply($, viewers.map(function(v) {
        return v.full_init_defer;
      })).done(defer.resolve);
      return defer;
    };

    ViewerManger.prototype.stop = function() {
      return viewers.forEach(function(v) {
        return v.stop();
      });
    };

    ViewerManger.prototype.play = function() {
      return viewers.forEach(function(v) {
        return v.play(true);
      });
    };

    return ViewerManger;

  })();

  this.ViewerManger = ViewerManger;

}).call(this);
