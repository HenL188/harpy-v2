-module(lib).
-import(encryption, [encrypt/3, decrypt/4, key_gen/3]).
-export([data/2, input/0]).

data([], _) ->
    none;
data([Head | Tail], Input) ->
    Key = key_gen([], true, Input),
    F = file:read_file(Head),
    case F of
        {ok, Data} ->
            encrypt(Key, Data, [Head | Tail]);
        {error, Reason} ->
            io:format("Error: ~w ~n", [Reason])
    end,
    data(Tail, Input).

parse() ->
    Input = io:get_line("Enter: "),
    Chomp = string:chomp(Input),
    Files = string:split(Chomp, " "),
    Files.

input() ->
    Files = parse(),
    Input = io:get_line("Enter passkey: "),
    data(Files, Input).
