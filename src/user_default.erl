%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 2月 2026 上午 9:20
%%%-------------------------------------------------------------------
-module(user_default).
-author("si").

-export([start/0]).

start() ->
    {ok, ConnPid} = gun:open("localhost", 8080),
    {ok, _Protocol} = gun:await_up(ConnPid),
    StreamRef = gun:get(ConnPid, "/"),
    receive
        {gun_response, ConnPid, StreamRef, fin, Status, Headers} ->
            io:format("Status: ~p~nHeaders: ~p~n", [Status, Headers]);
        {gun_data, ConnPid, StreamRef, fin, Body} ->
            io:format("Body: ~s~n", [Body])
    end.