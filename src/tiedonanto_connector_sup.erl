%%%-------------------------------------------------------------------
%%% @author Mathieu Kerjouan <contact@steepath.eu>
%%% @copyright 2019 Mathieu Kerjouan
%%%
%%% @doc tiedonanto_connector_sup manage all processes relative to
%%%      endpoint connection. That means this supervisor is the main
%%%      to control the connector processes pool for each procotol.
%%%      Fortunately, all processes with a specific protocol are 
%%%      managed with their own supervisor.
%%% @end
%%%-------------------------------------------------------------------
-module(tiedonanto_connector_sup).
-behaviour(supervisor).
-export([start_link/0, start_link/1]).
-export([init/1]).
-export([connector/0, connector/1]).
-export([connector_sup/1, connector_sup/2]).
-type args() :: list().

%%--------------------------------------------------------------------
%% @doc start_link/0
%% @end
%%--------------------------------------------------------------------
-spec start_link() -> {ok, term()}.
start_link() ->
    start_link([]).

%%--------------------------------------------------------------------
%% @doc start_link/1
%% @end
%%--------------------------------------------------------------------
-spec start_link(Args :: args()) -> {ok, term()}.
start_link(Args) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, Args).

%%--------------------------------------------------------------------
%% @doc supervisor_flags/0
%% @end
%%--------------------------------------------------------------------
-spec supervisor_flags() -> map().
supervisor_flags() ->
    #{ strategy => one_for_one
     , intensity => 0
     , period => 1 
     }.

%%--------------------------------------------------------------------
%% @doc connector/0
%% @end
%%--------------------------------------------------------------------
-spec connector() -> map().
connector() ->
    connector([]).

%%--------------------------------------------------------------------
%% @doc connector/1
%% @end
%%--------------------------------------------------------------------
-spec connector(Args :: list()) -> map().
connector(Args) ->
    #{ id => tiedonanto_connector
     , start => {tiedonanto_connector, start_link, Args}
     , type => worker
     }.

%%--------------------------------------------------------------------
%% @doc connector_sup/1
%% @end
%%--------------------------------------------------------------------
-spec connector_sup(Protocol :: atom()) -> map().
connector_sup(Protocol) ->
    connector_sup(Protocol, []).

%%--------------------------------------------------------------------
%% @doc connector_sup/2
%% @end
%%--------------------------------------------------------------------
-spec connector_sup(Protocol :: atom(), Args :: list()) -> map().
connector_sup(http, Args) ->
    #{ id => tiedonanto_connector_http_sup
     , start => {tiedonanto_connector_http_sup, start_link, Args}
     , type => supervisor
     };
connector_sup(tcp, Args) ->
    #{ id => tiedonanto_connector_tcp_sup
     , start => {tiedonanto_connector_tcp_sup, start_link, Args}
     , type => supervisor
     };
connector_sup(ssl, Args) ->
    #{ id => tiedonanto_connector_ssl_sup
     , start => {tiedonanto_connector_ssl_sup, start_link, Args}
     , type => supervisor
     };
connector_sup(udp, Args) ->
    #{ id => tiedonanto_connector_udp_sup
     , start => {tiedonanto_connector_udp_sup, start_link, Args}
     , type => supervisor
     }.

%%--------------------------------------------------------------------
%% @doc child_specs/0
%% @end
%%--------------------------------------------------------------------
-spec child_specs() -> [map(), ...].
child_specs() ->
    [ connector()
    , connector_sup(http)
    , connector_sup(tcp)
    , connector_sup(ssl)
    , connector_sup(udp)
    ].

%%--------------------------------------------------------------------
%% @doc supervisor_state/0
%% @end
%%--------------------------------------------------------------------
-spec supervisor_state() -> {map(), [map(), ...]}.
supervisor_state() ->
    { supervisor_flags()
    , child_specs() 
    }.

%%--------------------------------------------------------------------
%% @doc init/1
%% @end
%%--------------------------------------------------------------------
-spec init(list()) -> {ok, {map(), [map(), ...]}}.
init(_Args) ->
    {ok, supervisor_state()}.
