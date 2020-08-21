function [OutputStruct] = CorrectDuration(InputStruct)
%{
    [Output] = CorrectDuration(Input)

    Function takes in a string duration and outputs double duration based
    in hours

    Input: InputStruct - array of structs with a duration field
    Output: OutputStruct - a structure of array of structs with corrected
                           duration field

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

IntegerValidString = ["0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]; %Valid Integer values
ModifierValidString = ["h" "m" "s"]; %Valid time modifier strings
OutputStruct = InputStruct; %Place input into output

for i = 1:length(InputStruct)
    %For each value of the input structure, pull out duration string field
    DurInput = InputStruct(i).duration;
    %Find places of all spaces
    SpaceIndex = find(DurInput == ' ');
    %If only one space, duration is in valid format continue to parse
    if length(SpaceIndex) == 1
        %Get all string values up until the space
        IntString = DurInput(1:SpaceIndex-1);
        %Get all string values after the space
        ModifierString = DurInput(SpaceIndex+1:end); 
        IntIndex = 1;
        while (IntIndex < length(IntString)) && (sum(strcmp(IntegerValidString, string(IntString(IntIndex)))) == 0)
           %Check to make sure all characters are valid integer characters
           %stop when a valid is occured and treat value as
           %total duration
           IntIndex = IntIndex + 1; 
        end
        ModIndex = 1;
        while (ModIndex < length(ModifierString)) && (sum(strcmp(ModifierValidString, string(ModifierString(ModIndex)))) == 0)
           %Check to make sure the modifier string is valid, stop when
           %valid character is incurred
           ModIndex = ModIndex + 1; 
        end
        %Since some durations were not in ideal format use found value as total string
        IntString = IntString(IntIndex);
        %Found at least one valid modifier character
        ModifierString = ModifierString(ModIndex);
        %Based on modifier, convert IntString into a double
        if strcmp(ModifierString, ModifierValidString(1))
            %If already in hours, simply convert value into double
            OutputStruct(i).duration = round(str2num(IntString));
        elseif strcmp(ModifierString, ModifierValidString(2))
            %If in minutes, convert and divide by 60
            OutputStruct(i).duration = round(str2num(IntString)/60);
        else
            %If in seconds, convert and divide by 360
            OutputStruct(i).duration = round(str2num(IntString)/360);
        end
        if isempty(OutputStruct(i).duration)
            %If particular field is empty, set to zero
           OutputStruct(i).duration = 0; 
        end
    else
        %If number of spaces not equal to one indicates that duration is
        %not in a valid format. Assign 0 to allow for use later. 
        OutputStruct(i).duration = 0;
    end
end

end