library(tidyverse)
library(cowplot)

TCR_circos = function(df, clonotype ="cdr3s_nt", annotations = NULL, colors = NULL, scale = 1/3, gap=0.2, max.n = NULL){
  
  #filter for annotations in the dataframe
  if(!all(annotations %in% colnames(df))){warning("not all annotations are in the dataframe")
    annotations = annotations[annotations %in% colnames(df)]}
  
  #check if any annotations or clonotypes are present
  if(length(annotations) < 1){stop("no annotations are in the dataframe")}
  if(!all(annotations %in% names(colors))){stop("not all annotations have a color pallette assigned")}
  if(!clonotype %in% colnames(df)){stop("no clonotypes in the dataframe")}
  
  #filter for cells with clonotypes called
  df %>% 
    filter(!is.na(!!sym(clonotype))) ->
    df
  
  if(nrow(df) < 1){stop("no clonotype rows in dataframe")}
  
  #order of clonotypes by frequency
  df %>%
    group_by(!!sym(clonotype)) %>% 
    summarise(n = n()) %>% 
    arrange(-n) %>% 
    pull(!!sym(clonotype)) -> order
  
  #plot the annontations and the legends
  plots = list()
  legends = list()
  for(i in annotations){
    df %>% 
      ggplot() + 
      aes_string(x = clonotype, fill = i) +
      geom_bar(position = "fill") + scale_fill_manual(values = colors[[i]]) + 
      scale_x_discrete(limits = order) +
      theme_void() + coord_polar(start = 0) + 
      theme(plot.margin = unit(rep(0,4), "cm")) ->
      temp_plot
    
    legends[[i]] <- get_legend(temp_plot)
    
    plots[[i]] <- temp_plot + theme(legend.position = "none") 
    
  }
  
  #convert the annotation plots to rings
  for(i in 1:length(annotations)){
    plots[[annotations[i]]] <- plots[[annotations[i]]] + ylim((1-2/scale)+i-1+(i)*gap,(1+1/scale)+i-1+(i)*gap)
  }
  
  #determine the maximum frequency of clonotypes
  if(is.null(max.n)){
    df %>%
      group_by(!!sym(clonotype)) %>% 
      summarise(n = n()) %>% 
      arrange(-n) %>% 
      pull(n) %>% 
      max ->
      max.n
  }
  
  #add the clonotype plot to the plot_list
  df %>% 
    group_by(!!sym(clonotype)) %>% 
    summarise(n = n()) %>% 
    mutate(p = n/max.n) %>% 
    ggplot() + aes_string(x=clonotype) + aes(y = p) + geom_bar(stat = "identity", fill="grey60") + 
    scale_x_discrete(limits = order) +
    theme_void() + coord_polar(start = 0) + theme(legend.position = "none") + ylim(-2,1) + 
    theme(plot.margin = unit(rep(0,4), "cm")) ->
    plots[[clonotype]]
  
  #draw the circos plots
  circos_plot <- ggdraw()
  for(i in names(plots)){
    circos_plot <- ggdraw(circos_plot) + draw_plot(plots[[i]])
  }
  
  #draw the legend
  circos_legend = plot_grid(plotlist = legends, nrow=1)
  
  #return the plot and legend
  return(list("plot" = circos_plot, "legend" = circos_legend))
  
}



