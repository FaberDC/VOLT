function [] = VOLT(results, branch_var, terminal, bus_var, show_labels, opts)
%                    ___
%    /\_/\          /   \
%   | ^.^ |         |_/| |          
%    \ U /\__________/   |     Visual 
%     \       VOLT      /      Output for  
%      \               /       Layered  
%       |   |-----|   |        Topologies 
%       |___|     |___|~~~~
% 
% VOLT visualizes the network topology with professional color maps, line widths, 
%          and colorbars for power flows and voltage profiles.
%
% Version: 1.0.0
% Date: 2026-09-01
%
% Copyright (c) 2026  Fabrizio De Caro, Alfredo Vaccaro /
%                     Power Systems Research Group /
%                     University of Sannio, Benevento, Italy
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <https://www.gnu.org/licenses/>.
%
%
%%% Requirements:
%   Requires MATLAB (R2023b or later) and Graph Theory toolbox routines.
%   MATPOWER is required for data structure compatibility and for ext2int.
%
%
%%% Example:
%   mpc = loadcase('case5');
%   results = runpf(mpc);
%   opts = []; % optional
%   VOLT(results,'S','F','VM','Y',opts);
%
%%% Inputs
%
%   results      : Structure with bus, branch, gen, baseMVA, and Coords (optional) fields.
%   branch_var   : 'P' | 'Q' | 'I' | 'S' | 'L' 
%                  (Target branch metric used for edge color scaling).
%   terminal     : 'F' | 'T' 
%                  (Terminal reference for computed metrics: 'F' = From/Sending, 'T' = To/Receiving).
%   bus_var      : 'VM' | 'VA' 
%                  (Node color mapping: VM = Magnitude, VA = Phase Angle).
%   show_labels  : 'Y' | 'N' 
%                  (Enables/disables textual overlays).
%   opts         : Optional structure containing visual configuration settings:
%
% Outputs:
%   None. The function directly opens an interactive MATLAB Figure window. 
%   Optionally, when specified by the user, saves both a '.fig' and a document in the specified format of the visual output.
%
%%% Color & Rendering Options
%      vm_breaks     = [0.8, 0.9, 1.0, 1.1, 1.2]  % Reference thresholds for bus voltage magnitude colormap and bus colorbar ticks
%      va_breaks     = [-30,-15,0,15,30];         % Reference thresholds for bus voltage phase colormap and edge colorbar ticks
%                      if va_breaks is empty the colorbar is computed again
%      br_breaks     = [ ]                        % Reference thresholds for edge magnitude colormap and colorbar ticks
%      branch_w      = [0.8, 3.6];                % Min and max branch line widths
%      vm_range      = [];                        % Array of voltage levels for element filtering (empty = no filter)
%      filter_mode   = 'strict';                  % Voltage filtering logic ('strict' | 'base')
%      coord_regen   = 0;                         % Force coordinate regeneration (1 = active, 0 = inactive)
%      branch_rate   = 0;                         % Branch rating limit for loading calculations (0 = Rate A, 1 = Rate B, 2 = Rate C)
%
%%% Geometry, Font & Window Layout
%      arrowsize     = 10;                        % Branch flow directional arrow size
%      markersize    = 6;                         % Base node marker size
%      fontsize      = 9;                         % General font size for labels and legends
%      layoutgraph   = 'force';                   % MATLAB digraph layout algorithm
%      graphit       = 5000;                      % Maximum iterations for graph positioning
%      figpos        = [100, 100, 1200, 850];     % Figure window position and size [left, bottom, width, height]
%      axpos         = [0.05, 0.1, 0.85, 0.85];   % Plot axes position within figure [left, bottom, width, height]
%
%%% Visibility Flags & Spatial Offsets (1 = Enabled, 0 = Disabled)
%      bus_dl        = 0;                         % Node detail level: 0 (ID), 1 (ID+VM+VA), 2 (full metrics)
%      branch_dl     = 0;                         % Branch detail level: 0 (P,Q), 1 (P,Q+S), 2 (full metrics)
%      trs_dl        = 0;                         % Transformer detail: 0 (trs label), 1 (full metrics)
%      bus_lab_on    = 1;                         % Enable node data labels
%      branch_lab_on = 1;                         % Enable edge data labels
%      trs_lab_on    = 1;                         % Enable transformer data labels
%      branch_sign   = 'relative"  (signs align with arrow: + forward, - reverse) or 'tabular' (raw tabular output signs)
%      leg_trs_on    = 1;                         % Enable transformer legend
%      leg_note_on   = 1;                         % Enable note legend
%      auxbusID_on   = 0;                         % Enable auxiliary bus ID rendering
%
%%%
%     savefig       = 0;                          % Save figure: (0) no, (1)
%     figname       = string                      % string name
%     figfomat      = string                      % pdf or eps
%
%
%%% 
%      
%
%% --- Input, default e fallback
if nargin < 2 || isempty(branch_var),  branch_var  = 'S';  end
if nargin < 3 || isempty(terminal),    terminal    = 'F';  end
if nargin < 4 || isempty(bus_var),     bus_var     = 'VM'; end
if nargin < 5 || isempty(show_labels), show_labels = 'Y';  end
if nargin < 6 || isempty(opts),        opts        = struct(); end

if isstring(branch_var),  branch_var  = char(branch_var);  end
if isstring(terminal),    terminal    = char(terminal);    end
if isstring(bus_var),     bus_var     = char(bus_var);     end
if isstring(show_labels), show_labels = char(show_labels); end

switch upper(show_labels)
    case {'Y', 'YES'}
        showEL = true;
    case {'N', 'NO'}
        showEL = false;
    otherwise
        error('VOLTS:InvalidExtraLabels', ...
            'Invalid show_labels option ''%s''. Valid options are ''Y'' (''YES'') or ''N'' (''NO'').', show_labels);
end

