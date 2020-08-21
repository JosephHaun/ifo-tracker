function [CurrentState] = IFOTracker(Database1, Database2, ParentFigure)
%{
    [CurrentState] = IFOTracker(DataInput)

    Function takes in a structure containing relevant data and produces a
    figure that contains GUI elements to display and sort relevant data.

    Input:  Database1 -     A structure with state abreviations as pages.
                            Each page contains an array of structures with city, 
                            state, date_time, date_num, shape, duration, 
                            city_latitude, and city_longitude pages
            Database2 -     A structure with state abreviations as pages. Each
                            page is a table of data with headers of city,
                            state, date_time, shape, and duration
            ParentFigure -  figure handle to calling GUI for swapping
                            between figures and preventing significant computation
    Output: CurrentState -  structure containing the figure and GUI elements
                            that were setup to allow calling function to
                            manipulate the figure as needed.
 
            CurrentState Data Fields: DateNums an array of datenums,
            StateStrings a array of strings indicating state abreviations, CityStrings an array
            of strings indicating cities for current state, DateRange an
            array of datenums indicating max and min, DurationRange an
            array of doubles indicating max and min, AddShapesArray an
            array of strings of all shapes available to add to filter,
            RemoveShapesArray an array of strings of all shapes available
            to remove from filtering

            CurrentState UI Fields: ExitProgramButton,
            AnalyticsButton, ShowMapButton1, RefreshButton, ImagePanel,
            CitySelector, StateSelector, AreaSelectorPanel, CountryButton,
            StateButton, CityButton, DateSliderPanel, DateSlider,
            DateMinButton, DateMaxButton, DateResetButton, DateMinText,
            DateErrorText, DateMaxText, DurationSlider, DurationPanel,
            DurationMinText, DurationMaxText, DurationErrorText,
            DurationResetButton, DurationMinButton,
            DurationMaxButton,ShapeSelectorPanel, AddShapeSelector,
            RemoveShapeSelector, AddShapeButton, RemoveShapeButton

            CurrentState Axes Fields: ImageAxes
            
            
            Jonah Baumgartner
            Daniel Gil
            Joe Haun
            Priyanka Khera
            Austin Salois
            Thomas Swanson
            
            EE 314: IFO Tracker Project
            12-12-18
%}

%Parse out shapes, duration range, and all date nums for displaying on GUI
TemporaryShapesArray = GetAllShapes(Database1);
TemporaryDurationRange = GetDurationRange(Database1);
CurrentState.DateNums = GetAllDateNums(Database1);

%Make main figure window
CurrentState.MainPanel = figure( 'NumberTitle', 'off', 'MenuBar', 'none','Toolbar', 'none','Visible','off', 'Name', 'Identified Flying Objects', 'WindowState', 'fullscreen');

%Make button that will move close this window
CurrentState.ExitProgramButton = uicontrol(CurrentState.MainPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.975 0.975 0.025 0.025], 'String', 'X', 'Tooltip', 'Return to main menu');

    function ExitProgramButtonFunction(Object, CallData)
        %Since the GUI is resource heavy on startup, don't actually close
        %this window when the button is pushed. Simply hide it and reveal
        %the previously hidden parent window.
        Object.Parent.Visible = 'off';
        %ParentFigure.Visible = 'on';
    end

%Make control panel area
CurrentState.ControlPanel = uipanel('Units', 'normalized', 'Position', [0.7 0.1 0.2 0.8], 'BackgroundColor', [1 1 1]);

%Make buttons to transfer between Histogram and Map display panels
CurrentState.AnalyticsButton = uicontrol(CurrentState.ControlPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.5 0.075 0.4 0.05], 'String', 'Show Analytics', 'Visible', 'on', 'Enable', 'on', 'Tooltip', 'Change to showing a histogram of statewide data');
CurrentState.ShowMapButton1 = uicontrol(CurrentState.ControlPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.1 0.075 0.4 0.05], 'String', 'Show Map', 'Visible', 'on', 'Enable', 'off', 'Tooltip', 'Change to showing a map of current data');

%Make button to refresh the data available to be plotted
CurrentState.RefreshButton = uicontrol(CurrentState.ControlPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.1 0.025 0.8 0.05], 'String', 'Refresh', 'Visible', 'on', 'Enable', 'on', 'Tooltip', 'Get new data from the database to display');

