from SPARQLWrapper import SPARQLWrapper, JSON, XML, RDFXML
from server import KG, PREFIXES
from rdflib import Graph, RDF, RDFS, Namespace, Literal
from pprint import pprint


DBR = Namespace("http://dbpedia.org/resource/")
GP = Namespace("http://irnok.net/ontology/geopollution#")


DBPEDIA = "http://dbpedia.org/"
EP = DBPEDIA + "sparql"

POLLUTANTS = PREFIXES + """
SELECT DISTINCT ?pol WHERE
{
   ?_ gp:pollutedBy ?pol .
}
"""

GET_LABLE = PREFIXES + """
SELECT DISTINCT ?label WHERE {
   <%s> rdfs:label ?label .
       FILTER (
#         langMatches(lang(?label), 'en')
#         ||
         langMatches(lang(?label), 'ru')
       )
}
"""

DEP = SPARQLWrapper(EP)
DEP.setReturnFormat(JSON)

def load_names():
    r = KG.query(POLLUTANTS)
    # print(KG.serialize(format="turtle"))
    # print(list(r)[:10])
    g = Graph()
    g.bind("dbr", DBR)
    g.bind("gp", GP)
    r=list(r)
    r.append((DBR["Percentage"],))
    for p in r:
        p = p[0]
        g.add((p, RDF.type, DBR["Matter"]))
        Q = GET_LABLE % p
        # print(Q)
        print("ENT:", p, end=" ")
        DEP.setQuery(Q)
        rr = DEP.queryAndConvert()
        # {'head':
        #  {'link': [],
        #   'vars': ['label']},
        #  'results': {'distinct': False,
        #              'ordered': True,
        #              'bindings': []}}
        bs = rr["results"]["bindings"]

        if len(bs)>0:
            name = bs[0]["label"]["value"]
            lang = "ru"
        else:
            name = str(p).replace(str(DBR), "")
            lang = "en"
        print("{}@{}".format(name, lang))
        g.add((p, RDFS.label, Literal(name, lang=lang)))
    g.add((GP["PartsPerMillion"], RDFS.label, Literal("PPM", lang="en")))
    g.serialize(destination="../vkr/names.rdf", format="pretty-xml")




if __name__=="__main__":
    load_names()