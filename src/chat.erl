-module(chat).

-export([connect_sender/3, connect_poller/2,
         send/2, poll/1,
         start_room/1,
         init_state/1]).

-record(room, {router, pub}).

-record(sender, {dealer, name}).

%% ===================================================================
%% Client API 
%% ===================================================================

connect_sender(Server, Port, Name) ->
    init_sender(
      connect_socket(dealer, Server, Port),
      Name).

init_sender(Dealer, Name) ->
    #sender{dealer=Dealer, name=Name}.

connect_poller(Server, Port) ->
    connect_socket(sub, Server, Port).

send(#sender{dealer=Dealer, name=Name}, Msg) ->
    send_from(Name, Msg, Dealer).

send_from(Name, Msg, Dealer) ->
    ezmq:send(Dealer, from_msg(Name, Msg)).

from_msg(Name, Msg) when is_binary(Msg) ->
    [iolist_to_binary(["[", Name, "] ", Msg])];
from_msg(Name, Msg) when is_list(Msg) ->
    from_msg(Name, iolist_to_binary(Msg)).

poll(Socket) ->
    print_msg(recv_msg(Socket)),
    poll(Socket).

recv_msg(Socket) ->
    {ok, [Msg]} = ezmq:recv(Socket),
    Msg.

print_msg(Msg) ->
    io:format("~p~n", [Msg]).

connect_socket(Type, Addr, Port) ->    
    {ok, Socket} = ezmq:socket([{type, Type}]),
    ezmq:connect(Socket, tcp, Addr, Port, []),
    Socket.

%% ===================================================================
%% Server API
%% ===================================================================

start_room(PortBase) ->
    room_loop(init_state(PortBase)).

init_state(PortBase) ->
    #room{
       router=init_router(router_port(PortBase)), 
       pub=init_pub(pub_port(PortBase))}.

router_port(PortBase) -> PortBase.

pub_port(PortBase) -> PortBase + 1.

init_router(Port) ->
    bind_socket(router, Port).

init_pub(Port) ->
    bind_socket(pub, Port).

room_loop(#room{router=Router, pub=Pub}=State) ->
    publish_msg(recv_router_msg(Router), Pub),
    room_loop(State).

recv_router_msg(Router) ->
    handle_router_recv(ezmq:recv(Router)).

handle_router_recv({ok, {_Id, [Msg]}}) -> Msg;
handle_router_recv(Other) ->
    io:format("[ERROR] Unexpected router result: ~p~n", [Other]).

publish_msg(Msg, Pub) ->
    ezmq:send(Pub, [Msg]).

bind_socket(Type, Port) ->
    {ok, Socket} = ezmq:socket([{type, Type}]),
    ok = ezmq:bind(Socket, tcp, Port, []),
    Socket.