%Initialize ShowMapSet and AnalyticsSet variables for dealing with GUI
%elements visible
setappdata(CurrentState.MainPanel, 'ShowMapSet', 1);
setappdata(CurrentState.MainPanel, 'AnalyticsSet', 0);

    function AnalyticsButtonFunction(Object, CallData)
        %Enable the show map button and disable the analytics button
        CurrentState.ShowMapButton1.Enable = 'on';
        CurrentState.AnalyticsButton.Enable = 'off';
        %Change the state of the variables to reflect this change
        setappdata(CurrentState.MainPanel, 'ShowMapSet', 0);
        setappdata(CurrentState.MainPanel, 'AnalyticsSet', 1);
        %Put GUI into state mode to avoid user confusion
        CurrentState.StateSelector.Visible = 'on';
        CurrentState.StateSelector.Enable = 'on';
        CurrentState.CitySelector.Enable = 'off';
        CurrentState.CitySelector.Visible = 'off';
        CurrentState.StateButton.Value = 1;
        %Set appropriate mode values for use in refresh function parsing
        setappdata(CurrentState.MainPanel, 'CountryMode', 0);
        setappdata(CurrentState.MainPanel, 'StateMode', 1);
        setappdata(CurrentState.MainPanel, 'CityMode', 0);
        
    end
    function ShowMapButtonFunction(Object, CallData)
        %Turn map button off, analytics button on and change the state of
        %variables for the refresh function
        CurrentState.ShowMapButton1.Enable = 'off';
        CurrentState.AnalyticsButton.Enable = 'on';
        setappdata(CurrentState.MainPanel, 'ShowMapSet', 1);
        setappdata(CurrentState.MainPanel, 'AnalyticsSet', 0);
        
    end
    function RefreshButtonFunction(Object, CallData)
        %Call function to refresh image panel with whatever state is chosen
        RefreshImagePanel(); 
    end

%Make image panel area and axes to plot images/graphs
CurrentState.ImagePanel = uipanel('Units', 'normalized', 'Position', [0.1 0.1 0.55 0.8], 'BackgroundColor', [1 1 1], 'Visible', 'on');
CurrentState.ImageAxes = axes(CurrentState.ImagePanel);

%Turn axis off to make it look pretty
axis off;

%Parse out all states and the list of cities for Alaska
[CurrentState.StateStrings, CurrentState.CityStrings] = GetAllStates(Database1, "AK");

%Make area selector and radio buttons
CurrentState.StateSelector = uicontrol(CurrentState.ControlPanel, 'Style', 'popupmenu', 'String', CurrentState.StateStrings, 'Units', 'normalized', 'Position', [0.1 0.8 0.8 0.05], 'Enable', 'off', 'Visible', 'off');
CurrentState.CitySelector = uicontrol(CurrentState.ControlPanel, 'Style', 'popupmenu', 'String', CurrentState.CityStrings, 'Units', 'normalized', 'Position', [0.1 0.75 0.8 0.05], 'Enable', 'off', 'Visible', 'off');

%Set default values for parsing variables and parsing mode for refresh
setappdata(CurrentState.MainPanel, 'StateSelectorVal', string(CurrentState.StateSelector.String(CurrentState.StateSelector.Value)));
setappdata(CurrentState.MainPanel, 'CitySelectorval', string(CurrentState.CitySelector.String(CurrentState.CitySelector.Value)));
setappdata(CurrentState.MainPanel, 'CountryMode', 1);
setappdata(CurrentState.MainPanel, 'StateMode', 0);
setappdata(CurrentState.MainPanel, 'CityMode', 0);

%Make area selector button panel and three radial buttons for country,
%state, and city modes
CurrentState.AreaSelectorPanel = uibuttongroup(CurrentState.ControlPanel, 'Units', 'normalized', 'Position', [0.1 0.85 0.8 0.1], 'Title', 'Area Selection', 'BackgroundColor', [1 1 1]);
CurrentState.CountryButton = uicontrol(CurrentState.AreaSelectorPanel, 'Style', 'radiobutton', 'String', 'Country-Wide', 'Value', 1, 'Units', 'normalized', 'Position', [0.07 0.25 0.5 0.5], 'TooltipString', 'Select a general area', 'BackgroundColor', [1 1 1]);
CurrentState.StateButton = uicontrol(CurrentState.AreaSelectorPanel, 'Style', 'radiobutton', 'String', 'State', 'Units', 'normalized', 'Position', [0.50 0.25 0.5 0.5], 'TooltipString', 'Select a location area to look at.', 'BackgroundColor', [1 1 1] );
CurrentState.CityButton = uicontrol(CurrentState.AreaSelectorPanel, 'Style', 'radiobutton', 'String', 'City', 'Units', 'normalized', 'Position', [0.75 0.25 0.5 0.5], 'TooltipString', 'Select a location area to look at.', 'BackgroundColor', [1 1 1]);

