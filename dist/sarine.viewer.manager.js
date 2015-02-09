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
      fromTag = option.fromTag, toTag = option.toTag, stoneViews = option.stoneViews, template = option.template, jsons = option.jsons, logicRoot = option.logicRoot, logicPath = option.logicPath;
      viewers = [];
      this.bind = option.template ? loadTemplate : bindElementToSelector;
    }

    bindElementToSelector = function(selector) {
      var defer;
      defer = $.Deferred();
      $(selector).find(fromTag).each((function(_this) {
        return function(i, v) {
          var toElement, type;
          toElement = $("<" + toTag + ">");
          type = $(v).attr("viewer");
          toElement.data("type", type);
          toElement.addClass("viewer " + type);
          toElement.attr("id", "viewr_" + i);
          $(v).replaceWith(toElement);
          addViewer(type, toElement);
          return defer.resolve();
        };
      })(this));
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
      var data, inst;
      data = void 0;
      $.ajaxSetup({
        async: false
      });
      $.getJSON(jsons + type + ".json", (function(_this) {
        return function(d) {
          return data = d;
        };
      })(this));
      $.getScript(logicRoot + logicPath.replace(/\{name\}/g, data.name));
      $.ajaxSetup({
        async: false
      });
      inst = eval(data.instance);
      viewers.push(new inst($.extend({
        src: stoneViews[type],
        element: toElement
      }, data.args)));
      return true;
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
