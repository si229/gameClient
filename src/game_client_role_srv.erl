%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(game_client_role_srv).

-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2,
    code_change/3]).

-define(SERVER, ?MODULE).
-define(LOOP_TIMER(), erlang:start_timer(1000, self(), loop_timer)).
-include("log.hrl").
-include("msg.hrl").

-record(state, {account, ws_pid
    , loop_timer_ref, time
    , is_login = false, real_money = 0, bonus_credits = 0}).

%%%===================================================================
%%% Spawning and gen_server implementation
%%%===================================================================

start_link(Account) ->
    gen_server:start_link(?MODULE, [Account], []).

init([Account]) ->
    WsPid = game_client_user_msg:start(self()),
    process_flag(trap_exit, true),
    erlang:monitor(process, WsPid),
    {ok, #state{account = Account, ws_pid = WsPid, loop_timer_ref = ?LOOP_TIMER()}}.

handle_call(_Request, _From, State = #state{}) ->
    {reply, ok, State}.

handle_cast(_Request, State = #state{}) ->
    {noreply, State}.


handle_info({msg, Msg}, State) ->
    handle_server_msg(Msg, State);

handle_info({timeout, TimerRef, loop_timer},
    State = #state{loop_timer_ref = TimerRef, ws_pid = WsPid, is_login = IsLogin}) ->
    game_client_user_msg:send_heartbeat(WsPid),
    case IsLogin of
        false ->
            Msg = jsx:encode(#{msg_id => login_req, option => ?login_with_guest}),
            send_msg(WsPid, Msg);
        _ ->
            skip
    end,
    {noreply, State#state{loop_timer_ref = ?LOOP_TIMER(), is_login = true}};
handle_info(_Info, State = #state{}) ->
    {noreply, State}.

terminate(_Reason, _State = #state{}) ->
    ok.

code_change(_OldVsn, State = #state{}, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
handle_server_msg(#{<<"msg_id">> := <<"heartbeat_resp">>, <<"time">> := Time}, State) ->
    ?INFO("# heartbeat_resp "),
    {noreply, State#state{time = Time}};

handle_server_msg(#{<<"msg_id">> := <<"login_resp">>
    , <<"account">> := Account
    , <<"bonus_credits">> := BonusCredits
    , <<"real_money">> := RealMoney
} = Msg, #state{} = State) ->
    ?INFO("# login resp ~p", [Msg]),
    {noreply, State#state{is_login = true, account = Account, bonus_credits = BonusCredits, real_money = RealMoney}}.

send_msg(WsPid, Msg) ->
    WsPid ! {send_msg, Msg}.