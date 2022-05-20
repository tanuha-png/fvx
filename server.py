from flask import (
    Flask, request, url_for,
    send_from_directory, make_response, render_template)

from markupsafe import escape
import requests as rq
from lxml.html import fromstring
from SPARQLWrapper import SPARQLWrapper, JSON, XML, RDFXML
from json import dumps


app = Flask(__name__)

# app.route('/<path:subpath>')

BASE_URL = "http://localhost:5000/static/"

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
    resp = make_response(kg)
    resp.content_type = "text/xml"
    return resp


@app.route('/static/<path:path>')
def send_report(path):
    return send_from_directory('static', path)


POL_SERVER_EP = "http://irnok.net:3030/sparql"

GET_SAMPLES = """
PREFIX wgs: <http://www.w3.org/2003/01/geo/wgs84_pos#>

SELECT ?probe ?lat ?long WHERE {
  ?probe a <http://dbpedia.org/page/Sample_(material)> .
  ?probe wgs:lat ?lat .
  ?probe wgs:long ?long .
}

LIMIT 10"""

LIST_HTML = """
 <head>
  <meta charset="utf-8" />
 </head>
 <body>
  <ul>
  {}
  </ul>
 </body>
</html>
"""


@app.route('/samples')
def sample_list():
    sparql = SPARQLWrapper("http://irnok.net:3030/sparql")
    # sparql.setReturnFormat(RDFXML)
    sparql.setReturnFormat(JSON)
    sparql.setQuery(GET_SAMPLES)
    results = sparql.queryAndConvert()
    # probes = [r['probe']['value'] for r in results["results"]["bindings"]]
    probes = [[r['probe']['value'],
               r["lat"]["value"],
               r['long']['value']] for r in results["results"]["bindings"]]
    #lp = "\n<br/>".join(["<li>{} {} {}</li>".format(*p) for p in probes])
    return render_template("samples.html", probes=probes)
    # return dumps(results["results"]["bindings"])
    # return results.toxml(encoding="utf-8")


# url_for('static', filename='fvx-html.xsl')
# url_for('static', filename='fvx-json.xsl')
# url_for('static', filename='foaf-vix.css')
# url_for('static', filename='foaf-vix.js')
