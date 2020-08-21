function [LatArray, LonArray] = GetLocations(Database, Mode, Limiters)
%{

    [LatArray, LonArray] = GetLocations(Database, Mode, Limiters)

    Function returns an array of latitude and longitudes based on current
    Mode value and Limiters.
    
    Input:  Database - Entire database in the form of a struct with arrays
            of structs for state data
            Mode - value of 0, 1, or 2 which indicate Country-wide,
            State-wide, or City-wide respectively. 
            Limiters - A struct containing with date_min, date_max,
            dur_min, dur_max, state, city, and shapes pages
    Output: LatArray - array of doubles indicating latitudes to be plotted
            LonArray - array of doubles indicating longitudes to be
            plotted

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Preallocate InternalDatabase for concatenation
InternalDatabase = [];

%Depending on mode, create internal array for parsing, if country-wide
%concatenate all states together, otherwise just copy one specific state
if Mode == 0
    FieldNames = fieldnames(Database);
    for i = 1:length(FieldNames)
        eval(strcat("InternalDatabase = vertcat(InternalDatabase, Database.", string(FieldNames{i}), ");"))
    end
else 
    eval(strcat("InternalDatabase = [Database.", Limiters.state, "];"))
end

DatabaseLength = length(InternalDatabase);
%Preallocate output arrays to save some time with 360 to be parsed out
FlagValue = 360;
TempLatArray = FlagValue*ones(1, DatabaseLength);
TempLonArray = FlagValue*ones(1, DatabaseLength);
for i = 1:DatabaseLength
    %If current entry meets Limiter conditions, check mode and add to temp arrays 
    if (InternalDatabase(i).duration >= Limiters.dur_min) && (InternalDatabase(i).duration <= Limiters.dur_max) && (InternalDatabase(i).date_num >= Limiters.date_min) && (InternalDatabase(i).date_num <= Limiters.date_max) && (sum(strcmpi(InternalDatabase(i).shape, Limiters.shapes)) == 1)
        if (Mode < 2)
            %If not in city mode, simply add any matching value to arrays
            TempLatArray(i) = InternalDatabase(i).city_latitude;
            TempLonArray(i) = InternalDatabase(i).city_longitude;
        else
            %If in city mode, check to make sure the city field matches 
            if strcmpi(string(InternalDatabase(i).city), Limiters.city)
                TempLatArray(i) = InternalDatabase(i).city_latitude;
                TempLonArray(i) = InternalDatabase(i).city_longitude;
            end
        end
    end
end

%Remove all FlagValues from the array as they should be much larger than any 
%possible value also removing any NaNs that may be in the data due to incomplete database
LatArray = TempLatArray(TempLatArray ~= FlagValue);
LatArray = LatArray(~isnan(LatArray));
LonArray = TempLonArray(TempLonArray ~= FlagValue);
LonArray = LonArray(~isnan(LonArray));

end