%Declare object functions for area selector panel
    function CountryButtonFunction(Object, CallData)
        %Turn state and city selectors off 
        CurrentState.StateSelector.Visible = 'off';
        CurrentState.StateSelector.Enable = 'off';
        CurrentState.CitySelector.Enable = 'off';
        CurrentState.CitySelector.Visible = 'off';
        %Transition variables into country mode for refresh parsing
        setappdata(CurrentState.MainPanel, 'CountryMode', 1);
        setappdata(CurrentState.MainPanel, 'StateMode', 0);
        setappdata(CurrentState.MainPanel, 'CityMode', 0);
        
    end
    function StateButtonFunction(Object, Calldata)
        %Turn state selector on and city selector off
        CurrentState.StateSelector.Visible = 'on';
        CurrentState.StateSelector.Enable = 'on';
        CurrentState.CitySelector.Enable = 'off';
        CurrentState.CitySelector.Visible = 'off';
        %Transition variables into state mode for refresh parsing
        setappdata(CurrentState.MainPanel, 'CountryMode', 0);
        setappdata(CurrentState.MainPanel, 'StateMode', 1);
        setappdata(CurrentState.MainPanel, 'CityMode', 0);
        
    end
    function CityButtonFunction(Object, Calldata)
        %Turn both state and city selectors on
        CurrentState.StateSelector.Visible = 'on';
        CurrentState.StateSelector.Enable = 'on';
        CurrentState.CitySelector.Enable = 'on';
        CurrentState.CitySelector.Visible = 'on';
        %Transition variables into city mode for refresh parsing
        setappdata(CurrentState.MainPanel, 'CountryMode', 0);
        setappdata(CurrentState.MainPanel, 'StateMode', 0);
        setappdata(CurrentState.MainPanel, 'CityMode', 1);
        
    end
    function StateSelectorFunction(Object, Calldata)
        %Set Selector value for parsing as current value
        setappdata(CurrentState.MainPanel, 'StateSelectorVal', string(CurrentState.StateSelector.String(CurrentState.StateSelector.Value)));
        
        %Get all states and cities again for currently selector state
        [CurrentState.StateStrings, CurrentState.CityStrings] = GetAllStates(Database1, getappdata(CurrentState.MainPanel, 'StateSelectorVal'));
        
        %Change CitySelector string values to reflect new state choice
        CurrentState.CitySelector.String = CurrentState.CityStrings;
        
        if getappdata(CurrentState.MainPanel, 'CityMode') == 1
            %If in city mode, also set the current city selector string for refresh parsing
            setappdata(CurrentState.CitySelector, 'String', CurrentState.CityStrings);
            set(CurrentState.CitySelector, 'String', CurrentState.CityStrings);
        end
        
    end
    function CitySelectorFunction(Object, Calldata)
        %Set current city selector value for refresh parsing
        setappdata(CurrentState.MainPanel, 'CitySelectorVal', string(CurrentState.CitySelector.String(CurrentState.CitySelector.Value)));
        
    end

%Make date slider
CurrentState.DateSliderPanel = uipanel(CurrentState.ControlPanel, 'Units', 'normalized', 'Position', [0.1 0.65 0.8 0.1], 'Title', 'Select Date', 'BackgroundColor', [1 1 1]);

%Get date range
CurrentState.DateRange = [min(CurrentState.DateNums) max(CurrentState.DateNums)];

%Set indicator, min, and max values for refresh parsing
setappdata(CurrentState.MainPanel, 'DateMinSet', 0);
setappdata(CurrentState.MainPanel, 'DateMaxSet', 0);
setappdata(CurrentState.MainPanel, 'DateMinVal', CurrentState.DateRange(1));
setappdata(CurrentState.MainPanel, 'DateMaxVal', CurrentState.DateRange(2));
CurrentState.DateMinString = ["Min: " "Not Set"];
CurrentState.DateMaxString = ["Max: " "Not Set"];

