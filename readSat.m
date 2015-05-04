function[AllRecords] = readSat(SatelliteName)
% Read data from all satellite files and merge the data

%  SatelliteName = ('?????')
% cd 'D:\TUM\Semester 1\Applied Computer Science\Satellite_Altimetry'
currentDir = cd;
SatFolder = [SatelliteName,'_raw']
cd (SatFolder)

% Find RMP file
RMPFileName = ['*',SatelliteName,'*','.rmp'];
MetaFileName = ls (RMPFileName) % RMP file name
MetaFileFullName = [currentDir,'\',MetaFileName]

% Find Satellite data files
name = ['*',SatelliteName,'*','.00'];
files = ls (name) % List of data files
cd (currentDir)

% ===== Parse RMP file for description ====================================
[NumberOfParameters, Parameter, LegthOfByte, DataType, Desimal, Unit, ShortCut, DescriptionOfParameter] = ParseRMP(SatelliteName, MetaFileName);

% ===== Parce data files ==================================================
AllRecords = [];
for i = 1:size(files,1)
    FileName = files(i,:)
    Records = ParseSAT(SatelliteName, FileName, NumberOfParameters, Parameter, LegthOfByte, DataType, Desimal, Unit, ShortCut, DescriptionOfParameter);    
    AllRecords = [AllRecords;Records];    %#ok<AGROW>

    % Save as a table in binary and ASCII
    mkdir ([SatelliteName,'_ASCII'])
    ASCIIFileName = [SatelliteName,'_ASCII\',FileName,'_ASCII.txt']
    FileID = fopen(ASCIIFileName, 'w'); % Open the binary file for writing with file ID

    % ======== Write Header into ASCII file ===============================
    fprintf(FileID, '%12s %14s\r\n', 'Satellite: ', SatelliteName);
    fprintf(FileID, '%18s %24s\r\n', 'Date of parsing: ', datestr(now,'dd-mmmm-yyyy, HH:MM:SS'));
    fprintf(FileID, '\r\n');
    fprintf(FileID, '%16s\t %15s\t %15s\t %11s\t  %10s\t', ShortCut{1,:}, ShortCut{2,:}, ShortCut{3,:}, ShortCut{4,:}, ShortCut{5,:}); % Write header
    for column = 6:18
        fprintf(FileID, '%10s\t', ShortCut{column,:});
    end
    fprintf(FileID, '%10s\r\n', ShortCut{19,:});
    
    fprintf(FileID, '%16s\t %15s\t %15s\t %11s\t  %10s\t', ' -  ', '[deg]', '[deg]', '[m] ', '[m] '); % Write header
    for i = 6:15
        fprintf(FileID, '%10s\t', '[m] ');
    end
    fprintf(FileID, '%10s\t %10s\t %10s\t %10s\r\n', ' - ', '- ', '[m] ','[m] ');
    
    for i = 1:258; 
        fprintf(FileID, '%1s', '=');   % Add separation line after header
    end
    fprintf(FileID, '%1s\r\n', ' ');

    %  ======== Write data into file in table form ========================
    for row = 1:size(Records,1)
        fprintf(FileID, '%16.5f\t %15.6f\t %15.6f\t %10.3f\t %10.3f\t', Records(row,1),Records(row,2), Records(row,3), Records(row,4), Records(row,5));            
        for value = 6:15   
            fprintf(FileID, '%10.3f\t', Records(row,value));
        end
        fprintf(FileID, '%10.0f\t', Records(row,16));
        fprintf(FileID, '%10.0f\t', Records(row,17));
        fprintf(FileID, '%10.3f\t', Records(row,18));
        fprintf(FileID, '%10.3f\r\n', Records(row,19)); 
    end
    fclose(FileID);
end
    disp('Data reading is finished');
end