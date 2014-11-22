-module(address).
-author("@mathiasverraes").
-export([parse/1]).

%% parse "54.170.112.57:5555" into {{54,170,112,57},5555}
parse(Str) ->
    [Address, Port] = re:split(Str, ":"),
    [A, B, C, D] = re:split(Address, "\\."),
    {{c(A), c(B), c(C), c(D)}, c(Port)}.

c(X) -> list_to_integer(binary_to_list(X)).

