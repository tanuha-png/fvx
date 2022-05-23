from flask import (
    Flask, request, url_for,
    send_from_directory, make_response, render_template)
from rdflib import Graph
import requests as rq
from pprint import pprint
from SPARQLWrapper import SPARQLWrapper, JSON, XML, RDFXML



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
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?probe ?label ?lat ?long WHERE {
  ?probe a <http://dbpedia.org/page/SampleMaterial> .
  ?probe rdfs:label ?label .
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


def getsamplesfromsite(site):
    sparql = SPARQLWrapper(site)
    sparql.setReturnFormat(JSON)
    sparql.setQuery(GET_SAMPLES)

    results = sparql.queryAndConvert()
    probes = [[r['probe']['value'],
               r['label']['value'],
               r["lat"]["value"],
               r['long']['value']] for r in results["results"]["bindings"]]
    return probes


KG_FILENAME="fvx/database-from-python.ttl"

KG = Graph()
KG.parse(KG_FILENAME)


def getsamplesfromfile(filename):
    results = KG.query(GET_SAMPLES)
    return results

def getfromlocal(query, initBindings=None):
    if initBindings is None:
        return KG.query(query)
    else:
        return KG.query(query, initBindings=initBindings)

@app.route('/samples')
def sample_list():
    #probes = getsamplesfromsite("http://irnok.net:3030/sparql")
    probes = getsamplesfromfile()
    pprint(list(probes))
    return render_template("samples.html", probes=probes)


SELECT_AMOUNTS = """
PREFIX wgs: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX gp: <http://irnok.net/ontology/geopollution#>
PREFIX base: <http://irnok.net/ontology/geopollution/>

  SELECT ?element ?amount ?unit ?uName WHERE {
  ?probe a <http://dbpedia.org/page/SampleMaterial> .
  base:UGS-0212 base:contains  ?elAmount .
  ?elAmount gp:amount ?amount .
  ?elAmount gp:pollutedBy ?element .
  ?elAmount gp:unit ?unit .

  SERVICE <https://dbpedia.org/sparql> {
      ?element rdfs:label ?elName .
      ?unit rdfs:label ?uName .
      FILTER (
        langMatches(lang(?elName), 'ru')
        &&
        langMatches(lang(?uName), 'ru')
      )
    }
}
 LIMIT 10
"""

@app.route('/probe')
def sampe_edit():
    uri = request.args.get('uri')
    q = SELECT_AMOUNTS.replace("URI", uri)
    print(q)
    data = getfromlocal(q)
    print(list(data))
    return render_template("probe.html")

# url_for('static', filename='fvx-html.xsl')
# url_for('static', filename='fvx-json.xsl')
# url_for('static', filename='foaf-vix.css')
# url_for('static', filename='foaf-vix.js')
