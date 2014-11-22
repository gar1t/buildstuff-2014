-module(buildstuff).

-export([start/0, hello/0, test_zmq/0]).

start() ->
    ok = application:start(sasl),
    ok = application:start(gen_listener_tcp),
    ok = application:start(syntax_tools),
    ok = application:start(compiler),
    ok = application:start(goldrush),
    ok = application:start(lager),
    ok = application:start(ezmq).    

hello() ->
    "Hello Buildstuff".

test_zmq() ->

    {ok, Req} = ezmq:socket([{type, req}]),
    {ok, Rep} = ezmq:socket([{type, rep}]),

    ok = ezmq:bind(Rep, tcp, 5555, []),
    ok = ezmq:connect(Req, tcp, {127,0,0,1}, 5555, []),
    
    ok = ezmq:send(Req, [<<"hello">>]),
    
    Result = ezmq:recv(Rep),
    
    io:format("***** ~p~n", [Result]),

    ezmq:close(Req),
    ezmq:close(Rep),
 
    ok.
