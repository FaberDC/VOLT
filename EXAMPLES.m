% VOLT Usage Examples
%
% Each section can be executed independently by placing the cursor
% inside the block and pressing Ctrl+Enter (Cmd+Enter on macOS).

close all
clear all
clc

%% CASE 5

opts = [];
opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.8,3.6]; 
opts.branch_range   = []; 
opts.filter_mode = 'base'; 
opts.coord_regen = 0; 
opts.branch_rate     = 'A'; 
opts.arrowsize   = 2*[10]; 
opts.markersize  = 2*[6]; 
opts.fontsize    = 2*[9]; 
opts.bus_dl      = [0]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [1]; 
opts.bus_lab_on  = [1]; 
opts.branch_lab_on = [1]; 
opts.trs_lab_on  = [1]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [5000];  
opts.leg_trs_on  = [1];
opts.branch_sign = 'tabular';
opts.leg_note_on = [1]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [1]; 
opts.figname     = 'case5'; 
opts.figformat   = 'pdf'; 

mpc = case5; 
results = runpf(mpc);
VOLT(results,"S","F","VM","Y",opts)
exportgraphics(gcf, strcat(opts.figname,'.pdf'), 'ContentType', 'vector');


%% CASE 5 ZOOMED

close all
opts = [];
opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.8,3.6]; 
opts.branch_range   = [];%[345 350]; 
opts.filter_mode = 'base'; 
opts.coord_regen = 0; 
opts.branch_rate     = 'A';
opts.arrowsize   = 2*[10]; 
opts.markersize  = 2*[6]; 
opts.fontsize    = 1.5*[9]; 
opts.bus_dl      = [2]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [1]; 
opts.bus_lab_on  = [1]; 
opts.branch_lab_on = [0]; 
opts.trs_lab_on  = [1]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [5000];  
opts.leg_trs_on  = [1];
opts.branch_sign = 'tabular';
opts.leg_note_on = [1]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [0]; 
opts.figname     = 'case5b'; 
opts.figformat   = 'pdf'; 

mpc = case5; 
results = runpf(mpc);
VOLT(results,"S","F","VM","Y",opts)
exportgraphics(gcf, strcat(opts.figname,'.pdf'), 'ContentType', 'vector');

%% CASE 118

opts = [];
opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.8,3.6]; 
opts.branch_range   = [];%[345 350]; 
opts.filter_mode = 'base'; 
opts.coord_regen = 0; 
opts.branch_rate     = 'A'; 
opts.arrowsize   = [10]; 
opts.markersize  = [6]; 
opts.fontsize    = [9]; 
opts.bus_dl      = [0]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [0]; 
opts.bus_lab_on  = [1]; 
opts.branch_lab_on = [0]; 
opts.trs_lab_on  = [1]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [5000];  
opts.leg_trs_on  = [1];
opts.branch_sign = 'tabular';
opts.leg_note_on = [1]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [1]; 
opts.figname     = 'case118'; 
opts.figformat   = 'pdf'; 

mpc = case118; 
results = runpf(mpc);
VOLT(results,"S","F","VM","Y",opts)
exportgraphics(gcf, strcat(opts.figname,'.pdf'), 'ContentType', 'vector');

%% CASE 118 FILTER

opts = [];
%opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.8,3.6]; 
opts.vm_range   = [345 350];%[345 350]; 
opts.filter_mode = 'base'; 
opts.coord_regen = 0; 
opts.branch_rate     = 'A'; 
opts.arrowsize   = 1.5*[10]; 
opts.markersize  = 1.5*[6]; 
opts.fontsize    = 1.5*[9]; 
opts.bus_dl      = [0]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [0]; 
opts.bus_lab_on  = [1]; 
opts.branch_lab_on = [0]; 
opts.trs_lab_on  = [1]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [5000];  
opts.leg_trs_on  = [1];
opts.branch_sign = 'tabular';
opts.leg_note_on = [1]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [1]; 
opts.figname     = 'case118b'; 
opts.figformat   = 'pdf'; 

mpc = case118; 
h=plot(graph(mpc.branch(:,1),mpc.branch(:,2)), 'Layout', opts.layoutgraph, ...
        'Iterations', opts.graphit, 'UseGravity', true);
mpc.Coord = [h.XData',h.YData'];
results = runpf(mpc);
VOLT(results,"S","F","VM","Y",opts)

%% CASE 39
opts = [];
opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.8,3.6]; 
opts.branch_range   = [] 
opts.filter_mode = 'base'; 
opts.coord_regen = 0; 
opts.branch_rate     = 'A'; 
opts.arrowsize   = 1.5*[10]; 
opts.markersize  = 1.5*[6]; 
opts.fontsize    = 1.5*[9]; 
opts.bus_dl      = [0]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [0]; 
opts.bus_lab_on  = [1]; 
opts.branch_lab_on = [0]; 
opts.trs_lab_on  = [1]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [5000];  
opts.leg_trs_on  = [1];
opts.branch_sign = 'tabular';
opts.leg_note_on = [1]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [1]; 
opts.figname     = 'case39'; 
opts.figformat   = 'pdf'; 

mpc = case39; 
h=plot(graph(mpc.branch(:,1),mpc.branch(:,2)), 'Layout', opts.layoutgraph, ...
        'Iterations', opts.graphit, 'UseGravity', true);
mpc.Coord = [h.XData',h.YData'];

mpc.branch(9,11) = 0;
results = runpf(mpc);
VOLT(results,"L","F","VM","Y",opts)

%% CASE 1356
opts = [];
opts.va_breaks   = [-30,-15,0,15,30]; 
opts.vm_breaks   = [0.90 0.95 1.00 1.05 1.10]; 
opts.branch_w       = [0.5,3]; 
opts.branch_range   = []; 
opts.filter_mode = 'base'; 
opts.coord_regen = 1; 
opts.branch_rate     = 'A'; 
opts.arrowsize   = [5]; 
opts.markersize  = [6]; 
opts.fontsize    = [15]; 
opts.bus_dl      = [0]; 
opts.branch_dl   = [0]; 
opts.trs_dl      = [0]; 
opts.bus_lab_on  = [0]; 
opts.branch_lab_on = [0]; 
opts.trs_lab_on  = [0]; 
opts.figpos      = [100, 100, 1200, 850]; 
opts.axpos       = [0.05, 0.1, 0.85, 0.85]; 
opts.layoutgraph = 'force'; 
opts.graphit     = [2000];  
opts.leg_trs_on  = [0];
opts.branch_sign = 'tabular';
opts.leg_note_on = [0]; 
opts.auxbusID_on = [0]; 
opts.savefig     = [0]; 
opts.figname     = 'case1356pegase'; 
opts.figformat   = 'pdf'; 

mpc = case1354pegase;

results = runpf(mpc);
VOLT(results,"S","F","VM","N",opts)
exportgraphics(gcf, strcat(opts.figname,'.pdf'), 'ContentType', 'vector');
