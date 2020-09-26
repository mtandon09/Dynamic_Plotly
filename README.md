## Making arbitrary plots from an R `data.frame` with [`plot_ly`](https://plotly.com/r/)

## Motivation
R is great (lol) and all, but sometimes you just wanna look at the data.  `plot_ly` allows you to make super useful interactive plots from R, but you kinda need to know *what* you want to plot already, which is not great for exploration.

I wanted to be able to plot arbitrary columns from an R `data.frame`, without having to plot each one out individually or as [subplots](https://plotly.com/r/subplots/).  The idea is to render a single plot, but be able to change the x- and y- (and -z) variable arbitrarily.  Additionally, scaling other plotting options like color, shape, size, and alpha could be useful to add more dimensions to the plot.

## Function options
```
make_customizable_plotly(my_dataframe,      
                         sort_by_cor=F,     
                         id_var=NULL,       
                         plot3D=F,
                         my_title="",
                         pointsize=10,
                         plotwidth=800, plotheight=600) {
```
### Arguments
Name | Value
-------- | -----
`my_dataframe` | `data.frame` containing data to plot
`sort_by_cor` | Whether or not to sort the order of the drop-down menu by correlation; can be TRUE/FALSE or a correlation method supported by `cor()`
`id_var` | Column name to use as ID in hover text; `row.names` used by default
`my_title` | Title for the plot
`pointsize` | Size of the markers
`plotwidth` | Width of the plot in pixels
`plotheight` | Height of the plot in pixels

### Return Value
A `plotly` object, which is a subset of [`htmlwidget`](https://www.htmlwidgets.org/)



