% sude konyalioglu
% 2019400204
% compiling: yes
% complete: no
:- ['cmpecraft.pro'].

:- init_from_map.

abs(X, Y) :- X < 0, Y is -X.
abs(X, X) :- X >= 0.

% 10 points
manhattan_distance(A ,B , Distance) :- 
	nth0(0,A,Head_A), nth0(0,B,Head_B), nth0(1,A,Tail_A), nth0(1,B,Tail_B),
	DistX is Head_A - Head_B, DistY is Tail_A - Tail_B, 
	abs(DistX, AbsX), abs(DistY, AbsY), 
	Distance is AbsX+AbsY.

min_of_two(A, B, Min):- A =< B, Min is A.
min_of_two(A, B, Min):- A > B, Min is B.

% 10 points
% minimum_of_list(+List, -Minimum) :- .
minimum_of_list([H|T], Min) :- min_of_l(H, T, Min).
	min_of_l( Min,[], Min).
	min_of_l(Head, [H|T], Min):-  min_of_two(Head, H, Min_of_T), Min_temp is Min_of_T, min_of_l(Min_temp, T, Min).

indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1),
  !,
  Index is Index1+1.
  
append([],[],[]).
append( [], X, X).                                   
append(X,[],X).
append( [X | Y], Z, [X | W]) :- append( Y, Z, W).
  

% 10 points
% find_nearest_type(+State, +ObjectType, -ObjKey, -Object, -Distance) :- .
find_nearest_type(State, ObjectType, ObjKey, Object, Distance) :- 
	nth0(1,State,ObjD),
	nth0(0,State,Agent),
	AgX is Agent.x, AgY is Agent.y,
	findall(Obj, ObjD.Obj.type = ObjectType, [SametypeH|SametypeT]),
	make_dist_l([SametypeH|SametypeT], AgX, AgY, ObjD, DistList),
	minimum_of_list(DistList, Min),
	indexOf(DistList, Min, Index),
	length(DistList, L),
	RealInd is L - Index -1,
	nth0(RealInd, [SametypeH|SametypeT], FoundKey),
	ObjKey is FoundKey,
	get_dict(FoundKey, ObjD, Object),
	Distance is Min.
	
make_dist_l([], _AgX, _AgY, _ObjDict, [1000000000000000000]).
make_dist_l([H|T], AgX, AgY, ObjDict, DistList):- 
	get_dict(H, ObjDict, Value),
	ObjX is Value.x,
	ObjY is Value.y,
	manhattan_distance([AgX, AgY],[ObjX, ObjY], Distance),
	make_dist_l(T, AgX, AgY, ObjDict, NewList),
	append(NewList, [Distance], DistList).
	

% 10 points
% navigate_to(+State, +X, +Y, -ActionList, +DepthLimit) :- .
navigate_to(State, X, Y, _ActionList, DepthLimit) :- 
	nth0(0,State,Agent),
	manhattan_distance([Agent.x, Agent.y], [X,Y], Dist),
	Dist>DepthLimit,!, fail.
	
navigate_to(State, X, Y, ActionList, _DepthLimit) :- 
	nth0(0,State,Agent),
	navigate_helper(Agent.x, Agent.y, X, Y, ActionList).

navigate_to_wo_limit(State, X, Y, ActionList) :- 
	nth0(0,State,Agent),	
	navigate_helper(Agent.x, Agent.y, X, Y, ActionList).
	
	
navigate_helper(X, Y, X, Y, []).
navigate_helper(AgX, AgY, X, Y, ActList):-
	AgX > X -> (
		Temp is AgX - 1,
		navigate_helper(Temp, AgY, X, Y, NewList),
		append(NewList, [go_left], ActList)
		).
	
navigate_helper(AgX, AgY, X, Y, ActList):-
	AgX < X -> (
		Temp is AgX + 1,
		navigate_helper(Temp, AgY, X, Y, NewList),
		append(NewList, [go_right], ActList)
		).
	
navigate_helper(AgX, AgY, X, Y, ActList):-
	AgY > Y-> (
		Temp is AgY - 1,
		navigate_helper(AgX, Temp, X, Y, NewList),
		append(NewList, [go_up], ActList)
		).
	
navigate_helper(AgX, AgY, X, Y, ActList):-
	AgY < Y-> (
		Temp is AgY + 1,
		navigate_helper(AgX, Temp, X, Y, NewList),
		append(NewList, [go_down], ActList)
		).

% 10 points
% chop_nearest_tree(+State, -ActionList) :- .
chop_nearest_tree(State, ActionList) :- 
	find_nearest_type(State, tree, _ObjKey, Object, _Distance), 
	ObjX is Object.x,
	ObjY is Object.y,
	navigate_to_wo_limit(State, ObjX, ObjY, InitActionList), 
	append(InitActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).

