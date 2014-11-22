-module(buildstuff).

-export([start/0, hello/0, req_socket/2, send/2]).

start() ->
    e2_application:start_with_dependencies(buildstuff).

hello() ->
    "Hello Buildstuff".

req_socket(Addr, Port) ->
    {ok, Req} = ezmq:socket([{type, req}]),
    ok = ezmq:connect(Req, tcp, Addr, Port, []),
    Req.

send(Socket, Bin) when is_binary(Bin) ->
    ezmq:send(Socket, [Bin]);
send(Socket, Frames) when is_list(Frames) ->
    ezmq:send(Socket, Frames).
