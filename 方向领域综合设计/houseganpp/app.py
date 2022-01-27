from flask import Flask, request, send_file

import numpy as np
from generate import generate as gen

app = Flask(__name__)

@app.route("/generate", methods=['POST'])
def generate():
    real_nodes = request.json['nodes']
    nds = np.eye(18)[real_nodes].tolist()
    eds = request.json['edges']
    gen(nds, eds)
    return send_file('./dump/fp_final_generate.png', mimetype='image/png')
