.PHONY: app test



app:
	FLASK_APP=server flask run

test:
	curl http://localhost:5000/?uri=https://wojciechpolak.org/foaf.rdf
