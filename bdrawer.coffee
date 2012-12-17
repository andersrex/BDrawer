# BDrawer 0.1
# MIT Licensed
# By Anders Rex (andersrex.com)

class window.BDrawer

  constructor: (options) ->
    return null unless options.content and options.drawer

    # Get options
    @content = options.content
    @drawer = options.drawer
    @speed = options.speed or 300
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
    @_start = Number( new Date() )
    @_dx = 0

  _touchMove: (e) ->

    # Check for other gestures than swipe
    if e.touches.length > 1 or e.scale && e.scale isnt 1
      return

    # Calculate delta x
    @_dx = e.touches[0].pageX - @_x
    if @closed
      if @openable
        unless @_touchPrevented()
          @_dx = 0 if @_dx < 0
          @_move @_dx, 0
    else
      @_dx = 0 if @_dx > 0
      @_dx = -@width+@overlap if @_dx+@width-@overlap < 0
      @_move @_dx+@width-@overlap, 0

  _touchEnd: (e) ->
    if @_touchPrevented()
      return

    # Tap if there is no delta x
    if @_dx == 0
      return

    # Check if swipe is enough to close or open drawer
    # @TODO: Check for short and fast swipe
    validSwipe = (Number(new Date()) - @start < 200 or
                Math.abs(@_dx) > (@width-@overlap)/2)

    if validSwipe
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
