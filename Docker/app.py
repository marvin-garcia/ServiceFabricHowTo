from os import walk
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():

    path = '\\\\servicefabric3storage.file.core.windows.net\\fileshare'
    filestring = ""
    for root, dirs, files in walk(path):
        for filename in files:
            filestring = ", %s" % (filename)

    return filestring

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)