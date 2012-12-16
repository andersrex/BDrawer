class window.BDrawer

  constructor: (options) ->

    return null unless options.content and options.drawer

    # Get options
    @content = options.content
    @drawer = options.drawer
    @speed = options.speed or 300
    @overlap = options.overlap or 60
    @options = options or {}
    @closed = 1

    # @TODO: hide container

    # Get parent element width
    @width = @content.parentNode.getBoundingClientRect().width

    # Set up CSS for content element
    style = @content.style
    style.display = 'block';
    style.position = 'fixed';
    style.left = '0px';
    style.top = '0px';
    style.zIndex = '1';
    style.width = @width

    # Set up CSS for drawer element
    style = @drawer.style
    style.display = 'block';
    style.position = 'fixed';
    style.left = '0px';
    style.top = '0px';
    style.zIndex = '-1';
    style.width = @width

    # Bind events
    @content.addEventListener('webkitTransitionEnd', @, false)
    @content.addEventListener('touchstart', this, false);
    @content.addEventListener('touchmove', this, false);
    @content.addEventListener('touchend', this, false);

    # @TODO: show container

    @close(0)

  # Move the content delta x (dx) with speed (speed)
  move: (dx, speed) ->
    style = @content.style
    style.webkitTransitionDuration = speed + 'ms';
    style.webkitTransform = 'translate3d(' + dx + 'px, 0, 0)';

  open: () ->
    @move @width - @overlap, @speed

    @closed = 0

  close: () ->
    @move 0, @speed

    @closed = 1

  toggle: () ->

    if @closed
      @open @speed

    else
      @close @speed

  touchStart: (e) ->

    @x = e.touches[0].pageX
    @y = e.touches[0].pageY
    @start = Number( new Date() )

  touchMove: (e) ->

    if e.touches.length > 1 or e.scale && e.scale isnt 1
      return
      e.preventDefault();

    # Calculate delta x
    @dx = e.touches[0].pageX - @x;

    # @TODO: Scrolling test
    console.log @dx

    if @closed
      @dx = 0 if @dx < 0
      @move @dx, 0
    else
      @dx = 0 if @dx > 0
      @move @dx+@width-@overlap, 0

    e.stopPropagation()

  touchEnd: (e) ->
    # or Math.abs(@dx) > 20
    if (Number(new Date()) - @start < 250 or Math.abs(@dx) > (@width-@overlap)/2) and @dx > 0
      @move @width-@overlap, 200
      @closed = 0
    else
      @move 0, 200
      @closed = 1

    e.stopPropagation()

  handleEvent: (e) ->
    # Event handler

    if e.type is 'touchstart'
      @touchStart e

    else if e.type is 'touchmove'
      @touchMove e

    else if e.type is 'touchend'
      @touchEnd e
