scatterplot3d_edit <- function (x, y = NULL, z = NULL, color = par("col"), pch = NULL, fill = NULL,
                          main = NULL, sub = NULL, xlim = NULL, ylim = NULL, zlim = NULL,
                          xlab = NULL, ylab = NULL, zlab = NULL, scale.y = 1, angle = 40,
                          axis = TRUE, tick.marks = TRUE, label.tick.marks = TRUE,
                          x.ticklabs = NULL, y.ticklabs = NULL, z.ticklabs = NULL,
                          n.breaks.x = NULL, n.breaks.y = NULL, n.breaks.z = NULL,
                          x.pretty = TRUE, y.pretty = TRUE, z.pretty = TRUE,
                          x.sig = NULL, y.sig = NULL, z.sig = NULL,
                          y.margin.add = 0, grid = TRUE, box = TRUE, lab = par("lab"),
                          labs.line.x = -0.5, labs.adj.y = 0, labs.line.z = -1,
                          lab.z = mean(lab[1:2]), type = "p", highlight.3d = FALSE,
                          mar = c(5, 3, 4, 3) + 0.1, bg = par("bg"), col.axis = par("col.axis"),
                          col.grid = "grey", col.lab = par("col.lab"), cex.symbols = par("cex"),
                          cex.axis = 0.8 * par("cex.axis"), cex.lab = par("cex.lab"),
                          font.axis = par("font.axis"), font.lab = par("font.lab"),
                          lty.axis = par("lty"), lty.grid = par("lty"), lty.grid.xy = par("lty"),
                          lty.grid.xz = par("lty"), lty.grid.yz = par("lty"), lty.hide = NULL,
                          lwd.grid.xy = par("lwd"), lwd.grid.xz = par("lwd"), lwd.grid.yz = par("lwd"),
                          lty.hplot = par("lty"), log = "", ...)
{
  mem.par <- par(mar = mar)
  x.scal <- y.scal <- z.scal <- 1
  xlabel <- if (!missing(x))
    deparse(substitute(x))
  ylabel <- if (!missing(y))
    deparse(substitute(y))
  zlabel <- if (!missing(z))
    deparse(substitute(z))
  if (highlight.3d && !missing(color))
    warning("color is ignored when highlight.3d = TRUE")
  if (!is.null(d <- dim(x)) && (length(d) == 2) && (d[2] >= 4))
    color <- x[, 4]
  else if (is.list(x) && !is.null(x$color))
    color <- x$color
  xyz <- xyz.coords(x = x, y = y, z = z, xlab = xlabel, ylab = ylabel,
                    zlab = zlabel, log = log)
  if (is.null(xlab)) {
    xlab <- xyz$xlab
    if (is.null(xlab))
      xlab <- ""
  }
  if (is.null(ylab)) {
    ylab <- xyz$ylab
    if (is.null(ylab))
      ylab <- ""
  }
  if (is.null(zlab)) {
    zlab <- xyz$zlab
    if (is.null(zlab))
      zlab <- ""
  }
  if (length(color) == 1)
    color <- rep(color, length(xyz$x))
  else if (length(color) != length(xyz$x))
    stop("length(color) ", "must be equal length(x) or 1")
  angle <- (angle%%360)/90
  yz.f <- scale.y * abs(if (angle < 1) angle else if (angle >
                                                        3) angle - 4 else 2 - angle)
  yx.f <- scale.y * (if (angle < 2)
    1 - angle
    else angle - 3)
  if (angle > 2) {
    temp <- xyz$x
    xyz$x <- xyz$y
    xyz$y <- temp
    temp <- xlab
    xlab <- ylab
    ylab <- temp
    temp <- xlim
    xlim <- ylim
    ylim <- temp
  }
  angle.1 <- (1 < angle && angle < 2) || angle > 3
  angle.2 <- 1 <= angle && angle <= 3
  dat <- cbind(as.data.frame(xyz[c("x", "y", "z")]), col = color)
  if (!is.null(xlim)) {
    xlim <- range(xlim)
    dat <- dat[xlim[1] <= dat$x & dat$x <= xlim[2], , drop = FALSE]
  }
  if (!is.null(ylim)) {
    ylim <- range(ylim)
    dat <- dat[ylim[1] <= dat$y & dat$y <= ylim[2], , drop = FALSE]
  }
  if (!is.null(zlim)) {
    zlim <- range(zlim)
    dat <- dat[zlim[1] <= dat$z & dat$z <= zlim[2], , drop = FALSE]
  }
  n <- nrow(dat)
  if (n < 1)
    stop("no data left within (x|y|z)lim")
  y.range <- range(dat$y[is.finite(dat$y)])
  if (type == "p" || type == "h") {
    y.ord <- rev(order(dat$y))
    dat <- dat[y.ord, ]
    if (length(pch) > 1)
      if (length(pch) != length(y.ord))
        stop("length(pch) ", "must be equal length(x) or 1")
    else pch <- pch[y.ord]
    if (length(bg) > 1)
      if (length(bg) != length(y.ord))
        stop("length(bg) ", "must be equal length(x) or 1")
    else bg <- bg[y.ord]
    if (length(cex.symbols) > 1)
      if (length(cex.symbols) != length(y.ord))
        stop("length(cex.symbols) ", "must be equal length(x) or 1")
    else cex.symbols <- cex.symbols[y.ord]
    daty <- dat$y
    daty[!is.finite(daty)] <- mean(daty[is.finite(daty)])
    if (highlight.3d && !(all(diff(daty) == 0)))
      dat$col <- rgb(red = seq(0, 1, length = n) * (y.range[2] -
                                                      daty)/diff(y.range), green = 0, blue = 0)
  }
  p.lab <- par("lab")
  y.range <- range(dat$y[is.finite(dat$y)], ylim)
  if(y.pretty) {
    y.prty <- pretty(y.range, n = ifelse(is.null(n.breaks.y), lab[2], n.breaks.y), min.n = max(1, min(0.5 * lab[2], p.lab[2])))
    y.scal <- round(diff(y.prty[1:2]), digits = 12)
    y.add <- min(y.prty)
    dat$y <- (dat$y - y.add)/y.scal
    y.max <- (max(y.prty) - y.add)/y.scal
    if (!is.null(ylim)) {
      y.max <- max(y.max, ceiling((ylim[2] - y.add)/y.scal))
    }
  } else {
    y.prty <- seq(from=y.range[1], to=y.range[2], length.out = ifelse(is.null(n.breaks.y), lab[2], n.breaks.y))
    y.scal <- round(diff(y.prty[1:2]), digits = 12)
    y.add <- min(y.prty)
    dat$y <- (dat$y - y.add)/y.scal
    y.max <- (max(y.prty) - y.add)/y.scal
    if (!is.null(ylim)) {
      y.max <- min(y.max, (ylim[2] - y.add)/y.scal) + (y.scal * ifelse(is.null(n.breaks.y), lab[2], n.breaks.y))
    }
  }
  x.range <- range(dat$x[is.finite(dat$x)], xlim)
  if(x.pretty) {
    x.prty <- pretty(x.range, n = ifelse(is.null(n.breaks.x), lab[1], n.breaks.x), min.n = max(1, min(0.5 * lab[1], p.lab[1])))
    x.scal <- round(diff(x.prty[1:2]), digits = 12)
    dat$x <- dat$x/x.scal
    x.range <- range(x.prty)/x.scal
    x.max <- ceiling(x.range[2])
    x.min <- floor(x.range[1])
    if (!is.null(xlim)) {
      x.max <- max(x.max, ceiling(xlim[2]/x.scal))
      x.min <- min(x.min, floor(xlim[1]/x.scal))
    }
  } else {
    x.prty <- seq(from=x.range[1], to=x.range[2], length.out = ifelse(is.null(n.breaks.x), lab[1], n.breaks.x))
    x.scal <- round(diff(x.prty[1:2]), digits = 12)
    dat$x <- dat$x/x.scal
    x.range <- range(x.prty)/x.scal
    x.max <- x.range[2] + (x.scal * ifelse(is.null(n.breaks.x), lab[1], n.breaks.x))
    x.min <- x.range[1] - (x.scal * ifelse(is.null(n.breaks.x), lab[1], n.breaks.x))
    if (!is.null(xlim)) {
      x.max <- min(x.max, (xlim[2]/x.scal)) + (x.scal * ifelse(is.null(n.breaks.x), lab[1], n.breaks.x))
      x.min <- max(x.min, (xlim[1]/x.scal)) - (x.scal * ifelse(is.null(n.breaks.x), lab[1], n.breaks.x))
    }
  }
  x.range <- range(x.min, x.max)
  z.range <- range(dat$z[is.finite(dat$z)], zlim)
  if(z.pretty){
    z.prty <- pretty(z.range, n = ifelse(is.null(n.breaks.z), lab.z, n.breaks.z), min.n = max(1, min(0.5 * lab.z, p.lab[2])))
    z.scal <- round(diff(z.prty[1:2]), digits = 12)
    dat$z <- dat$z/z.scal
    z.range <- range(z.prty)/z.scal
    z.max <- ceiling(z.range[2])
    z.min <- floor(z.range[1])
    if (!is.null(zlim)) {
      z.max <- max(z.max, ceiling(zlim[2]/z.scal))
      z.min <- min(z.min, floor(zlim[1]/z.scal))
    }
  } else {
    z.prty <- seq(from=z.range[1], to=z.range[2], length.out = ifelse(is.null(n.breaks.z), lab.z, n.breaks.z))
    z.scal <- round(diff(z.prty[1:2]), digits = 12)
    dat$z <- dat$z/z.scal
    z.range <- range(z.prty)/z.scal
    z.max <- z.range[2] + (z.scal * ifelse(is.null(n.breaks.z), lab.z, n.breaks.z))
    z.min <- z.range[1] - (z.scal * ifelse(is.null(n.breaks.z), lab.z, n.breaks.z))
    if (!is.null(zlim)) {
      z.max <- min(z.max, (zlim[2]/z.scal)) + (z.scal * ifelse(is.null(n.breaks.z), lab.z, n.breaks.z))
      z.min <- max(z.min, (zlim[1]/z.scal)) - (z.scal * ifelse(is.null(n.breaks.z), lab.z, n.breaks.z))
    }
  }
  z.range <- range(z.min, z.max)
  plot.new()
  if (angle.2) {
    x1 <- x.min + yx.f * y.max
    x2 <- x.max
  }
  else {
    x1 <- x.min
    x2 <- x.max + yx.f * y.max
  }
  plot.window(c(x1, x2), c(z.min, z.max + yz.f * y.max))
  temp <- strwidth(format(rev(y.prty))[1], cex = cex.axis/par("cex"))
  if (angle.2)
    x1 <- x1 - temp - y.margin.add
  else x2 <- x2 + temp + y.margin.add
  plot.window(c(x1, x2), c(z.min, z.max + yz.f * y.max))
  if (angle > 2)
    par(usr = par("usr")[c(2, 1, 3:4)])
  usr <- par("usr")
  title(main, sub, ...)
  if ("xy" %in% grid || grid) {
    i <- x.min:x.max
    segments(i, z.min, i + (yx.f * y.max), yz.f * y.max +
               z.min, col = col.grid, lty=lty.grid.xy, lwd=lwd.grid.xy)
    i <- 0:y.max
    segments(x.min + (i * yx.f), i * yz.f + z.min, x.max +
               (i * yx.f), i * yz.f + z.min, col = col.grid, lty=lty.grid.xy, lwd=lwd.grid.xy)
  }
  if ("xz" %in% grid) {
    i <- x.min:x.max
    segments(i + (yx.f * y.max), yz.f * y.max + z.min,
             i + (yx.f * y.max), yz.f * y.max + z.max,
             col = col.grid, lty = lty.grid.xz, lwd=lwd.grid.xz)
    temp <- yx.f * y.max
    temp1 <- yz.f * y.max
    i <- z.min:z.max
    segments(x.min + temp,temp1 + i,
             x.max + temp,temp1 + i , col = col.grid, lty = lty.grid.xz, lwd=lwd.grid.xz)

  }

  if ("yz" %in% grid) {
    i <- 0:y.max
    segments(x.min + (i * yx.f), i * yz.f + z.min,
             x.min + (i * yx.f) ,i * yz.f + z.max,
             col = col.grid, lty = lty.grid.yz, lwd=lwd.grid.yz)
    temp <- yx.f * y.max
    temp1 <- yz.f * y.max
    i <- z.min:z.max
    segments(x.min + temp,temp1 + i,
             x.min, i , col = col.grid, lty = lty.grid.yz, lwd=lwd.grid.yz)
  }

  if (axis) {
    xx <- if (angle.2)
      c(x.min, x.max)
    else c(x.max, x.min)
    if (tick.marks) {
      xtl <- (z.max - z.min) * (tcl <- -par("tcl"))/50
      ztl <- (x.max - x.min) * tcl/50
      mysegs <- function(x0, y0, x1, y1) segments(x0,
                                                  y0, x1, y1, col = col.axis, lty = lty.axis)
      i.y <- 0:y.max
      mysegs(yx.f * i.y - ztl + xx[1], yz.f * i.y + z.min,
             yx.f * i.y + ztl + xx[1], yz.f * i.y + z.min)
      i.x <- x.min:x.max
      mysegs(i.x, -xtl + z.min, i.x, xtl + z.min)
      i.z <- z.min:z.max
      mysegs(-ztl + xx[2], i.z, ztl + xx[2], i.z)
      if (label.tick.marks) {
        las <- par("las")
        mytext <- function(labels, side, at, line, ...) mtext(text = labels, line = line,
                                                        side = side, at = at, col = col.lab,
                                                        cex = cex.axis, font = font.lab, ...)
        if (is.null(x.ticklabs)) {
          if(!x.pretty & !is.null(x.sig)) {
            x.ticklabs <- format(i.x * x.scal, digits = x.sig)
          } else {
            x.ticklabs <- format(i.x * x.scal)
          }
        }
        mytext(x.ticklabs, side = 1, at = i.x, line = labs.line.x)
        if (is.null(z.ticklabs)) {
          if(!z.pretty & !is.null(z.sig)) {
            z.ticklabs <- format(i.z * z.scal, digits = z.sig)
          } else {
            z.ticklabs <- format(i.z * z.scal)
          }
        }
        mytext(z.ticklabs, line = labs.line.z, las=1, side = if (angle.1)
          4
          else 2, at = i.z, adj = if (0 < las && las <
                                        3)
            1
          else NA)
        temp <- if (angle > 2)
          rev(i.y)
        else i.y
        if (is.null(y.ticklabs)) {
          if(!y.pretty & !is.null(y.sig)) {
            y.ticklabs <- format(y.prty, digits = y.sig)
          } else {
            y.ticklabs <- format(y.prty)
          }
        }
        else if (angle > 2)
          y.ticklabs <- rev(y.ticklabs)
        text(i.y * yx.f + xx[1] + labs.adj.y, i.y * yz.f + z.min,
             y.ticklabs, pos = if (angle.1)
               2
             else 4, offset = 1, col = col.lab, cex = cex.axis/par("cex"),
             font = font.lab)
      }
    }
    mytext2 <- function(lab, side, line, at) mtext(lab,
                                                   side = side, line = line, at = at, col = col.lab,
                                                   cex = cex.lab, font = font.axis, las = 0)
    lines(c(x.min, x.max), c(z.min, z.min), col = col.axis,
          lty = lty.axis)
    mytext2(xlab, 1, line = 1.5, at = mean(x.range))
    lines(xx[1] + c(0, y.max * yx.f), c(z.min, y.max * yz.f +
                                          z.min), col = col.axis, lty = lty.axis)
    mytext2(ylab, if (angle.1)
      2
      else 4, line = 0.5, at = z.min + y.max * yz.f)
    lines(xx[c(2, 2)], c(z.min, z.max), col = col.axis,
          lty = lty.axis)
    mytext2(zlab, if (angle.1)
      4
      else 2, line = 1.5, at = mean(z.range))
    if (box) {
      if (is.null(lty.hide))
        lty.hide <- lty.axis
      temp <- yx.f * y.max
      temp1 <- yz.f * y.max
      lines(c(x.min + temp, x.max + temp), c(z.min + temp1,
                                             z.min + temp1), col = col.axis, lty = lty.hide)
      lines(c(x.min + temp, x.max + temp), c(temp1 + z.max,
                                             temp1 + z.max), col = col.axis, lty = lty.axis)
      temp <- c(0, y.max * yx.f)
      temp1 <- c(0, y.max * yz.f)
      lines(temp + xx[2], temp1 + z.min, col = col.axis,
            lty = lty.hide)
      lines(temp + x.min, temp1 + z.max, col = col.axis,
            lty = lty.axis)
      temp <- yx.f * y.max
      temp1 <- yz.f * y.max
      lines(c(temp + x.min, temp + x.min), c(z.min + temp1,
                                             z.max + temp1), col = col.axis, lty = if (!angle.2)
                                               lty.hide
            else lty.axis)
      lines(c(x.max + temp, x.max + temp), c(z.min + temp1,
                                             z.max + temp1), col = col.axis, lty = if (angle.2)
                                               lty.hide
            else lty.axis)
    }
  }
  x <- dat$x + (dat$y * yx.f)
  z <- dat$z + (dat$y * yz.f)
  col <- as.character(dat$col)
  if (type == "h") {
    z2 <- dat$y * yz.f + z.min
    segments(x, z, x, z2, col = col, cex = cex.symbols,
             lty = lty.hplot, ...)
    points(x, z, type = "p", col = col, pch = pch, bg = bg,
           cex = cex.symbols, ...)
  }
  else if (!is.null(fill)) { ## to do a polygon with fill instead
    polygon(x, z, col = fill, border = col, angle = angle, ...)
  }
  else points(x, z, type = type, col = col, fill = 'black', pch = pch, bg = bg, cex = cex.symbols, ...)
  if (axis && box) {
    lines(c(x.min, x.max), c(z.max, z.max), col = col.axis,
          lty = lty.axis)
    lines(c(0, y.max * yx.f) + x.max, c(0, y.max * yz.f) +
            z.max, col = col.axis, lty = lty.axis)
    lines(xx[c(1, 1)], c(z.min, z.max), col = col.axis,
          lty = lty.axis)
  }
  ob <- ls()
  rm(list = ob[!ob %in% c("angle", "mar", "usr", "x.scal",
                          "y.scal", "z.scal", "yx.f", "yz.f", "y.add", "z.min",
                          "z.max", "x.min", "x.max", "y.max", "x.prty", "y.prty",
                          "z.prty")])
  rm(ob)
  invisible(list(xyz.convert = function(x, y = NULL, z = NULL) {
    xyz <- xyz.coords(x, y, z)
    if (angle > 2) {
      temp <- xyz$x
      xyz$x <- xyz$y
      xyz$y <- temp
    }
    y <- (xyz$y - y.add)/y.scal
    return(list(x = xyz$x/x.scal + yx.f * y, y = xyz$z/z.scal +
                  yz.f * y))
  }, points3d = function(x, y = NULL, z = NULL, type = "p",
                         ...) {
    xyz <- xyz.coords(x, y, z)
    if (angle > 2) {
      temp <- xyz$x
      xyz$x <- xyz$y
      xyz$y <- temp
    }
    y2 <- (xyz$y - y.add)/y.scal
    x <- xyz$x/x.scal + yx.f * y2
    y <- xyz$z/z.scal + yz.f * y2
    mem.par <- par(mar = mar, usr = usr)
    on.exit(par(mem.par))
    if (type == "h") {
      y2 <- z.min + yz.f * y2
      segments(x, y, x, y2, ...)
      points(x, y, type = "p", ...)
    } else points(x, y, type = type, ...)
  }, plane3d = function(Intercept, x.coef = NULL, y.coef = NULL,
                        lty = "dashed", lty.box = NULL, ...) {
    if (!is.atomic(Intercept) && !is.null(coef(Intercept))) Intercept <- coef(Intercept)
    if (is.null(lty.box)) lty.box <- lty
    if (is.null(x.coef) && length(Intercept) == 3) {
      x.coef <- Intercept[if (angle > 2) 3 else 2]
      y.coef <- Intercept[if (angle > 2) 2 else 3]
      Intercept <- Intercept[1]
    }
    mem.par <- par(mar = mar, usr = usr)
    on.exit(par(mem.par))
    x <- x.min:x.max
    ltya <- c(lty.box, rep(lty, length(x) - 2), lty.box)
    x.coef <- x.coef * x.scal
    z1 <- (Intercept + x * x.coef + y.add * y.coef)/z.scal
    z2 <- (Intercept + x * x.coef + (y.max * y.scal + y.add) *
             y.coef)/z.scal
    segments(x, z1, x + y.max * yx.f, z2 + yz.f * y.max,
             lty = ltya, ...)
    y <- 0:y.max
    ltya <- c(lty.box, rep(lty, length(y) - 2), lty.box)
    y.coef <- (y * y.scal + y.add) * y.coef
    z1 <- (Intercept + x.min * x.coef + y.coef)/z.scal
    z2 <- (Intercept + x.max * x.coef + y.coef)/z.scal
    segments(x.min + y * yx.f, z1 + y * yz.f, x.max + y *
               yx.f, z2 + y * yz.f, lty = ltya, ...)
  }, box3d = function(...) {
    mem.par <- par(mar = mar, usr = usr)
    on.exit(par(mem.par))
    lines(c(x.min, x.max), c(z.max, z.max), ...)
    lines(c(0, y.max * yx.f) + x.max, c(0, y.max * yz.f) +
            z.max, ...)
    lines(c(0, y.max * yx.f) + x.min, c(0, y.max * yz.f) +
            z.max, ...)
    lines(c(x.max, x.max), c(z.min, z.max), ...)
    lines(c(x.min, x.min), c(z.min, z.max), ...)
    lines(c(x.min, x.max), c(z.min, z.min), ...)
  }))
}
