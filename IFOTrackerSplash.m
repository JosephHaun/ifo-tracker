function IFOTrackerSplash()
%{
    
    IFOTrackerSplash()

    Function creates both the splash page and main page for IFOTracker
    Project.

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

disp("Loading database...")
TempStruct = load("SortedByState.mat"); %Loads a variable named StatesData into temp value
DatabaseInTables = TempStruct.StatesData;
TempStruct = load("IFOTrackerDatabase.mat"); %Loads a variable named Database into temp value
DatabaseInStructs = TempStruct.Database;

disp("Generating figure...")
MainFigure = figure( 'NumberTitle', 'off', 'MenuBar', 'none','Toolbar', 'none','Visible','off', 'Name', 'Identified Flying Objects', 'WindowState', 'fullscreen');

%Make exit button to close program
ExitProgramButton = uicontrol(MainFigure, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.975 0.975 0.025 0.025], 'String', 'X', 'Tooltip', 'Close program');

    function ExitButtonFunction(Object, Calldata, ParentFigure)
        ParentFigure.Visible = 'off';
        disp("Goodbye!")
        close('all')
    end

%Make button control panel area
ControlPanel = uipanel('Units', 'normalized', 'Position', [0.7 0.1 0.2 0.8], 'BackgroundColor', [1 1 1]);

InitComment = GetRandomComment(DatabaseInTables);
ControlPanelText = uicontrol(ControlPanel, 'Style', 'text', 'String', strcat("Comment: ",InitComment), 'FontSize', 15, 'Units', 'normalized', 'Position', [0 0 1 1], 'BackgroundColor', [1 1 1]);

    function EnterButtonFunction(Object, Calldata, NextFigure)
        NextFigure.Visible = 'on';
        %Object.Parent.Visible = 'off';
    end

    function CommentButtonFunction(Object, Calldata, TextBox)
       TextBox.String = strcat("Comment: ", GetRandomComment(DatabaseInTables)); 
    end

%Create main display panel
MainDisplayPanel = uipanel('Units', 'normalized', 'Position', [0.1 0.1 0.55 0.55], 'BackgroundColor', [1 1 1], 'Visible', 'on');
EnterButton = uicontrol(MainDisplayPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.5 0.05 0.2 0.1], 'String', 'Begin!', 'Tooltip', 'Begin your journey!', 'Enable', 'off', 'Fontsize', 10);
CommentButton = uicontrol(MainDisplayPanel, 'Style', 'pushbutton', 'Units', 'normalized', 'Position', [0.25 0.05 0.2 0.1], 'String', 'Change Comment', 'Tooltip', 'Get a random description from the database!', 'Enable', 'on', 'Fontsize', 10);
IFOTrackerString1 = 'Welcome to the IFO Tracker project! This project is able to show you whether or not a specific area has any UFO sightings at any given date. ';
IFOTrackerString2 = 'You can filter by these factors: location, date sighted, duration reported, and shape reported. Once selected, hit the refresh button and ';
IFOTrackerString3 = 'the map will update based on any available points matching your specifications in the database. If a historical view of any particular state strikes your fancy ';
IFOTrackerString4 = 'then hit the analytics button to see a histogram showing all sightings for the state over the width of the database. When you are ready, go ahead and hit BEGIN!';
MainDisplayText = uicontrol(MainDisplayPanel, 'Style', 'text', 'String', [IFOTrackerString1 IFOTrackerString2, IFOTrackerString3, IFOTrackerString4], 'FontSize', 25, 'Units', 'normalized', 'Position', [0 0 1 1], 'BackgroundColor', [1 1 1]);
uistack(MainDisplayText, 'bottom')

%Make title display area
TitlePanel = uipanel('Units', 'normalized', 'Position', [0.1 0.7 0.55 0.2], 'BackgroundColor', [1 1 1], 'Visible', 'on');
TitleText = uicontrol(TitlePanel, 'Style', 'text', 'String', 'IFO Tracker', 'FontSize', 110, 'Units', 'normalized', 'Position', [0 0 1 1], 'BackgroundColor', [1 1 1]);

%Load and set image in the background
ImageHandle = axes(MainFigure, 'units', 'normalized', 'position', [ 0 0 1 1]);
uistack(ImageHandle, 'bottom');
ImageData = imread('DefaultMapImage.jpg');
ScaledImage = imagesc(ImageData);
set(ImageHandle, 'handlevisibility', 'off', 'visible', 'off');

disp("Setup done, turning on figure")
MainFigure.Visible = 'on';

disp("Making secondary window. Expect some flashes...")
ChildFigureStruct = IFOTracker(DatabaseInStructs, DatabaseInTables, MainFigure);

ExitProgramButton.Callback = {@ExitButtonFunction, MainFigure};
EnterButton.Callback = {@EnterButtonFunction, ChildFigureStruct.MainPanel};
CommentButton.Callback = {@CommentButtonFunction, ControlPanelText};

disp("Secondary window made...")
EnterButton.Enable = 'on';

end