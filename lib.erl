-module(lib).
-export([data/1, input/0]).



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

parse() ->
    Input = io:get_line("Enter: "),
    Chomp = string:chomp(Input),
    Files = string:split(Chomp, " "),
    Files.


input() ->
    Files = parse(),
    io:format(Files),
    data(Files).
    
    
