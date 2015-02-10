class ViewerManger
	viewers  = []
	stoneViews = undefined
	fromTag  = undefined 
	toTag = undefined 
	stoneViews = undefined 
	template  = undefined
	jsons  = undefined
	logicRoot  = undefined
	logicPath  = undefined
	bind : Error
	getPath = (src)=>
		arr = src.split("/")
		arr.pop()
		arr.join("/")

	constructor: (option) ->
		{fromTag, toTag, stoneViews,template,jsons,logicRoot} = option
		logicRoot = stoneViews.viewersBaseUrl + "{version}/js/"
		jsons = stoneViews.viewersBaseUrl + "{version}/jsons/"
		viewers = []
		@bind = if option.template then loadTemplate else bindElementToSelector
	bindElementToSelector = (selector)-> 
		defer = $.Deferred()
		arrDefer = []
		$(selector).find(fromTag).each((i, v) =>
			toElement = $ "<#{toTag}>"
			type = $(v).attr("viewer") ;
			toElement.data("type", type)
			toElement.data("version", $(v).attr("version"))
			toElement.addClass("viewer " + type)
			toElement.attr("id","viewr_#{i}")
			$(v).replaceWith(toElement)
			arrDefer.push addViewer(type,toElement)
		)
		$.when.apply($,arrDefer).then(()->defer.resolve())
		defer
	loadTemplate = (selector) -> 
		defer = $.Deferred()
		deferArr = []
		$("<div>").load(template,(a,b,c)-> 
			$(selector).prepend($(a).each( (i,v)=> 
				if(v.tagName == "SCRIPT" && v.src)
					deferArr.push $.Deferred()
					v.src = v.src.replace getPath(location.origin + location.pathname),getPath(template)
					$.getScript v.src, ()=>
						deferArr.pop()
						if deferArr.length == 0
							bindElementToSelector(selector).then(()=>defer.resolve())

					$(v).remove();
				if(v.tagName == "LINK" && v.href)
					v.href = v.href.replace getPath(location.origin + location.pathname),getPath(template)
				));
			if deferArr.length == 0
				bindElementToSelector(selector).then(defer.resolve)
		)
		defer.then ()-> $(document).trigger("loadTemplate")

	addViewer = (type,toElement)->
		defer = $.Deferred()
		data = undefined
		$.ajaxSetup(
			async : false
		);
		$.getJSON jsons.replace("{version}",toElement.data("version") || "v1") + type + ".json",(d)=>
			data = d;
		$.ajaxSetup(
			async : true
		);
		$.getScript(logicRoot.replace("{version}", toElement.data("version") || "v1") + data.name + (if location.hash.indexOf("debug") == 1 then ".bundle.js" else ".bundle.min.js"),()->
			inst = eval(data.instance)
			viewers.push new inst $.extend({src : stoneViews.viewers[type],element: toElement},data.args)
			defer.resolve()
		)
		defer

	getViewers : ()-> viewers

	first_init : ()->
		defer = $.Deferred()
		viewers.forEach (v)-> v.first_init()
		$.when(viewers.map((v)-> v.first_init_defer)).done(defer.resolve)
		defer
	full_init : ()->
		defer = $.Deferred()
		viewers.forEach (v)-> v.full_init()
		$.when.apply($,viewers.map((v)-> v.full_init_defer)).done(defer.resolve)
		defer
	stop : ()->
		viewers.forEach((v)-> v.stop())
	play : ()->
		viewers.forEach((v)-> v.play(true))
@ViewerManger = ViewerManger
