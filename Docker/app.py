import os
import sys
from os import walk
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():

    path = str(sys.argv[1])
    filestring = 'Node name: ' + os.environ['COMPUTERNAME'] + '<br />Azure file path: ' + path + '<br />Azure files:<br />' 
    for root, dirs, files in walk(path):
        for filename in files:
            filestring = filestring + filename + "<br />"

    return filestring

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
