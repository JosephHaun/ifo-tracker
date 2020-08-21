function [DataOutput] = GetAllDateNums(DataInput)
%{
    [DataOutput] = GetAllDateNums(DataInput)

    Function gets all unique date_num values

    Input: DataInput - a structure with arrays of structures with date_num fields

    Output: DataOutput - an array of unique date_nums for entirety of database

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Get all field names for input and preallocate output for concatenation
FieldNames = fieldnames(DataInput);
DataOutput = [];
for i = 1:length(FieldNames)
    %Get length for each 
    %eval(strcat("TempLength = length(DataInput.",string(FieldNames{i}),");"));
    
    %Get all date_nums for each state 
    eval(strcat("TempArray = [DataInput.",string(FieldNames{i}),".date_num];"))
    %Add all state date_nums to overall array and sort out duplicates
    DataOutput = unique(horzcat(DataOutput,TempArray));
end

end