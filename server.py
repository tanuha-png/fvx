from pprint import pprint
from flask import (Flask, request, url_for, send_from_directory, make_response,
                   render_template)
from rdflib import Graph
import requests as rq
from pprint import pprint
from SPARQLWrapper import SPARQLWrapper, JSON, XML, RDFXML
import os

app = Flask(__name__)

# app.route('/<path:subpath>')

BASE_URL = "http://localhost:5000/static/"

<<<<<<< HEAD
#if os.system == "nt":
KG_FILE_DIR = "../vkr/"
#else:
  #  KG_FILE_DIR = "../GeoGisKG/"
=======
if os.system == "nt":
    KG_FILE_DIR = "../vkr/"
else:
    KG_FILE_DIR = "../GeoGisKG/"
>>>>>>> eug/master

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
        kgs = kgs[:1] + [FVX_HTML] + kgs[1:]
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

PREFIXES = """
PREFIX wgs: <http://www.w3.org/2003/01/geo/wgs84_pos#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX gp: <http://irnok.net/ontology/geopollution#>
PREFIX base: <http://irnok.net/database/geopollution#>
"""

GET_SAMPLES = PREFIXES + """
SELECT ?probe ?label ?lat ?long WHERE {
  ?probe a <http://dbpedia.org/resource/Sample_(material)> .
  ?probe rdfs:label ?label .
  ?probe wgs:lat ?lat .
  ?probe wgs:long ?long .
}
ORDER BY ?label 
LIMIT 200"""


GET_WP_AP = PREFIXES + """
SELECT ?text WHERE {
    @WHAT@ a <http://dbpedia.org/resource/Sample_(material)> .
    @WHAT@ wgs:@WHAT@ @TEXT@
}
LIMIT 1
"""

DEL_WP_AP = PREFIXES + """
DELETE {
    @WHAT@ wgs:@WHAT@ @TEXT@ .
} WHERE {
    @WHAT@ a <http://dbpedia.org/resource/Sample_(material)> .
    @WHAT@ wgs:@WHAT@ @TEXT@ .
}
"""

INS_WP_AP = PREFIXES + """
INSERT {
    @WHAT@ wgs:@WHAT@ @TEXT@ .
} WHERE {
    @WHAT@ a <http://dbpedia.org/resource/Sample_(material)> .
    # @WHAT@ wgs:@WHAT@ @TEXT@ .
}
"""

def getsamplesfromsite(site):
    sparql = SPARQLWrapper(site)
    sparql.setReturnFormat(JSON)
    sparql.setQuery(GET_SAMPLES)

    results = sparql.queryAndConvert()
    probes = [[
        r['probe']['value'], r['label']['value'], r["lat"]["value"],
        r['long']['value']
    ] for r in results["results"]["bindings"]]
    return probes

QUERIES = [
        (("lat", "long"), [GET_WP_AP,DEL_WP_AP,INS_WP_AP]),
    ]

def gettemplate(what):
    for t, qs in QUERIES:
        if what in t:
            templ = qs
    return templ

# KG_FILENAME = KG_FILE_DIR+"database-from-python.ttl"
KG_FILENAME = KG_FILE_DIR+"database-from-python.rdf"
NAMES_FILENAME = KG_FILE_DIR+"names.rdf"

KG = Graph()
print("INFO: Loading database from {}".format(KG_FILENAME))
KG.parse(KG_FILENAME)
NG = Graph()
NG.parse(NAMES_FILENAME)

NAMES = {}

SELECT_NAMES = PREFIXES + """
SELECT ?ent ?label WHERE {
    ?ent rdfs:label ?label .
}
"""

def load_names():
    r = NG.query(SELECT_NAMES)
    for (e, label) in r:
        NAMES[e] = label

load_names()



def getsamplesfromfile():
    results = KG.query(GET_SAMPLES)
    return results


def getfromlocal(query, initBindings=None):
    if initBindings is None:
        data = KG.query(query)
    else:
        data =  KG.query(query, initBindings=initBindings)
    # data = [
    #     [ label(el) for el in row ]
    #     for row in data
    # ]
    return data



@app.route('/samples')
def sample_list():
    #probes = getsamplesfromsite("http://irnok.net:3030/sparql")
    probes = getsamplesfromfile()
    pprint(list(probes))
    return render_template("samples.html", probes=probes)


SELECT_AMOUNTS = PREFIXES + """
  SELECT ?element ?amount ?unit WHERE {
  <@URI@> a <http://dbpedia.org/resource/Sample_(material)> .
  <@URI@> gp:contains  ?elAmount .
  ?elAmount gp:amount ?amount .
  ?elAmount gp:pollutedBy ?element .
  ?elAmount gp:unit ?unit .
}
  LIMIT 200
"""

def label(en):
    if en in NAMES:
        return NAMES[en]
    else:
        return en


@app.route('/probe')
def sampe_edit():
    uri = request.args.get('uri')
    q = SELECT_AMOUNTS.replace("@URI@", uri)
    print(q)
    data = getfromlocal(q)
    return render_template("probe.html", data=data, label=label)


# url_for('static', filename='fvx-html.xsl')
# url_for('static', filename='fvx-json.xsl')
# url_for('static', filename='foaf-vix.css')
# url_for('static', filename='foaf-vix.js')
