function [ShapesArray] = GetAllShapes(DataInput)
%{
    [ShapesArray] = GetAllShapes(DataInput)

    Function gets all unique shapes from database

    Input: DataInput - a structure with arrays of structures as pages for
                       each state

    Output: ShapesArray - array of strings indicating all unique shapes in
                          database

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

ShapesArray = [DataInput.CA(1).shape]; %Seed Output with a known shape
%Get all input fields
FieldNames = fieldnames(DataInput);
for i = 1:length(FieldNames)
    %Find length of each specific state database
   eval(strcat("TempLength = length(DataInput.",string(FieldNames{i}),");"))
   for k = 1:TempLength
       %Get all shapes for the specific state database
       eval(strcat("TempShape = string(DataInput.",string(FieldNames{i}),"(k).shape);"))
       if (sum(strcmpi(TempShape,ShapesArray))) == 0 && (strcmpi(TempShape,"") == 0)
           %Compare all strings, add to output if not present. Make sure it is not a blank
          ShapesArray = horzcat(ShapesArray,TempShape);
       end
   end
end

end
