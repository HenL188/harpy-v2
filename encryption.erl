-module(encryption).
-export([key_gen/3, encrypt/3, decrypt/4]).

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

encrypt([], [], _) ->
    done;
encrypt([], _, _) ->
    Reason = "No key",
    {error, Reason};
encrypt([KH | KT], Data, [FileH, FileT]) ->
    IV = <<0:128>>,
    AAD = "harpy",
    {Encrypt, Tag} = crypto:crypto_one_time_aead(aes_256_gcm, KH, IV, Data, AAD, true),
    KeyFile = [KH] ++ ".txt",
    Verify = file:write_file(KeyFile, Tag),
    case Verify of
        ok -> ok;
        {error, Error} -> io:format("Error: ~w~n", [Error])
    end,
    Verify2 = file:write_file(KeyFile, Encrypt),
    case Verify2 of
        ok -> ok;
        {error, Reason} -> io:format("Error: ~w~n", [Reason])
    end,
    NewFile = file:write_file(FileH, Encrypt),
    case NewFile of
        ok -> ok;
        {error, Err} -> io:format("Error: ~w~n", [Err])
    end,
    encrypt(KT, Data, FileT).

decrypt([], [], [], _) ->
    done;
decrypt([], _, _, _) ->
    Reason = "No key",
    {error, Reason};
decrypt(_, _, [], _) ->
    Reason = "No tag",
    {error, Reason};
decrypt([KH | KT], Data, [TagH | TagT], [FileH, FileT]) ->
    IV = <<0:128>>,
    AAD = "harpy",
    Decrypt = crypto:crypto_one_time_aead(aes_256_gcm, KH, IV, Data, AAD, TagH, false),
    case Decrypt of
        error -> io:format("Failed to decrypt");
        _ -> io:format(Decrypt)
    end,
    decrypt(KT, Data, TagT, FileT).
