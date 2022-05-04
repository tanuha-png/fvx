from flask import Flask, request

from markupsafe import escape
import requests as rq
from lxml.html import fromstring


app = Flask(__name__)

# app.route('/<path:subpath>')

BASE_URL = "http://localhost:5000/"

HTML_DEF = """<html>
 <head>
  <meta charset="utf-8" />
 </head>
 <body>
  <a href="?https://wojciechpolak.org/foaf.rdf">Run an example</a>
 </body>
</html>
"""

FVX_HTML = '<?xml-stylesheet type="text/xsl"'\
    ' href="{}fvx-html.xsl?v=1.0"?>'.format(
        BASE_URL)


@app.route('/')
def show_subpath():
    # show the subpath after /path/
    try:
        rc = rq.get(request.args['uri'])
        kg = rc.text
        kgs = kg.split('\n')
        kgs = kgs[:1]+[FVX_HTML] + kgs[1:]
        kg = '\n'.join(kgs)
    except KeyError:
        return HTML_DEF
    return kg


url_for('static', filename='fvx-html.xsl')
