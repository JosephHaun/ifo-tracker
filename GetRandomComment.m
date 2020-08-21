function [Comment] = GetRandomComment(StatesData)
%{
    [Comment] = GetRandomComment(StatesData)

    Function uses given database to parse out a single random comment and
    return it to the caller.

    Input: StatesData - a structure of tables with state abreviations as
                        the pages used
    Output: Comment - a string of the comment that was randomly selected
                      for display

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Get all fields of database
StatesList = fieldnames(StatesData);

%Get a random state from the fieldnames
State = string(StatesList{randi(length(StatesList))});

%Get the size of the table chosen
x = size(StatesData.(eval('State')));

%Chose a random number based on the size of table chosen
Num = randi(eval('x(1)'));

%Use the random number generated to chose a comment from the selected state
Comment = string(StatesData.(eval('State'))((eval('Num')),:).text);

end