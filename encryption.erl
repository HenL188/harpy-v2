-module(encryption).
-export([key_gen/0, encrypt/2, decrypt/3]).

key_gen(N, List, B) ->
    if
        B == true ->
            Input = io:get_line("Enter passkey: "),
            B = false
    end,
    _ = crypto:rand_seed_alg(crypto_aes, Input),
    Length = iolist_size(Input),
    if
        Length < 32 ->
            Bytes = 32 - Length,
            Rand = crypto:strong_rand_bytes(Bytes),
            R = binary_to_list(Rand),
            K = lists:append(Input, R),
            Key = list_to_binary(K),
            Keys = lists:append(List,Key);
        Length > 32 ->
            io:format("Passkey bigger than 32 bytes"),
            B = true,
            key_gen(N,List,B);
        true ->
            Keys = lists:append(List,Input)
    end,
    if
        N > 0 -> N - 1, key_gen(N,Keys,B);
        true -> Keys
    end.

encrypt([],[]) ->
    done;

encrypt([],Data) ->
    Reason = "No key",
    {error, Reason};

encrypt([KH|KT], Data) ->
    IV = <<0:128>>,
    AAD = "harpy",
    {Encrypt, Tag} = crypto:crypto_one_time_aead(aes_256_gcm, KH, IV, Data, AAD, true),
    Tag2 = binary_to_list(Tag),
    Tag3 = Tag2 ++ [10],
    Verify = file:write_file("verify.txt", Tag3, [append]),
    case Verify of
        ok -> io:format("encrypted~n");
        {error, Error} -> io:format("Error: ~w~n", [Error])
    end,
    encrypt(KT,Data).
    

decrypt(Key, Data, Tag) ->
    IV = <<0:128>>,
    AAD = "harpy",
    Decrypt = crypto:crypto_one_time_aead(aes_256_gcm, Key, IV, Data, AAD, Tag, false),
    case Decrypt of
        error -> io:format("Failed to decrypt");
        _ -> io:format(Decrypt)
    end.
