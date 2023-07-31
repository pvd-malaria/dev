from <- dir()
(from <- from[from %in% c("run.R", "sivep_completo.rds")])

to <- "../../beluzo-malaria/surv/"

# dir.create(to)

file.copy(from, to, overwrite = TRUE)