%Create date slider, min, max, and reset control elements
CurrentState.DateSlider = uicontrol(CurrentState.DateSliderPanel, 'Style', 'slider', 'TooltipString', 'Select a Date', 'Min', CurrentState.DateRange(1), 'Max', CurrentState.DateRange(2), 'Value', round(median(CurrentState.DateNums)), 'SliderStep', [0.01 0.2], 'Units', 'normalized', 'Position', [0 0.3 1 0.7], 'Tooltip', 'Move to select a date');
CurrentState.DateMinButton = uicontrol(CurrentState.DateSliderPanel, 'Style', 'pushbutton', 'String', 'Set Min', 'Units', 'normalized', 'Position', [0 0 0.4 0.3], 'Tooltip', 'Set the minimum date to get');
CurrentState.DateMaxButton = uicontrol(CurrentState.DateSliderPanel, 'Style', 'pushbutton', 'String', 'Set Max', 'Units', 'normalized', 'Position', [0.4 0 0.4 0.3], 'Enable', 'on',  'Tooltip', 'Set the maximum date to get');
CurrentState.DateResetButton = uicontrol(CurrentState.DateSliderPanel, 'Style', 'pushbutton', 'String', 'Reset', 'Units', 'normalized', 'Position', [0.8 0 0.2 0.3], 'Enable', 'off', 'Tooltip', 'Return to default values');

%Create indicator text boxes to display selected values or errors
CurrentState.DateMinText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', strcat(CurrentState.DateMinString(1),CurrentState.DateMinString(2)), 'Units', 'normalized', 'Position', [0.1 0.6 0.4 0.05], 'BackgroundColor', [1 1 1]);
CurrentState.DateMaxText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', strcat(CurrentState.DateMaxString(1),CurrentState.DateMaxString(2)), 'Units', 'normalized', 'Position', [0.5 0.6 0.4 0.05], 'BackgroundColor', [1 1 1]);
CurrentState.DateErrorText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', ' ', 'Units', 'normalized', 'Position', [0 0.575 1 0.05], 'BackgroundColor', [1 1 1]);

%Declare object functions for date selector panel
    function DateSliderFunction(Object, CallData)
       CurrentState.DateErrorText.String = datestr(Object.Value);
    end
    function DateMinFunction(Object, CallData)
        if (CurrentState.DateSlider.Value <= getappdata(CurrentState.MainPanel, 'DateMaxVal'))
            %Turn off min button, and turn reset button on
            CurrentState.DateMinButton.Enable = 'off';
            CurrentState.DateResetButton.Enable = 'on';
            %Set min value and indicator for refresh parsing
            setappdata(CurrentState.MainPanel, 'DateMinSet', 1);
            setappdata(CurrentState.MainPanel, 'DateMinVal', CurrentState.DateSlider.Value);
            %Set min text to reflect chosen value while wiping out error text
            CurrentState.DateMinText.String = strcat(datestr(getappdata(CurrentState.MainPanel, 'DateMinVal')));
            CurrentState.DateErrorText.String = " ";
        else
           CurrentState.DateErrorText.String = "Min Value too large"; 
        end
    end
    function DateMaxFunction(Object, CallData)
        %If max value is not less than min value change text and variables
        if (CurrentState.DateSlider.Value >= getappdata(CurrentState.MainPanel, 'DateMinVal'))
            %Turn off max button, turn on refresh button
            CurrentState.DateMaxButton.Enable = 'off';
            CurrentState.ResetButton.Enable = 'on';
            %Change variables to for refresh parsing
            setappdata(CurrentState.MainPanel, 'DateMaxSet', 1);
            setappdata(CurrentState.MainPanel, 'DateMaxVal', CurrentState.DateSlider.Value);
            %Change error and max texts to reflect current values
            CurrentState.DateErrorText.String = " ";
            CurrentState.DateMaxText.String = strcat(datestr(getappdata(CurrentState.MainPanel, 'DateMaxVal')));
        else
            %If value too small, throw error into error text box
            CurrentState.DateErrorText.String = "Max Value too small";
        end
        
    end
    function DateResetFunction(Object, CallData)
        CurrentState.DateResetButton.Enable = 'off';
        CurrentState.DateMaxButton.Enable = 'on';
        CurrentState.DateMinButton.Enable = 'on';
        CurrentState.DateMaxText.String = strcat(CurrentState.DateMaxString(1), CurrentState.DateMaxString(2));
        CurrentState.DateMinText.String = strcat(CurrentState.DateMinString(1), CurrentState.DateMinString(2));
        CurrentState.DateErrorText.String = ' ';
        setappdata(CurrentState.MainPanel, 'DateMaxSet', 0);
        setappdata(CurrentState.MainPanel, 'DateMinSet', 0);
        setappdata(CurrentState.MainPanel, 'DateMaxVal', CurrentState.DateRange(2));
        setappdata(CurrentState.MainPanel, 'DateMinVal', CurrentState.DateRange(1));
        %Throw to refresh function
        
    end