% 10 points
% mine_nearest_stone(+State, -ActionList) :- .
mine_nearest_stone(State, ActionList) :-
	find_nearest_type(State, stone, _ObjKey, Object, _Distance), 
	ObjX is Object.x,
	ObjY is Object.y,
	navigate_to_wo_limit(State, ObjX, ObjY, InitActionList), 
	append(InitActionList, [left_click_c, left_click_c, left_click_c, left_click_c], ActionList).

% 10 points
% gather_nearest_food(+State, -ActionList) :- .
gather_nearest_food(State, ActionList) :- 
	find_nearest_type(State, food, _ObjKey, Object, _Distance), 
	ObjX is Object.x,
	ObjY is Object.y,
	navigate_to_wo_limit(State, ObjX, ObjY, InitActionList), 
	append(InitActionList, [left_click_c], ActionList).



% 10 points
% collect_requirements(+State, +ItemType, -ActionList) :- .

%STICK
%no trees
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stick,
	not(chop_nearest_tree(State, ActionList)),!, fail.

%need to chop tree	
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stick,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 2,
	chop_nearest_tree(State, ActionList).
	
	
	
%STONE PICKAXE

%need only logs
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList).
	
%need only one stick
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) >= 3,
	collect_requirements(State, stick, InitActionList),
	append(InitActionList, [craft_stick], ActionList).
	
%need only two sticks
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) >= 3,
	collect_requirements(State, stick, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick, craft_stick], ActionList).
	
%need only cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList).
	
%need logs and 1 stick
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick], ActionList).
	
%need logs and 2 sticks
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4),
	append(ActionList4, ActionList3, ActionList5),
	append(ActionList5, [craft_stick, craft_stick], ActionList).

%need logs and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	append(ActionList1, ActionList2, ActionList).

%need 1 stick and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick], ActionList).

%need 2 sticks and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4),
	append(ActionList4, ActionList3, ActionList5),
	append(ActionList5, [craft_stick, craft_stick], ActionList).

%need logs, 1 stick, cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4), 
	append(ActionList4, ActionList3, ActionList5), 
	append(ActionList5, [craft_stick], ActionList).

	
%need logs, 2 stick, cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_pickaxe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	collect_requirements(State, stick, ActionList4),
	collect_requirements(State, stick, ActionList5),
	append(ActionList4, ActionList5, ActionList6), 
	append(ActionList3, ActionList6, ActionList7),
	append(ActionList7, [craft_stick, craft_stick], ActionList).

%STONE AXE

%need only logs
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList).
	
%need only one stick
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) >= 3,
	collect_requirements(State, stick, InitActionList),
	append(InitActionList, [craft_stick], ActionList).
	
%need only two sticks
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) >= 3,
	collect_requirements(State, stick, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick, craft_stick], ActionList).
	
%need only cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList).
	
%need logs and 1 stick
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick], ActionList).
	
%need logs and 2 sticks
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) >= 3,
	chop_nearest_tree(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4),
	append(ActionList4, ActionList3, ActionList5),
	append(ActionList5, [craft_stick, craft_stick], ActionList).

%need logs and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) >= 2,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	append(ActionList1, ActionList2, ActionList).

%need 1 stick and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	append(ActionList3, [craft_stick], ActionList).

%need 2 sticks and cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) >= 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) < 3,
	mine_nearest_stone(State, ActionList1),
	collect_requirements(State, stick, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4),
	append(ActionList4, ActionList3, ActionList5),
	append(ActionList5, [craft_stick, craft_stick], ActionList).

%need logs, 1 stick, cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 1,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	collect_requirements(State, stick, ActionList3),
	append(ActionList1, ActionList2, ActionList4), 
	append(ActionList4, ActionList3, ActionList5), 
	append(ActionList5, [craft_stick], ActionList).

	
%need logs, 2 stick, cobblestones
collect_requirements(State, ItemType, ActionList) :-
	ItemType=stone_axe,
	nth0(0,State,Agent),
	get_dict(inventory, Agent, Bag),
	Bag.get(log, 0) < 3,
	Bag.get(stick, 0) = 0,
	Bag.get(cobblestone, 0) < 3,
	chop_nearest_tree(State, ActionList1),
	mine_nearest_stone(State, ActionList2),
	append(ActionList1, ActionList2, ActionList3), 
	collect_requirements(State, stick, ActionList4),
	collect_requirements(State, stick, ActionList5),
	append(ActionList4, ActionList5, ActionList6), 
	append(ActionList3, ActionList6, ActionList7),
	append(ActionList7, [craft_stick, craft_stick], ActionList).

	
% 5 points
% find_castle_location(+State, -XMin, -YMin, -XMax, -YMax) :- .


% 15 points
% make_castle(+State, -ActionList) :- .
