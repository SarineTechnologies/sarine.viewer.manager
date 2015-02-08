class ViewerManger
	viewers  = []
	stoneViews = undefined
	fromTag  = undefined 
	toTag = undefined 
	stoneViews = undefined 
	template  = undefined
	bind : Error
	constructor: (option) ->
		{fromTag, toTag, stoneViews,template} = option
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
			
			$(@).find("script").each (i,v)=> 
				if v.src
					deferArr.push($.Deferred())
					$.ajax(
						url : v.src
						dataType : "script",
						async : false ,
						success : ()->deferArr.pop().resolve()
						)
				else
					$("<script type='text/javascript'></script>").text(v.innerText).appendTo(selector)
				v.remove()
			$(selector).prepend($(@).children())
			$.when.apply($,deferArr).done(()->
				bindElementToSelector(selector).then(defer.resolve))
			)
		defer.then ()-> $(document).trigger("loadTemplate")

	addViewer = (type,toElement)->
		switch type
			when "realview"
				viewers.push new Viewer.Dynamic.Sprite({
					src : stoneViews[type]
					element: toElement
					jsonFileName : "/Jsons/iview.json"
					firstImagePath : "/Images/Eyeview/img0.jpg"
					spritesPath : "/EyeViewSprites/sprite"
					oneSprite : true
					autoPlay : true
				})
			when "topinspection"
				viewers.push new Viewer.Dynamic.Sprite({
					src : stoneViews[type]
					element: toElement
					jsonFileName : "/Jsons/impression.json"
					firstImagePath : "/Images/Impression/img0.jpg"
					spritesPath : "/ImpressionSprites/sprite_"
					oneSprite : false
				})
			when "light"
				viewers.push new Light({
					src : stoneViews[type]
					element: toElement
				})
			else
				console.error type , 'not define!'
				return false
		true

	getViewers : ()-> viewers

	first_init : ()->
		defer = $.Deferred()
		$.when.apply($,viewers.map((v)-> v.first_init())).done(defer.resolve)
		defer
	full_init : ()->
		defer = $.Deferred()
		$.when.apply($,viewers.map((v)-> v.full_init())).done(defer.resolve)
		defer
	stop : ()->
		viewers.forEach((v)-> v.stop())
	play : ()->
		viewers.forEach((v)-> v.play(true))
@ViewerManger = ViewerManger
