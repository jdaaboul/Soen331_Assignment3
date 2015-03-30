:- consult(facts).

%%RULES
is_edge(Event,Guard):-  transition(_,_,Event,Guard,_), Guard \= null, Event \= null.

is_loop(Event, Guard):- is_edge(Event, Guard), transition(X,X,Event,Guard,_).

all_loops(Set):- findall([Event,Guard], (transition(_,_,Event, Guard,_), is_loop(Event, Guard)), L), list_to_set(L,Set).

size(Length):- findall([Event, Guard], (is_edge(Event,Guard)), L), length(L, Length).

is_link(Event, Guard):- is_edge(Event,Guard), transition(A, B, Event, Guard, _), A \= B.

all_superstates(Set):- findall(Super, superstate(Super, _), L), list_to_set(L, Set).

ancestor(Ancestor, Descendant):- superstate(Ancestor, Descendant).

inherits_transitions(State, List):- findall(transition(Source, Destination, Event, Guard, Action), 
(superstate(Source, State), transition(Source, Destination, Event, Guard, Action)), List).

all_states(L) :- findall(State, state(State), L).

all_init_states(L):-  findall(State, initial_state(State,_), L).

get_starting_state(State):- initial_state(State, null).

state_is_reflexive(State):- transition(State,_,Event,Guard,_), is_loop(Event, Guard). 

graph_is_reflexive:- forall(state(State),state_is_reflexive(State)).

get_guards(Ret) :- findall(Guard,(transition(_,_,_,Guard,_),Guard \= null),L), list_to_set(L,Ret).

get_events(Ret) :- findall(Event,(transition(_,_,Event,_,_), Event \= null),L),list_to_set(L,Ret).

get_actions(Ret) :- findall(Action,(transition(_,_,_,_,Action), Action \= null),L),list_to_set(L,Ret).

get_only_guarded(Ret) :- findall([Source,Destination],(transition(Source,Destination,null,Guard,null), Guard \= null),Ret).

legal_events_of(State, L):- findall([Event, Guard], (transition(State,_, Event, Guard, _), is_edge(Event, Guard)), L).