%Set Duration range along with variables available to functions
CurrentState.DurationRange = [0 TemporaryDurationRange];
CurrentState.DurationMinString = ["Min: " "Not Set"];
CurrentState.DurationMaxString = ["Max: " "Not Set"];
setappdata(CurrentState.MainPanel, 'DurationMinSet', 0);
setappdata(CurrentState.MainPanel, 'DurationMaxSet', 0);
setappdata(CurrentState.MainPanel, 'DurationMinVal', CurrentState.DurationRange(1));
setappdata(CurrentState.MainPanel, 'DurationMaxVal', CurrentState.DurationRange(2));

%Create panel, slider, min, max, reset, and text GUI elements
CurrentState.DurationSliderPanel = uipanel(CurrentState.ControlPanel, 'Units', 'normalized', 'Position', [0.1 0.45 0.8 0.1], 'Title', 'Select Duration', 'BackgroundColor', [1 1 1]);
CurrentState.DurationSlider = uicontrol(CurrentState.DurationSliderPanel, 'Style', 'slider', 'TooltipString', 'Select a duration', 'Min', CurrentState.DurationRange(1), 'Max', CurrentState.DurationRange(2), 'Value', CurrentState.DurationRange(2)/2, 'SliderStep', [0.001 0.2], 'Units', 'normalized', 'Position', [0 0.3 1 0.7], 'Tooltip', 'Select a duration in hours');
CurrentState.DurationMinButton = uicontrol(CurrentState.DurationSliderPanel, 'Style', 'pushbutton', 'String', 'Set Min', 'Units', 'normalized', 'Position', [0 0 0.4 0.3], 'Tooltip', 'Select a minimum duration in hours');
CurrentState.DurationMaxButton = uicontrol(CurrentState.DurationSliderPanel, 'Style', 'pushbutton', 'String', 'Set Max', 'Units', 'normalized', 'Position', [0.4 0 0.4 0.3], 'Enable', 'on', 'Tooltip', 'Select a maximum duration in hours');
CurrentState.DurationResetButton = uicontrol(CurrentState.DurationSliderPanel, 'Style', 'pushbutton', 'String', 'Reset', 'Units', 'normalized', 'Position', [0.8 0 0.2 0.3], 'Enable', 'off', 'TooltipString', 'Clear Selection');
CurrentState.DurationMinText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', strcat(CurrentState.DurationMinString(1),CurrentState.DurationMinString(2)), 'Units', 'normalized', 'Position', [0.1 0.4 0.4 0.05], 'BackgroundColor', [1 1 1]);
CurrentState.DurationMaxText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', strcat(CurrentState.DurationMaxString(1),CurrentState.DurationMaxString(2)), 'Units', 'normalized', 'Position', [0.5 0.4 0.4 0.05], 'BackgroundColor', [1 1 1]);
CurrentState.DurationErrorText = uicontrol(CurrentState.ControlPanel, 'Style', 'text', 'String', ' ', 'Units', 'normalized', 'Position', [0 0.375 1 0.05], 'BackgroundColor', [1 1 1]);

