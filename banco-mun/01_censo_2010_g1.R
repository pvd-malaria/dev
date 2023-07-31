# Censo subarq generator ------------------------------------------------------
# Pkgs/opts
rm(list = ls()); gc()

xfun::pkg_attach("tidyverse", "microdadosBrasil")

# Import ----------------------------------------------------------------------

# variaveis

vars <- c(
    uf        = "V0001"
  , mun       = "V0002"
  , ctrl      = "V0300"
  , peso      = "V0010"
  , sitru     = "V1006 "
  , sexo      = "V0601"
  , idade     = "V6036"
  , raca      = "V0606"
  , data_fixa = "V6264"
  , nv_ins    = "V6400"
  , rend_pc   = "V6531"
)

# check with import dicionary

dic <- get_import_dictionary('CENSO', 2010, 'pessoas')

stopifnot(all(vars %in% dic$var_name))

# arquivos

paths <- dir(path = "../dados/cd10",
             pattern = "Pessoas",
             recursive = TRUE,
             full.names = TRUE)

# importação

suppressMessages({

  censo <- map_dfr(
    .x = paths,
    .f = read_CENSO,
    ft = "pessoas",
    i = 2010,
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

file = "censo_2010.rds"

write_rds(censo, file)

cat(paste0("O arquivo ", file, " foi criado com sucesso."))
