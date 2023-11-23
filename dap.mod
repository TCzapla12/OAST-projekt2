param maxNode, >= 0, integer;
param module_capacity, >=0, integer;

set Nodes=1..maxNode;

set Links;
param link_nodeA { Links }, in Nodes;
param link_nodeZ { Links }, in Nodes;

param module_cost { Links } default 1;

param number_of_modules { Links }, >= 0, default 1000; # number of modules c(e)

set Demands;
param demand_volume { Demands }, >= 0, default 0; # h(d)

param demand_maxPath { Demands }, >= 0, default 0; # number of available paths for each demand
set Demand_pathLinks { d in Demands, dp in 1..demand_maxPath[d] } within Links; # paths as sets of links

var demandPath_flow { d in Demands, 1..demand_maxPath[d]}, >= 0, integer; # flow x_dp

var z, integer; # link overload

subject to demand_satisfaction_constraint { d in Demands }:
  sum { dp in 1..demand_maxPath[ d] } demandPath_flow[ d, dp ] = demand_volume[ d ];
  
subject to capacity_constraint { l in Links }:
  number_of_modules[ l ] * module_capacity + z >= sum { d in Demands, dp in 1..demand_maxPath[ d ]: sum{ k in Demand_pathLinks[ d, dp ]: k = l } 1 > 0 } demandPath_flow[ d, dp ];
 
minimize maxLinkOverload:
  z;


problem dap:
  maxLinkOverload,
   
  demandPath_flow, z,  
  demand_satisfaction_constraint, capacity_constraint
;
	

