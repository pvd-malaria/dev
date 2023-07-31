# Notas sobre o processo de linkage

O objetivo geral era encontrar pacientes cujo tratamento de malária havia fracassado, e elas retornavam ao local de atendimento com sintomas novamente. A grande dificuldade é a ausência de identificadores únicos ou, pelo menos, semi-únicos, como nome do paciente, frequentemente utilizados na literatura sobre linkage probabilístico. 

Um dos pressupostos do linkage probabilístico, é que um operador humano seria capaz de identificar únicamente um par de registros, e a abordagem computacional seria um facilitador nesse processo. Este pressuposto não se sustenta na nossa análise, mesmo um operador humano estaria operando dentro de uma lógica de *educated guess*, partindo do princípio de que duas observações com características muito similares, dentro de um determinado intervalo de tempo, devem pertencer ao mesmo indivíduo.

# Datasets originais

O dataset original do SIVEP, utilizando apenas casos positivos e sem inconsistências de preenchimento totalizou 3.575.089 casos, sendo 597.178 retornos para verificação da cura (LVC) e 2.977.911 notificações primárias de malária. Destes, foram removidos casos em que faltasse informação sobre localidades, sexo ou idade dos pacientes, resultando em 557.559 LVCs e 2.815.311 notificações primárias.

# Blocking versus comparação de pares

Dado o alto grau de incerteza sobre unicidade de identificação dos pares, acredito que não é prudente a aplicação de probabilidades sobre as variáveis, como local notificação, local de residência, sexo, idade, etc. Optei por uma abordagem totalmente conservadora partindo do princípio de que é melhor perder um registro 95% similar a outro do que arriscar um linkage incorreto (minimização de beta em detrimento de alfa). Nesse sentido, apliquei uma estratégia de blocking simples que reduziu o número de pares abaixo do número de samples do dataset original e apliquei filtros nesse dataset para garantir que os registros sejam minimamente plausíveis.

# Variáveis de bloqueio

Foram utilizadas como variáveis de bloqueio: 

- "COD_UNIN": código da unidade notificante
- "MUN_RESI": código do município de residência
- "MUN_INFE": código do município onde o paciente se infectou
- "LOC_RESI": código da localidade de residência
- "idade": idade do paciente, em anos
- "SEXO": sexo do paciente
- "COD_OCUP": código da ocupação (trabalho) do paciente
- "NIV_ESCO": código do nível de escolaridade do paciente
- "GESTANTE.": informações sobre pacientes gestantes

Este processo de bloqueio resultou em 1.097.221 de pares possíveis.

# Filtragem de casos possíveis

As variáveis de bloqueio não fazem nenhuma referência temporal, então o processo de filtragem começa pelas datas: cada paciente precisa passar primeiro por uma notificação primária e, dentro de um período de no máximo 60 dias, caso ele retorne para fazer a LVC, ele será notificado novamente. Aqui existe a possibilidade inafastável de erro por se tratar de uma nova infecção, já que a partir de 2011, existe um critério para determinação de LVC, que é a realização de um tratamento anterior entre 40 e 60 dias antes desta nova malária, dependendo do tipo. Os erros que procuramos afastar foram que as datas de exame da LVC devem ser posteriores as datas da notificação primária e a distância entre as duas datas seja menor que 60 dias. Outro erro que procuramos afastar é que o resultado dos exames de LVC e notificação primária sejam consistentes: isso quer dizer que o plasmódio identificado nos dois exames deve obedecer a lógica abaixo:

| Código        | Primeiro Exame | Segundo Exame |
| ------------- | -------------- | ------------- |
| 2-Falciparum  |              2 |        2 ou 3 |
| 3-F+Fg        |              3 |        2 ou 3 |
| 4-Vivax       |              4 |             4 |
| 5-F+V         |              5 |           2-7 |
| 6-V+Fg        |              6 |           2-7 |
| 7-Fg          |              7 |     2, 3 ou 7 |
| 8-Malariae    |              8 |             8 |
| 9-F+M         |              9 |      2-7 ou 9 |
| 10-Ovale      |             10 |            10 |

Esta filtragem reduziu o número de pares para 83.455 e é este o banco apresentado.

# Problemas

Mesmo após esse extenso processo de filtragem, ainda encontramos 22.000 entradas duplicadas, sobre as quais não é possível ter certeza absoluta de que trata-se de um indivíduo único. Existem duas opções então: minha preferência, é que seja abandonado o processo de linkage probabilístico, dado o alto grau de incerteza sobre os matches, mesmo os bem sucedidos. A falta de variáveis mais substantivas de identificação como nome e data de nascimento prejudicam bastante a viabilidade das matches. A alta taxa de casos duvidosos bem como a ausência de variáveis que permitam desambiguar o registro pioram ainda mais as chances de cometer erros beta. A segunda opção é trabalhar com os matches "certeiros", partindo do pressuposto de que não há ambiguidade e que esses registros seguramente pertencem ao mesmo indivíduo. Essa solução é arriscada porque inclusive não há clareza na documentação do banco sobre quais critérios são utilizados no preenchimento de notificações de LVC.

Mesmo adotando um critério mais estrito, utilizando a data de nascimento no lugar da idade, chegamos a 23.571 pares, com 396 duplicados. Isto quer dizer que sob as melhores condições possíveis e com total concordância em todas as características de identificação de um indivíduo, apenas 4,2% dos casos puderam ser linkados. Na minha opinião, isto indica que o processo de linkage não pode seguir adiante devido a incertezas fundamentais sobre a validade dos links.
