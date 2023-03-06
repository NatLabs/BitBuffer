.PHONY: test compile-tests docs no-warn

test: 
	find tests -type f -name '*.Test.mo' -print0 | xargs -0 $(shell vessel bin)/moc -r $(shell mops sources) -wasi-system-api

no-warn:
	find src -type f -name '*.mo' -print0 | xargs -0 $(shell vessel bin)/moc -r $(shell mops sources) -Werror -wasi-system-api

docs: 
	$(shell vessel bin)/mo-doc
	$(shell vessel bin)/mo-doc --format plain