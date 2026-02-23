%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 21. 2月 2026 上午 9:20
%%%-------------------------------------------------------------------
-module(user_default).

-include("log.hrl").

-export([start/0]).

-export([do/1]).

do(Account)->
    supervisor:start_child(game_client_role_sup,[Account]).

start() ->
    {ok, ConnPid} = gun:open("localhost", 6006),
    {ok, _Protocol} = gun:await_up(ConnPid),
    %% 发起 WebSocket 请求
    StreamRef = gun:ws_upgrade(ConnPid, "/ws"),
    receive
        {gun_upgrade, ConnPid, StreamRef, [<<"websocket">>], _Headers} ->
            ?WARNING("WebSocket 已连接~n"),
            %% 发送一条消息
            send_heartbeat(ConnPid,StreamRef),
            loop(ConnPid, StreamRef);
        {gun_response, ConnPid, StreamRef, _, Status, _Headers} ->
            ?WARNING("WebSocket 升级失败: ~p~n", [Status]);
        Msg->
            ?WARNING("WebSocket 已连接 ~p~n",[Msg])
    end.

loop(ConnPid, StreamRef) ->
    receive
        {gun_ws, ConnPid, StreamRef, {text, Msg}} ->
            ?WARNING("收到服务端消息: ~s~n", [Msg]),
            loop(ConnPid, StreamRef);
        {login_req,Account,Password}->
            send_login_do(ConnPid,StreamRef,Account,Password),
            loop(ConnPid, StreamRef);
        Msg->
            ?WARNING("收到服务端消息: ~p~n", [Msg]),
            loop(ConnPid, StreamRef)
    end.

send_heartbeat(ConnPid,StreamRef)->
    Msg = jsx:encode(#{msg_id => heartbeat_req,  id => 1}),
    gun:ws_send(ConnPid, StreamRef, {binary, Msg}).


send_login_do(ConnPid,StreamRef,Account,Password)->
    Msg = jsx:encode(#{msg_id => login_req,  account => Account,password=>Password}),
    gun:ws_send(ConnPid, StreamRef, {binary, Msg}).