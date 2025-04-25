-module(encryption).
-export([key_gen/3, encrypt/2, decrypt/3]).

key_gen(List, B, Input) ->
    _ = crypto:rand_seed_alg(crypto_aes, Input),
    Length = iolist_size(Input),
    if
        Length < 32 ->
            Bytes = 32 - Length,
            Rand = crypto:strong_rand_bytes(Bytes),
            R = binary_to_list(Rand),
            Keyl = lists:append(Input, R),
            Key = list_to_binary(Keyl),
            Keys = lists:append(List, [Key]),
            Keys;
        Length > 32 ->
            io:format("Passkey bigger than 32 bytes~n"),
            io:format("Generating random key~n"),
            Keys = List,
            B = true,
            key_gen(Keys, B, Input);
        true ->
            Keys = lists:append(List, Input),
            Keys
    end.

encrypt([], []) ->
    done;
encrypt([], _) ->
    Reason = "No key",
    {error, Reason};
encrypt([KH | KT], Data) ->
    IV = <<0:128>>,
    AAD = "harpy",
    io:format("~w~n", [Data]),
    {Encrypt, Tag} = crypto:crypto_one_time_aead(aes_256_gcm, KH, IV, Data, AAD, true),
    Verify = file:write_file("verify.txt", Tag),
    case Verify of
        ok -> ok;
        {error, Error} -> io:format("Error: ~w~n", [Error])
    end,
    encrypt(KT, Data).

decrypt(Key, Data, Tag) ->
    IV = <<0:128>>,
    AAD = "harpy",
    Decrypt = crypto:crypto_one_time_aead(aes_256_gcm, Key, IV, Data, AAD, Tag, false),
    case Decrypt of
        error -> io:format("Failed to decrypt");
        _ -> io:format(Decrypt)
    end.
