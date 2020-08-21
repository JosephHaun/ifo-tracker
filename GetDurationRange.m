function [MaxDuration] = GetDurationRange(DataInput)
%{
    [MaxDuration] = GetDurationRange(DataInput)

    Function gets max duration from database

    Input: DataInput - a structure of arrays of structures for each state database

    Output: MaxDuration - double value of largest duration in database

    Output: 
    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

MaxDuration = 0;
FieldNames = fieldnames(DataInput);

for i = 1:length(FieldNames)
    %Get specific state database
    eval(strcat("Temp = DataInput.", string(FieldNames{i}),";"));
    for j = 1:length(Temp)
        %Find largest duration value in all databases
       if MaxDuration < Temp(j).duration
          MaxDuration = Temp(j).duration; 
       end
    end
end

end