library(rvest)

url<-"https://www.otodom.pl/pl/oferty/sprzedaz/mieszkanie/lublin?areaMax=38&page=1"
download.file(url, destfile="page.html")
page <- read_html('page.html')

x <- page %>% html_nodes(xpath='//*[@class="css-s8wpzb eclomwz2"]') %>% html_text()

