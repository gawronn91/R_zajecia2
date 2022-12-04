install.packages("rvest")
install.packages("RSelenium")

library(rvest)
library(RSelenium)
#To Rselenium działa tak, że otwiera nam w przeglądarce stronę na pocie i możemy live 
#codem mani pulować tym, co tam jest 


url<-"https://www.otodom.pl/pl/oferty/sprzedaz/mieszkanie/lublin?areaMax=38&page=1"
#download.file(url, destfile="page.html")
read_html(url) %>% html_nodes(".eoupkm71 css-1lc8b1f e11e36i3")

#remDr$close()
#rm(rd)
#rm(remDr)
#To może być przydatne, żeby zamknąć sesję i usunąc obiekty

rd<- RSelenium::rsDriver(browser = "chrome",chromever = "108.0.5359.71" )
remDr<- rd[['client']]
remDr$navigate(url)
Sys.sleep(1)
pageFromSelenium <- remDr$getPageSource()[[1]] %>% rvest::read_html()
przyciski <- pageFromSelenium %>% html_elements(".eoupkm71.css-1lc8b1f.e11e36i3")
# Ta klasa odpowiada przyciskom na dole strony do tego, z eby pójść do page 2,3....
ilestron <- przyciski[(length(przyciski))-1] %>% html_text()
#Robimy to -1, bo na ostatniej stronie już nie bedzie przycisku

wektorLinkow <- c()

i <- 1
ilestron <- 4
for(i in 1:ilestron){
  urll <- paste0("https://www.otodom.pl/pl/oferty/sprzedaz/mieszkanie/lublin?areaMax=38&page=",i)
  remDr$navigate(urll)
  Sys.sleep(1)
  webElement <- remDr$findElement("css", "body")
  webElement$sendKeysToElement(list(key="end"))
  Sys.sleep(1)
  #Te sleepy sa ważne, żeby react zdąrzył się załadować
  webElement$sendKeysToElement(list(key="end"))
  #To nam zjeżdża na sam dół
  
  Sys.sleep(1)
  pageFromSelenium <- remDr$getPageSource()[[1]] %>% rvest::read_html()
  #To nam już pobiera przesunięta i załadowaną stronę (gdy react już wszystko załadował)
  
  linki <- pageFromSelenium %>% html_elements(".css-14cy79a.e3x1uf06") %>%
    html_elements(".css-p74l73.es62z2j19") %>% html_node("a") %>% html_attr("href")
  
  #Uwaga!! jak są spacje w tym class, to zastępujemy kropkami!!!
  # W tym momencie powinniśmy miec listę wszystkich linków w <li> - czyli ogłoszeń
  
  wektorLinkow <- c(wektorLinkow, linki)
  
}

wektorLinkow <- unique(wektorLinkow)


w <- 1
miasto <- "Lublin"
data <- "04.12.2022"
zrobWiersz <- function(w,wektorLinkow, miasto,data, remDr){
  
  urll <- paste0("https://www.otodom.pl", wektorLinkow[w])
  remDr$navigate(urll)
  Sys.sleep(1)
  webElement <- remDr$findElement("css", "body")
  webElement$sendKeysToElement(list(key="end"))
  Sys.sleep(1)
  webElement$sendKeysToElement(list(key="end"))
  
  Sys.sleep(1)
  pageFromSelenium <- remDr$getPageSource()[[1]] %>% rvest::read_html()
  cena <- pageFromSelenium %>% html_elements(".css-8qi9av.eu6swcv19") %>% html_text()
  
  v <- pageFromSelenium %>% html_elements(".css-1qzszy5.estckra8") %>% html_text()
  indexy <- seq(1,length(v))
  nazwyKolumn <- v[indexy %% 2 == 1]
  wartosci <- v[indexy %% 2 == 0]
  
  df1 <- data.frame(t(wartosci))
  names(df1) <- nazwyKolumn
  if(!any(is.na(names(df1)))){
    df1<- cbind(df1,miasto)
    df1<- cbind(df1,data=data)
    df1<- cbind(cena=cena, df1)# To nie zostało sprawdzone jeszcze
  }
  
  df1
}

View(df1)

install.packages("gtools")
library(gtools)


miastaDF<-NULL
liczbalinkow <- length(wektorLinkow)

l <- 1

# W domu oczywiście zrobić fora do licby linkow
for(l in 1:5){
  skip <- FALSE
  tryCatch(
    temp <- zrobWiersz(l,wektorLinkow,miasto, data, remDr),
    error=function(e){
      print(e); skip <<- TRUE # Ta podwójna stzałka jest istotna do działaia w trycatch
      }
  )
  
  if(skip){next}
  if ( !any(is.na(names(temp)))){
    if(is.null(miastaDF)){
      miastaDF <- temp
    }else{
      miastaDF <- smartbind(miastaDF,temp)
    }
  }
}


View(miastaDF)


#Hasło:  "!r23_pjatK_23!"#
install.packages(c("DBI","RMySQL","rstudioapi"))
install.packages("dplyr")
library(DBI)
library(RMySQL)
library(rstudioapi)
library(dplyr)

View(miastaDF)
con <- DBI::dbConnect(RMySQL::MySQL(), 
                      encoding ="UTF-8",
                      host = "51.83.185.240",
                      user = "student",
                      dbname = "rzajecia23",
                      password ="!r23_pjatK_23!"#rstudioapi::askForPassword("Database password")
)
dbGetQuery(con,'SET NAMES utf8')
dbGetQuery(con,'set character set "utf8"')

#To nam wysyła do bazy naszego dataframe
dbWriteTable(con, "gawronski_miasta", miastaDF, append = FALSE,overwrite=TRUE)

#To nam ściąga tabelę z MySQLa
dbListTables(con)
gawronski <- tbl(con,"gawronski_miasta")

#Odpytujemy
gawronski%>%select(Powierzchnia)

#To nam disconnectuje połączenie
dbDisconnect(con)







