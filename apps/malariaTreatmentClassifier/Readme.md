Malaria treatment scheme classifier.

To execute the classifier call the API using 'POST' method:

/classifier/

Parameters:

[('id_pacie', '0'), ('id_dimea', '0'), ('sexo', '0'), ('raca', '0'), ('niv_esco', '0'), ('cod_ocup', '0'), ('gestante', '0'), ('sintomas', '0'), ('vivax', '0'), ('falciparum', '0'), ('tipo_lam', '0'), ('exame', '0'), ('res_exam', '0'), ('qtd_cruz', '0'), ('hemoparasi', '0')])
     
Return a JSON objetct with probabilities of each predicted class, sample:

{
 "0": "0.26992828",
 "1": "0.7300717",
 "img": "static/imgs/23_Mar_2022_07_40_12.png"
}
