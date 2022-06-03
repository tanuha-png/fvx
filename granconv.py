from lxml import etree
from rdflib import (Graph, BNode, Namespace, RDF, RDFS, FOAF, Literal)
from uuid import uuid1
from pprint import pprint

root = etree.iterparse("./Ярки.xml",
                       events=('start',))

DB = Namespace("http://irnok.net/database/granulometric/")
DD = Namespace("http://irnok.net/ontology/granulometric/")


G = Graph()
G.bind("db", DB)
G.bind("dd", DD)

def uuid(NS):
    uu = uuid1()
    return NS[uu.hex]

EXP = uuid(DB)
G.add((EXP, RDFS.label, Literal("Ярки", lang="ru")))



pat = None

for ev, node in root:
    if node.tag == "ArrayOfAnyType":
        pat = None
        continue
    elif node.tag == "anyType":
        pat = uuid(DB)
        # print(pat)
        G.add((EXP, DD.anyType, pat))
        G.add((pat, RDF.type, DD["AnyType"]))
        # pprint(node.attrib)
        typ = node.get("{http://www.w3.org/2001/XMLSchema-instance}type")
        typ = typ.replace("ListFullAllInherited", "")
        G.add((pat, RDF.type, DD[typ]))
        continue

    v = node.text

    if v is None:
        continue

    try:
        v = int(v)
    except ValueError:
        try:
            v = float(v)
        except ValueError:
            pass
    if pat is None:
        print(ev, node)
    else:
        G.add((pat, DD[node.tag], Literal(v)))

G.serialize(destination="Ярки.ttl",
            format="turtle",
            encoding="utf8")
