from flask import Flask
from argparse import ArgumentParser

app = Flask(__name__)
parser = ArgumentParser()

parser.add_argument("--show-words", help="自定義顯示文字", dest="showWords", default="Hello World!!!")

showWords = ""

@app.route('/')
def hello():
    return showWords

if __name__ == '__main__':
    args = parser.parse_args()
    showWords = args.showWords

    app.run(debug=True,host='0.0.0.0')
