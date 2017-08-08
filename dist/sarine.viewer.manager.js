
/*!
sarine.viewer.manager - v0.19.0 -  Tuesday, August 8th, 2017, 3:55:06 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.
 */

(function() {
  var ViewerManger;

  ViewerManger = (function() {
    var addViewer, allViewresList, bindElementToSelector, configurationToTemplateMapper, existInConfig, experiencesList, findAttribute, fromTag, getAllTemplates, getPath, getTemplateLists, getTemplateMapperByConfigName, iconsList, infoPopupsList, initLocalStorage, initTemplates, initTemplatesMapper, jsons, jsonsAll, jsonsAllObj, loadTemplate, logicPath, logicRoot, popupInfoMapper, recurse, stoneViews, template, templateContainers, toTag, viewers;

    viewers = [];

    stoneViews = void 0;

    fromTag = void 0;

    toTag = void 0;

    stoneViews = void 0;

    template = void 0;

    jsons = void 0;

    jsonsAll = void 0;

    jsonsAllObj = void 0;

    logicRoot = void 0;

    logicPath = void 0;

    allViewresList = void 0;

    configurationToTemplateMapper = void 0;

    popupInfoMapper = void 0;

    experiencesList = void 0;

    iconsList = void 0;

    infoPopupsList = void 0;

    templateContainers = void 0;

    ViewerManger.prototype.bind = Error;

    getTemplateLists = function() {
      return {
        experiencesList: experiencesList,
        iconsList: iconsList,
        infoPopupsList: infoPopupsList
      };
    };

    getPath = function(src) {
      var arr;
      arr = src.split("/");
      arr.pop();
      return arr.join("/");
    };

    initLocalStorage = function(type) {
      if (typeof Storage !== "undefined") {
        if (localStorage.getItem(type) === null) {
          return localStorage.setItem(type, "[]");
        }
      }
    };

    initTemplates = function() {
      var allTemplates;
      allTemplates = getAllTemplates();
      if (allTemplates) {
        experiencesList = allTemplates.templates;
        iconsList = allTemplates.icons;
        infoPopupsList = allTemplates.infoPopups;
      }
    };

    initTemplatesMapper = function() {
      configurationToTemplateMapper = null;
      if (window.sarineViewerTemplatesMapping && sarineViewerTemplatesMapping.mapper) {
        configurationToTemplateMapper = sarineViewerTemplatesMapping.mapper.getMapper();
      }
    };

    function ViewerManger(option) {
      fromTag = option.fromTag, toTag = option.toTag, stoneViews = option.stoneViews, template = option.template, jsons = option.jsons, logicRoot = option.logicRoot, templateContainers = option.templateContainers;
      window.cacheVersion = "?" + "0.19.0";
      if (configuration.cacheVersion) {
        window.cacheVersion += configuration.cacheVersion;
      }
      initLocalStorage('stones');
      initLocalStorage('templates');
      initTemplatesMapper();
      initTemplates();
      logicRoot = stoneViews.viewersBaseUrl + "atomic/{version}/js/";
      jsons = stoneViews.viewersBaseUrl + "atomic/{version}/jsons/";
      jsonsAll = stoneViews.viewersBaseUrl + "atomic/bundle/all.json";
      allViewresList = stoneViews.viewers;
      viewers = [];
      this.bind = option.template ? loadTemplate : bindElementToSelector;
    }

    bindElementToSelector = function(selector) {
      var arrDefer, defer, _t;
      defer = $.Deferred();
      arrDefer = [];
      _t = this;
      document.viewersList = JSON.parse(JSON.stringify(allViewresList));
      $(selector).find(fromTag).each((function(_this) {
        return function(i, v) {
          var active, attr, coordinates, menu, order, toElement, type, _i, _len, _ref;
          toElement = $("<" + toTag + ">");
          type = $(v).attr("viewer");
          order = $(v).attr('order') || 99;
          _ref = v.attributes;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            attr = _ref[_i];
            toElement.data(attr.name, attr.value);
          }
          toElement.data({
            "type": $(v).attr("viewer"),
            "order": order,
            "version": $(v).attr("version")
          });
          toElement.attr({
            "id": "viewr_" + i,
            "order": order
          });
          if (type === "loupe3DFullInspection") {
            menu = $(v).attr('menu') || true;
            coordinates = $(v).attr('coordinates') || true;
            active = $(v).attr('active') || true;
            toElement.data({
              "menu": menu,
              "coordinates": coordinates,
              "active": active
            });
            toElement.attr({
              "menu": menu,
              "coordinates": coordinates,
              "active": active
            });
          }
          toElement.addClass("viewer " + type);
          $(v).replaceWith(toElement);
          return arrDefer.push(addViewer(type, toElement));
        };
      })(this));
      $(selector).find('*[data-sarine-info]').each((function(_this) {
        return function(i, v) {
          var $el;
          $el = $(v);
          return $el.text(findAttribute(stoneViews, $el.data('sarineInfo')));
        };
      })(this));
      $(selector).find('*[data-sarine-info-display]').each((function(_this) {
        return function(i, v) {
          var $el, item, key, mapObj;
          $el = $(v);
          key = findAttribute(stoneViews, $el.data('sarineInfoDisplay'));
          mapObj = findAttribute(gradeScales, $el.data('sarineInfoDisplay').replace('stoneProperties.', ''));
          if (mapObj && key) {
            item = mapObj.filter(function(v) {
              return v.name === key;
            })[0];
            if (item !== null && typeof item !== 'undefined') {
              return $el.text(item["default-display"]);
            }
          }
        };
      })(this));
      $(selector).find('*[data-sarine-report]').each((function(_this) {
        return function(i, v) {
          var $el, attr, date, format;
          $el = $(v);
          attr = $el.data('sarineReport');
          if (attr.indexOf('::') === -1) {
            return $el.text(findAttribute(report, attr));
          } else {
            date = findAttribute(report, attr.split('::')[0]);
            format = attr.split('::')[1];
            return $el.text(moment.utc(date).format(format));
          }
        };
      })(this));
      $.when.apply($, arrDefer).then(function() {
        return defer.resolve();
      });
      return defer;
    };

    recurse = function(o, props) {
      if (props.length === 0) {
        return o;
      }
      if (!o) {
        return void 0;
      }
      return recurse(o[props.shift()], props);
    };

    findAttribute = function(obj, ns) {
      return recurse(obj, ns.split('.'));
    };

    getTemplateMapperByConfigName = function(exp) {
      var ret, templateVersion;
      ret = {};
      if (configurationToTemplateMapper[exp.atom].infos) {
        ret.infos = configurationToTemplateMapper[exp.atom].infos;
      } else {
        ret.infos = [];
      }
      if (exp.atom === 'lightReportViewer') {
        if (exp.hasOwnProperty('templateVersion')) {
          ret.iconName = configurationToTemplateMapper[exp.atom].icon.templateVersion;
          templateVersion = parseInt(exp.templateVersion);
          if (templateVersion !== NaN) {
            ret.templateName = configurationToTemplateMapper.lightReportViewer.experience.templateVersion + templateVersion.toString();
          }
        } else if (exp.hasOwnProperty('page')) {
          ret.templateName = configurationToTemplateMapper[exp.atom].experience[exp.page];
          ret.iconName = configurationToTemplateMapper[exp.atom].icon[exp.page];
        }
      } else {
        ret.templateName = configurationToTemplateMapper[exp.atom].experience;
        ret.iconName = configurationToTemplateMapper[exp.atom].icon;
      }
      return ret;
    };

    getAllTemplates = function() {
      var icons, infos, infosIndex, templates;
      if (window.sarineViewerTemplates !== void 0) {
        templates = '';
        icons = '';
        infos = '';
        infosIndex = [];
        $.each(configuration.experiences, function(key, exp) {
          var templateMap;
          templateMap = getTemplateMapperByConfigName(exp);
          if (templateMap.templateName && templateMap.iconName) {
            if (sarineViewerTemplates[templateMap.templateName]) {
              templates += sarineViewerTemplates[templateMap.templateName];
              $.each(templateMap.infos, function(i, infoName) {
                if (sarineViewerTemplates[infoName]) {
                  if (!infosIndex[infoName]) {
                    infos += sarineViewerTemplates[infoName];
                    infosIndex[infoName] = true;
                  }
                }
              });
            }
            if (sarineViewerTemplates[templateMap.iconName]) {
              icons += sarineViewerTemplates[templateMap.iconName];
            }
          }
        });
        return {
          templates: templates,
          icons: icons,
          infoPopups: infos
        };
      }
      return null;
    };

    loadTemplate = function(selector) {
      return $(document).trigger("loadTemplate");
    };

    existInConfig = function(type) {
      return configuration.experiences && typeof configuration.experiences !== 'undefined' && configuration.experiences.filter(function(i) {
        return i.atom === type;
      }).length > 0;
    };

    addViewer = function(type, toElement) {
      var callbackPic, data, defer, path, s, src, url;
      defer = $.Deferred();
      data = void 0;
      callbackPic = void 0;
      $.ajaxSetup({
        async: false
      });
      if (jsonsAllObj === void 0) {
        $.getJSON(jsonsAll + window.cacheVersion, (function(_this) {
          return function(d) {
            jsonsAllObj = d;
            return data = d[toElement.data("version") || "v1"][type];
          };
        })(this));
        $.ajaxSetup({
          async: true
        });
      } else {
        data = jsonsAllObj[toElement.data("version") || "v1"][type];
      }
      callbackPic = data.callbackPic || jsons.replace("{version}", toElement.data("version") || "v1") + "no_stone.png";
      if (stoneViews.viewers[type] === null) {
        src = callbackPic.split("/");
        path = src.pop();
        stoneViews.viewers[type] = src.join("/") + "/";
        data.instance = "SarineImage";
        data.name = "sarine.viewer.image";
        data.args = {
          "imagesArr": [path]
        };
      }
      url = logicRoot.replace("{version}", toElement.data("version") || "v1") + data.name + (location.hash.indexOf("debug") === 1 ? ".bundle.js" : ".bundle.min.js") + window.cacheVersion;
      s = $("<script>", {
        type: "text/javascript"
      }).appendTo("body").end()[0];
      s.onload = function() {
        var inst;
        inst = eval(data.instance);
        viewers.push(new inst($.extend({
          src: stoneViews.viewers[type],
          element: toElement,
          callbackPic: callbackPic,
          stoneProperties: stoneViews.stoneProperties,
          baseUrl: stoneViews.viewersBaseUrl
        }, data.args)));
        return defer.resolve();
      };
      s.src = url;
      return defer;
    };

    ViewerManger.prototype.getViewers = function() {
      return viewers;
    };

    ViewerManger.prototype.sortByOrder = function(viewersArr) {
      var obj;
      obj = [];
      viewersArr.forEach(function(v) {
        var order;
        order = v.element.data('order');
        if (obj[order] === void 0) {
          obj[order] = [];
        }
        return obj[order].push(v);
      });
      return obj.filter(function(v) {
        return v;
      });
    };

    ViewerManger.prototype.init_list = function(list, method, defer) {
      var arr, current, pmId, v, _list, _method, _t;
      _t = this;
      _list = list;
      _method = method;
      defer = defer || $.Deferred();
      current = list.shift();
      arr = [];
      for (v in current) {
        pmId = current[v].id + "_" + current[v].element.data('type');
        $(document).trigger(_method + "_start", [
          {
            Id: pmId
          }
        ]);
        arr.push(current[v][_method]().then((function(pmId) {
          return function() {
            return $(document).trigger(_method + "_end", [
              {
                Id: pmId
              }
            ]);
          };
        })(pmId)));
      }
      $.when.apply($, arr).then(function() {
        if (_list.length === 0) {
          $(document).trigger("all_" + _method + "_ended");
          return defer.resolve();
        } else {
          return _t.init_list(_list, _method, defer);
        }
      });
      return defer;
    };

    ViewerManger.prototype.first_init = function() {
      var defer;
      defer = $.Deferred();
      this.init_list(this.sortByOrder(viewers), "first_init").then(defer.resolve);
      return defer;
    };

    ViewerManger.prototype.full_init = function() {
      var defer;
      defer = $.Deferred();
      this.init_list(this.sortByOrder(viewers), "full_init").then(defer.resolve);
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
