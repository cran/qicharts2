#' @import ggplot2
plot.qic <- function(x, title, ylab, xlab, subtitle, caption, part.labels,
                     n.facets,
                     nrow, ncol, scales, show.labels, show.grid, show.95,
                     decimals, flip, dots.only, point.size,
                     x.format, x.angle, x.pad,
                     y.expand, y.percent, y.percent.accuracy, strip.horizontal,
                     # col.line = '#5DA5DA', 
                     # col.signal = '#F15854', 
                     # col.target = '#059748',
                     ...) {
  # Set colours
  col1      <- '#8C8C8C' # rgb(140, 140, 140, maxColorValue = 255) # grey
  col2      <- getOption('qic.linecol', default = '#5DA5DA')       # blue
  # col3      <- getOption('qic.signalcol', default = '#F15854')     # red
  col3      <- getOption('qic.signalcol', default = '#FAA43A')     # amber
  col4      <- getOption('qic.targetcol', default = '#059748')     # green
  col5      <- '#C8C8C8' # rgb(200, 200, 200, maxColorValue = 255) # light grey
  cols      <- c('col1' = col1,
                 'col2' = col2,
                 'col3' = col3,
                 'col4' = col4,
                 'col5' = col5)
  
  x$dotcol  <- ifelse(x$y == x$cl, 'col5', 'col2')
  x$dotcol  <- ifelse(x$sigma.signal, 'col3', x$dotcol)
  x$dotcol  <- ifelse(x$include, x$dotcol, 'col5')
  x$linecol <- ifelse(x$runs.signal, 'col3', 'col1')

  # Set label parameters
  lab.size <- 3
  lab.just <- ifelse(flip, 'center', -0.2)
  
  # Get number of facet dimensions
  # n.facets <- sum((length(unique(x$facet1))) > 1,
  #                 (length(unique(x$facet2)) > 1))
  
  # Get freeze point
  freeze <- max(x$xx[x$baseline])
  if (freeze < (max(x$xx) - 1)) {
    freeze <- (as.numeric(x$x[freeze]) + as.numeric(x$x[freeze + 1])) / 2
  } else {
    freeze <- Inf
  }
  
  # Prepare plot
  p <- ggplot(x, aes({ x }, { y }, group = { part })) +
    theme_bw() +
    theme(panel.border     = element_rect(colour = 'grey93'),
          strip.background = element_rect(colour = 'grey93', fill = 'grey93'),
          axis.ticks       = element_line(colour = 'grey80'),
          panel.grid       = element_blank(),
          legend.position  = 'none')
  
  # Add control limits and centre and target lines
  if (getOption('qic.clshade', default = TRUE) &
      sum(!is.na(x$lcl))) {
    p <- p +
      geom_ribbon(aes(ymin ={ lcl }, ymax = { ucl }),
                              fill = 'grey87',
                  alpha = 0.4)
  } else {
    p <- p +
      geom_line(aes(y = { lcl }), colour = col1, na.rm = T)
    
    p <- p +
      geom_line(aes(y = { ucl }), colour = col1, na.rm = T)
  }

  if (isTRUE(show.95)) {
    p <- p +
      geom_line(aes(y = { lcl.95 }), colour = col1, na.rm = T) +
      geom_line(aes(y = { ucl.95 }), colour = col1, na.rm = T)
  }
  
  p <- p +
    geom_line(aes(y = { target }), 
                        colour = col1, 
              na.rm = T, 
              linetype = 3)
  
  p <- p +
    geom_line(aes(y = { cl }, linetype = { runs.signal }, colour = { linecol }),
                        na.rm = TRUE) +
    scale_linetype_manual(values = c('FALSE' = 'solid', 'TRUE' = 'longdash'))
  
  # Add data points and line
  if (dots.only) {
    p <- p + 
      geom_point(aes(colour = { dotcol }), size = 3 * point.size, na.rm = TRUE)
  } else {
    p <- p +
      geom_line(colour = col2, linewidth = 1.1, na.rm = TRUE) +
      geom_point(aes(colour = { dotcol }), size = point.size, na.rm = TRUE)
  }
  p <- p + scale_colour_manual(values = cols)
  
  # Add line labels
  if (show.labels) {
    p <- p +
      geom_text(aes(y = { target.lab },
                     label = { lab.format(target.lab, decimals, y.percent) }),
                na.rm = TRUE,
                size = lab.size,
                hjust = lab.just) +
      geom_text(aes(y = { lcl.lab },
                     label = { lab.format(lcl.lab, decimals, y.percent) }),
                na.rm = TRUE,
                size = lab.size,
                hjust = lab.just) +
      geom_text(aes(y = { ucl.lab },
                     label = { lab.format(ucl.lab, decimals, y.percent) }),
                na.rm = TRUE,
                size = lab.size,
                hjust = lab.just) +
      geom_text(aes(y = { cl.lab },
                     label = { lab.format(cl.lab, decimals, y.percent) }),
                na.rm = TRUE,
                size = lab.size,
                hjust = lab.just)
  }
  
  # Add freeze line and part labels
  if (is.finite(freeze)) {
    p <- p + 
      geom_vline(aes(xintercept = freeze), colour = col1, linetype = 3)
  }
  
  if (!is.null(part.labels)) {
    if (is.finite(freeze)) {
      plabs <- split(x, x['baseline'])
      part.labels <- rev(part.labels)
    } else {
      plabs <- split(x, x['part'])
    }
    
    plabs <- lapply(plabs, function(x) {median(as.numeric(x$x))})
    plabs <- as.data.frame(do.call(rbind, plabs))
    colnames(plabs) <- 'x'
    
    if (length(part.labels) == nrow(plabs)) {
      plabs$z <- part.labels
      plabs$y <- Inf
      
      if (inherits(x$x, 'POSIXct')) {
        plabs$x <- as.POSIXct(plabs$x, origin = '1970-01-01')
      }
      
      p <- p +
        geom_label(aes(y = { y }, label = { z }, group = 1), 
                   data = plabs,
                   na.rm = T,
                   linewidth = 0,
                   label.padding = unit(0.5, 'lines'),
                   size = lab.size,
                   alpha = 0.5,
                   vjust = ifelse(flip, 'center', 'inward'),
                   hjust = ifelse(flip, 'inward', 'center'))
    } else {
      warning('Length of part.labels argument must match the number of parts to label.')
    }
  }
  
  # Add notes
  x.notes <- x[!is.na(x$notes), ]
  
  if (nrow(x.notes)) {
    p <- p +
      geom_segment(aes(xend = { x }, yend = Inf),
                   data = x.notes,
                   linetype = 3,
                   colour = col1) +
      geom_label(aes(y = Inf, label = { notes }),
                 data = x.notes,
                 linewidth = NA,
                 label.padding = unit(0.3, 'lines'),
                 size = lab.size,
                 alpha = 0.5,
                 vjust = ifelse(flip, 'center', 'inward'),
                 hjust = ifelse(flip, 'inward', 'center'))
  }
  
  # Facets
  if (n.facets == 1) {
    p <- p + facet_wrap( ~ facet1,
                         nrow = nrow,
                         ncol = ncol,
                         scales = scales)
  } else if (n.facets == 2) {
    p <- p + facet_grid(facet1 ~ facet2,
                        scales = scales)
  } else {
    p <- p + facet_null()
  }
  
  # Add title and axis labels
  p <- p +
    labs(title = title,
         x = xlab,
         y = ylab,
         caption = caption,
         subtitle = subtitle)
  
  # Format x axis labels
  if (!is.null(x.format) && inherits(x$x, 'POSIXct')) {
    p <- p + scale_x_datetime(date_labels = x.format)
  }
  
  # Rotate x axis labels
  if (!is.null(x.angle)) {
    p <- p +
      theme(axis.text.x = element_text(angle = x.angle, vjust = 1, hjust = 1))
  }
  
  # Expand y limits
  p <- p + expand_limits(y = y.expand)
  
  # Format percent axis
  if (y.percent) {
    p <- p + scale_y_continuous(labels = scales::percent_format(y.percent.accuracy))
  }
  
  # Add space for line labels
  subgroups <- unique(x$x)
  
  if(is.character(subgroups) || is.factor(subgroups))
    subgroups <- seq_along(subgroups)
  
  p <- p +
    expand_limits(x = max((subgroups)) +
                    diff(range((subgroups))) / 30 * x.pad * show.labels)
  
  # Show grid
  if (show.grid) {
    p <- p + theme(panel.grid = element_line(linewidth = 0.1, colour = col1))
    # p <- p + theme(panel.grid = element_line())
  }
  
  # Flip chart
  if (flip) {
    p <- p + coord_flip()
  }
  
  # Horizontal y strip
  if (strip.horizontal)
    p <- p + theme(strip.text.y = element_text(angle = 0,
                                               hjust = 0),
                   strip.background = element_blank())
  
  return(p)
}
