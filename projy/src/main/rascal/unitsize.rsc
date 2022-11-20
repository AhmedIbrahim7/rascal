module unitsize

/* This model aims to gauge the 'unitsize' metric of software code by computing the LoC (lines of code) of a singular Java unit (method), 
 * as outlined in 'A Practical Model for Measuring Maintainability', section A. 
 * The emphasis is on counting every single method code line except for comments and blank lines. 
 */

import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;
import String;
import util::Math;
import volume;

// FindUnitSize computes the size of a unit (method in Java) using the same functionality as the LineCounter function established in volume.rsc
int FindUnitSize(loc unitloc) {
	int lines=0;
	for (str codeline <- readFileLines(unitloc)){
    str pureline = trim(codeline);
    if (/(^(\/\/+))|(^(\/\*)+)|(^(\*)+)|((\*\/)$)|(^\n*$)/ := pureline){
		continue;
	}
	else {
		lines+=1;
	}
	}
	return lines;
}
// According to the following source: https://dzone.com/articles/rule-30-%E2%80%93-when-method-class-or , 
// A low, medium, high and very high risk for unit sizes LoC in Java would be 10, 30, 50, 50< (respectively).  
// These risk valuation strings are derived from the 'Model on Measuring Maintainability' paper, section V.C.1.
// Whereby they range from not much, to moderate, high and very high.

// a ranking system that increments the respective indices (return values) of an empty array that would result in the risk spread
int FindUnitRisk(int unitsize) {
    if (unitsize <= 10) {
        return 0;
    } else if (unitsize <= 30) {
        return 1;
    } else if (unitsize <= 50) {
        return 2;
    } else {
        return 3;
    }
}
// This function increments the indices of the risk spread array corresponding to its respective risk level
// sample to call: FindUnitSizeRiskSpread(getASTs(|project://smallsql0.21_src|))
list[real] FindUnitSizeRiskSpread(list[Declaration] asts) {
    list[int]riskarray=[0,0,0,0];
    visit(asts){
        case Declaration unit:\method(_, _, _, _):
            riskarray[FindUnitRisk(FindUnitSize(unit.src))] += 1;

        case Declaration unit:\method(_, _, _, _, _):
            riskarray[FindUnitRisk(FindUnitSize(unit.src))] += 1;

        case Declaration unit:\constructor(_, _, _, _):
            riskarray[FindUnitRisk(FindUnitSize(unit.src))] += 1;
            
        case Declaration unit:\initializer(_):
            riskarray[FindUnitRisk(FindUnitSize(unit.src))] += 1;
    }
    int total = sum(riskarray);
    list[real] results = [(toReal(riskarray[n]*100)/total) | int n <- [0..4]];
    return results;
}
// Function to gauge the unit size's rank based on the two functions above
//sample to call: UnitSizeRank(FindUnitSizeRiskSpread(getASTs(|project://smallsql0.21_src|)))
str UnitSizeRank(list[real] RiskSpread) {
    if (RiskSpread[1] <= 25 && RiskSpread[2] <= 0 && RiskSpread[3] <= 0) {
        return "++";
    } else if (RiskSpread[1] <= 30 && RiskSpread[2] <= 5 && RiskSpread[3] <= 0) {
        return "+";
    } else if (RiskSpread[1] <= 40 && RiskSpread[2] <= 10 && RiskSpread[3] <= 0) {
        return "o";
    } else if (RiskSpread[1] <= 50 && RiskSpread[2] <= 15 && RiskSpread[3] <= 5) {
        return "-";
    } else {
        return "--";
    }
}