%Declare object functions for duration selector panel 
    function DurationSliderFunction(Object, Calldata)
       CurrentState.DurationErrorText.String = strcat(string(Object.Value), " hours"); 
    end

    function DurationMinFunction(Object, CallData)
        if (CurrentState.DurationSlider.Value <= getappdata(CurrentState.MainPanel, 'DurationMaxVal'))
            %If current slider value is less than set max value turn off min button and turn on reset button
            CurrentState.DurationMinButton.Enable = 'off';
            CurrentState.DurationResetButton.Enable = 'on';
            %Set variables for refresh parsing and current 
            setappdata(CurrentState.MainPanel, 'DurationMinSet', 1);
            setappdata(CurrentState.MainPanel, 'DurationMinVal', CurrentState.DurationSlider.Value);
            %Set duration and error texts to appropriate values
            CurrentState.DurationMinText.String = strcat(string(getappdata(CurrentState.MainPanel, 'DurationMinVal')), " hours");
            CurrentState.DurationErrorText.String = " ";
        else
            %If value is too large, display error
           CurrentState.DurationErrorText.String = "Min value too large"; 
        end
        
    end

    function DurationMaxFunction(Object, CallData)
        if (CurrentState.DurationSlider.Value >= getappdata(CurrentState.MainPanel, 'DurationMinVal'))
            %If current duration is greater than min, turn off and on buttons
            CurrentState.DurationMaxButton.Enable = 'off';
            CurrentState.DurationResetButton.Enable = 'on';
            %Set variables for refresh parsing
            setappdata(CurrentState.MainPanel, 'DurationMaxSet', 1);
            setappdata(CurrentState.MainPanel, 'DurationMaxVal', CurrentState.DurationSlider.Value);
            %Set max and error texts to reflect current values
            CurrentState.DurationMaxText.String = strcat(string(getappdata(CurrentState.MainPanel, 'DurationMaxVal')), " hours");
            CurrentState.DurationErrorText.String = " ";
        else
            %If current value is too small, display error
           CurrentState.DurationErrorText.String = "Max value too small";
        end

    end

    function DurationResetFunction(Object, CallData)
        %Turn off reset button, turn on min and max buttons
        CurrentState.DurationResetButton.Enable = 'off';
        CurrentState.DurationMaxButton.Enable = 'on';
        CurrentState.DurationMinButton.Enable = 'on';
        %Reset duratio indicattors and values
        setappdata(CurrentState.MainPanel, 'DurationMaxSet', 0);
        setappdata(CurrentState.MainPanel, 'DurationMinSet', 0);
        setappdata(CurrentState.MainPanel, 'DurationMaxVal', CurrentState.DurationRange(2));
        setappdata(CurrentState.MainPanel, 'DurationMinVal', CurrentState.DurationRange(1));
        %Reset text boxes to default values
        CurrentState.DurationMinText.String = strcat(CurrentState.DurationMinString(1), CurrentState.DurationMinString(2));
        CurrentState.DurationMaxText.String = strcat(CurrentState.DurationMaxString(1), CurrentState.DurationMaxString(2));
        CurrentState.DurationErrorText.String = ' ';
        
    end

%Get all unique shapes for display
CurrentState.AddShapesArray = TemporaryShapesArray; 
CurrentState.RemoveShapesArray = [];
%Make shape selector panel, selectors, and buttons
CurrentState.ShapeSelectorPanel = uipanel(CurrentState.ControlPanel, 'Units', 'normalized', 'Position', [0.1 0.15 0.8 0.2], 'Title', 'Select Shape', 'BackgroundColor', [1 1 1]);
CurrentState.AddShapeSelector = uicontrol(CurrentState.ShapeSelectorPanel, 'Style', 'listbox', 'String', CurrentState.AddShapesArray, 'Units', 'normalized', 'Position', [0 0.2 0.5 0.8], 'TooltipString', 'Add a shape');
CurrentState.RemoveShapeSelector = uicontrol(CurrentState.ShapeSelectorPanel, 'Style', 'listbox', 'String', CurrentState.RemoveShapesArray, 'Units', 'normalized', 'Position', [0.5 0.2 0.5 0.8], 'TooltipString', 'Remove a shape');
CurrentState.AddShapeButton = uicontrol(CurrentState.ShapeSelectorPanel, 'Style', 'pushbutton', 'String', 'Add Shape', 'Units', 'normalized', 'Position', [0 0 0.5 0.2], 'TooltipString', 'Add shapes to display');
CurrentState.RemoveShapeButton = uicontrol(CurrentState.ShapeSelectorPanel, 'Style', 'pushbutton', 'String', 'Remove Shape', 'Units', 'normalized', 'Position', [0.5 0 0.5 0.2], 'TooltipString', 'Remove shapes to display', 'Enable', 'off');

