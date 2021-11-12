function myStackPlotter(Ir,d,t, typ, imageFlag, dt)

%% Section 1: Assign t if not done so already
s=size(Ir);

%If t is empty, just assign it an integer index
if isempty(t)==1
    t=0 : dt : (s(2)-1);
end




%% Section 2: Determine How it will be plotted depending on transect type

% If X Transect, horizontal Axis will be X, vertical Axis will be Time
if strcmp(typ,'x')==1
    
    hAxis=typ;
    hVect=d;
    
    vAxis='t';
    vVect=t;
    
    % Need to Make Rows Time and Columns X for imagesc to work.
    for k=1:length(Ir(1,1,:)) % For each RGB value
        Ip(:,:,k)=Ir(:,:,k)';
    end
end


% If Y Transect, horizontal Axis will be t, vertical Axis will be Y
if strcmp(typ,'y')==1
    
    vAxis=typ;
    vVect=d;
    
    hAxis='t';
    hVect=t;
    
    % Rows need to be Y and columns need to be time, Already in this
    % format.
    Ip=Ir;
end



%% Section 3: Do Plotting Depending if you want an RGB or Pcolor Plot

% If user entered an rgb image
if length(s)==3 % if the size vector has 3 dimenions.
    imagesc(hVect, vVect, Ip)
end


% If The user entered a grayscale image
if length(s)==2 % if the size vector has 2 dimenions.
    % make Grid for pcolor
    [H,V]=meshgrid(hVect,vVect);
    pcolor(H,V,(Ip))
    shading flat
    colormap(gray)
end


%% Section 3: Add Axes Limits

set(gca,'ydir','normal')        % Imagesc plots as imshow, with V increasing
% from top to bottom, we need to reset to
% normal axis direction, increasing from
% bottom to top.
xlim([min(min(hVect)) max(max(hVect))])
ylim([min(min(vVect)) max(max(vVect))])
xlabel(hAxis)
ylabel(vAxis)

end