% Options
if nargin < 6 || isempty(opts), opts = struct(); end
if ~isfield(opts, 'va_breaks')     || isempty(opts.va_breaks),   opts.va_breaks   = [-30,-15,0,15,30]; end
if ~isfield(opts, 'vm_breaks')     || isempty(opts.vm_breaks),   opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; end
if ~isfield(opts, 'br_breaks')     || isempty(opts.br_breaks),   opts.br_breaks   = []; end
if ~isfield(opts, 'branch_w')      || isempty(opts.branch_w),    opts.branch_w    = [0.8,3.6]; end
if ~isfield(opts, 'vm_range')      || isempty(opts.vm_range),    opts.vm_range    = []; end
if ~isfield(opts, 'filter_mode')   || isempty(opts.filter_mode), opts.filter_mode = 'strict'; end
if ~isfield(opts, 'coord_regen')   || isempty(opts.coord_regen), opts.coord_regen = 0; end
if ~isfield(opts, 'branch_rate')   || isempty(opts.branch_rate), opts.branch_rate = 'A'; end
if ~isfield(opts, 'arrowsize')     || isempty(opts.arrowsize),   opts.arrowsize   = 10; end
if ~isfield(opts, 'markersize')    || isempty(opts.markersize),  opts.markersize  = 6; end
if ~isfield(opts, 'fontsize')      || isempty(opts.fontsize),    opts.fontsize    = 9; end
if ~isfield(opts, 'bus_dl')        || isempty(opts.bus_dl),      opts.bus_dl      = 0; end
if ~isfield(opts, 'branch_dl')     || isempty(opts.branch_dl),   opts.branch_dl   = 0; end
if ~isfield(opts, 'trs_dl')        || isempty(opts.trs_dl),      opts.trs_dl      = 0; end
if ~isfield(opts, 'bus_lab_on')    || isempty(opts.bus_lab_on),  opts.bus_lab_on  = 1; end
if ~isfield(opts, 'branch_lab_on') || isempty(opts.branch_lab_on), opts.branch_lab_on = 1; end
if ~isfield(opts, 'trs_lab_on')    || isempty(opts.trs_lab_on),  opts.trs_lab_on  = 1; end
if ~isfield(opts, 'figpos')        || isempty(opts.figpos),      opts.figpos      = [100, 100, 1200, 850]; end
if ~isfield(opts, 'axpos')         || isempty(opts.axpos),       opts.axpos       = [0.05, 0.1, 0.85, 0.85]; end
if ~isfield(opts, 'layoutgraph')   || isempty(opts.layoutgraph), opts.layoutgraph = 'force'; end
if ~isfield(opts, 'graphit')       || isempty(opts.graphit),     opts.graphit     = 5000;  end
if ~isfield(opts, 'branch_sign')   || isempty(opts.branch_sign), opts.branch_sign = 'relative'; end
if ~isfield(opts, 'leg_trs_on')    || isempty(opts.leg_trs_on),  opts.leg_trs_on  = 1;  end
if ~isfield(opts, 'leg_note_on')   || isempty(opts.leg_note_on), opts.leg_note_on = 1; end
if ~isfield(opts, 'auxbusID_on')   || isempty(opts.auxbusID_on), opts.auxbusID_on = 0; end
if ~isfield(opts, 'savefig')       || isempty(opts.savefig)    , opts.savefig     = 0; end
if ~isfield(opts, 'figname')       || isempty(opts.figname)    , opts.figname     = [ ]; end
if ~isfield(opts, 'figformat')     || isempty(opts.figformat)  , opts.figformat   = 'pdf'; end


% L coherence (Rate Required)
switch upper(num2str(opts.branch_rate))
    case 'A'
        rate_col = 6; 
    case 'B'
        rate_col = 7;
    case 'I'
        rate_col = 8;
    otherwise
        error('VOLTS:InvalidBranchRate', ...
            'Invalid branch_rate ''%s''. Valid options are ''A'', ''B'', or ''I''.', opts.branch_rate);
end

if strcmp(branch_var,'L')
    if any(isnan(results.branch(:,rate_col)) | results.branch(:,rate_col) == 0)
        warning('VOLTS:MissingBranchRating', ...
        'branch_var="L" requested, but results.branch(:,RATE) contains zero or NaN values. Automatically switching to branch_var="S" due to missing rating parameters.');
        branch_var = 'S';
    end
end

%% Force bus consecutive enumeration conversion
if ~all(diff(sort(results.bus(:,1))) == 1)
   results.bus(:,14) = results.bus(:,1);
   opts.auxbusID_on = 1;
   results = rmfield(results, 'order');
   results = ext2int(results);
end

%% --- Filter Grids Elements According to Rate Voltage Values
if ~isempty(opts.vm_range)
    results_old = results;
    
    % Handle voltage thresholds (kV)
    if numel(opts.vm_range) < 2
        KVthrdw = opts.vm_range(1);
        KVthrup = 1e9;
    else
        KVthrdw = opts.vm_range(1);
        KVthrup = opts.vm_range(2);
    end
    
    % 1) Identify HV buses (within range) and LV buses (out of range)
    exc = (results_old.bus(:,10) >= KVthrdw) & (results_old.bus(:,10) < KVthrup);
    btk = results_old.bus(exc, 1);    % HV buses to retain
    ob  = results_old.bus(~exc, 1);   % LV buses (external boundary nodes)
    
    % 2) Extract branch connections
    f = results_old.branch(:,1);
    t = results_old.branch(:,2);
    
    % 3) Apply filtering mode strategy
    switch lower(opts.filter_mode)
        case 'strict'
            connected = [];
            
        case 'base'
            % Keep LV boundary buses directly connected to HV buses
            connected = ob( ismember(ob, f(ismember(t, btk))) | ...
                           ismember(ob, t(ismember(f, btk))) );
                       
        otherwise
            error('VOLTS:InvalidFilterMode', ...
                'Invalid filter mode ''%s''. Valid options are ''strict'' or ''base''.', opts.filter_mode);
    end
    
    % 4) Candidate buses to keep
    keep_buses = unique([btk; connected]);
    
    % 5) Retain only branches where BOTH terminal buses belong to keep_buses
    brtk = ismember(f, keep_buses) & ismember(t, keep_buses);
    
    % 6) Prune isolated buses (nodes with no active connections left)
    %    Prevents orphan nodes from breaking ext2int
    active_branch_buses = unique([f(brtk); t(brtk)]);
    keep_buses = intersect(keep_buses, active_branch_buses);
    
    % Terminate gracefully if no valid network components remain
    if isempty(keep_buses)
        disp('Nothing to Visualize: no active buses left after filtering.');
        return;
    end
    
    % 7) Rebuild the reduced results structure
    results = results_old;
    
    % Logical masks to ensure perfectly synchronized indexing
    bus_mask  = ismember(results_old.bus(:,1), keep_buses);
    gen_mask  = ismember(results_old.gen(:,1), keep_buses);
    
    results.bus    = results_old.bus(bus_mask, :);
    results.branch = results_old.branch(brtk, :);
    results.gen    = results_old.gen(gen_mask, :);
    
    if isfield(results_old, 'gencost') && ~isempty(results_old.gencost)
        results.gencost = results_old.gencost(gen_mask, :);
    end
    
    % Keep Coord array perfectly aligned with results.bus
    if isfield(results_old, 'Coord') && ~isempty(results_old.Coord)
        results.Coord = results_old.Coord(bus_mask, :);
    end
    
    % 8) Reset internal MATPOWER indexing maps
    if isfield(results, 'order'), results = rmfield(results, 'order'); end
    if isfield(results, 'int'),   results = rmfield(results, 'int');   end
    
    % Store original bus IDs in column 14
    results.bus(:,14) = results.bus(:,1);
    opts.auxbusID_on = 1;
    
    % 9) Coherence verification and internal mapping conversion
    num_bus_table = size(results.bus, 1);
    fprintf('Coherent reduced network: %d buses retained.\n', num_bus_table);
    
    try
        results = ext2int(results);
    catch ME
        warning('ext2int failed: %s', ME.message);
        disp('Nothing to Visualize');
        return;
    end