%Declare object functions for shape selector panel
    function AddRemoveShapeFunction(Object, CallData)
        %Since function is for both buttons, chose while button based on button string value
       if strcmp(string(Object.String), "Add Shape")
           %Add currently selected shape to remove selector and remove from add selector
           if length(string(CurrentState.AddShapeSelector.String)) ~= 1
               %If shape selector string is not going to be empty convert cell arrays to strings and concatenate vertically
               CurrentState.RemoveShapeSelector.String =  [string(cell2mat(CurrentState.AddShapeSelector.String(CurrentState.AddShapeSelector.Value))); string(CurrentState.RemoveShapeSelector.String)];
               CurrentState.AddShapeSelector.String = transpose((string(CurrentState.AddShapeSelector.String(CurrentState.AddShapeSelector.String ~= string(cell2mat(CurrentState.AddShapeSelector.String(CurrentState.AddShapeSelector.Value)))))));
           else
               %If shape selector string is going to be empty, replace empty with a blank array
               CurrentState.RemoveShapeSelector.String = [string(CurrentState.AddShapeSelector.String); string(CurrentState.RemoveShapeSelector.String)];
               CurrentState.AddShapeSelector.String = [];
           end
           %Put selector at first value to avoid blanks being added
           CurrentState.AddShapeSelector.Value = 1;
       elseif strcmp(string(Object.String), "Remove Shape")
           %Perform same actions as adding, but with remove selector
           if length(string(CurrentState.RemoveShapeSelector.String)) ~= 1
               %If shape selector string is not going to be empty convert cell arrays to strings and concatenate vertically
               CurrentState.AddShapeSelector.String =  [string(cell2mat(CurrentState.RemoveShapeSelector.String(CurrentState.RemoveShapeSelector.Value))); string(CurrentState.AddShapeSelector.String)];
               CurrentState.RemoveShapeSelector.String = transpose((string(CurrentState.RemoveShapeSelector.String(CurrentState.RemoveShapeSelector.String ~= string(cell2mat(CurrentState.RemoveShapeSelector.String(CurrentState.RemoveShapeSelector.Value)))))));
           else
               %If shape selector string is going to be empty, replace empty with a blank array
               CurrentState.AddShapeSelector.String = [string(CurrentState.RemoveShapeSelector.String); string(CurrentState.AddShapeSelector.String)];
               CurrentState.RemoveShapeSelector.String = []; 
           end
           %Put selector at first value to avoid blanks being added
           CurrentState.RemoveShapeSelector.Value = 1;
       end
       %If the add selector string is empty, turn off the add shape button otherwise turn in on in case it was disabled
       if length(CurrentState.AddShapeSelector.String) == 0
          CurrentState.AddShapeButton.Enable = 'off'; 
       else
           CurrentState.AddShapeButton.Enable = 'on';
           CurrentState.AddShapeSelector.String = CurrentState.AddShapeSelector.String(~cellfun(@isempty,CurrentState.AddShapeSelector.String));
       end
       %If the remove selector string is empty, turn off remove shape button. Otherwise turn on the remove shape button in case it was disabled
       if length(CurrentState.RemoveShapeSelector.String) == 0
          CurrentState.RemoveShapeButton.Enable = 'off'; 
       else
           CurrentState.RemoveShapeButton.Enable = 'on';
           CurrentState.RemoveShapeSelector.String = CurrentState.RemoveShapeSelector.String(~cellfun(@isempty,CurrentState.RemoveShapeSelector.String));
       end
       
    end

%Set callback functions for buttons, selectors, sliders
CurrentState.ExitProgramButton.Callback = {@ExitProgramButtonFunction};
CurrentState.AnalyticsButton.Callback = {@AnalyticsButtonFunction};
CurrentState.ShowMapButton1.Callback = {@ShowMapButtonFunction};
CurrentState.CountryButton.Callback = {@CountryButtonFunction};
CurrentState.StateButton.Callback = {@StateButtonFunction};
CurrentState.CityButton.Callback = {@CityButtonFunction};
CurrentState.StateSelector.Callback = {@StateSelectorFunction};
CurrentState.CitySelector.Callback = {@CitySelectorFunction};
CurrentState.DateSlider.Callback = {@DateSliderFunction};
CurrentState.DateMinButton.Callback = {@DateMinFunction};
CurrentState.DateMaxButton.Callback = {@DateMaxFunction};
CurrentState.DateResetButton.Callback = {@DateResetFunction};
CurrentState.DurationSlider.Callback = {@DurationSliderFunction};
CurrentState.DurationMinButton.Callback = {@DurationMinFunction};
CurrentState.DurationMaxButton.Callback = {@DurationMaxFunction};
CurrentState.DurationResetButton.Callback = {@DurationResetFunction};
CurrentState.AddShapeButton.Callback = {@AddRemoveShapeFunction};
CurrentState.RemoveShapeButton.Callback = {@AddRemoveShapeFunction};
CurrentState.RefreshButton.Callback = {@RefreshButtonFunction};

