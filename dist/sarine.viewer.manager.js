(function() {
  var ViewerManger;

  ViewerManger = (function() {
    var addViewer, bindElementToSelector, fromTag, loadTemplate, stoneViews, template, toTag, viewers;

    viewers = [];

    stoneViews = void 0;

    fromTag = void 0;

    toTag = void 0;

    stoneViews = void 0;

    template = void 0;

    ViewerManger.prototype.bind = Error;

    function ViewerManger(option) {
      fromTag = option.fromTag, toTag = option.toTag, stoneViews = option.stoneViews, template = option.template;
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
        $(this).find("script").each((function(_this) {
          return function(i, v) {
            if (v.src) {
              deferArr.push($.Deferred());
              $.ajax({
                url: v.src,
                dataType: "script",
                async: false,
                success: function() {
                  return deferArr.pop().resolve();
                }
              });
            } else {
              $("<script type='text/javascript'></script>").text(v.innerText).appendTo(selector);
            }
            return v.remove();
          };
        })(this));
        $(selector).prepend($(this).children());
        return $.when.apply($, deferArr).done(function() {
          return bindElementToSelector(selector).then(defer.resolve);
        });
      });
      return defer.then(function() {
        return $(document).trigger("loadTemplate");
      });
    };

    addViewer = function(type, toElement) {
      switch (type) {
        case "realview":
          viewers.push(new Viewer.Dynamic.Sprite({
            src: stoneViews[type],
            element: toElement,
            jsonFileName: "/Jsons/iview.json",
            firstImagePath: "/Images/Eyeview/img0.jpg",
            spritesPath: "/EyeViewSprites/sprite",
            oneSprite: true,
            autoPlay: true
          }));
          break;
        case "topinspection":
          viewers.push(new Viewer.Dynamic.Sprite({
            src: stoneViews[type],
            element: toElement,
            jsonFileName: "/Jsons/impression.json",
            firstImagePath: "/Images/Impression/img0.jpg",
            spritesPath: "/ImpressionSprites/sprite_",
            oneSprite: false
          }));
          break;
        case "light":
          viewers.push(new Light({
            src: stoneViews[type],
            element: toElement
          }));
          break;
        default:
          console.error(type, 'not define!');
          return false;
      }
      return true;
    };

    ViewerManger.prototype.getViewers = function() {
      return viewers;
    };

    ViewerManger.prototype.first_init = function() {
      var defer;
      defer = $.Deferred();
      $.when.apply($, viewers.map(function(v) {
        return v.first_init();
      })).done(defer.resolve);
      return defer;
    };

    ViewerManger.prototype.full_init = function() {
      var defer;
      defer = $.Deferred();
      $.when.apply($, viewers.map(function(v) {
        return v.full_init();
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
