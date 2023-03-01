
test:
	$(shell vessel bin)/moc -r --hide-warnings $(shell vessel sources) -wasi-system-api ./tests/*Test.mo

docs:
	$(shell vessel bin)/mo-doc

no-warn:
	find src -type f -name '*.mo' -print0 | xargs -0 $(shell vessel bin)/moc -r $(shell mops sources) -Werror -wasi-system-api
