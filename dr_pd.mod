param maxNode, >= 0, integer;
param module_capacity, >=0, integer;
param failureSituations, >= 0, integer;

set Nodes=1..maxNode;
set Situations=1..failureSituations;

set Links;
param link_nodeA { Links }, in Nodes;
param link_nodeZ { Links }, in Nodes;

param module_cost { Links } default 1;

param number_of_modules { Links }, >= 0, default 1000; # number of modules c(e)

set Demands;
param demand_volume { Demands }, >= 0, default 0; # h(d) = h(d,0) -> czy h(d,s) nas interesuje? - chcemy 100% restoration

param demand_maxPath { Demands }, >= 0, default 0; # number of available paths for each demand
set Demand_pathLinks { d in Demands, dp in 1..demand_maxPath[d] } within Links; # paths as sets of links
set SituationLinks { s in Situations } within Links; # alpha(e,s) - link availability coefficient

param Alpha {l in Links, s in Situations}, >= 0, default 0;

var demandPath_flow { d in Demands, 1..demand_maxPath[d]}, >= 0, integer; # flow x_dp

var number_of_linksModules { Links }, >= 0, integer; # y_e

subject to demand_satisfaction_constraint { d in Demands, s in Situations }:
  sum { dp in 1..demand_maxPath[ d] } demandPath_flow[ d, dp ]                     >= demand_volume[ d ];

subject to demand_satisfaction_constraint_ddap { d in Demands }:
  sum { dp in 1..demand_maxPath[ d] } demandPath_flow[ d, dp ] = demand_volume[ d ];

subject to capacity_constraint_ddap { l in Links }:
  number_of_linksModules[ l ] * module_capacity >= sum { d in Demands, dp in 1..demand_maxPath[ d ]: sum{ k in Demand_pathLinks[ d, dp ]: k = l } 1 > 0 } demandPath_flow[ d, dp ];

minimize minLinksCost:
   sum { l in Links } module_cost[ l ] * number_of_linksModules[ l ]; 

problem drpd:
  minLinksCost,
  demandPath_flow, number_of_linksModules,
  demand_satisfaction_constraint_ddap, capacity_constraint_ddap
;