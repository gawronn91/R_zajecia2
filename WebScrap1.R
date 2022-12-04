library(rvest)
install.packages("rvest")

url<-"https://www.otodom.pl/pl/oferty/sprzedaz/mieszkanie/lublin?areaMax=38&page=1"
read_html(url) %>% html_nodes(".eoupkm71 css-1lc8b1f e11e36i3")