%Declare function for refreshing image panel
    function RefreshImagePanel()
        if getappdata(CurrentState.MainPanel, 'CountryMode') == 1
            Mode = 0;
        elseif getappdata(CurrentState.MainPanel, 'StateMode') == 1
            Mode = 1;
        else
            Mode = 2; 
        end
        %Set city and state in limiters
        Limiters.state = getappdata(CurrentState.MainPanel, 'StateSelectorVal');
        Limiters.city = getappdata(CurrentState.MainPanel, 'CitySelectorVal');
        
        %Set date min and max in limiters, find actual value by taking current slider value and indexing CurrentState.DateNums
        if getappdata(CurrentState.MainPanel, 'DateMinSet') == 1
            %If set pull out value, otherwise get min slider value
            Limiters.date_min = CurrentState.DateNums(round(getappdata(CurrentState.MainPanel, 'DateMinVal')/length(CurrentState.DateNums)));
        else
            Limiters.date_min = CurrentState.DateSlider.Min;
        end
        
        if getappdata(CurrentState.MainPanel, 'DateMaxSet') == 1
            %If set pull out value, otherwise get max slider value
           Limiters.date_max = getappdata(CurrentState.MainPanel, 'DateMaxVal'); 
        else
           Limiters.date_max = CurrentState.DateSlider.Max; 
        end
        
        %Set duration min and max in limiters
        if getappdata(CurrentState.MainPanel, 'DurationMinSet') == 1
            %If set get value, otherwise get current value
            Limiters.dur_min = getappdata(CurrentState.MainPanel, 'DurationMinVal');
        else
            Limiters.dur_min = CurrentState.DurationSlider.Min;
        end

        if getappdata(CurrentState.MainPanel, 'DurationMaxSet') == 1
            %If set get value, otherwise get current value
            Limiters.dur_max = getappdata(CurrentState.MainPanel, 'DurationMaxVal');
        else
            Limiters.dur_max = CurrentState.DurationSlider.Max;
        end
        
        %Set shapes array in liimters from remove shape selector
        Limiters.shapes = CurrentState.RemoveShapeSelector.String;
        
        %Choose a figure to load based on options chosen
         if getappdata(CurrentState.MainPanel, 'ShowMapSet') == 1
             %If map, get latitude and longitude for current data
             [Lat, Lon] = GetLocations(Database1, Mode, Limiters);
             %Delete current axes and remake to avoid plotting issues
             delete(CurrentState.ImageAxes);
             CurrentState.ImageAxes = axes(CurrentState.ImagePanel);
             %Plot new map based on latitude and longitude values
             GenerateNewMap(CurrentState.ImageAxes, Lat, Lon);
         else
             %Delete currente axes and remake to avoid plotting issues
             delete(CurrentState.ImageAxes);
             CurrentState.ImageAxes = axes(CurrentState.ImagePanel);
             %Establish local variable for eval command
             LocalDatabase = [];
             %Dynamically get current state histogram data
             eval(strcat("LocalDatabase = Database2.", getappdata(CurrentState.MainPanel, 'StateSelectorVal'), ";"))
             %Plot histogram based on selected state
             GetMyHistogram(LocalDatabase ,getappdata(CurrentState.MainPanel, 'StateSelectorVal'), CurrentState.ImageAxes);
         end
    end

%Load and set image in the background
ImageHandle = axes(CurrentState.MainPanel, 'units', 'normalized', 'position', [ 0 0 1 1]);
uistack(ImageHandle, 'bottom');
ImageData = imread('DefaultMapImage.jpg');
ScaledImage = imagesc(ImageData);
set(ImageHandle, 'handlevisibility', 'off', 'visible', 'off');

%Completed Setup generate default map
GenerateNewMap(CurrentState.ImageAxes,[32.8205865, 37.7536232, 42.3143286], [-96.8716256, -122.4334806, -71.0403235]);
CurrentState.MainPanel.Visible = 'off';

end