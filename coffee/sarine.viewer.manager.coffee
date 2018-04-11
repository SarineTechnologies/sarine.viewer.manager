###!
sarine.viewer.manager - v0.21.0 -  Tuesday, April 10th, 2018, 6:16:30 PM 
 The source code, name, and look and feel of the software are Copyright © 2015 Sarine Technologies Ltd. All Rights Reserved. You may not duplicate, copy, reuse, sell or otherwise exploit any portion of the code, content or visual design elements without express written permission from Sarine Technologies Ltd. The terms and conditions of the sarine.com website (http://sarine.com/terms-and-conditions/) apply to the access and use of this software.

###
class ViewerManger
	viewers  = []
	stoneViews = undefined
	fromTag  = undefined
	toTag = undefined
	stoneViews = undefined
	template  = undefined
	jsons  = undefined
	jsonsAll = undefined
	jsonsAllObj = undefined
	logicRoot  = undefined
	logicPath  = undefined
	allViewresList = undefined
	configurationToTemplateMapper = undefined
	popupInfoMapper = undefined
	experiencesList = undefined
	iconsList = undefined
	infoPopupsList = undefined
	templateContainers = undefined
	bind : Error
	getTemplateLists = () =>
		return {
			experiencesList: experiencesList,
			iconsList: iconsList,
			infoPopupsList: infoPopupsList
		}

	getPath = (src)=>
		arr = src.split("/")
		arr.pop()
		arr.join("/")
	initLocalStorage = (type)->
		if typeof(Storage) != "undefined"
			if localStorage.getItem(type) == null
				localStorage.setItem(type, "[]")

	initTemplates = ()->
		allTemplates = getAllTemplates()
		if(allTemplates)
			experiencesList = allTemplates.templates
			iconsList = allTemplates.icons
			infoPopupsList = allTemplates.infoPopups
		return

	initTemplatesMapper = ()->
		configurationToTemplateMapper = null
		if window.sarineViewerTemplatesMapping && sarineViewerTemplatesMapping.mapper
      configurationToTemplateMapper = sarineViewerTemplatesMapping.mapper.getMapper()

		return

	constructor: (option) ->
		{fromTag, toTag, stoneViews,template,jsons,logicRoot, templateContainers} = option
		window.cacheVersion = "?" +  "__VERSION__"
		if configuration.cacheVersion
			window.cacheVersion += configuration.cacheVersion
		initLocalStorage('stones')
		initLocalStorage('templates')
		initTemplatesMapper()
		initTemplates()
		logicRoot = stoneViews.viewersBaseUrl + "atomic/{version}/js/"
		jsons = stoneViews.viewersBaseUrl + "atomic/{version}/jsons/"
		jsonsAll = 	stoneViews.viewersBaseUrl + "atomic/bundle/all.json"
		allViewresList = stoneViews.viewers
		viewers = []
		@bind = if option.template then loadTemplate else bindElementToSelector
	bindElementToSelector = (selector)->
		defer = $.Deferred()
		arrDefer = []
		_t = @
		document.viewersList = JSON.parse(JSON.stringify(allViewresList))
		$(selector).find(fromTag).each((i, v) =>

			toElement = $ "<#{toTag}>"
			type = $(v).attr("viewer")
			order = $(v).attr('order') || 99

			for attr in v.attributes
				toElement.data(attr.name,attr.value);

			toElement.data({"type": $(v).attr("viewer"), "order": order, "version": $(v).attr("version")})
			toElement.attr({"id" : "viewr_#{i}", "order" : order})


			if(type == "loupe3DFullInspection")
				coordinates = $(v).attr('coordinates') || true
				active = $(v).attr('active') || true

				toElement.data({"coordinates" : coordinates, "active" : active})
				toElement.attr({"coordinates" : coordinates, "active" : active})

			if(type == "externalPdf")	
				popup = $(v).attr('mode') || "target"
				toElement.data({"mode" : popup})
				toElement.attr({"mode" : popup})

			toElement.addClass("viewer " + type)

			$(v).replaceWith(toElement)
			arrDefer.push addViewer(type,toElement)
		)
		$(selector).find('*:not(.summary__spec__value,.props-unit__value)[data-sarine-info]').each( (i,v) =>
			$el = $(v)
			$el.text findAttribute(stoneViews, $el.data('sarineInfo'))
		)
		$(selector).find('*:not(.summary__spec__value,.summary__spec__title,.props-unit__value)[data-sarine-info-display]').each( (i,v) =>
			$el = $(v)
			key = findAttribute(stoneViews, $el.data('sarineInfoDisplay'))
			mapObj = findAttribute(gradeScales, $el.data('sarineInfoDisplay').replace('stoneProperties.',''))
			if(mapObj && key)
				item = mapObj.filter((v)-> return v.name == key)[0] 			
				if(item != null && typeof item != 'undefined' && !$el.hasClass('props-unit__value'))
					$el.text item["default-display"]
		)
		$(selector).find('*[data-sarine-report]').each( (i,v) =>
			$el = $(v)
			attr = $el.data('sarineReport')
			if attr.indexOf('::') == -1
				$el.text findAttribute(report, attr)
			else
				date = findAttribute(report, attr.split('::')[0])
				format = attr.split('::')[1]
				$el.text moment.utc(date).format(format)
		) 
		$.when.apply($,arrDefer).then(()->defer.resolve())
		defer

	recurse = (o, props) ->
		if props.length == 0
			return o
		if !o
			return undefined
		return recurse(o[props.shift()], props)

	findAttribute = (obj, ns) ->
		return recurse(obj, ns.split('.'))

	getTemplateMapperByConfigName = (exp)->
		ret = {}
		if(configurationToTemplateMapper[exp.atom].infos)
			ret.infos = configurationToTemplateMapper[exp.atom].infos
		else
			ret.infos = []
		if(exp.atom == 'lightReportViewer')
			if exp.hasOwnProperty('templateVersion')
				ret.iconName = configurationToTemplateMapper[exp.atom].icon.templateVersion
				templateVersion = parseInt(exp.templateVersion)
				if templateVersion != NaN
					ret.templateName = configurationToTemplateMapper.lightReportViewer.experience.templateVersion + templateVersion.toString()
			else if exp.hasOwnProperty('page')
				ret.templateName = configurationToTemplateMapper[exp.atom].experience[exp.page]
				ret.iconName = configurationToTemplateMapper[exp.atom].icon[exp.page]
		else
			ret.templateName = configurationToTemplateMapper[exp.atom].experience
			ret.iconName = configurationToTemplateMapper[exp.atom].icon
		return ret;

	getAllTemplates = () ->
		if(window.sarineViewerTemplates != undefined)
			templates = ''
			icons = ''
			infos = ''
			infosIndex = []
			$.each configuration.experiences, (key, exp) ->
				templateMap = getTemplateMapperByConfigName exp
				if(templateMap.templateName && templateMap.iconName)
					if(sarineViewerTemplates[templateMap.templateName])
						templates += sarineViewerTemplates[templateMap.templateName]
						$.each templateMap.infos, (i, infoName) ->
							if(sarineViewerTemplates[infoName])
								if(!infosIndex[infoName])
									infos += sarineViewerTemplates[infoName]
									infosIndex[infoName] = true
							return
					if(sarineViewerTemplates[templateMap.iconName])
						icons += sarineViewerTemplates[templateMap.iconName]
				return
			return {
			templates: templates
			icons: icons
			infoPopups: infos
			}
		return null

	loadTemplate = (selector) ->
		$(document).trigger("loadTemplate")
		
	#existInConfig = (type)->
	#	return configuration.experiences && typeof configuration.experiences != 'undefined' && configuration.experiences.filter((i)-> return i.atom == type).length > 0

	addViewer = (type,toElement)->
		defer = $.Deferred()
		data = undefined
		callbackPic = undefined
		
		$.ajaxSetup(
			async : false
		);


		#if configuration.experiences && typeof configuration.experiences != 'undefined' && !existInConfig(type)
		#	return

		if (atomsConfiguration?)
			data = atomsConfiguration[toElement.data("version") || "v1"][type]
		else #fallback !!! if atoms configuration does not exist - take from s3
			$.getJSON jsonsAll + window.cacheVersion ,(jsondata)=>
				atomsConfiguration = jsondata
				data = jsondata[toElement.data("version") || "v1"][type]
			$.ajaxSetup(
				async : true
			);

		callbackPic = (data.callbackPic || jsons.replace("{version}", toElement.data("version") || "v1") + "no_stone.png")
		if stoneViews.viewers[type] == null
			src = callbackPic.split("/")
			path = src.pop();
			stoneViews.viewers[type] =src.join("/") + "/"
			data.instance = "SarineImage"
			data.name = "sarine.viewer.image"
			data.args = {"imagesArr" : [path]}
		
		# Get from the atoms config object the version of the current atom.
		atomVersion = "?" + data["version"]

		url = logicRoot.replace("{version}", toElement.data("version") || "v1") + data.name + (if location.hash.indexOf("debug") == 1 then ".bundle.js" else ".bundle.min.js") + atomVersion

		s = $("<script>",{type:"text/javascript"}).appendTo("body").end()[0]
		s.onload = ()->
			inst = eval(data.instance)
			viewers.push new inst $.extend({
				src : stoneViews.viewers[type],
				element: toElement,
				callbackPic : callbackPic,
				stoneProperties : stoneViews.stoneProperties,
				baseUrl :  stoneViews.viewersBaseUrl
			},data.args)
			defer.resolve()
		s.src = url

		defer

	getViewers : ()-> viewers

	sortByOrder : (viewersArr) ->
		obj = []
		viewersArr.forEach (v) ->
			order = v.element.data('order')
			if obj[order] == undefined
				obj[order] = []
			obj[order].push(v)
		obj.filter((v)-> return v)

	init_list : (list,method,defer) ->
		_t = @
		_list = list
		_method = method
		defer = defer || $.Deferred()
		current = list.shift()
		arr = []
		for v of current
			pmId = current[v].id + "_" + current[v].element.data('type')
			$(document).trigger(_method + "_start",[{Id : pmId}])
			arr.push current[v][_method]().then do(pmId) -> -> $(document).trigger(_method + "_end",[{Id : pmId}])
		$.when.apply($,arr).then(()->
			if _list.length == 0
				$(document).trigger("all_" + _method + "_ended")
				defer.resolve();
			else
				_t.init_list(_list,_method,defer)
		)
		defer

	first_init : ()->
		defer = $.Deferred()
		@init_list(@sortByOrder(viewers),"first_init").then(
			defer.resolve
		)
		defer

	full_init : ()->
		defer = $.Deferred()
		@init_list(@sortByOrder(viewers),"full_init").then(defer.resolve)
		defer
	stop : ()->
		viewers.forEach((v)-> v.stop())
	play : ()->
		viewers.forEach((v)-> v.play(true))
@ViewerManger = ViewerManger
