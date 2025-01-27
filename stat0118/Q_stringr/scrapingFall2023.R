library(RSelenium)
library(tidyverse)
library(rvest)

remDr <- remoteDriver(
  remoteServerAddr = "localhost",
  port = 4932L,
  browserName = "firefox"
)

rD <- rsDriver(browser = "firefox",
               chromever  = NULL,
               port = 4932L)

remDr <- rD[["client"]]

remDr$open()


remDr$navigate("https://catalog.middlebury.edu/offerings/search/catalog/catalog%2FMCUG?term=term%2F202320&department=&keywords=&time_start=0&time_end=86400&type%5B%5D=genera%3Aoffering%2FLCT&type%5B%5D=genera%3Aoffering%2FSEM&search=Search")



i <- 1
n <- 1

titlesdata <- data.frame(matrix("bleh", nrow = 586, ncol = 6)) %>%
  rename("titles" = 1) %>%
  rename("distros" = 2) %>%
  rename("department" = 3) %>%
  rename("time" = 4) %>%
  rename("location" = 5) %>%
  rename("professor" = 6)


html <- remDr$getPageSource()[[1]]



for(n in 1:586){
  xpath <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/div[3]/strong", sep = "")
  xpath2 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/div[3]", sep = "")
  xpath3 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/div[3]/span[2]", sep = "")
  xpath4 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[1]/dl/dd[5]", sep = "")
  xpath5 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[1]/dl/dd[4]", sep = "")
  xpath6 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/dl/dd[3]", sep = "")
  xpath7 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/dl/dd[2]", sep = "")
  xpath8 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[2]/dl/dd[1]", sep = "")
  xpath9 <- paste("/html/body/article/section[2]/div/table/tbody/tr[", i, "]/td[1]/a", sep = "")
  titlesdata$titles[n] <- read_html(html) %>% 
    html_element(xpath = xpath) %>%
    html_text2()
  titlesdata$description[n] <- read_html(html) %>% 
    html_element(xpath = xpath2) %>%
    html_text()
  titlesdata$distros[n] <- read_html(html) %>% 
    html_element(xpath = xpath4) %>%
    html_text()
  titlesdata$department[n] <- read_html(html) %>% 
    html_element(xpath = xpath5) %>%
    html_text()
  titlesdata$time[n] <- read_html(html) %>% 
    html_element(xpath = xpath6) %>%
    html_text()
  titlesdata$location[n] <- read_html(html) %>% 
    html_element(xpath = xpath7) %>%
    html_text()
  titlesdata$professor[n] <- read_html(html) %>% 
    html_element(xpath = xpath8) %>%
    html_text()
  titlesdata$courseNum[n] <- read_html(html) %>% 
    html_element(xpath = xpath9) %>%
    html_text()
  i <- i + 1
  n <- n + 1
  if(i%%10==1 & n<12){
    remDr$findElements("xpath", "/html/body/article/section[2]/div/div[3]/a[10]")[[1]]$clickElement()
    html <- remDr$getPageSource()[[1]]
    i <- 1
  }
  if(i%%10==1 & n>12){
    remDr$findElements("xpath", "/html/body/article/section[2]/div/div[3]/a[11]")[[1]]$clickElement()
    html <- remDr$getPageSource()[[1]]
    i <- 1
  }
}



titlesdata2 <- titlesdata %>%
  mutate(description = str_remove(titlesdata$description, coll(titlesdata$title)))

titlesdata2 <- titlesdata2 %>%
  mutate(description = str_remove(description, regex("\\[collapse\\]"))) %>%
  mutate(description = str_remove(description, regex("\\.\\.\\. read more")))

titlesdata2 <- titlesdata2 %>%
  mutate(meet = time) %>%
  mutate(time = str_extract(time, regex(".*m.*m"))) %>%
  mutate(meet = str_remove(meet, regex(".*m.*m on ")))

write_csv(titlesdata, "/Users/violetross/Desktop/TA Data Science/Stringr Lesson/coursesNoSep3.csv")

write_csv(courses, "/Users/violetross/Desktop/TA Data Science/Stringr Lesson/courses.csv")



