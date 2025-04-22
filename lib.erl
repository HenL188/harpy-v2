-module(lib).
-export([data/1]).



data([]) ->
    none;

data([Head|Tail]) ->
    F = file:read_file(Head),
    case F of
        {ok, Data} ->
            Data;
        {error, Reason} ->
            io:format("Error: ~w ~n", [Reason])
    end,
    data(Tail).
