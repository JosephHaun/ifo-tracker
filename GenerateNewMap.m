function GenerateNewMap(AxesHandle, Latitude, Longitude)
%{
    GenerateNewMap(AxesHandle, Latitude, Longitude)
    
    Function uses plot_google_map.m to generate a static image of a map to
    be displayed on current axis with lat-lon indicators

    Input:  AxesHandle - axes on which to create map image
            Latitude - array of chars indicating Latitude values for
            points
            Longitude - array of chars indicating Longitude values for
            points
    Output: None

    Jonah Baumgartner
    Daniel Gil
    Joe Haun
    Priyanka Khera
    Austin Salois
    Thomas Swanson

    EE 314: IFO Tracker Project
    12-12-18
%}

%lat = [48.8708  51.5188   41.9260 40.4312   52.523   37.982];
%lon = [2.4131  -0.1300    12.4951 -3.6788    13.415   23.715];

%Insert your Google API Key here.
APIKey = 'AIzaSyDTiAr4EjdhBGGX2tw3I6Obu9vOvfSUK1o'; %Invalid API Key

%Plot points on blank map
plot(Longitude, Latitude, '.r', 'MarkerSize', 20)
%Plot map image as background of given axes
plot_google_map('APIKey', APIKey, 'MapScale', 2, 'Axis', AxesHandle, 'Scale', 2);

end