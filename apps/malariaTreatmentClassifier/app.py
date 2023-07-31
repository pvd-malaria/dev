from flask import Flask, render_template, request, make_response
import pandas as pd
import glob
import json
from xgboost import XGBClassifier
from datetime import datetime


def plot_results(df, exec_id):
    # plot a Stacked Bar Chart using matplotlib
    df.plot(kind='barh',
            stacked=True,
            title='Probabilidade de tratamento 11',
            figsize=(4, 2),
            mark_right=True).get_figure().savefig('static/imgs/' + exec_id + '.png')


app = Flask(__name__)
app.config['SECRET_KEY'] = ''

messages = []
features = {}

print("Loading malaria_model...")
malaria_model = XGBClassifier()
malaria_model.load_model("static/xgb_model.bin")
print("Done!")

print("Loading feature labels")
with open('static/labels.json') as json_file:
    labels = json.load(json_file)
print("Done!")

print("Loading features values")
for f in glob.glob("static/cols/*"):
    df_cols = pd.read_csv(f).drop('Unnamed: 0', axis=1, inplace=False)
    features[df_cols.columns[0]] = df_cols
print("Done!")


@app.route('/')
def index():
    return render_template('index.html', messages=messages)


@app.route('/classifier/', methods=('GET', 'POST'))
def classifier():
    if request.method == 'POST':
        exec_id = datetime.now().strftime("%d_%b_%Y_%H_%M_%S")
        features_dict = request.form.to_dict()
        print('exec_id: ' + exec_id)
        print(request.form)

        # VERIFICAR ORDEM DO VERTOR DE FEATURES
        input_features = pd.DataFrame(features_dict, index=[0], dtype="int")

        result_proba = malaria_model.predict_proba(input_features)
        print(pd.DataFrame(result_proba))

        plot_results(pd.DataFrame(result_proba), exec_id)

        result = {
            "0": str(result_proba[0][0]),
            "1": str(result_proba[0][1]),
            "img": 'static/imgs/' + exec_id + '.png'
        }

        response = make_response(json.dumps(result), 200)
        response.mimetype = "application/json"
        return response

    return render_template('classifier.html', features=features, messages=messages, labels=labels)
