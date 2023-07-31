# section_header ------------------------------------------------------------
library(data.table)
library(tidyverse)
library(geobr)
library(sf)

# import ------------------------------------------------------------
data <- read_rds("dados/sivep_datatable.rds")

municipios <- if (file.exists("sivep/municipios_centro.gpkg")) {
  st_read("sivep/municipios_centro.gpkg")
} else {
  read_municipal_seat()
}

limites <- if (file.exists("sivep/municipios_limite.gpkg")) {
  st_read("sivep/municipios_limite.gpkg")
} else {
  read_municipality()
}

# lista de países ---------------------------------------------------
paises <- c("1 - BRASIL", '75 - GANA', '150 - NIGERIA',
            "2 - AFEGANISTAO", '76 - GIBRALTAR', '151 - NIUE',
            "3 - AFRICA-SUL", '77 - GRA-BRETANHA', '152 - NORFOLK',
            "4 - ALBANIA", '78 - GRANADA', '153 - NORUEGA',
            "5 - ALEMANHA", '79 - GRECIA', '154 - NOVA CALEDONIA',
            "6 - ANDORRA", '80 - GROENLANDIA', '155 - NOVA ZELANDIA',
            "7 - ANGOLA", '81 - GUADALUPE', '156 - OMA',
            "8 - ANGUILLA", '82 - GUAM', '159 - PACIFICO',
            "9 - ANTIGUA", '83 - GUATEMALA', '160 - PANAMA',
            "10 - ANTILHAS", '84 - GUIANA', '161 - PAPUA',
            "11 - ARABIA SAUDITA", '85 - GUIANA FRANCESA', '162 - PAQUISTAO',
            "12 - ARGELIA", '86 - GUINE', '163 - PARAGUAI',
            "13 - ARGENTINA", '87 - GUINE-BISSAU', '164 - PASCOA',
            "14 - ARUBA", '88 - GUINE-EQUAT.', '165 - PERU',
            "15 - AUSTRALIA", '89 - HAITI', '166 - PITCAIRN',
            "16 - AUSTRIA", '90 - HOLANDA', '167 - POLINESIA',
            "17 - BAHAMAS", '91 - HONDURAS', '168 - POLONIA',
            "18 - BAHREIN", '92 - HONG-KONG', '169 - PORTO-RICO',
            "19 - BANGLADESH", '93 - HUNGRIA', '170 - PORTUGAL',
            "20 - BARBADOS", '94 - IEMEN', '171 - QUENIA',
            "21 - BELGICA", '95 - IEMEN-EX', '172 - REP. DOMINICANA',
            "22 - BELIZE", '96 - IEMEN-SUL-EX', '173 - REP.CENTRO AFRICANA',
            "23 - BENIN", '97 - INDIA', '174 - REUNIAO',
            "24 - BERMUDAS", '98 - INDONESIA', '175 - ROMENIA',
            "25 - BOLIVIA", '100 - IRA', '176 - RUANDA',
            "26 - BOTSUANA", '101 - IRAQUE', '177 - SAARA-OCIDENTAL',
            "27 - AFARS - TERRITORIO FRANCES", '102 - IRIA-OCID.', '178 - SAINT-PIERRE',
            "28 - BRUNEI", '103 - IRLANDA', '179 - SALOMAO',
            "29 - BULGARIA", '104 - ISLANDIA', '180 - SAMOA-AMERICA',
            "30 - BURKINA", "105 - ISRAEL", "181 - SAMOA-OCIDENTAL",
            "31 - BURUNDI", '106 - ITALIA', '182 - SAN MARINO',
            "32 - BUTAO", '107 - IUGOSLAVIA', '183 - SANTA HELENA',
            "33 - CABO-VERDE", '108 - JAMAICA', '184 - SANTA LUCIA',
            "34 - CAMAROES", '109 - JAPAO', '185 - SAO CRISTOVAO',
            '35 - CAMBOJA', '110 - JOHNSTON', '186 - SAO TOME',
            '36 - CANADA', '111 - JORDANIA', '187 - SAO VICENTE',
            '37 - CANAL', '112 - JUAN-FERNA.', '188 - SENEGAL',
            '38 - CATAR', '113 - KIRIBATI', '189 - SERRA LEOA',
            '39 - CAYMAN', '114 - KUWAIT', '190 - SEYCHELLES',
            '40 - CEUTA', '115 - LAOS', '191 - SIRIA',
            '41 - CHADE', '116 - LESOTO', '192 - SOMALIA',
            '42 - CHILE', '117 - LIBANO', '193 - SRI-LANKA',
            '43 - CHINA', '118 - LIBERIA', '194 - SUAZILANDIA',
            '44 - CHIPRE', '119 - LIBIA', '195 - SUDAO',
            '45 - CHRISTMAS', '120 - LIECHTENST.', '196 - SUECIA',
            '46 - CINGAPURA', '121 - LUXEMBURGO', '197 - SUICA',
            '47 - COCOS', '122 - MACAU', '198 - SURINAME',
            '48 - COLOMBIA', '123 - MADAGASCAR', '199 - TAILANDIA',
            '49 - COMORES', '124 - MALAISIA', '200 - TANZANIA',
            '50 - CONGO', '125 - MALAVI', '201 - TCHECOSLOVAQUIA',
            '51 - COOK', '126 - MALDIVAS', '202 - TIMOR',
            '52 - COREIA-NORTE', '127 - MALI', '203 - TOGO',
            '53 - COREIA-SUL', '128 - MALTA', '204 - TONGA',
            '54 - COSTA-MARFIM', '129 - MALVINAS', '205 - TOQUELAU',
            '55 - COSTA-RICA', '130 - MAN', '206 - TRINIDAD E TOBAGO',
            '56 - CUBA', '131 - MARIANAS', '207 - TUNISIA',
            '57 - DINAMARCA', '132 - MARROCOS', '208 - TURKS',
            '58 - DJIBUTI', '133 - MARTINICA', '209 - TURQUIA',
            '59 - DOMINICA', '134 - MAURICIO', '210 - TUVALU',
            '60 - EGITO', '135 - MAURITANIA', '211 - UGANDA',
            '61 - EL-SALVADOR', '136 - MAYOTTE', '212 - URSS',
            '62 - EMIR.ARABES', '137 - MEXICO', '213 - URUGUAI',
            '63 - EQUADOR', '138 - MIANMA', '214 - VANUATU',
            '64 - ESPANHA', '139 - MIDWAY', '215 - VATICANO',
            '65 - ETIOPIA', '140 - MOCAMBIQUE', '216 - VENEZUELA',
            '66 - EUA', '141 - MONACO', '217 - VIETNA',
            '67 - FARDE', '142 - MONGOLIA', '218 - VIRGENSAMER',
            '68 - FIJI', '143 - MONTSERRAT', '219 - VIRGENSBRIT',
            '69 - FILANDIA', '144 - NAMIBIA', '220 - WAKE',
            '70 - FILIPINAS', '145 - NAURU', '221 - WALLIS',
            '71 - FORMOSA', '146 - NAVES', '222 - ZAIRE',
            '72 - FRANCA', '147 - NEPAL', '223 - ZAMBIA',
            '73 - GABAO', '148 - NICARAGUA', '224 - ZIMBABUE',
            '74 - GAMBIA', '149 - NIGER', '999 - OUTROS') %>%
  tibble(paises = .) %>%
  separate(col = paises,
           into =  c("codigos", "paises"),
           sep = " - ",
           convert = TRUE,
           extra = "merge") %>%
  arrange(codigos) %>%
  mutate(paises = str_to_title(paises))

