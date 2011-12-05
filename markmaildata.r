library(RCurl)
library(XML)
require(plyr)

# 2009
theurl <- "http://markmail.org/browse/?q=from:emergya+from:juanje+from:juanje.ojeda+from:gloob+from:aleiva+from:fontanon+from:delawen+from:javiube+from:jmprieto+date:2009+-type:checkins+-list:com.selenic.mercurial"

webpage <- getURL(theurl)
webpage <- readLines(tc <- textConnection(webpage)); close(tc)
pagetree <- htmlTreeParse(webpage, error=function(...){}, useInternalNodes = TRUE)
counts <- xpathSApply(pagetree, "//tr/td[@align = 'right']", xmlValue)
counts <- as.numeric(counts)
lists <- xpathSApply(pagetree, "//tr/td/a", xmlValue)
content_2009 <- data.frame(row.names = lists, "Año 2009" = counts, stringsAsFactors = FALSE)

# 2010
theurl <- "http://markmail.org/browse/?q=from:emergya+from:juanje+from:juanje.ojeda+from:gloob+from:aleiva+from:fontanon+from:delawen+from:javiube+from:jmprieto+date:2010+-type:checkins+-list:com.selenic.mercurial"

webpage <- getURL(theurl)
webpage <- readLines(tc <- textConnection(webpage)); close(tc)
pagetree <- htmlTreeParse(webpage, error=function(...){}, useInternalNodes = TRUE)
counts <- xpathSApply(pagetree, "//tr/td[@align = 'right']", xmlValue)
counts <- as.numeric(counts)
lists <- xpathSApply(pagetree, "//tr/td/a", xmlValue)
content_2010 <- data.frame(row.names = lists, "Año 2010" = counts, stringsAsFactors = FALSE)

# 2011
theurl <- "http://markmail.org/browse/?q=from:emergya+from:juanje+from:juanje.ojeda+from:gloob+from:aleiva+from:fontanon+from:delawen+from:javiube+from:jmprieto+date:2011+-type:checkins+-list:com.selenic.mercurial"

webpage <- getURL(theurl)
webpage <- readLines(tc <- textConnection(webpage)); close(tc)
pagetree <- htmlTreeParse(webpage, error=function(...){}, useInternalNodes = TRUE)
counts <- xpathSApply(pagetree, "//tr/td[@align = 'right']", xmlValue)
counts <- as.numeric(counts)
lists <- xpathSApply(pagetree, "//tr/td/a", xmlValue)
content_2011 <- data.frame(row.names = lists, "Año 2011" = counts, stringsAsFactors = FALSE)

# Total
cont1 <- merge(content_2009, content_2010, by = "row.names", all = TRUE)
cont2 <- merge(content_2010, content_2011, by = "row.names", all = TRUE)
contents <- join(cont1, cont2, by = 1, type = "full")
contents[is.na(contents)] <- 0

# Graphs
barplot(as.matrix(contents[c(2,3,4)]), 
    xlab='Año', 
    ylab='Número de correos', 
    main="Correos por año",
    legend.text=rownames(contents$Row.names),
    beside=T)

# Queries
## GNOME lists and its number of mails
subset(contents, grepl("*gnome*", contents$Row.names))
## List with more mails per year
for (year in seq(2,4)) {
    max_mails <- which.max(contents[[year]])
    titles <- row.names(contents)
    print(titles[year], contents$Row.names[max_mails])
}
