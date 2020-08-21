% Austin Salois, EE314
% This script reads in a file in the table format, and parses the data
% into structs where the field is the name of the state that all the data
% is for.

%Change this path depending on where your file is located
file='/Users/Ausitn/Desktop/Fall2018/EE314/Project/nuforc_reports.csv';
fid=fopen(file);
%Text=textscan(fid, '%s%s%s%f%s%s%s%s%s%s%f%f','Delimiter',',', 'HeaderLines', 1);
%Text=importdata(file,',')

Text=readtable(file); %Read the data

LAT=Text.city_latitude; %Getting Lat and Lon of all Data
LON=Text.city_longitude;
LAT(LAT< 20)=NaN;%Deleting data outside the square around the USA
LON(LON > -50)=NaN;

temp=char(Text(1,:).state);
StatesData.(temp)=(Text(1,:));
States={temp};

%All this is putting the data into structs by state
for i= 2:height(Text)
%for i= 2:200  
   state=char(Text(i,:).state);
   count = 1;
   if isempty(state) == 0
       while count <= length(States)
           if state == States{count}
               StatesData.(state)=[StatesData.(state); Text(i,:)];
               count=length(States)+1;
           end
           if count == length(States)
               StatesData.(state)=Text(i,:);
               States{end+1}=state;
               count=length(States)+1;
           end
        count=count + 1;

       end
   end    
end

%This is all stripping out structs that ARE NOT states
States=["AL", 'AK', 'AZ', 'AR', 'CA' ,'CO', 'CT', 'DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'];
Fields=string(fieldnames(StatesData));
tmp=~ismember(Fields,States);
tmp2=find(tmp == 1);
StatesData=rmfield(StatesData,Fields(tmp2));

%This uses the google maps plot that is zipped on the google drive
% plot(LON,LAT);
% plot(LON,LAT,'.r','MarkerSize',20) 
% plot_google_map

