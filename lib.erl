-module(lib).
-export([data/1]).

data(File) ->
    F = file:read_file(File),
    case F of
        {ok, Data} ->
            Data;
        {error, Reason} ->
            io:format("Error: ~w ~n", [Reason])
    end.

