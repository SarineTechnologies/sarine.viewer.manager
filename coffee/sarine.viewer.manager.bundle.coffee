###!
sarine.viewer.manager - v0.11.0 -  Monday, February 8th, 2016, 5:44:11 PM 
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
	bind : Error
	getPath = (src)=>
		arr = src.split("/") 
		arr.pop() 
		arr.join("/")

	constructor: (option) ->
		{fromTag, toTag, stoneViews,template,jsons,logicRoot} = option
		window.cacheVersion = "?" +  "0.11.0"
		if configuration.cacheVersion
			window.cacheVersion += configuration.cacheVersion
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
				menu = $(v).attr('menu') || true
				coordinates = $(v).attr('coordinates') || true
				active = $(v).attr('active') || true

				toElement.data({"menu" : menu, "coordinates" : coordinates, "active" : active})   
				toElement.attr({"menu" : menu, "coordinates" : coordinates, "active" : active}) 				

			toElement.addClass("viewer " + type)			

			$(v).replaceWith(toElement)
			arrDefer.push addViewer(type,toElement)
		)
		$(selector).find('*[data-sarine-info]').each( (i,v) => 
			$el = $(v)
			$el.text findAttribute(stoneViews, $el.data('sarineInfo'))					
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

	loadTemplate = (selector) -> 
		defer = $.Deferred()
		deferArr = []
		scripts = []
		$("<div>").load(template + window.cacheVersion,(a,b,c)-> 
			$(selector).prepend($(a).filter( (i,v)=> 
				if(v.tagName == "SCRIPT" )
					if(v.src)
						deferArr.push $.Deferred()
						v.src = v.src.replace getPath(location.origin + location.pathname),getPath(template)
						$.getScript v.src, ()=>
							deferArr.pop()
							if deferArr.length == 0
								$(selector).append scripts
								bindElementToSelector(selector).then(()=>defer.resolve())
					else
						scripts.push v
					$(v).remove();
					return false
				if(v.tagName == "LINK" && v.href)
					v.href = v.href.replace getPath(location.origin + location.pathname),getPath(template)
				true
				));
			if deferArr.length == 0
				bindElementToSelector(selector).then(defer.resolve)
		)
		defer.then ()-> $(document).trigger("loadTemplate")

	existInConfig = (type)->			
		return typeof configuration.experiences != 'undefined' && configuration.experiences.filter((i)-> return i.atom == type).length > 0		

	addViewer = (type,toElement)->
		defer = $.Deferred()
		data = undefined
		callbackPic = undefined
		$.ajaxSetup(
			async : false
		);


		if typeof configuration.experiences != 'undefined' && !existInConfig(type)
			return
		
		###$.getJSON jsons.replace("{version}",toElement.data("version") || "v1") + type + ".json" + window.cacheVersion ,(d)=>
			data = d;###
		if (jsonsAllObj == undefined)
			$.getJSON jsonsAll + window.cacheVersion ,(d)=>
				jsonsAllObj = d
				data = d[toElement.data("version") || "v1"][type]
			$.ajaxSetup(
				async : true
			); 
		else
			data = jsonsAllObj[toElement.data("version") || "v1"][type]
			
		callbackPic = (data.callbackPic || jsons.replace("{version}", toElement.data("version") || "v1") + "no_stone.png")
		if stoneViews.viewers[type] == null
			src = callbackPic.split("/")
			path = src.pop(); 
			stoneViews.viewers[type] =src.join("/") + "/"
			data.instance = "SarineImage"
			data.name = "sarine.viewer.image"
			data.args = {"imagesArr" : [path]} 
		url = logicRoot.replace("{version}", toElement.data("version") || "v1") + data.name + (if location.hash.indexOf("debug") == 1 then ".bundle.js" else ".bundle.min.js") + window.cacheVersion
		# $.getScript(url,()->
		# 	inst = eval(data.instance)
		# 	viewers.push new inst $.extend({src : stoneViews.viewers[type],element: toElement},data.args)
		# 	defer.resolve()
		# )
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
				defer.resolve();  
			else
				_t.init_list(_list,_method,defer)
		)				
		defer
		
	first_init : ()-> 
		defer = $.Deferred()		 
		@init_list(@sortByOrder(viewers),"first_init").then(defer.resolve)
		defer

	full_init : ()->
		defer = $.Deferred()
		@init_list(@sortByOrder(viewers),"full_init").then(defer.resolve)
		# viewers.forEach (v)->
		# 	pmId = v.id + "_" + v.element.data('type')			
		# 	$(document).trigger("full_init_start",[{Id : pmId}])
		# 	v.full_init().then((v)-> 
		# 		$(document).trigger("full_init_end",[{Id : pmId}])
		# 	)
		# $.when.apply($,viewers.map((v)-> v.full_init_defer)).done(defer.resolve)
		defer
	stop : ()->
		viewers.forEach((v)-> v.stop())
	play : ()->
		viewers.forEach((v)-> v.play(true))
@ViewerManger = ViewerManger


