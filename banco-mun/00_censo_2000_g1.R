# Censo subarq generator ------------------------------------------------------
# Pkgs/opts
rm(list = ls()); gc()

xfun::pkg_attach("tidyverse", "microdadosBrasil")

# Import ----------------------------------------------------------------------
# variaveis
vars <- c(
  mun         = "V0103"
  , ctrl      = "V0300"
  , sitru     = "V1006"
  , idade     = "V4752"
  , raca      = "V0408"
  , data_fixa = "V4250"
  , an_est    = "V4300"
  , sexo      = "V0401"
  , rend_to   = "V4614"
  , peso      = "PES_PESSOA"
)

# check with import dicionary
dic <- get_import_dictionary('CENSO', 2000, 'pessoas')

stopifnot(all(vars %in% dic$var_name))

# arquivos
paths <- dir(path = "../dados/cd00",
             pattern = "^PES",
             ignore.case = TRUE,
             recursive = TRUE,
             full.names = TRUE)

# importação

suppressMessages({

  censo <- map_dfr(
    .x = paths,
    .f = read_CENSO,
    ft = "pessoas",
    i = 2000,
    root_path = NULL,
    vars_subset = vars
  )

})

# consistência ----------------------------------------------------------------
stopifnot(all(names(censo) %in% vars))

x <- names(censo)
for (i in seq_along(x)) {
  names(censo)[i] <- attr(vars, "name")[which(x[i] == vars)]
}

tibble(x, names(censo))

head(censo)

# exportação ------------------------------------------------------------------
file = "censo_2000.rds"
write_rds(censo, file)

cat(paste0("O arquivo ", file, " foi criado com sucesso."))
