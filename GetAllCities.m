function [CityArray] = GetAllCities(DataIn)
%{
    [CityArray] = GetAllCities(DataIn)

    Function takes in array of structures and gathers all unique city
    strings

    Input:  DataIn - array of structures pertaining to specific state

    Output: CityArray - array of strings of city names
    
    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Get all unique city names from entirety of given array of structures
CityCells = unique(upper({DataIn(1:end).city}));
%Preallocate array for corrections
CityArray = string(zeros(1,length(CityCells)));
for i = 1:length(CityCells)
    Temp = CityCells{i};
    %If not a strange value like a blank, UNKNOWN, ?, or 0 convert each city into a string
    if ~(strcmp(string(Temp),"")) && ~(strcmp(string(Temp),"UNKNOWN")) && ~(strcmp(string(Temp(1)),"?")) && ~(strcmp(string(Temp),"0"))
        CityArray(i) = string(CityCells{i});
    end
end

end