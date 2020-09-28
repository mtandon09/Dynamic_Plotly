make_customizable_plotly <- function(my_dataframe,      ## Data frame with data
                                     sort_by_cor=F,     ## Whether or not to sort the order of the options by correlation; can be TRUE/FALSE or a correlation method supported by 'cor()'
                                     # color_var=NULL,    ## Column name in 'my_dataframe' with data to color by
                                     id_var=NULL,   ## Column name to use for ID in hover text
                                     plot3D=F,
                                     my_title="",
                                     pointsize=10,
                                     plotwidth=800, plotheight=600) {
  # my_dataframe <- alldata
  colnames(my_dataframe) <- make.names(colnames(my_dataframe), unique=T)  ## Make syntactically correct colnames, otherwise plotly freaks out
  
  ## Figure out whether or not to sort by correlation
  cormeths=c("pearson","spearman","kendall")
  if (is.logical(sort_by_cor)) {
    meth=cormeths[1]
  } else if (sort_by_cor %in% cormeths) {
    meth=sort_by_cor
    sort_by_cor=TRUE
  } else {
    stop("'sort_by_cor' must be TRUE/FALSE or one of c('pearson','spearman','kendall')")
  }
  
  # Columns included in the dropdown
  varnames <- colnames(my_dataframe)
  
  # Determine which columns are numeric
  numeric_col=rep(FALSE, ncol(my_dataframe))
  for (i in 1:ncol(my_dataframe)) {
    numeric_col[i] <- is.numeric(my_dataframe[,i])
  }
  
  # if you request that the column order be sorted by correlation, 
  #   only numeric columns are used
  if (sort_by_cor) {
    num_data <- my_dataframe[, numeric_col]
    if (ncol(num_data) < 2) {
      warning("Couldn't find 2 or more numeric columns.")
    } else {
      pairwise_corr <- cor(num_data, method=meth)
      ordered_columns <- rownames(pairwise_corr)[order(abs(pairwise_corr[,1]), decreasing = T)]
      varnames <- c(ordered_columns, setdiff(varnames, ordered_columns))  ## Add back the non-numeric column names
    }
  }
  
  # Prettify the names a bit for display
  names(varnames) <- tools::toTitleCase(gsub("_|\\.", " ", varnames))
  
  # This df holds column names and prettified labels
  my_col_order <- data.frame(column_name=factor(varnames, levels = varnames),
                             column_label=factor(names(varnames), levels = names(varnames)))
  
  # Enumerate drop-down options
  #### THIS IS SUPER UGLY
  # I tried writing functions to build some of these args programmatically
  #   but I couldn't figure out a smart way
  # Also the 'list' structure has be to EXACTLY right or plotly fails silently
  
  # This shifts the column names for x, y, and z so they're pointing at different variables on initialization
  color_dropdown_opts <- rep(list(NA), nrow(my_col_order))
  x_dropdown_opts <- rep(list(NA), nrow(my_col_order))
  shifted_y <- rbind(my_col_order[2:nrow(my_col_order),], my_col_order[1,])
  y_dropdown_opts <- rep(list(NA), nrow(shifted_y))
  shifted_z <- rbind(shifted_y[2:nrow(shifted_y),], shifted_y[1,])
  z_dropdown_opts <- rep(list(NA), nrow(shifted_z))
  
  for (i in 1:nrow(my_col_order)) {
    curr_col = as.character(my_col_order$column_name)[i]
    curr_label = as.character(my_col_order$column_label)[i]
    curr_ycol = as.character(shifted_y$column_name[i])
    curr_ylabel = as.character(shifted_y$column_label[i])
    curr_zcol = as.character(shifted_z$column_name[i])
    curr_zlabel = as.character(shifted_z$column_label[i])
    
    color_arg <- list(marker = list(color = as.formula(paste0("~",curr_col)),
                                    size = pointsize))
    if (!numeric_col[i]) {
      ###### THIS IS NOT WORKING IDK WHY!
      ## But this at least makes the color black, instead of doing nothing
      color_arg <- list(color = as.formula(paste0("~",curr_col)))
    }
    color_dropdown_opts[[i]] <- list(method = "update",
                                     args = list(
                                       color_arg,
                                       list(showlegend = TRUE)
                                     ),
                                     label = curr_label)
    if (plot3D) {
      ## Gah! Setting one axis label resets the others!!!!
      x_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(x = list(as.formula(paste0("~",curr_col)))),
                                               list(scene = list(xaxis = list(title = curr_label)))
                                   ),
                                   label = curr_label)
      
      y_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(y = list(as.formula(paste0("~",curr_ycol)))),
                                               list(scene = list(yaxis = list(title = curr_ylabel)))
                                   ),
                                   label = curr_ylabel)
      
      z_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(z = list(as.formula(paste0("~",curr_zcol)))),
                                               list(scene = list(zaxis = list(title = curr_zlabel)))
                                   ),
                                   label = curr_zlabel)
    } else {
      ## But for 2D it works as expected (when one axis label is changed, the other remains the same)
      x_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(x = list(as.formula(paste0("~",curr_col)))),
                                               list(xaxis = list(title = curr_label))
                                   ),
                                   label = curr_label)
      
      y_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(y = list(as.formula(paste0("~",curr_ycol)))),
                                               list(yaxis = list(title = curr_ylabel))
                                   ),
                                   label = curr_ylabel)
      
      z_dropdown_opts[[i]] <- list(method = "update",
                                   args = list(list(z = list(as.formula(paste0("~",curr_zcol)))),
                                               list(zaxis = list(title = curr_zlabel))
                                   ),
                                   label = curr_zlabel)
      
    }
    
  }
  
  
  color_dropdown_opts <- color_dropdown_opts[numeric_col]
  color_dropdown_opts[[i+1]] <- list(method = "update",
                                     args = list(
                                       list(marker = list(color = as.formula("~default_color"),
                                                          size = pointsize))
                                     ),
                                     label = "None")
  color_dropdown_opts <- c(color_dropdown_opts[length(color_dropdown_opts)],color_dropdown_opts[1:(length(color_dropdown_opts)-1)])
  
  # Add some columns to data frame before plotting
  data_for_plotly <- as.data.frame(my_dataframe)
  data_for_plotly$default_color <- "foo"
  id_vec <- row.names(data_for_plotly)
  if (!is.null(id_var)) {
    if (id_var %in% colnames(data_for_plotly)) {
      id_vec <- as.character(data_for_plotly[, id_var])
    }
  }
  data_for_plotly$hoverid <- id_vec
  
  # Set z data as appropriate
  zval <- NULL
  charttype <- "scatter"
  if (plot3D) {
    zval <- as.formula(paste0("~",as.character(my_col_order$column_name)[3]))
    charttype <- "scatter3d"
  }
  # Make base plot
  p <- plot_ly(data=data_for_plotly, 
               x = as.formula(paste0("~",as.character(my_col_order$column_name)[1])),
               y = as.formula(paste0("~",as.character(my_col_order$column_name)[2])),
               z = zval,
               marker = list(color = as.formula("~default_color"),
                             size = pointsize),
               text=~hoverid,
               hovertemplate = paste(
                 "<b>%{text}</b><br><br>",
                 "%{yaxis.title.text}: %{y}<br>",
                 "%{xaxis.title.text}: %{x}<br>",
                 "<extra></extra>"
               ),
               width=plotwidth, height=plotheight,
               type = charttype, mode="markers")
  
  # Set up for adding drop-down buttons
  dropdown_ylocs <- seq(0.2, 0.6, length.out = 3)
  names(dropdown_ylocs) <- rev(c("x","y","z"))
  all_buttons_list <- list(
    list(
      x=-0.2,
      y = 0.9,
      buttons = color_dropdown_opts
    ),
    list(
      x=-0.2,
      y = dropdown_ylocs["x"],
      buttons = x_dropdown_opts
    ),
    list(
      x=-0.2,
      y = dropdown_ylocs["y"],
      buttons = y_dropdown_opts
    ),
    list(
      x=-0.2,
      y = dropdown_ylocs["z"],
      buttons = z_dropdown_opts
    )
  )
  ann_list <- list(
    list(text="Color by", showarrow=FALSE, xref="paper", yref="paper", x=-0.25, y = 0.9*1.05),
    list(text="X-Axis", showarrow=FALSE, xref="paper", yref="paper", x=-0.25, y=dropdown_ylocs["x"]*1.05),
    list(text="Y-Axis", showarrow=FALSE, xref="paper", yref="paper", x=-0.25, y=dropdown_ylocs["y"]*1.05),
    list(text="Z-Axis", showarrow=FALSE, xref="paper", yref="paper", x=-0.25, y=dropdown_ylocs["z"]*1.05)
  )
  if (!plot3D) {
    all_buttons_list <- all_buttons_list[-length(all_buttons_list)]
    ann_list <- ann_list[-length(ann_list)]
  }
  
  # Add drop-down menu buttons
  if (plot3D) {
    p <- p %>%
      layout(
        autosize = F,
        title = my_title,
        scene = list(
          xaxis = list(title = as.character(my_col_order$column_name)[1]),
          yaxis = list(title = as.character(my_col_order$column_name)[2]),
          zaxis = list(title = as.character(my_col_order$column_name)[3])
        ),
        updatemenus = all_buttons_list,
        annotations = ann_list
      )
    
  } else {
    p <- p %>%
      layout(
        autosize = F,
        title = my_title,
        xaxis = list(title = as.character(my_col_order$column_name)[1]),
        yaxis = list(title = as.character(my_col_order$column_name)[2]),
        updatemenus = all_buttons_list,
        annotations = ann_list
      )
  }
  
  
  
  return(p)
  
}

