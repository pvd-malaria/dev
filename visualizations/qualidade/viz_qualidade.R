library(tidyverse)
library(ggdark)


viz <- readxl::read_excel("qualidade.xlsx") %>% 
  janitor::clean_names() # column names to lowercase

summary(viz)

v1<-ggplot(data=viz,
          aes(x = ano, y = missing))+
  geom_point(color="magenta3",  size=3) +
  facet_wrap(~uf)+
  theme_gray()+
  scale_x_continuous(breaks = scales::breaks_width(1))+
  coord_cartesian(ylim=c(0,1))+
  labs(title = "Porcentagem de informações ausentes segundo variável e UF, 2007-2019",
       x = "Ano",
       y = "% de informações ausentes"
       )+
  dark_theme_gray()

v1

  
  
  
  
