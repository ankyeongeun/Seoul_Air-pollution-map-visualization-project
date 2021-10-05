library(rvest)
library(httr)


service_key = serviceKey
#발급된 서비스키을 service_key 변수에 할당


url = paste0("http://openapi.airkorea.or.kr/openapi/services/rest/",
             "ArpltnInforInqireSvc/getCtprvnMesureSidoLIst?",
             "sidoName=서울",
             "&searchCondition=DAILY",
             "&pageNo=",1,
             "&numOfRows=",25,
             "&ServiceKey=",service_key)
url_get = GET(url)
#URL을 GET방식으로 호출하여 데이터 요청
#url 만들기


url_xml = read_xml(url_get)
url_xml


item_list = xml_nodes(url_xml, 'items item')
#XML 형식으로 저장된 url_xml 변수에서 아래의 노드로 이동하여 필요한 데이터 수집
item_list[[1]]

tmp_item = xml_children(item_list[[1]])
tmp_item

item_list = lapply(item_list, function(x) return(xml_text(xml_children(x))))
item_list[[1]]

item_list[[2]]


item_dat = do.call('rbind',item_list)
item_dat = data.frame(item_dat, stringsAsFactors = F)
head(item_dat)
tmp = xml_nodes(url_xml, 'items item') 
colnames_dat = html_name(xml_children(tmp[[1]]))
colnames_dat
colnames(item_dat) = colnames_dat
head(item_dat)

View(item_dat)

#데이터 모으기
air_data = NULL
while(1)
{
  url = paste0("http://openapi.airkorea.or.kr/openapi/services/rest/",
               "ArpltnInforInqireSvc/getCtprvnMesureSidoLIst?",
               "sidoName=서울",
               "&searchCondition=DAILY",
               "&pageNo=",1,
               "&numOfRows=",600,
               "&ServiceKey=",service_key)
  url_xml = read_xml(GET(url))
  item_list = url_xml %>% xml_nodes('items item')
  item_list = lapply(item_list, function(x) return(xml_text(xml_children(x))))
  item_dat = do.call('rbind',item_list)
  item_dat = data.frame(item_dat, stringsAsFactors = F)
  names(item_dat) <- colnames_dat
  air_data = rbind(item_dat, air_data)
  Sys.sleep(3600)
  write.csv(air_data, "air_data.csv", row.names = F)
  cat(item_dat$dataTime[1],'\n')
}


#---------------------------------------------------shiny
library(shiny)
ui = fluidPage(
  titlePanel("Welcome shiny!"),
  sidebarLayout(
    sidebarPanel(
      textInput("input_text", "텍스트를 입력하세요.")
    ),
    mainPanel(
      textOutput("output_text")
    )
  )
)


server = function(input, output)
{
  return(NULL)
}


server = function(input, output)
{
  output$output_text = renderText({
    input$input_text
  })
}
shinyApp(ui = ui, server= server)


#---------------------------------------------------find dust by shiny


url = paste0("http://openapi.airkorea.or.kr/openapi/services/rest/",
             "ArpltnInforInqireSvc/getCtprvnMesureSidoLIst?",
             "sidoName=서울",
             "&searchCondition=DAILY",
             "&pageNo=",1,
             "&numOfRows=",600,
             "&ServiceKey=",service_key)
url_xml = xml(GET(url))
item_list = url_xml %>% xml_nodes('items item')
item_list = lapply(item_list, function(x) return(xml_text(xml_children(x))))
item_dat = do.call('rbind',item_list)
item_dat = data.frame(item_dat, stringsAsFactors = F)
item_dat[item_dat == '-'] = 0
tmp = xml_nodes(url_xml, 'items item') 
colnames_dat = xml_tag(xml_children(tmp[[1]]))
colnames(item_dat) = colnames_dat


library(ggmap)
uniq_region = unique(item_dat$cityName)
geo_dat = geocode(paste("서울특별시", uniq_region))
geo_dat = cbind(cityName = uniq_region, geo_dat)
head(geo_dat)

item_dat = merge(item_dat, geo_dat, by = "cityName")
head(item_dat)
write.csv(item_dat, 'air_quality.csv', row.names = F)

dat = read.csv('air_quality.csv') #읽어와야 함~
View(dat)

ui = fluidPage(
  titlePanel("Air quality data visualization"),
  sidebarLayout(
    sidebarPanel(
      selectInput('region', 'cityName', choices = sort(unique(dat$cityName))),
      selectInput('date', 'dataTime', choices = sort(unique(dat$dataTime))),
      selectInput('category', 'category', choices = colnames(dat)[3:8])
    ),
    mainPanel(
      plotOutput("hist1"),
      plotOutput("hist2")
    )
  )
)



server = function(input, output)
{
  return(NULL)
}
shinyApp(ui = ui, server = server)
# 슬라이드 49까지 만들었음


