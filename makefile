
test:
	$(shell vessel bin)/moc -r --hide-warnings $(shell vessel sources) -wasi-system-api ./tests/*Test.mo

docs:
	$(shell vessel bin)/mo-doc