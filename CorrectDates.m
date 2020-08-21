function [DataOutput] = CorrectDates(TableData, ArrayData)
%{
    [DataOutput] = CorrectDates(TableData, ArrayData)

    Function takes in database and converts date format into Matlab format

    Input: TableData - structure with each page a table for a specific
                       state
           ArrayData - a structure with each page an array of structures
                       for a specific state with a date_time string field
    
    Output: DataOutput - ArrayData with added datenum field from converted
                         date_num field

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%Get all field names for structure
FieldNames = fieldnames(ArrayData);
%Place given structure of arrays of structures into output
DataOutput = ArrayData;

for i = 1:length(FieldNames)
    %Change all dates to MM/DD/YYYY format
    eval(strcat("TempDates = newDateVector_modified(TableData.",string(FieldNames{i}),");"))
    for k = 1:length(TempDates)
        %Assign every corrected date to the appropriate date_time field
        eval(strcat("DataOutput.",FieldNames{i},"(k).date_time = TempDates(k);"))
        %Add a date_num field to each array element and convert date_time to date_num
        eval(strcat("DataOutput.",FieldNames{i},"(k).date_num = datenum(TempDates(k));"))
    end
end


end