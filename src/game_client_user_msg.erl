%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 2月 2026 上午 9:20
%%%-------------------------------------------------------------------
-module(game_client_user_msg).

-include("log.hrl").

-export([start/1]).

-export([send_heartbeat/1]).


start(UserPid) ->
    erlang:spawn(fun() -> start_do(UserPid) end).


start_do(UserPid) ->
    {ok, ConnPid} = gun:open("localhost", 6006),
    {ok, _Protocol} = gun:await_up(ConnPid),
    StreamRef = gun:ws_upgrade(ConnPid, "/ws"),
    State = #{id => 1, user_pid => UserPid},
    receive
        {gun_upgrade, ConnPid, StreamRef, [<<"websocket">>], _Headers} ->
            send_heartbeat_do(ConnPid, StreamRef, 1),
            loop(ConnPid, StreamRef, State);
        {gun_response, ConnPid, StreamRef, _, Status, _Headers} ->
            ?WARNING("WebSocket 升级失败: ~p~n", [Status]);
        Msg ->
            ?WARNING("WebSocket 连接异常 ~p~n", [Msg])
    end.

loop(ConnPid, StreamRef, #{id := Id, user_pid := UserPid} = State) ->
    receive
        {gun_ws, ConnPid, StreamRef, {text, Msg}} ->
            ?WARNING("收到服务端消息: ~s~n", [Msg]),
            loop(ConnPid, StreamRef, State);
        {gun_ws, ConnPid, StreamRef, {binary, Msg}} ->
            case catch jsx:decode(Msg, [return_maps]) of
                MapMsg when is_map(MapMsg) ->
                    UserPid ! {msg, MapMsg};
                _ ->
                    skip
            end,
            loop(ConnPid, StreamRef, State);
        {send_msg,Msg}->
            gun:ws_send(ConnPid, StreamRef, {binary, Msg}),
            loop(ConnPid, StreamRef, State);
        heartbeat_req ->
            send_heartbeat_do(ConnPid, StreamRef, Id) -
                loop(ConnPid, StreamRef, State#{id => Id + 1});
        Msg ->
            ?WARNING("unknow msg: ~p~n", [Msg]),
            loop(ConnPid, StreamRef, State)
    end.


send_heartbeat(WsPid) ->
    WsPid ! heartbeat_req.

send_heartbeat_do(ConnPid, StreamRef, Id) ->
    Msg = jsx:encode(#{msg_id => heartbeat_req, id => Id}),
    gun:ws_send(ConnPid, StreamRef, {binary, Msg}).

