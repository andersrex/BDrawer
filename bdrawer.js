// Generated by CoffeeScript 1.4.0
(function() {

  window.BDrawer = (function() {

    function BDrawer(options) {
      var style;
      if (!(options.content && options.drawer)) {
        return null;
      }
      this.content = options.content;
      this.drawer = options.drawer;
      this.speed = options.speed || 300;
      this.overlap = options.overlap || 60;
      this.options = options || {};
      this.closed = true;
      this.width = this.content.parentNode.getBoundingClientRect().width;
      style = this.content.style;
      style.display = 'block';
      style.position = 'fixed';
      style.left = '0px';
      style.top = '0px';
      style.zIndex = '1000';
      style.width = this.width + 'px';
      style = this.drawer.style;
      style.display = 'block';
      style.position = 'fixed';
      style.left = '0px';
      style.top = '0px';
      style.zIndex = '900';
      style.width = this.width + 'px';
      this.content.addEventListener('webkitTransitionEnd', this, false);
      this.content.addEventListener('touchstart', this, false);
      this.content.addEventListener('touchmove', this, false);
      this.content.addEventListener('touchend', this, false);
    }

    BDrawer.prototype.move = function(dx, speed) {
      var style;
      style = this.content.style;
      style.webkitTransitionDuration = speed + 'ms';
      return style.webkitTransform = 'translate3d(' + dx + 'px, 0, 0)';
    };

    BDrawer.prototype.open = function() {
      this.move(this.width - this.overlap, this.speed);
      return this.closed = false;
    };

    BDrawer.prototype.close = function() {
      this.move(0, this.speed);
      return this.closed = true;
    };

    BDrawer.prototype.toggle = function() {
      if (this.closed) {
        return this.open();
      } else {
        return this.close();
      }
    };

    BDrawer.prototype.handleEvent = function(e) {
      if (e.type === 'touchstart') {
        return this.touchStart(e);
      } else if (e.type === 'touchmove') {
        return this.touchMove(e);
      } else if (e.type === 'touchend') {
        return this.touchEnd(e);
      }
    };

    BDrawer.prototype.touchStart = function(e) {
      this.x = e.touches[0].pageX;
      this.y = e.touches[0].pageY;
      return this.start = Number(new Date());
    };

    BDrawer.prototype.touchMove = function(e) {
      if (e.touches.length > 1 || e.scale && e.scale !== 1) {
        return;
        e.preventDefault();
      }
      this.dx = e.touches[0].pageX - this.x;
      if (this.closed) {
        if (this.dx < 0) {
          this.dx = 0;
        }
        this.move(this.dx, 0);
      } else {
        if (this.dx > 0) {
          this.dx = 0;
        }
        this.move(this.dx + this.width - this.overlap, 0);
      }
      return e.stopPropagation();
    };

    BDrawer.prototype.touchEnd = function(e) {
      if ((Number(new Date()) - this.start < 200 || Math.abs(this.dx) > (this.width - this.overlap) / 2) && this.dx > 0) {
        this.move(this.width - this.overlap, 200);
        this.closed = false;
      } else {
        this.move(0, 200);
        this.closed = true;
      }
      return e.stopPropagation();
    };

    return BDrawer;

  })();

}).call(this);