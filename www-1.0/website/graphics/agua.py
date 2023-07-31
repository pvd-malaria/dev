from django.conf import settings
import pandas as pd
import numpy as np
import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output, State
import plotly.graph_objs as go

stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css', 'https://pastebin.com/raw/gUTNSAa4']

ufs = {
	11: 'RO', 12: 'AC', 13: 'AM', 14: 'RR', 15: 'PA', 16: 'AP', 17: 'TO',
	21: 'MA', 22: 'PI', 23: 'CE', 24: 'RN', 25: 'PB', 26: 'PE', 27: 'AL', 28: 'SE', 29: 'BA',
	31: 'MG', 32: 'ES', 33: 'RJ', 35: 'SP',
	41: 'PR', 42: 'SC', 43: 'RS',
	50: 'MS', 51: 'MT', 52: 'GO', 53: 'DF'
}

regioes = {
	'Norte': list(range(11, 18)),
	'Nordeste': list(range(21, 30)),
	'Sudeste': [31, 32, 33, 35],
	'Sul': [41, 42, 43],
	'Centro-Oeste': list(range(50, 54))
}

regCores = {
    'Norte': '#01cdfe',
    'Nordeste': '#fffb69',
    'Sudeste': '#05ffa1',
    'Sul': '#b967ff',
    'Centro-Oeste': '#ff71ce'
}

def obterRegiao(ufid):
	for reg in regioes:
		if ufid in regioes[reg]:
			return reg

dfMortalidade = pd.read_csv(settings.STATIC_URL_ROOT + '/graphics/agua/mortalidade.csv')
dfAgua = pd.read_csv(settings.STATIC_URL_ROOT + '/graphics/agua/agua.csv')

df = dfMortalidade.rename(columns={'2000': 'M2000', '2010': 'M2010'})

df['A2000'] = dfAgua['2000']
df['A2010'] = dfAgua['2010']

df['Cod'] = df['UF']
df['UF'] = df['Cod'].apply(lambda x: ufs[x])
df['Região'] = df['Cod'].apply(lambda x: obterRegiao(x))

df = df[['Cod', 'UF', 'Região', 'M2000', 'A2000', 'M2010', 'A2010']]

ACCUM_STEP = 0.15
ACCUM_SKIP = 0.5
ACCUM_INICIO = -((27 * ACCUM_STEP) + (4 * ACCUM_SKIP)) / 2
SPAN_ANOS = 8
MAX_WIDTH = (27 * ACCUM_STEP) + (4 * ACCUM_SKIP) + 2

accum = ACCUM_INICIO
nRegs = [k for k in regioes]
ufCtr = 0
def cumsum(x):
	global accum, nRegs, ufCtr

	k = x + accum

	accum += ACCUM_STEP

	ufCtr += 1
	if ufCtr >= len(regioes[nRegs[0]]):
		ufCtr = 0
		nRegs.pop(0)
		accum += ACCUM_SKIP
	return k

df2000 = df.copy()
df2000['Ano'] = 2000
df2000['PosX'] = df2000['Ano'].apply(lambda x: cumsum(x))
accum = ACCUM_INICIO
nRegs = [k for k in regioes]
ufCtr = 0
df2000.rename(columns={'M2000': 'Mortalidade', 'A2000': 'Abastecimento'}, inplace = True)
df2000 = df2000[['Cod', 'UF', 'Região', 'Ano', 'Mortalidade', 'Abastecimento', 'PosX']]
df2000['Raio'] = df2000['Mortalidade']
df2000['Raio'] = df2000['Raio'].apply(lambda x: 2 * x / df2000['Abastecimento'].apply(lambda y: y / 100))

df2010 = df.copy()
df2010['Ano'] = 2010
df2010['PosX'] = df2010['Ano'].apply(lambda x: cumsum(x))
df2010.rename(columns={'M2010': 'Mortalidade', 'A2010': 'Abastecimento'}, inplace = True)
df2010 = df2010[['Cod', 'UF', 'Região', 'Ano', 'Mortalidade', 'Abastecimento', 'PosX']]
df2010['Raio'] = df2010['Mortalidade']
df2010['Raio'] = df2010['Raio'].apply(lambda x: 2 * x / df2010['Abastecimento'].apply(lambda y: y / 100))

