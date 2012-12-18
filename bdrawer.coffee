# BDrawer 0.1
# MIT Licensed
# By Anders Rex (andersrex.com)

class window.BDrawer

  constructor: (options) ->
    return null unless options.content and options.drawer

    # Get options
    @content = options.content
    @drawer = options.drawer
    @speed = options.speed or 200
    @overlap = options.overlap or 60
    @openable = options.openable or true
    @prevented = options.prevented or {y1: false, y2: false}
    @closed = options.closed or true
    @options = options or {}

    @width = @content.getBoundingClientRect().width

    # Set up CSS for content element
    style = @content.style
    style.display = 'block'
    style.position = 'fixed'
    style.left = '0px'
    style.top = '0px'
    style.zIndex = 1000
    style.width = @width + 'px'

    # Set up CSS for drawer element
    style = @drawer.style
    style.display = 'block'
    style.position = 'fixed'
    style.left = '0px'
    style.top = '0px'
    style.zIndex = 900
    style.width = @width + 'px'

    # Set up mask element
    @mask = document.createElement 'div'
    style = @mask.style
    style.position = 'absolute'
    style.display = 'block'
    style.width = '100%'
    style.height = '100%'
    style.left = 0
    style.top = '50px'
    style.zIndex = 1000
    style.visibility = 'hidden'
    style.opacity = 0
    style.background = 'black'
    @content.appendChild @mask

    # Bind events for content element
    @content.addEventListener 'touchstart', this, false
    @content.addEventListener 'touchmove', this, false
    @content.addEventListener 'touchend', this, false
    @mask.addEventListener 'click', this, false

  handleEvent: (e) ->
    switch e.type
      when "touchstart" then @_touchStart e
      when "touchmove" then @_touchMove e
      when "touchend" then @_touchEnd e
      when "click" then @close()

  open: () ->
    @_move @width - @overlap, @speed
    @_showMask()
    @closed = false

  close: () ->
    @_move 0, @speed
    @_hideMask()
    @closed = true

  toggle: () ->
    if @closed
      @open()
    else
      @close()

  _showMask: ->
    @mask.style.visibility = 'visible'

  _hideMask: ->
    @mask.style.visibility = 'hidden'

  # Move the content element delta x (dx) with speed (speed)
  _move: (dx, speed) ->
    if @openable
      style = @content.style
      style.webkitTransitionDuration = speed + 'ms'
      style.webkitTransform = 'translate3d(' + dx + 'px, 0, 0)'

  _touchStart: (e) ->
    @_x = e.touches[0].pageX
    @_y = e.touches[0].pageY
    @_t = Number( new Date() )
    @_dx = 0

    # For checking for Y axis scrolling
    @_scrolling = null

  _touchMove: (e) ->
    # Check if touch is prevented
    if @_touchPrevented() and @closed
      return

    # Check for other gestures than swipe
    if e.touches.length > 1
      return

    # Delta X and delta Y
    @_dx = e.touches[0].pageX - @_x
    dy = e.touches[0].pageY - @_y

    # If first delta y is twice bigger that delta x we are scrolling
    if @_scrolling is null
      @_scrolling = Math.abs(dy) > Math.abs(@_dx)

    unless @_scrolling
      if @closed and @openable
        @_dx = 0 if @_dx < 0
        @_move @_dx, 0
      else
        @_dx = 0 if @_dx > 0
        @_dx = -@width+@overlap if @_dx+@width-@overlap < 0
        @_move @_dx+@width-@overlap, 0

  _touchEnd: (e) ->
    if @_touchPrevented() or @_scrolling or @_dx is 0
      return

    dt = Number(new Date()) - @_t

    # Check if swipe is enough to close or open drawer
    validSwipe = (dt < 200 or
      Math.abs(@_dx) > (@width-@overlap)/2) or
      (Math.abs(@_dx) > 20 and dt < 150)

    if validSwipe and not @_scrolling
      if @_dx > 0
        @open()
      else
        @close()
    else
      if @_dx > 0
        @close()
      else
        @open()

  _touchPrevented: ->
    y1 = @prevented.y1
    y2 = @prevented.y2

    if y1 is false or @_y < y1 or y2 is false or @_y > y2
      return false
    else
      return true
