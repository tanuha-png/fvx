from pprint import pprint
from flask import (Flask, request, url_for, send_from_directory, make_response,
                   render_template, jsonify)
from rdflib import Graph, URIRef
import requests as rq
from pprint import pprint
from SPARQLWrapper import SPARQLWrapper, JSON, XML, RDFXML
from lxml import etree

import os
import os, io, json
import requests
from html import escape

# from pyRdfa import pyRdfa

app = Flask(__name__)

# app.route('/<path:subpath>')

BASE_URL = "http://localhost:5000/static/"
DISTILLER_URL = "http://rdf.greggkellogg.net/distiller"

#if os.system == "nt":
KG_FILE_DIR = "..\\vkr\\"
#else:
 #   KG_FILE_DIR = "../GeoGisKG/"

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
    (("lat", "long"), [GET_WP_AP, DEL_WP_AP, INS_WP_AP]),
]


def gettemplate(what):
    for t, qs in QUERIES:
        if what in t:
            templ = qs
    return templ


# KG_FILENAME = KG_FILE_DIR+"database-from-python.ttl"
KG_FN = "database-from-python.rdf"
KG_FILENAME = KG_FILE_DIR + KG_FN
NAMES_FILENAME = KG_FILE_DIR + "names.rdf"


def binds(g):
    g.bind("owl", URIRef("http://www.w3.org/2002/07/owl#"))
    g.bind("rdf", URIRef("http://www.w3.org/1999/02/22-rdf-syntax-ns#"))
    g.bind("gp", URIRef("http://irnok.net/ontology/geopollution#"))
    g.bind("gpdb", URIRef("http://irnok.net/ontology/database/"))
    g.bind("dbr", URIRef("http://dbpedia.org/resource/"))
    g.bind("wgs", URIRef("http://www.w3.org/2003/01/geo/wgs84_pos#"))
    g.bind("rdfs", URIRef("http://www.w3.org/2000/01/rdf-schema#"))


KG = Graph()
binds(KG)
print("INFO: Loading database from {}".format(KG_FILENAME))
KG.parse(KG_FILENAME)

NG = Graph()
binds(NG)
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
        NAMES[str(e)] = label


load_names()


#def getsamplesfromfile():
 #   results = KG.query(GET_SAMPLES)
  #  return results


@app.route('/samples')
def sample_list():
    #probes = getsamplesfromsite("http://irnok.net:3030/sparql")
    probes = KG.query(GET_SAMPLES)
    #pprint(list(probes))
    return render_template("samples.html", probes=probes)


SELECT_AMOUNTS = PREFIXES + """
SELECT ?elAmount ?element ?amount ?unit ?probe_name
WHERE
{
#WHERE
  ?probe a <http://dbpedia.org/resource/Sample_(material)> .
#DELETEE
  ?probe rdfs:label ?probe_name .
  ?probe gp:contains  ?elAmount .
  ?elAmount gp:amount ?amount .
  ?elAmount gp:pollutedBy ?element .
  ?elAmount gp:unit ?unit .
#DELETEE
#WHERE
}
#  LIMIT 200
"""

DELETE_AMOUNTS = PREFIXES + """

DELETE
{
@DELETEE@
}
WHERE
{
@WHERE@
}

"""


def label(en):
    if en in NAMES:
        return NAMES[en]
    else:
        return en


@app.route('/probe')
def sampe_edit():
    uri = request.args.get('uri')
    # q = SELECT_AMOUNTS.replace("@URI@", uri)
    #print(q)
    # data = getfromlocal(SELECT_AMOUNTS,
    #                     initBindings={
    #                         "probe":uri
    #                     })
    uri = URIRef(uri)
    print("About:", uri)
    r = KG.query(SELECT_AMOUNTS,
                 initBindings={"probe": uri})

    ss = io.BytesIO()
    r.serialize(destination=ss, format='json')
    ss.seek(0, 0)
    js = json.load(ss)
    data = js["results"]["bindings"]
    pprint(data)
    name = data[0]["probe_name"]["value"] if len(data)>0 else ''
    return render_template("probe.html",
                           data=data,
                           label=label,
                           about=str(uri),
                           probe_name=name)


@app.route('/api/v1.0/save', methods=['POST'])
def save():
    js = request.json
    html=js["html"]
    uri =js["uri"]


    # print(html)
    o = open("html.html", "w")
    o.write(html)
    o.close()
    print("await distiller")
    rq = requests.post(DISTILLER_URL,
                       json={
                           "command": "serialize",
                           "input": html
                       })
    js = rq.json()
    # TODO: Delete all edited data
    # and add imported.
    ss = io.StringIO(js["serialized"])
    g = KG

    _, where, _ = SELECT_AMOUNTS.split("#WHERE", maxsplit=2)
    _, deletee, _ = SELECT_AMOUNTS.split("#DELETEE", maxsplit=2)

    delq=DELETE_AMOUNTS.replace("@DELETEE@", deletee).replace("@WHERE@", where)
    print(delq)
    g.update(delq,
             initBindings={"probe": uri})
    # binds(g)
    g.parse(ss)
    g.serialize(destination=KG_FN, encoding="utf8", format="turtle")
    #msgs = js["messages"]
    #answer = {"result": "OK", "messages": msgs}
    #return jsonify(answer)






