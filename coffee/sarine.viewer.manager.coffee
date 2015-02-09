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
		{fromTag, toTag, stoneViews,template,jsons,logicRoot,logicPath} = option
		viewers = []
		@bind = if option.template then loadTemplate else bindElementToSelector
	bindElementToSelector = (selector)->
		defer = $.Deferred()
		$(selector).find(fromTag).each((i, v) =>
			toElement = $ "<#{toTag}>"
			type = $(v).attr("viewer") ;
			toElement.data("type", type)
			toElement.addClass("viewer " + type)
			toElement.attr("id","viewr_#{i}")
			$(v).replaceWith(toElement)
			addViewer(type,toElement)
			defer.resolve()
		)
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
		data = undefined
		$.ajaxSetup(
			async : false
		);
		$.getJSON jsons+type + ".json",(d)=>
			data = d;
		$.getScript logicRoot + logicPath.replace(/\{name\}/g, data.name)
		$.ajaxSetup(
			async : false
		);
		inst = eval(data.instance)
		viewers.push new inst $.extend({src : stoneViews[type],element: toElement},data.args)
		# switch type
		# 	when "realview"
		# 		viewers.push new Viewer.Dynamic.Sprite({
		# 			src : stoneViews[type]
		# 			element: toElement
		# 			jsonFileName : "/Jsons/iview.json"
		# 			firstImagePath : "/Images/Eyeview/img0.jpg"
		# 			spritesPath : "/EyeViewSprites/sprite"
		# 			oneSprite : true
		# 			autoPlay : true
		# 		})
		# 	when "topinspection"
		# 		viewers.push new Viewer.Dynamic.Sprite({
		# 			src : stoneViews[type]
		# 			element: toElement
		# 			jsonFileName : "/Jsons/impression.json"
		# 			firstImagePath : "/Images/Impression/img0.jpg"
		# 			spritesPath : "/ImpressionSprites/sprite_"
		# 			oneSprite : false
		# 		})
		# 	when "light"
		# 		viewers.push new Viewer.Dynamic.Light({
		# 			src : stoneViews[type]
		# 			element: toElement
		# 		})
		# 	else
		# 		console.error type , 'not define!'
		# 		return false
		true

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
