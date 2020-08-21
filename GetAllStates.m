 function [StateArray, CityArray] = GetAllStates(DataIn, State)
%{
    [StateArray, CityArray] = GetAllCities(DataIn, State)

    Function takes in array of structures and gathers all unique city
    strings for specified state returning both the entirety of the states
    and all unique cities

    Input:  DataIn - array of structures with state pages pertaining to specific state
            State - string of specific state abbreviation
    Output: CityArray - array of unique strings of city names for specified
                        state
            StateArray - array of unique strings of state abbreviations
    
    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Get all field names from the input
StateCells = fieldnames(DataIn);

%Preallocated StateArray to save time
StateArray = string(zeros(1,length(StateCells)));

%Preallocate CityArray to allow for concatenation
CityArray = [];
for i = 1:length(StateCells)
    %For every state add the string to the array
    StateArray(i) = string(StateCells{i});
    %If the specific state matches the provided state, add all cities to CityArray
    if(strcmpi(string(StateCells{i}), upper(State)))
        eval(strcat("CityArray = horzcat(CityArray, GetAllCities(DataIn.",string(StateCells{i}),"));"))
    end
end

%Sort both the States and Cities and remove duplicates where possible
StateArray = sort(unique(StateArray));
CityArray = sort(unique(CityArray));

%Check that the first element of the CityArray is not a string "0" to prevent erroneous parsing
if ~isempty(CityArray) && strcmp(CityArray(1),"0")
    %If it is, simply remove it
   CityArray = CityArray(2:end); 
end

end