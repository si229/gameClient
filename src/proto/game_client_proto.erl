%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 2月 2026 下午 1:04
%%%-------------------------------------------------------------------
-module(game_client_proto).
-author("si").

%% API
-export([enter_room/0, bet/1]).

enter_room() ->
    jsx:encode(#{msg_id => enter_room_req, play_type => 1, game_type => 1}).

bet(Amount) ->
    N = rand:uniform(10) - 1,
    jsx:encode(#{msg_id => betting_req, amount => Amount, zone => N,mode=>1}).