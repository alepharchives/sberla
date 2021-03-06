%% =====================================================================
%% This library is free software; you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as
%% published by the Free Software Foundation; either version 2 of the
%% License, or (at your option) any later version.
%%
%% This library is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
%% Lesser General Public License for more details.
%%
%% You should have received a copy of the GNU Lesser General Public
%% License along with this library; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
%% USA
%%

%%%-------------------------------------------------------------------
%%% @private
%%% File:      sberla_listener.erl
%%% @author    Alfonso De Gregorio <adg@crypto.lo.gy>
%%% @copyright 2011 Alfonso De Gregorio
%%% @doc    
%%%
%%% @since 2011-08-08 Alfonso De Gregorio
%%% @end 
%%%-------------------------------------------------------------------
-module(sberla_listener).
-author('Alfonso De Gregorio').

-behaviour(gen_server).

%% API
-export([start_link/3]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {host, port, apikey}).

-define(CLIENT, "sberla"). %% client identity
-define(APPVER, "0.1").    %% client version
-define(PVER, "3.0").      %% protocol version supported by sberla

-define(SAFEBROWSING_PATH, "/safebrowsing/api/lookup"). % SB API Path



%%--------------------------------------------------------------------
%% macro definitions
%%--------------------------------------------------------------------
-define(SERVER, ?MODULE).


%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% @spec start_link(Host, Port) -> {ok,Pid} | ignore | {error,Error}
%% @doc Starts the server
%% @end 
%%--------------------------------------------------------------------
start_link(Host, Port, Apikey) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE,
                          [Host, Port, Apikey],
                          []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% @spec init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% @doc Initiates the server
%% @end 
%%--------------------------------------------------------------------
init([Host, Port, Apikey]) ->
    {ok, #state{host = Host, port = Port, apikey = Apikey}}.

%%--------------------------------------------------------------------
%% @spec 
%% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% @doc Handling call messages
%% @end 
%%--------------------------------------------------------------------
%%handle_call(Operation, From, State) ->
handle_call({Op, Options, Path, L}, From, State) ->
    {ok, Pid} = sberla:start_client(),
    NewOptions = lists:append([ get_api_options(State#state.apikey) | Options]),
    CastedOperation = {Op, NewOptions},
    gen_server:cast(Pid, {CastedOperation, 
                         State#state.host, State#state.port, Path, L, From}),
    {noreply, State}.

%%    case Operation of
%%         {get, Options, Path, L} ->
%%              io:format("handle_call: ~n"),
%%              NewOptions = lists:append([ get_api_options(State#state.apikey) | Options]),
%%	      CastedOperation = {get, NewOptions},
%%              gen_server:cast(Pid, {CastedOperation, 
%%                         State#state.host, State#state.port, Path, L, From}),
%%              io:format("noreply, State -- coming back: ~n"),
%%              {noreply, State};
%%
%%         {post, Options, Path, L} ->
%%              io:format("handle_call: ~n"),
%%              NewOptions = lists:append([ get_api_options(State#state.apikey) | Options]),
%%	      CastedOperation = {post, NewOptions},
%%              gen_server:cast(Pid, {CastedOperation,
%%                         State#state.host, State#state.port, Path, L, From}),
%%              io:format("noreply, State -- coming back: ~n"),
 %%             {noreply, State};
 %%        _Else ->
 %%             io:format("no operation matched - coming back: ~n"),
 %%             {noreply, State}
%%    end.

%%--------------------------------------------------------------------
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% @doc Handling cast messages
%% @end 
%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% @doc Handling all non call/cast messages
%% @end 
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @spec terminate(Reason, State) -> void()
%% @doc This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%% @end 
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @doc Convert process state when code is changed
%% @end 
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------
get_api_options(Apikey) ->
    [
      {"client", ?CLIENT},
      {"appver", ?APPVER},
      {"pver", ?PVER},
      {"apikey", Apikey}
    ].

