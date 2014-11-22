-module(buildstuff).

-export([start/0, hello/0,
         req_socket/2, rep_socket/1,
         send/2, recv/1, rep_loop/1]).

start() ->
    e2_application:start_with_dependencies(buildstuff).

hello() ->
    "Hello Buildstuff".

req_socket(Addr, Port) ->
    {ok, Req} = ezmq:socket([{type, req}]),
    ok = ezmq:connect(Req, tcp, Addr, Port, []),
    Req.

rep_socket(Port) ->
    {ok, Rep} = ezmq:socket([{type, rep}]),
    ok = ezmq:bind(Rep, tcp, Port, []),
    Rep.

send(Socket, Bin) when is_binary(Bin) ->
    ezmq:send(Socket, [Bin]);
send(Socket, Frames) when is_list(Frames) ->
    ezmq:send(Socket, Frames).

recv(Socket) ->
    ezmq:recv(Socket).

rep_loop(Rep) ->
    {ok, Result} = ezmq:recv(Rep),
    io:format("Got: ~p~n", [Result]),
    ezmq:send(Rep, Result),
    rep_loop(Rep).