ponto <- st_point(c(-53.055504, 3.928298), dim = "XYZ")

fg <- tibble(name_long = "Guiana Francesa",
             geom = st_sfc(ponto, crs = 4326)) %>%
  st_sf(agr = "identity", crs = 4326)

world <- spData::world %>%
  select(name_long) %>%
  st_centroid() %>%
  filter(name_long %like% "Guyana" |
           name_long %like% "Venezuela" |
           name_long %like% "Peru" |
           name_long %like% "Bolivia" |
           name_long %like% "Suriname" |
           name_long %like% "Colombia" |
           name_long %like% "France" |
           name_long %like% "Angola" |
           name_long %like% "South Africa") %>%
  rbind(fg) %>%
  mutate(name_long = recode(name_long,
                            'South Africa' = 'Africa-Sul',
                            'France' = 'Franca',
                            'Guyana' = 'Guiana'))

paises <- right_join(paises, world, by = c("paises" = "name_long")) %>%
  st_sf(crs = 4326)

rm(world, fg)

# munge ------------------------------------------------------------
full <-
  data %>%
  as.tbl() %>%
  select(destino = MUN_RESI, origem = MUN_INFE) %>%
  filter(destino != origem) %>%
  count(origem, destino, name = "fluxos") %>%
  arrange(-fluxos)

reduced <-
  data %>%
  as.tbl() %>%
  select(destino = MUN_RESI, origem = MUN_INFE) %>%
  filter(destino != origem) %>%
  count(origem, destino, name = "fluxos") %>%
  filter(fluxos > 48) %>%
  arrange(-fluxos)

estrangeiro <-
  data %>%
  as.tbl() %>%
  select(origem = PAIS_INF, destino = MUN_RESI) %>%
  filter(origem != 1, !is.na(destino)) %>%
  count(origem, destino, name = "fluxos") %>%
  filter(fluxos > 48) %>%
  arrange(-fluxos)

full
reduced
estrangeiro

quantile(pull(full, fluxos), seq(0, 1, 0.01))
quantile(pull(estrangeiro, fluxos), seq(0,1,0.05))

cases <- bind_rows(reduced, estrangeiro)
cases

paises <- paises %>%
  rename(code = codigos, name = paises) %>%
  mutate(lon = st_coordinates(.)[,"X"],
         lat = st_coordinates(.)[,"Y"])

st_geometry(paises) <- NULL

municipios2 <- municipios %>%
  mutate(code = as.integer(substr(code_muni, 1, 6))) %>%
  select(code, name = name_muni) %>%
  st_make_valid() %>%
  st_transform(crs = 4326) %>%
  mutate(lon = st_coordinates(.)[,"X"],
         lat = st_coordinates(.)[,"Y"])

st_geometry(municipios2) <- NULL

locations <- bind_rows(paises, municipios2)

fluxo <-
  left_join(cases, locations, by = c("origem" = "code")) %>%
  left_join(locations, by = c("destino" = "code"),
            suffix = c(".origem", ".destino")) %>%
  mutate(stroke = fluxos/400,
         info = enc2native(paste0(name.origem, "->",
                                  name.destino, ": ",
                                  fluxos)))
arrange(fluxo, fluxos)

limites2 <- limites %>%
  st_make_valid() %>%
  st_transform(crs = 4326) %>%
  st_cast("POLYGON") %>%
  mutate(code = as.integer(substr(code_muni, 1, 6))) %>%
  select(code, name = name_muni) %>%
  filter(code %in% c(fluxo$origem, fluxo$destino))

limites2$name <- enc2native(as.character(limites2$name))

# save ------------------------------------------------------------
withr::with_dir("sivep/",{
  write_excel_csv2(fluxo, "07_fluxo_data.csv.xz")
  st_write(limites2, "07_limites_data.gpkg")
})

