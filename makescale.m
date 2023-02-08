function h = makescale(varargin)

[anum, latlim, lonlim, width, location, units, set_callbacks] = parseInputs(varargin{:});
if ~isreal(width)
    error('MAKESCALE:MapWithVal','MAPWIDTH must be a real number')
end

% Bound the width
width = min(max(width,0.1),0.9);
earthRadius = 6378137;

% Get the distance of the map
mlat = mean(latlim);
if abs(mlat) > 90;
    d = 0;
else
    d = earthRadius.*cosd(mlat).*deg2rad(diff(lonlim));
end
dlat = diff(latlim);
dlon = diff(lonlim);

% Calculate the distance of the scale bar
% rnd2 = floor(log10(d/scale))-1;

% Make the text string
if strcmpi(units,'si')
    dscale = round_scale(d*width);
    if d*width > 1e3
        dst = num2str(dscale/1e3);
        lbl = ' km';
    elseif d*width > width
        dst = num2str(dscale);
        lbl = ' m';
    else
        dst = num2str(dscale*1e3);
        lbl = ' mm';
    end
else
    if d*width > 1/0.000621371192        
        dscale = round_scale(d*width*0.000621371192);        
        dst = num2str(dscale);
        lbl = ' mi';
        dscale = dscale/0.000621371192;
    elseif d*width > 0.3048        
        dscale = round_scale(d*width/0.30482);
        dst = num2str(dscale);
        lbl = ' ft';
        dscale = dscale*.3048;
    else        
        dscale = round2(d*width/0.30482*12);
        dst = num2str(dscale);
        lbl = ' in';
        dscale = dscale/12*.3048;
    end
end

% Get the postions
d1 = [-0.02 0.05];
issouth = 0;
iseast = 0;
iswest = 0;
switch lower(location)
    case {'southeast','se'}
        issouth = 1;
        iseast = 1;
    case {'northeast','ne'}
        iseast = 1;
    case {'southwest','sw'}
        issouth = 1;
        iswest = 1;
    case {'northwest','nw'}
        iswest = 1;
    case {'north','n'}
    case {'south','s'}
        issouth = 1;
end

if issouth
    slat = latlim(1)+0.05*diff(latlim);
else
    slat = latlim(end)-0.08*diff(latlim);
end

if iseast
    slon = lonlim(end)-0.05*diff(lonlim);
    slon = [slon slon-rad2deg(dscale./(earthRadius.*cosd(mlat)))];
    slat = [slat slat];
elseif iswest
    slon = lonlim(1)+0.05*diff(lonlim);
    slon = [slon slon+rad2deg(dscale./(earthRadius.*cosd(mlat)))];
    slat = [slat slat];
    slon = fliplr(slon);
else
    slon = mean(lonlim);
    slon = slon + [-rad2deg(dscale./(earthRadius.*cosd(mlat)))/2 rad2deg(dscale./(earthRadius.*cosd(mlat))/2)];
    slat = [slat slat];
    slon = fliplr(slon);
end

% Get the box location
blat = [slat([2 1])+[d1(1)*dlat d1(2)*dlat] slat([1 2])+[d1(2)*dlat d1(1)*dlat]];
blat = blat([2:4 1]);
blon = [slon+[0.02*dlon -0.02*dlon] slon([2 1])+[-0.02*dlon 0.02*dlon]];

% Delete Old Scale
aold = gca;
axes(anum);
ch = get(anum,'Children');
isOldScale = strcmpi(get(ch,'Tag'),'MapScale');
delete(ch(isOldScale));

% Make the scale
washold = ishold;
hold on
hbox = patch(blon,blat,'w');
set(hbox,'Tag','MapScale');
hline = plot(slon,slat,'k','LineWidth',3);
set(hline,'Tag','MapScale');
units_axis = get(gca,'Units');
set(gca,'Units','Inches')
pos = get(gca,'OuterPosition');
sz = mean(pos(4));
htext = text(mean(blon),mean(blat)+.01*dlat,[dst lbl],'HorizontalAlignment','center','FontSize',sz*2.3);
hzoom = zoom;
hpan = pan(gcf);
set(htext,'Tag','MapScale')
set(gca,'Units',units_axis);

% Output Handles
if nargout > 0
    h = [hbox; hline; htext];
end

% Restore Hold Off
if ~washold
    hold off
end

% Set Resizer/Zoom/Pan/Click Callbacks
if set_callbacks
    set(gcf,'ResizeFcn',{@ChangeTextSize,gca,htext});
    set(hzoom,'ActionPostCallback',{@remakeZoomPanClick,anum,location,width,units});
    set(hpan,'ActionPostCallback',{@remakeZoomPanClick,anum,location,width,units});
    set(anum,'ButtonDownFcn',{@remakeZoomPanClick,anum,location,width,units});
end
axes(aold);

% Output Handles
if nargout > 0
    h = [hbox; hline; htext];
end

% Restore Hold Off
if ~washold
    hold off
end


function x = round2(x,base)
x = round(x./base).*base;

function scale = round_scale(scale)
pow = floor(log10(scale));
scale = scale / 10^pow;
if scale >= 5
    scale = 5;
elseif scale >= 2
    scale = 2;
elseif scale >= 1
    scale = 1;
end
scale = scale * 10^pow;

% Change the text font on figure resize.
function ChangeTextSize(~,~,anum,htext)
units = get(anum,'Units');
set(anum,'Units','Inches')
pos = get(anum,'OuterPosition');
sz = mean(pos(4));
set(htext,'FontSize',sz*2.3);
set(anum,'Units',units);

function remakeZoomPanClick(~,~,anum,location,width,units)
makescale(anum, 'location', location, 'width', width, 'units', units);

function [anum, latlim, lonlim, width, location, units, set_callbacks] = parseInputs(varargin)
% Default Values
anum = gca;
width = 0.2;
location = 'se';
units = 'si';
set_callbacks = 1;

% Loop through number of arguments in
ii = 1;
while ii <= length(varargin)    
    % Either a axis number, or a scale value
    if ii == 1 && isscalar(varargin{ii}) && ishandle(varargin{ii})
        % Check if it's an axis handle
        pos = get(varargin{ii},'ActivePositionProperty');
        if strcmpi(pos,'outerposition')
            anum = varargin{ii};            
        end   
        
        ii = ii + 1;
        
    elseif ischar(varargin{ii})
        param_name = lower(varargin{ii});
        if strcmpi(param_name, 'units')
            units = lower(varargin{ii+1});
            if ~ismember(units, {'si', 'imp'})                
                error('MAKESCALE:UNITS', 'UNITS must be one of the following: si, imp')
            end
            ii = ii + 2;
        elseif strcmpi(param_name, 'location')
            location = lower(varargin{ii+1});
            locs = {'northeast','ne','north','n','southeast','se','south',...
                's','southwest','sw','northwest','nw'};
            if ~ismember(location,locs)
                locOut = 'northeast, ne, north, n, southeast, se, south, s, southwest, sw, northwest, nw';
                error('MAKESCALE:LOCS',['LOCATION must be one of the following: ' locOut])
            end            
            ii = ii + 2;        
        elseif strcmpi(param_name, 'width')
            width = varargin{ii+1};
            ii = ii + 2;
        elseif strcmpi(param_name, 'set_callbacks')
            set_callbacks = varargin{ii+1};
            ii = ii + 2;
        else
            error('MAKESCALE:PARAM',['Unrecognized parameter: ' varargin{ii}]);
        end
    end
end

% Get limits
latlim = get(anum,'YLim');
lonlim = get(anum,'XLim');
