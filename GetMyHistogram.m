function [OutputStruct]=GetMyHistogram(InputStateTable, StateName, AxesHandle)
%
%       [OutputStruct]=GetMyHistogram(InputStateTable, StateName)
%
% Austin Salois, EE314, Fall 2018
% This function takes in a table of data for a state, feeds it to a 
% function that returns a vector of dates, and then plots a bar graph 
% of that data.
% *************************************************************************
%         Example input with data struct called StatesData
%         [OutputStruct]=GetMyHistogram(StatesData.CA, 'CA');
% *************************************************************************
% Inputs: 
%     InputStateTable: A table for a certain state
%     StateName: The name of the State in 2 letter abbriviation (String)
%     
% Outputs:
%     A struct containing
%         StateData: The table that was an input
%         StateName: The name of the state
%         Figure: The figure handle for the histogram
%     Jonah Baumgartner
%     Daniel Gil
%     Joe Haun
%     Priyanka Khera
%     Austin Salois
%     Thomas Swanson
% 
%     EE 314: IFO Tracker Project
%     12-12-18

%Get all dates to display on X axis of histogram
[YearVector]=newDateVector_modified(InputStateTable);

%Assign inputs to outputs
OutputStruct.StateData=InputStateTable;
OutputStruct.StateName=StateName;

%OutputStruct.Figure=figure;
%Create figure on given AxesHandle
cla(AxesHandle);
histogram(AxesHandle, YearVector.Year);
xlabel('Year');
ylabel('Number of sightings')
title(strcat('Histogram for State: ',StateName));
