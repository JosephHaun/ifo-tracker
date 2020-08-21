function [newDate] = newDateVector_modified(state)
%
%             [newDate] = newDateVector_modified(state)
%             
% Created by Thomas Swanson, EE314, Fall 2018
% Modified by Austin Salois, EE314, Fall2018
% input -- state: A table of data for a specific state
% 
% output -- newDate: vector of dates for each occurance as a string in the
%                    format "YYYY-MM-DD
% 
% 
%     Jonah Baumgartner
%     Daniel Gil
%     Joe Haun
%     Priyanka Khera
%     Austin Salois
%     Thomas Swanson
% 
%     EE 314: IFO Tracker Project
%     12-12-18

if isempty(state(1,:).date_time{1})
    %Set all empty date_time fields to standardized date
    state(1,:).date_time{1}='2000-01-01T00:00:00';
end

%Get length of state vector
stateVectorLength = size(state,1);
%Preallocate date array
newDate = string(ones(stateVectorLength,1));
i = 1;
while i <= stateVectorLength
    if isempty(state(i,:).date_time{1})
        %If date is empty, use previous date
        newDate(i)= newDate(i-1); 
    else
        %Otherwise, get appropriate date length
        modifiedDate = state(i,:).date_time{1}(1:10);
        newDate(i) = modifiedDate;
    end
    
i = i + 1;
end

%Convert newDate into datetimes
newDate = datetime(newDate);

return