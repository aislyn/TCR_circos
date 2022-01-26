# TCR_circos

The TCR_circos function is meant to create a circos-style ggplot full of annotations for single cell TCR data. Each "spoke" is intended to be a clonotype with the outmost ring being a clonotype's frequency and the inner rings showing the frequency of annotations for each clonotype. TCR_circos relies on cowplots to stack the annotation rings.

It takes the following arguments:

`df`: the data frame off annotations. It is intended to run from a dataframe where all column annotations are factors and each row is a cell. 

`clonotype`: is the (string) name of the column for the outmost clonotype annotations.

`annotation`: vector of the names of the columns to use as the inner annotation rings.

`colors`: is a named list of named vectors for the annotation colors.

`scale`: scale value for the width of the inner rings compared to the outmost. Sensible values are from 0.1 to 0.5.

`gap`: size of the gap between the rings. Sensible values are from 0 to 0.2.



for example:

```
colors = list("Cluster" = rainbow(11)[c(1,6,2,7,8,3,11,4,9,5,10)] %>% setNames(1:11),
              "mait_evidence" = topo.colors(12)[c(1,9,5,11,3,7)] %>%  setNames(levels(df$mait_evidence)),
              "n_TRB" = c("0" = "black", "1" = "tomato", "2"="goldenrod2"))
```

```
example_plot1 = TCR_circos(df[1:500,],  clonotype ="cdr3s_nt", annotations = annotations, colors = colors)
plot_grid(example_plot1$plot, example_plot1$legend, nrow=1)
```

![example_plot1](https://user-images.githubusercontent.com/7208125/151250865-90f1d2be-dddb-46ab-a7b1-1264aa4e49ed.jpg)
