-module(chat).

-export([connect/2, send/2, poll/1, start_room/1]).

%% ===================================================================
%% Client API 
%% ===================================================================

connect(Server, Port) ->
    {ok, Socket} = ezmq:socket([{type, dealer}]),
    ezmq:connect(Socket, tcp, Server, Port, []),
    Socket.

send(Socket, Msg) when is_binary(Msg) ->
    ezmq:send(Socket, [Msg]);
send(Socket, Msg) when is_list(Msg) ->
    ezmq:send(Socket, [iolist_to_binary(Msg)]).

poll(Room) ->
    {ok, Result} = ezmq:recv(Room),
    io:format("~p~n", [Result]),
    poll(Room).

%% ===================================================================
%% Server API
%% ===================================================================

start_room(Port) ->
    {ok, Socket} = ezmq:socket([{type, router}]),
    ok = ezmq:bind(Socket, tcp, Port, []),
    io:format("Room started on port ~b~n", [Port]),
    room_loop(Socket).

room_loop(Socket) ->
    Result = ezmq:recv(Socket),
    io:format("Server got: ~p~n", [Result]),
    room_loop(Socket).

