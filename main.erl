-module(main).
-import(lib, [data/1]).
-import(encryption, [key_gen/0,encrypt/2,decrypt/3]).
-export([start/0]).

start() ->
    Data = data("test.txt"),
    Key = key_gen(),
    {Data2,Tag} = encrypt(Key, Data),
    decrypt(Key,Data2, Tag).
    
