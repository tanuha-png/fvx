.PHONY: app test



app:
	FLASK_APP=server FLASK_ENV=development flask run

test:
	curl http://localhost:5000/?uri=https://wojciechpolak.org/foaf.rdf