df = pd.concat([df2000, df2010])

del dfMortalidade, dfAgua, df2000, df2010

def dispatcher_agua(request):
    '''
    Main function
    @param request: Request object
    '''

    app = _create_app()
    params = {
        'data': request.body,
        'method': request.method,
        'content_type': request.content_type
    }
    with app.server.test_request_context(request.path, **params):
        app.server.preprocess_request()
        try:
            response = app.server.full_dispatch_request()
        except Exception as e:
            response = app.server.make_response(app.server.handle_exception(e))
        return response.get_data()

def _create_app():
    app = dash.Dash(__name__, external_stylesheets=stylesheets)

    app.layout = html.Div(children = [
        html.Div(children = [
                html.H3(children=['Selecione uma UF:'], style = { 'marginBottom': '0px' }),
                html.Br(),
                dcc.Dropdown(
                    id = 'dd-estado',
                    options = [
                        { 'label': 'Todos', 'value': '*'},
                    ] + [ { 'label': ufs[i], 'value': i } for i in ufs ],
                    value = '*',

                ),
                html.Br()
            ],
            style = {
                'backgroundColor': '#e4e4e4',
                'margin': '0 auto',
                'width': '60%',
                'textAlign': 'center',
                'fontFamily': 'sans-serif',
            }
        ),
        dcc.Graph(
            id = 'relacao-agua',
            figure = { },
        )
    ])
    @app.callback(
    Output('relacao-agua', 'figure'),
    [Input('dd-estado', 'value')])

    def update_output(estado):
        dt = []
        ultimaRegiao = ''
        for i in df['Cod'].unique():
            scatter = go.Scatter(
                x = df[df['Cod'] == i]['PosX'],
                y = df[df['Cod'] == i]['Abastecimento'],
                mode = 'markers+text',
                textposition = 'middle left',
                text = df[df['Cod'] == i]['UF'],
                marker = {
                    'size': df[df['Cod'] == i]['Raio'],
                    'line': { 'color': 'black', 'width': 1 },
                    'color': regCores[obterRegiao(i)],
                },
                name = obterRegiao(i),
                hoverinfo = 'text',
                hovertext = df[df['Cod'] == i]['Mortalidade'].apply(lambda x: '%.2f‰ (†)<br>' % x) \
                            + df[df['Cod'] == i]['Abastecimento'].apply(lambda x: '%d%% (💧)' % x),
                hoverlabel = {
                    'bgcolor': 'white',
                    'bordercolor': 'white',
                    'font': { 'color': 'black', 'size': 16 }
                },
                showlegend = False,
            )
            if estado != '*':
                if estado != i:
                    scatter.opacity = 0.25
            obtReg = obterRegiao(i)
            if obtReg != ultimaRegiao:
                ultimaRegiao = obtReg
                scatter.legendgroup = 'legendgroup-1'
                scatter.showlegend = True
            dt.append(scatter)
        fig = {
            'data': dt,
            'layout': go.Layout(
                paper_bgcolor='#e4e4e4',
                plot_bgcolor='#e4e4e4',
                xaxis = {
                    'title': 'Ano',
                    'tickvals': [2000, 2010],
                    'range': [1995, 2015]
                },
                yaxis = {
                    'title': 'Abastecimento de Água (%)',
                    'range': [70, 104],
                },
                height = 800,
                hovermode = 'closest',
                shapes = [
                    go.layout.Shape(
                        type = 'rect',
                        x0 = 2000 - MAX_WIDTH / 2,
                        y0 = 72,
                        x1 = 2000 + MAX_WIDTH / 2,
                        y1 = 103,
                        line = {
                            'color': 'crimson',
                        },
                    ),
                    go.layout.Shape(
                        type = 'rect',
                        x0 = 2010 - MAX_WIDTH / 2,
                        y0 = 72,
                        x1 = 2010 + MAX_WIDTH / 2,
                        y1 = 103,
                        line = {
                            'color': 'royalblue',
                        },
                    ),
                ],
                showlegend = True,
            )
        };
        return fig

    return app

if __name__ == '__main__':
    app = _create_app()
    app.run_server()