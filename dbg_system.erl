-module(dbg_system).
-export([init/0]).
-record(state,{listVariables, maxLengthVariable, freeVariable, acc}).

init() ->
	State = #state{listVariables = [], maxLengthVariable = "", freeVariable= "", acc = 0},
	loop(State).

loop(State) ->
	receive
		{exit, Pid} ->
			io:format("Menssage: Pid(~p) decided finalize the execution.~n~n",[Pid]);
		
		{newVariable, Variable} ->
			case lists:member(Variable, State#state.listVariables) of
				false ->
					NewState = State#state{listVariables = lists:append(State#state.listVariables, [Variable])},
					loop(NewState);
				true ->
					loop(State)
			end;
			
		{freeVariable, Pid} ->
			NewState = State#state{maxLengthVariable = biggestVariable(State#state.listVariables, "", 0)},
			Pid ! {ok, "The free Variable is create"},
			loop(NewState);

		{newFreeVariable, Pid} ->
			NewState  =	State#state{
								freeVariable = State#state.maxLengthVariable ++ integer_to_list(State#state.acc + 1), 
								acc = State#state.acc + 1
								},

			Pid ! {ok, NewState#state.freeVariable},
			loop(NewState);

		Other ->
			erlang:exit(self(), {error, {"Title: Error option.~n", Other}})

	after
		50000  ->
			% io:format("Refresc New state is:  ~p~n",[State]),
			loop(State)

	end.

biggestVariable([Hd|Ld], Value, Leng) ->
	SizeVariable = string:len(Hd),
	if
		 SizeVariable > Leng ->
			biggestVariable(Ld, Hd, SizeVariable);
		true ->
			biggestVariable(Ld, Value, Leng)
	end;

biggestVariable([], Value, _) ->
	Value.
