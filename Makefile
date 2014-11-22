compile: deps
	./rebar compile

quick:
	./rebar skip_deps=true compile

shell:
	export ERL_LIBS=deps; erl -pa ebin -s reloader -s buildstuff

deps:
	./rebar get-deps