end

%% --- Data Sorting (Ascending ID Order for Inspection & Debugging)
[~, idxb]  = sortrows(results.bus, 1);        results.bus    = results.bus(idxb, :); 
[~, idxbr] = sortrows(results.branch, [1 2]); results.branch = results.branch(idxbr, :);

if isfield(results, 'Coord') && ~isempty(results.Coord)
     results.Coord = results.Coord(idxb,:);
end

%% --- 'Terminal' Column Selectors (for Reference Sign)
switch upper(branch_var)
    case 'P'
        pai = strcmp(terminal, "F") * 14 + strcmp(terminal, "T") * 16;
        
    case 'Q'
        pai = strcmp(terminal, "F") * 15 + strcmp(terminal, "T") * 17;
        
    case 'I'
        pai = strcmp(terminal, "F") * 18 + strcmp(terminal, "T") * 19;
        
    case {'S', 'L'}
        % For S/L, use the sign of forward/backward active power P
        pai = strcmp(terminal, "F") * 14 + strcmp(terminal, "T") * 16;
            
    otherwise
        error('VOLTS:InvalidBranchVar', ...
            'Unrecognized branch_var parameter ''%s''. Valid options are: P, Q, C, S, L.', branch_var);
end

%% --- VM/VP Selector for Node Coloring
switch upper(bus_var)
    case 'VM'
        vai = 8;
    case 'VA'
        vai = 9;
    otherwise
        error('VOLTS:InvalidBusVar', ...
            'Unrecognized bus_var parameter ''%s''. Valid options are ''VM'' or ''VA''.', bus_var);
end

%% --- Active Branches and Base Topology
bon    = results.branch(:,11);
active = (bon == 1);
B      = results.branch(active,1:2);

%% --- Bus Data for Color Mapping
N = results.bus(:,vai);

%% --- Auxiliary Quantities
Vph = results.bus(:,10) .* results.bus(:,8) .* exp(1j * results.bus(:,9)/180*pi) * 1e3; % [V]
Sa  = hypot(results.branch(:,14),results.branch(:,15)) * 1e6; % S_from [VA]
Sp  = hypot(results.branch(:,16),results.branch(:,17)) * 1e6; % S_to [VA]
[~,fidx]=ismember(results.branch(:,1),results.bus(:,1));
[~,tidx]=ismember(results.branch(:,2),results.bus(:,1));
Iaph =  Sa ./ (sqrt(3) * abs(Vph(fidx))); % [A] from (I want only current magnitude)
Ipph =  Sp ./ (sqrt(3) * abs(Vph(tidx))); % [A] to  (I want only current magnitude)
results.branch(:,18) = Iaph .* sign(results.branch(:,14)); % C_from with P_from sign
results.branch(:,19) = Ipph .* sign(results.branch(:,16)); % C_to   with P_to sign

%% --- Edge Color Mapping Data
if strcmp(terminal,"F")
    branch_values = results.branch(active, pai);
else
    branch_values = -results.branch(active, pai);
end

% Sovrascritture per S / Spu (magnitudine + segno coerente a pai)
if strcmp(branch_var,"S")

    if strcmp(terminal,"F")
        branch_values = Sp(active) .* sign(results.branch(active, pai)) / 1e6; % [MVA]
    else
        branch_values = -Sa(active) .* sign(results.branch(active, pai)) / 1e6; % [MVA]
    end

elseif strcmp(branch_var,"L")
    
    Sb_base = results.branch(active, rate_col) * 1e6; % [VA]  (RATE_A, VA rating A)
    
    if strcmp(terminal,"F")
        branch_values = ( Sp(active) .* sign(results.branch(active, pai)) ) ./ Sb_base; % [pu]
    else
        branch_values = ( -Sa(active) .* sign(results.branch(active, pai)) ) ./ Sb_base; % [pu]
    end
end

%% --- Final Input Validation
num_nodes    = numel(results.bus(:,1));
num_branches = size(B, 1);
if length(N) ~= num_nodes
   warning('Matrix N must have %d rows (one for each bus 1..%d). It may be islanded bus', num_nodes, num_nodes);
end
 % 
if length(branch_values) ~= num_branches
   error('branch_values must contain %d elements (one for each active branch).', num_branches);
end

%% --- Sign-Consistent Direction and Flow Reversal Tracking
edges      = B;
isReversed = false(num_branches,1);
for i = 1:num_branches
    if branch_values(i) < 0
        edges(i,:)      = [B(i,2), B(i,1)];
        branch_values(i)= abs(branch_values(i));
        isReversed(i)   = true;
    end
end

%% --- Graph Setup and Bus ID-to-Row Mapping
G     = digraph(edges(:,1), edges(:,2), branch_values, num_nodes);
busId = results.bus(:,1);
busarea = results.bus(:,7);

if size(results.bus,2)<14 
    busId_OR = results.bus(:,1);
else
    busId_OR = results.bus(:,14);
end

rowOf = @(ids) arrayfun(@(x) find(busId==x,1,'first'), ids);

% --- Mapping between graph edge order and original branch order ---------------
%   G.Edges.EndNodes     : [numE x 2] pairs of (from, to) in graph edge order
%   results.branch(:,1:2): [numB x 2] pairs of (from, to) in source branch order

edge_nodes_graph = G.Edges.EndNodes;  % It Does not collide with existing variables
branch_pairs_src = results.branch(results.branch(:,11)==1, 1:2); % It does not collide with existing variables
num_edges_graph = size(edge_nodes_graph, 1);
edge2branch_idx = zeros(num_edges_graph, 1);  % Output: row index in results.branch
%edge_flipped_flag = false(num_edges_graph, 1);% Output: is direction reversed?

% To speed up lookups, create two string-to-index maps:
% one for (f,t) and one for (t,f). Avoids O(N^2) loops on large networks.
key_forward = containers.Map('KeyType','char','ValueType','any');
key_reverse = containers.Map('KeyType','char','ValueType','any');

% Populate maps: key "f#t", value row index in results.branch
for r = 1:size(branch_pairs_src,1)
    f0 = branch_pairs_src(r,1);
    t0 = branch_pairs_src(r,2);
    kf = sprintf('%d#%d', f0, t0);
    kr = sprintf('%d#%d', t0, f0);
