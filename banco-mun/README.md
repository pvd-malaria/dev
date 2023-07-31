# Objetivo

Este banco foi criado como forma de centralizar informações de fontes distintas em formato comparável e relativo ao nível municipal, de tal forma a facilitar análises estatísticas  a partir de um framework analítico para o controle, a vigilância e a eventual eliminação da malária.

# Grupos de variáveis

Segundo a OMS, é possível estratificar o risco da malária em 4 níveis:

- Ecológico (receptividade)
- População (vulnerabilidade)
- Epidemiológico
- Intervenção

Desta forma, procurou-se reunir informações referentes a estes níveis em grupos de variáveis que, embora não representem uma relação direta com um nível específico, podem fornecer informações sobre uma dimensão do problema. Nesse sentido, separamos as variáveis do banco nos seguintes grupos:

1. Volume e distribuição da população
2. Estrutura da população
3. Mobilidade populacional
4. Variáveis socioeconômicas
5. Ambiente e clima
6. Saúde e epidemiologia

# Fontes de dados

Deu-se preferência a estatísticas oficiais, por sua confiabilidade e facilidade de acesso. A maior parte dos dados sobre os municípios é disponibilizada pelo IBGE através de pesquisas domiciliares como o CENSO e a PNAD, bem como algumas pesquisas de cunho econômico. As informações sobre ambiente e clima são disponibilizadas pelo INPE e o INMET e as informações de saúde são, em sua maioria, disponibilizadas por algum dos sistemas do Ministério da Saúde, como o SIVEP Malária e o CNES.

# Descrição das variáveis

No momento em que este documento foi escrito, fazem parte do banco informações sobre:

- Volume populacional
- Taxa de crescimento
- Grau de urbanização
- Estrutura por idade e sexo
- Nível de instrução
- Raça/cor
- Renda mensal per capita
- Volumes e taxas de migração
- PIB municipal
- IDH
- Setores de atividade
- Desmatamento, cobertura florestal e hidrografia
- Área do município
- Infraestrutura de saúde
- Médicos por 1000 habitantes
- Taxa de incidência (IPA) de malária
- Proporção de casos falciparum e vivax
- Proporção de casos notificados por detecção ativa
- Estabelecimentos de saúde por nível de atenção, tipo de atendimento.

As variáveis cuja inclusão no banco estão atualmente planejadas são:

- Clima: precipitação, temperatura, umidade relativa
- Equipes de saúde família

# Organização das variáveis no banco

O banco está organizado no formato wide, em que cada linha/observação do banco representa um município e todas as informações de todos os períodos se abrem em colunas. O banco foi organizado a partir do pressuposto de que softwares estatísticos como o R tem a capacidade de selecionar múltiplas variáveis e reformatar quando necessário e, portanto, ao preservar a unidade 1 município = 1 linha, era possível armazenar informações de fontes e períodos distintos em uma única tabela, sem a necessidade de executar joins posteriores. Vejamos por exemplo, a variável de Raça/Cor.

| name_2019_g0          | racaBranca_2000_g2 | racaPreta_2000_g2 | racaAmarela_2000_g2 | racaParda_2000_g2 | racaIndigena_2000_g2 |
| --------------------- | ------------------ | ----------------- | ------------------- | ----------------- | -------------------- |
| Alta Floresta D'Oeste | 0.546              | 0.0326            | 0.00128             | 0.407             | 0.01000              |
| Ariquemes             | 0.503              | 0.0595            | 0.00503             | 0.406             | 0.00618              |

Este pequeno excerto foi produzido com o comando em R

```r
bd %>% select(name_2019_g0, starts_with("raca"))
```
Onde `bd` é o nome do objeto que representa o banco de dados. Ele procura ilustrar as características de organização do banco. São elas:

Convenção de nomes: o primeiro campo representa o nome da variável, seguido de suas categorias em formato `camelCase`. Em seguida, em formato `snake_case` vem o período ao qual se refere a informação e o grupo do qual ela faz parte. Essa estrutura permite a seleção rápida de conjuntos de variáveis através de atalhos como `starts_with()`, `ends_with` e comandos equivalentes em softwares estatísticos.

Preferência por proporções e taxas comparáveis: onde possível, utilizamos variáveis que padronizam o peso do tamanho de cada município sobre indicador, como proporções de categorias ao invés de contagens, taxas anuais, etc.
