function [Output] = IFOTableToStruct(InputStruct)
%{
    [Output] = IFOTableToStruct(InputStruct)

    Function takes in a structure of tables and outputs a structure with arrays of structures containing
    data for each row present within the table

    Input: InputStruct - structure with state tables as pages to be parsed
                         into an array of structures with all headers as field names
    Output: Output - structure with each page being a state abreviation 
                     that contains an array of structures with all headers of tables as field names
                     

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%} 

%Get all field names from the input structure
FieldNames = fieldnames(InputStruct);
for i = 1:length(FieldNames)
    %For each field, convert table using table2struct and add to the output structure
    eval(strcat("Output.",string(FieldNames{i})," = ","eval(strcat('table2struct(InputStruct.',string(FieldNames{i}),')'));"));
    %Create a temporary array of structures to use in CorrectDuration function
    eval(strcat("Temp = Output.",string(FieldNames{i}), ";"));
    %Use CorrectDuration to convert the durations from strings to numbers
    eval(strcat("Output.",string(FieldNames{i})," = ","eval('CorrectDuration(Temp)');"));  
end
    %Use CorrectDates to convert all date strings into Matlab datenums and
    %add as extra field onto array of structures
    Output = CorrectDates(InputStruct, Output);
end