% For parallel branches between the same pair, accumulate a vector of indices
    if isKey(key_forward, kf)
        key_forward(kf) = [key_forward(kf) r];
    else
        key_forward(kf) = r;
    end
    if isKey(key_reverse, kr)
        key_reverse(kr) = [key_reverse(kr) r];
    else
        key_reverse(kr) = r;
    end
end
% Resolve edge matching for each graph edge
for e = 1:num_edges_graph
    fg = edge_nodes_graph(e,1);
    tg = edge_nodes_graph(e,2);
    % 1) Try direct match (same direction)
    kf = sprintf('%d#%d', fg, tg);
    if isKey(key_forward, kf)
        idx_list = key_forward(kf);
        % If parallel branches exist, select the first unassigned one (greedy)
        if numel(idx_list) == 1
            edge2branch_idx(e) = idx_list;
            continue
        else
            % If multiple candidates exist (parallel lines), select an available one
            chosen = 0;
            for cand = idx_list(:)'
                if ~any(edge2branch_idx == cand)
                    chosen = cand; break;
                end
            end
            if chosen == 0
                % All occupied: fallback to the first one
                chosen = idx_list(1);
            end
            edge2branch_idx(e) = chosen;
            continue
        end
    end
    % 2) Try reversed match (from <-> to)
    kr = sprintf('%d#%d', fg, tg); % Look up (tg, fg) using the reversed map
    if isKey(key_reverse, kr)
        idx_list = key_reverse(kr);
        if numel(idx_list) == 1
            edge2branch_idx(e) = idx_list;
            % edge_flipped_flag(e) = true;
            continue
        else
            chosen = 0;
            for cand = idx_list(:)'
                if ~any(edge2branch_idx == cand)
                    chosen = cand; break;
                end
            end
            if chosen == 0
                chosen = idx_list(1);
            end
            edge2branch_idx(e) = chosen;
            % edge_flipped_flag(e) = true;
            continue
        end
    end
    % 3) No match found
    warning('Arco del grafo #%d = [%d %d]: nessun match in results.branch(:,1:2).', e, fg, tg);
    edge2branch_idx(e) = NaN; % Explicitly flag missing match
end
% --- Mapping End-------------------------------------------------------------

%% --- Bus Voltage (kV) for Line Thickness: Rule in opts.width_rule ('min'|'max'|'avg')
EN       = G.Edges.EndNodes; 
if iscell(EN)
    EN = cell2mat(EN);
end

[~,b1]=ismember(EN,results.branch(:,[1,2]),'rows');
[~,b2]=ismember(EN,results.branch(:,[2,1]),'rows');
bb = b1+b2;
rowsFrom = rowOf( results.branch(bb,1) );
rowsTo   = rowOf( results.branch(bb,2) );
kV_from  = results.bus(rowsFrom,10);
kV_to    = results.bus(rowsTo,10);
[~,ctk]  = min([rowsFrom,rowsTo],[],2);

