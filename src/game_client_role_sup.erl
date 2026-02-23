%%%-------------------------------------------------------------------
%%% @author si
%%% @copyright (C) 2026, <COMPANY>
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(game_client_role_sup).

-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    AChild = #{id => 'game_client_role_srv',
        start => {'game_client_role_srv', start_link, []},
        restart => temporary,
        shutdown => 2000,
        type => worker,
        modules => ['game_client_role_srv']},

    {ok, {#{strategy => simple_one_for_one,
        intensity => 5,
        period => 30},
        [AChild]}
    }.