vbr = [kV_from,kV_to];
idx = sub2ind(size(vbr), (1:size(vbr,1)).', ctk);
kV_edge = vbr(idx);                     % C è N x 1

%% --- Line Width Mapping (Continuous Linear)
w_min  = opts.branch_w(1); w_max = opts.branch_w(2);
kVlo   = min(kV_edge);
kVhi   = max(kV_edge);
if abs(kVhi - kVlo) < eps
    widths = w_max * ones(num_branches,1);
else
    widths = w_min + (kV_edge - kVlo) * (w_max - w_min) / (kVhi - kVlo);
end

%% --- Plot (Main Axes for GRAPH)
figure('Position', opts.figpos); set(gcf,'Color','white');
ax = axes('Position', opts.axpos, 'Box','off'); % axes dei NODI

if (isfield(results, 'Coord') | size(results.bus,2)>14) && ~opts.coord_regen
    h = plot(G, 'Layout', 'force', 'Iterations', 1, 'ArrowSize', 7 , 'Marker', 'o', 'Parent', ax);
    try
        h.XData = results.Coord(:,1);
        h.YData = results.Coord(:,2);
    catch
        h.XData = results.bus(:,15);
        h.YData = results.bus(:,16);
    end
    scale = 2; % +10%
    mx = mean(h.XData); my = mean(h.YData);
    h.XData = (h.XData - mx) * scale + mx;
    h.YData = (h.YData - my) * scale + my;
    axis(ax, 'tight');
else

    baseArgs = {'Marker','o','Parent',ax};

    switch lower(opts.layoutgraph)
    
         case 'force'
            h = plot(G, 'Layout','force', ...
                     'ArrowSize',7, 'Iterations',opts.graphit, 'UseGravity',true,baseArgs{:});
    
         case 'auto'
            h = plot(G, 'Layout','auto', ...
                     'ArrowSize',7, baseArgs{:});
    
        case 'circle'
            h = plot(G, 'Layout','circle', ...
                     'ArrowSize',7, baseArgs{:});
    
        case 'layered'
            % Direction: 'right' | 'left' | 'down' | 'up'
            h = plot(G, 'Layout','layered', ...
                     'Direction','right', 'ArrowSize',7, baseArgs{:});
    
        case 'subspace'
            h = plot(G, 'Layout','subspace', ...
                     'ArrowSize',7, baseArgs{:});

        otherwise
            warning('Unrecognized layout "%s". Using "force".', opts.layoutgraph);
            h = plot(G, 'Layout','force', ...
                 'ArrowSize',7, 'Iterations',opts.graphit, 'UseGravity',true, baseArgs{:});
    
    end

end

h.EdgeLabelColor=[0 0 128]/255;
h.NodeLabelColor=[178, 34, 34]/255;

%% --- Node Colors (VM/VP) + RIGHT COLORBAR (Nodes) — ALWAYS VISIBLE
%% --- Node Colors (VM/VP) + RIGHT COLORBAR (Nodes) — ALWAYS VISIBLE
vm_breaks = opts.vm_breaks; 
va_breaks = opts.va_breaks;
v_colors = [ ...
                  0.00 0.00 0.60;  % min -> dark blue
                  0.00 0.70 1.00;  % low -> cyan
                  0.00 0.70 0.00;  % nominal -> green
                  1.00 0.85 0.00;  % high -> warm yellow
                  0.90 0.00 0.00]; % max -> red

switch bus_var
    case 'VM' 
           cb1_label = 'Voltage Magnitude (pu)';
           cb1_Ticks = vm_breaks;
           
    case 'VA'
           cb1_label = 'Voltage Phase (°)';
           if ~isempty(va_breaks)
               cb1_Ticks = va_breaks;
           else
               vamin = min(N);
               if vamin < 0 
                   vamin = round(min(N)*1.10, 0); 
               else 
                   vamin = round(min(N)*0.9, 0); 
               end
                
               vamax = max(N);
               if vamax < 0 
                   vamax = round(max(N)*1.10, 0); 
               else 
                   vamax = round(max(N)*0.9, 0); 
               end 
               cb1_Ticks = linspace(vamin, vamax, 5);
           end
end

% --- LIMITI DINAMICI PER LA COLORBAR ---
bmin = cb1_Ticks(1); 
bmax = cb1_Ticks(end);

% Evita errori se max e min coincidono
if bmax == bmin
    bmax = bmin + eps; 
end

nSteps = 512;
normalizedBreaks = (cb1_Ticks - bmin) / (bmax - bmin);
vm_customMap = interp1(normalizedBreaks, v_colors, linspace(0,1,nSteps), 'linear');

colormap(ax, vm_customMap);
h.NodeCData = N;

% Imposta la scala dei colori corrispondente ai ticks calcolati
if exist('clim', 'file')
    clim(ax, [bmin, bmax]);
else
    caxis(ax, [bmin, bmax]);
end
   
cb1 = colorbar(ax, 'Location', 'eastoutside'); 
cb1.Box = 'off';
cb1.Label.String = cb1_label;
cb1.Ticks = cb1_Ticks;
cb1.FontSize = opts.fontsize;

%% --- Edge Colors (branch_values) + LINE WIDTHS & ARROWS
if strcmp(branch_var,"L")
    cmap_edges = jet(256);   % EDGE COLORMAP
    bmin_e = 0;
    bmax_e = 1.5;                    % FIXED SCALE
    clim_bounds = [0, 1.5];          % FIXED COLOR SCALE

    % ALWAYS normalize values to [0,1] relative to [0,1.5]
    norm_vals = branch_values / clim_bounds(2);
    
    % Manual clipping below 0 and above 1
    norm_vals(norm_vals < 0) = 0;
    norm_vals(norm_vals > 1) = 1;
    
    % Map into colormap
    idxc = round(1 + (size(cmap_edges,1)-1) * norm_vals);
    idxc(idxc < 1) = 1;
    idxc(idxc > size(cmap_edges,1)) = size(cmap_edges,1);
    
    % Assign colors to branches
    h.EdgeColor = cmap_edges(idxc, :);
    h.EdgeColor = h.EdgeColor(edge2branch_idx,:);
    
    % Branch widths and arrows as before
    h.LineWidth = widths;
    h.ArrowSize = 6 + opts.arrowsize * (widths - w_min) / (w_max - w_min);
else
    cmap_edges = cool(256); % EDGE COLOR MAP
    if isempty(opts.br_breaks)
        bmin_e = 0; 
        bmax_e = max(branch_values);
    else
        bmin_e = opts.br_breaks(1);
        bmax_e = opts.br_breaks(end);
    end
    if bmax_e==bmin_e
          bmax_e=bmin_e+eps;
    end
    norm_vals = rescale(branch_values, 0, 1);
    idxc = round(1 + (size(cmap_edges,1)-1) * norm_vals);
    idxc(idxc > size(cmap_edges,1)) = size(cmap_edges,1);
    idxc(idxc < 1) = 1;
    h.EdgeColor = cmap_edges(idxc, :); % Branch colors via RGB
    h.EdgeColor = h.EdgeColor(edge2branch_idx,:);
    h.LineWidth = widths;
    h.ArrowSize = 6 + opts.arrowsize * (widths - w_min) / (w_max - w_min); 
end

%% --- LEFT COLORBAR (Branches) on Auxiliary Axes — ALWAYS VISIBLE
axEdges = axes('Position', ax.Position, 'Color','none', 'Visible','off', ...
    'XLim', ax.XLim, 'YLim', ax.YLim);
if strcmp(branch_var,"L")
   colormap(axEdges, jet);
else
   colormap(axEdges, cool);
end
set(axEdges, 'CLim', [bmin_e, bmax_e]);
cb2 = colorbar(axEdges, 'Location', 'westoutside'); cb2.Box = 'off';
cb2.FontSize = opts.fontsize;

if ~isempty(opts.br_breaks)
   cb2.Ticks = opts.br_breaks;
end

if     strcmp(branch_var,"P"), cb2.Label.String = 'Active Power Branch Flow (MW)';
elseif strcmp(branch_var,"Q"), cb2.Label.String = 'Reactive Power Branch Flow (MVAr)';
elseif strcmp(branch_var,"S"), cb2.Label.String = 'Apparent Power Branch Flow (MVA)';
elseif strcmp(branch_var,"I"), cb2.Label.String = 'Branch Current Magnitude (p.u.)'; % O (A) se già convertito
elseif strcmp(branch_var,"L"), cb2.Label.String = 'Branch Loading (p.u.)';

    if isempty(opts.br_breaks)
        cb2.Ticks = 0:0.25:1.5;
    end
end

%% --- Customizations & Bus Type Legend — ALWAYS VISIBLE
h.MarkerSize   = opts.markersize;
h.NodeFontSize = opts.fontsize;
hold(ax, 'on');
bus_types = results.bus(:,2);
x = h.XData;
y = h.YData;
idxPQ  = find(bus_types == 1);
idxPV  = find(bus_types == 2);
idxREF = find(bus_types == 3);
hREF = scatter(ax, x(idxREF), y(idxREF), h.MarkerSize^2, 'V', 'MarkerFaceColor','none', ...
    'MarkerEdgeColor','k', 'LineWidth',1);
hPQ  = scatter(ax, x(idxPQ),  y(idxPQ),  h.MarkerSize^2, 'o', 'MarkerFaceColor','none', ...
    'MarkerEdgeColor','k', 'LineWidth',1);
hPV  = scatter(ax, x(idxPV),  y(idxPV),  h.MarkerSize^2.1, 's', 'MarkerFaceColor','none', ...
    'MarkerEdgeColor','k', 'LineWidth',1);
lgd = legend(ax, [hREF, hPQ, hPV], {'REF', 'PQ', 'PV'}, ...
    'Location','northwest', 'Orientation','horizontal', 'Box','off','FontSize',opts.fontsize);
lgd.Title.String = 'Bus Type';
lgd.AutoUpdate   = 'off';
ax.XColor = [1 1 1]; ax.YColor = [1 1 1];

% --- Shift the legend slightly to the right ---
delta = -0.02;   %shift amount (increase/decrease as needed)
pos = lgd.Position;
pos(1) = pos(1) - delta;   % shift to the left
lgd.Position = pos;

%% --- "T" Labels for Transformers
if showEL && opts.trs_lab_on
    
    EN_local = G.Edges.EndNodes;
    if iscell(EN_local)
        EN_local = cell2mat(EN_local);
    end
    
    % Voltage (kV) at the ends of each branch [N_edges x 2]
    kv_pairs_local = [ results.bus( rowOf(EN_local(:,1)), 10 ), ...
                       results.bus( rowOf(EN_local(:,2)), 10 ) ];
                  
    % Flag: label only where kV values at the two ends differ (transformers)
    flag_kv_diff = kv_pairs_local(:,1) ~= kv_pairs_local(:,2);
    
    % Transformer data from standard MATPOWER columns on ACTIVE branches
    tap_ratio_local   = results.branch(active, 9);   % TAP (R)
    phase_shift_local = results.branch(active,10);   % SHIFT (S) in degrees
    
    % Graphical offset to slightly shift the label away from the segment
    xlim_ax = xlim(ax);  ylim_ax = ylim(ax);
    rangeMax_local = max(diff(xlim_ax), diff(ylim_ax));
    offset_local = 0.005 * rangeMax_local;
    
    % Loop over all drawn branches
    for kk = 1:num_branches
        
        % Skip branches that are not transformers (same kV at both ends)
        if ~flag_kv_diff(kk)
            continue
        end
        
        % 1. Determine label text based on detail level (opts.trs_dl)
        switch opts.trs_dl
            case 1
                % High detail: Symbol + Tap Ratio + Phase Shift
                lbl_T = sprintf('\\it t \\rm Tap %.2f S %.1f%c', ...
                                tap_ratio_local(kk), phase_shift_local(kk), 176);
            case 0
                % Base detail: Transformer symbol only
                lbl_T = sprintf('\\it t\\rm');
                
            otherwise
                % Fallback: Base detail
                lbl_T = sprintf('\\it t\\rm');
        end

        % Skip rendering if label text is empty
        if isempty(lbl_T)
            continue
        end
        
        % 2. Geometry calculation and positioning (computed only if needed)
        ii = EN_local(kk,1); jj = EN_local(kk,2);
        P0 = [x(ii) y(ii)];
        P1 = [x(jj) y(jj)];
        M  = (P0 + P1)/2; % Edge midpoint
        
        v  = P1 - P0;  
        nv = norm(v);
        if nv < eps
            n_hat = [0 1];
        else
            n_hat = [-v(2), v(1)] / nv;
        end
        Ptext = M + offset_local * n_hat;
        
        % 3. Draw label on axes
        text(Ptext(1), Ptext(2), lbl_T, ...
            'Parent', ax, 'Color', 'k', 'FontSize', opts.fontsize, ...
            'BackgroundColor', 'none', 'Margin', 1, ...
            'HorizontalAlignment','center', 'VerticalAlignment','middle', ...
            'Clipping','on', 'Interpreter','tex');
    end
end

% Transformer Legend
if opts.trs_lab_on > 0
    % change details according to trs_dl
    if opts.trs_dl > 0
        tr_text = '\bfTransformer:\rm "t", tap = ratio, s = shift (deg)';
    else
        tr_text = '\bfTransformer:\rm "t"';
    end
    
    % Clean old notes
    oldTrAnn = findall(gcf, 'Tag', 'tr_legend_note');
    if ~isempty(oldTrAnn), delete(oldTrAnn); end
    
    text(ax, 0.99, 0.98, tr_text, ...
        'Units', 'normalized', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', ...
        'FontSize', opts.fontsize, ...
        'Interpreter', 'tex', ...
        'Color', 'k', ...
        'BackgroundColor', [1 1 1 0.8], ...
        'Margin', 3, ...
        'Clipping', 'off', ...
        'Tag', 'tr_legend_note');
end
%% --- LEGEND: Voltage Levels (Line Width) — ALWAYS VISIBLE

kV_levels = unique(kV_edge(:),'sorted');
kV_levels = sort(kV_levels,'descend');
kVloLeg   = min(kV_edge); kVhiLeg = max(kV_edge);
if abs(kVhiLeg - kVloLeg) < eps
    widthsLevels = w_max * ones(numel(kV_levels),1);
else
    widthsLevels = w_min + (kV_levels - kVloLeg) * (w_max - w_min) / (kVhiLeg - kVloLeg);
end
posLeg = [ax.Position(1)+0.05, 0.02, 0.22, 0.18];
axLeg  = axes('Parent', gcf, 'Position', posLeg, 'Color', 'none', 'Box', 'off');
set(axLeg, 'XColor', 'none', 'YColor', 'none'); % Evita linee di bordo indesiderate
axis(axLeg, 'off'); xlim(axLeg,[0 1]); ylim(axLeg,[0 1]);
legendTitle = 'Voltage Levels';
text(axLeg, 0.02, 0.98, legendTitle, 'Units','normalized', 'FontWeight','bold', 'FontSize', opts.fontsize, ...
    'HorizontalAlignment','left', 'VerticalAlignment','top', 'Color','k','BackgroundColor','white');
nLevels = numel(kV_levels);
if nLevels == 0
    warning('No voltage levels found for line width legend.');
else
    padTop = 0.10; padBottom = 0.06; usableH = 1 - padTop - padBottom;
    dy = usableH / max(nLevels, 1); x0 = 0.05; x1 = 0.20;
    for kk = 1:nLevels
        yk = 1 - padTop - (kk-1)*dy - dy/2;
        line(axLeg, [x0 x1], [yk yk], 'Color', [0 0 0], 'LineWidth', widthsLevels(kk));
        lbl = sprintf('%.6g kV', kV_levels(kk));
        text(axLeg, 0.30, yk, lbl, 'Units','normalized', 'FontSize', opts.fontsize, ...
            'HorizontalAlignment','left', 'VerticalAlignment','middle', 'Color','k','BackgroundColor','white');
    end
end

%% ================== LABELS — START ==================
% Base calculations for labels
nb = size(results.bus,1);
VM = results.bus(:,8); VP = results.bus(:,9);
VB = results.bus(:,10); SM = results.branch(:,6);

activegen = results.gen(:,8) == 1;                 % active gens
[~,loc] = ismember(results.gen(activegen,1), results.bus(:,1));
nGen = accumarray(loc(loc>0), 1, [size(results.bus,1) 1], @sum, 0);

% LOAD
PD = zeros(nb,1);   
QD = zeros(nb,1);
if size(results.bus,2) >= 4
    PD = results.bus(:,3);   % MW
    QD = results.bus(:,4);   % MVAr
end

% GENERATION
Pg = zeros(nb,1); 
Qg = zeros(nb,1);
if isfield(results,'gen') && ~isempty(results.gen)
    gen_on = true(size(results.gen,1),1);
    if size(results.gen,2) >= 8
        gen_on = results.gen(:,8) == 1;
    end
    gbus = results.gen(gen_on,1);
    Pgk  = results.gen(gen_on,2);
    Qgk  = results.gen(gen_on,3);
    for gg = 1:numel(gbus)
        Pg(gbus(gg)) = Pg(gbus(gg)) + Pgk(gg);
        Qg(gbus(gg)) = Qg(gbus(gg)) + Qgk(gg);
    end
end

% Shunt GS/BS (MATPOWER: GS and BS in MVA)
GS = results.bus(:,5);   % conductance (p.u.)
BS = results.bus(:,6);   % susceptance (p.u.) > 0 CAPACITOR < 0 INDUCTOR

% Shunt power injections (MW, MVAr)
% NOTE: GS>0 absorbs active power; BS>0 means capacitive -> generates Q
Psh =  GS.*results.bus(:,8).^2+0; %* baseMVA;      % MW absorbed if GS>0
Qsh = -BS.*results.bus(:,8).^2+0; % * baseMVA;     % MVAr (BS>0 -> capacitive -> Qsh<0)

% FINAL corrected nodal injections (MATPOWER convention:
% injection = generation - load - shunt)
Pinj = Pg - PD - Psh;    % MW
Qinj = Qg - QD - Qsh;    % MVAr

degSym = char(176);

% P/Q extractions (from/to) for active branches
Pf_all = results.branch(:,14); Qf_all = results.branch(:,15);
Pt_all = results.branch(:,16); Qt_all = results.branch(:,17);
Pf = Pf_all(active); Qf = Qf_all(active);
Pt = Pt_all(active); Qt = Qt_all(active);
S_from_MVA = Sa(active) / 1e6; S_to_MVA = Sp(active) / 1e6;
I_from_A = abs(Iaph(active));  I_to_A  = abs(Ipph(active));

% base value extracted by the reference terminal
if strcmp(terminal, "F")
    P_edge = Pf(edge2branch_idx); 
    Q_edge = Qf(edge2branch_idx); 
    S_edge = S_from_MVA(edge2branch_idx); 
    I_edge = I_from_A(edge2branch_idx); 
else
    P_edge = Pt(edge2branch_idx); 
    Q_edge = Qt(edge2branch_idx); 
    S_edge = S_to_MVA(edge2branch_idx); 
    I_edge = I_to_A(edge2branch_idx);
end
SM_edge = SM(edge2branch_idx);

switch lower(opts.branch_sign)
    case 'tabular'
        % Sign coherent with matpower
        % No change to label
        
    case 'relative'
        % Label chosen variable positive and coherent with arrow, other variable sign changed accordingly
        if strcmp(branch_var, 'Q')
            dir_var = Q_edge; % Q reference edge
        else
            dir_var = P_edge; % P reference edge (also for S, I, L)
        end
        
        dir_factor = ones(size(dir_var));
        dir_factor(dir_var < 0) = -1;
        
        P_edge = P_edge .* dir_factor;
        Q_edge = Q_edge .* dir_factor;
        
    otherwise
        error('VOLTS:InvalidBranchDir', ...
            'Invalid opts.branch_sign ''%s''. Valid options are ''tabular'' or ''relative''.', opts.branch_sign);
end
%%% - To develop in the future!
% --- PATCH: voltage limits (Vmax/Vmin) and violation flags for BUS
%Vmax_bus = results.bus(:,12);   % VMAX (pu)
%Vmin_bus = results.bus(:,13);   % VMIN (pu)
%vm_is_out = (VM > Vmax_bus) | (VM < Vmin_bus);

% --- PATCH: Smax from RATE_A (col. 6) and violation flags for BRANCH
%Smax_branch = results.branch(active, 6);    % RATE_A (MVA)
%is_S_over   = S_edge > Smax_branch;

% --- PATCH: angle constraints (ANGMIN/ANGMAX) and violation flags
%ANGMIN = results.branch(active, 12);  % deg
%ANGMAX = results.branch(active, 13);  % deg
% differenza di angolo coerente con la direzione EN (F->T del grafo)
%dtheta = VP(rowsFrom) - VP(rowsTo);
%ang_violation = (dtheta < ANGMIN) | (dtheta > ANGMAX);

if showEL
    % 1. EDGE LABELS 
    if opts.branch_lab_on
        switch opts.branch_dl
            case 2 % High Details: P, Q, S, R, I
                edgeTxt = arrayfun(@(k) sprintf('P %.1fMW Q %.1fMvar S %.1fMVA R %.0fMVA I %.0fA', ...
                    P_edge(k), Q_edge(k), S_edge(k), SM_edge(k), I_edge(k)), ...
                    (1:num_branches)', 'UniformOutput', false);

            case 1 % Medium Details: P, Q, S
                edgeTxt = arrayfun(@(k) sprintf('P %.1fMW Q  %.1fMvar, S %.2fMVA', ...
                    P_edge(k), Q_edge(k), S_edge(k)), ...
                    (1:num_branches)', 'UniformOutput', false);

            case 0 % Base Detail: P, Q 
                edgeTxt = arrayfun(@(k) sprintf('P %.1fMW Q  %.1fMvar', ...
                    P_edge(k), Q_edge(k)), ...
                    (1:num_branches)', 'UniformOutput', false);

            otherwise % Base detail if wrong option is applied
                edgeTxt = arrayfun(@(k) sprintf('P %.1fMW Q  %.1fMvar', ...
                    P_edge(k), Q_edge(k)), ...
                    (1:num_branches)', 'UniformOutput', false);
        end

        % Apply Edge Labels
        try h.EdgeLabel = repmat({''}, height(G.Edges), 1); catch, end
        labeledge(h, 1:num_branches, edgeTxt);
        h.EdgeFontSize = opts.fontsize;
    else
        h.EdgeLabel = {}; % Switch off edge label only
    end

    % 2. BUS LABELS
    if opts.bus_lab_on
        % Bus Label with and without auxiliary ID
        if opts.auxbusID_on
            busLabel = arrayfun(@(i) sprintf('\\bf%d\\rm/(\\bf%d\\rm)', busId(i), busId_OR(i)), ...
                (1:num_nodes)', 'UniformOutput', false);
        else
            busLabel = arrayfun(@(i) sprintf('\\bf%d\\rm', busId(i)), ...
                (1:num_nodes)', 'UniformOutput', false);
        end

        % text generation according to opts.bus_dl
        switch opts.bus_dl
            case 2 % Full details: ID + every single details
                nodeTxt = arrayfun(@(i) sprintf([ ...
                    '%s V %4.0fkV ar[%1.0f]\n', ...
                    'V %2.2fpu \\theta %2.0f%s\n' ...
                    'Pinj  %5.1fMW Qinj %5.1fMVar \n' ...
                    'Pg    %5.1f " "   Qg   %5.1f " " \n' ...
                    'Pd    %5.1f " "  Qd   %5.1f " " \n' ...
                    'Psh   %5.1f " "  Qsh  %5.1f " " \n' ...
                    'Active Gens  %2.0f' ...
                    ], ...
                    busLabel{i}, VB(i), busarea(i), VM(i), VP(i), degSym, ...
                    Pinj(i), Qinj(i), Pg(i), Qg(i), PD(i), QD(i), Psh(i), Qsh(i), nGen(i)), ...
                    (1:num_nodes)', 'UniformOutput', false);

            case 1 % Bus ID + Voltage Magnitude and Phase
                nodeTxt = arrayfun(@(i) sprintf('%s\nV %2.2fpu \\theta %2.0f%s\n', ...
                    busLabel{i}, VM(i), VP(i), degSym), ...
                    (1:num_nodes)', 'UniformOutput', false);

            case 0 % Only Bus ID
                nodeTxt = arrayfun(@(i) sprintf('%s\n', busLabel{i}), ...
                    (1:num_nodes)', 'UniformOutput', false);

           otherwise % Only ID if wrong value is applied
                nodeTxt = arrayfun(@(i) sprintf('%s\n', busLabel{i}), ...
                    (1:num_nodes)', 'UniformOutput', false);
        end

        % Apply Node Label
        try h.NodeLabel = repmat({''}, num_nodes, 1); catch, end
        labelnode(h, 1:num_nodes, nodeTxt);
    else
        h.NodeLabel = {}; % Switch off bus Label
    end

else
    % showEL = NO LABELS
    h.EdgeLabel = {};
    h.NodeLabel = {};
end

%% --- BOTTOM RIGHT LEGEND: Arrow Direction & Meaning — ALWAYS VISIBLE
 if opts.leg_note_on
        switch branch_var
            case 'P',   p_desc = 'P" (Active Power, MW)';
            case 'Q',   p_desc = 'Q" (Reactive Power, MVAr)';
            case 'I',   p_desc = 'I" (Current, A)';
            case 'S',   p_desc = 'S" (Apparent Power, MVA)';
            case 'L',   p_desc = sprintf('L" (Line Loading, pu) [Rate %s]',opts.branch_rate);%'L" (Line Loading, pu)';
            otherwise,  p_desc = sprintf('Parameter branch_var="%s"', branch_var);
        end
        switch terminal
            case 'F'
                dir_desc = 'Terminal: "F" (\itfrom\rm)';
            case 'T'
                dir_desc = 'Terminal: "T" (\itto\rm)';
            otherwise
                dir_desc = sprintf('Parameter terminal="%s"', terminal);
        end
        % if strcmp(branch_var,'S') || strcmp(branch_var,'L'), s_note = 'If set S/L, P provides edge direction'; else, s_note = ''; end
        % legend_title = '\bf Branch Info \rm';
        % legend_lines = { sprintf('"%s', p_desc), dir_desc, s_note };
        % ll = legend_lines(~cellfun(@isempty, legend_lines)); ll = ll(:);
        % all_lines   = [{legend_title}; ll];
        % legend_text = strjoin(all_lines, '\n');
        % oldAnn = findall(gcf,'Type','textboxshape','Tag','flow_legend_br'); if ~isempty(oldAnn), delete(oldAnn); end
        % annotation(gcf, 'textbox', [(ax.Position(1)+ax.Position(3)-0.3) 0.06 0.30 0.14], ...
        %     'String', legend_text, 'Interpreter','tex', 'HorizontalAlignment','right', ...
        %     'VerticalAlignment','bottom', 'FontSize',opts.fontsize, 'EdgeColor', 'none', 'LineWidth', 0.5, ...
        %     'Color', [0 0 0], 'BackgroundColor', 'none', 'FitBoxToText', 'on', 'Tag', 'flow_legend_br');

    %Header
    legend_title = '\bf Branch Info \rm';
    p_desc_quoted = sprintf('"%s"', p_desc); % Risultato: "P" (Active Power Flow, MW) oppure "I" (Current, A)
    %Note for S and L (shown only when active power is not the direct metric)
    if strcmp(branch_var, 'S') || strcmp(branch_var, 'L')
        s_note = 'Arrows indicate P flow direction';
    else
        s_note = '';
    end
    
    %Concise sign convention note (shown only when text labels are enabled)
    if opts.branch_lab_on && strcmpi(opts.branch_sign, 'tabular') 
    sign_note = 'P/Q signs aligned with to tabular output';
    else
        if strcmpi(branch_var, 'Q')
            sign_note = 'P/Q signs: aligned with Q arrow (+ align, - oppose)';
        else
            sign_note = 'P/Q signs: aligned with P arrow (+ align, - oppose)';
        end
    end
    % Assembly and dynamic line filtering
    legend_lines = { dir_desc, p_desc_quoted, s_note, sign_note };
    ll = legend_lines(~cellfun(@isempty, legend_lines)); 
    all_lines = [{legend_title}; ll(:)];
    legend_text = strjoin(all_lines, '\n');
    
    % 6. Textbox rendering
    oldAnn = findall(gcf, 'Type', 'textboxshape', 'Tag', 'flow_legend_br'); 
    if ~isempty(oldAnn), delete(oldAnn); end
    annotation(gcf, 'textbox', [(ax.Position(1)+ax.Position(3)-0.30) 0.06 0.30 0.14], ...
        'String', legend_text, ...
        'Interpreter', 'tex', ...
        'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', opts.fontsize, ...
        'EdgeColor', 'none', ...
        'LineWidth', 0.5, ...
        'Color', [0 0 0], ...
        'BackgroundColor', 'none', ...
        'FitBoxToText', 'on', ...
        'Tag', 'flow_legend_br');
    % EXPORT FIG:
    if opts.savefig
        if isempty(opts.figname)
            d4t3t1m3 = string(datetime('now','Format', 'yyyy-MM-dd_HH-mm-ss'));
            casename = strcat("case_",string(numel(results.bus(:,1))),"_",d4t3t1m3);
        else
            casename = opts.figname;   
        end
    
        savefig(gcf, strcat(casename, ".fig"));
        
        set(gcf, 'Color', 'w', 'InvertHardcopy', 'off');
    
        formatLower = lower(opts.figformat);
        if strcmp(formatLower, 'pdf') || strcmp(formatLower, 'eps')
            exportgraphics(gcf, strcat(casename, ".", opts.figformat), ...
                'ContentType', 'vector', ...
                'BackgroundColor', 'white');
        else
            exportgraphics(gcf, strcat(casename, ".", opts.figformat), ...
                'Resolution', 300);
        end 
    end

% END OF VOLT

end


