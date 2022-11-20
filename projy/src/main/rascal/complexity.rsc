module complexity

import lang::java::m3::Core;
import lang::java::m3::AST;
import utilities;
import unitsize;
import util::Math;


// The method takes two paramaters. The first is the total LOC of the project and the second is list declaration type of the project.
// Returns tuple which consists of an overall complexity rank for a project and a risk profile.
tuple[str, map[str, real]] getProjectComplexityRankAndriskProfile(list[Declaration] asts) {
  map[loc, tuple[int, int]] complexityMap = getcalculatedUnitComplexityMap(asts);
	map[str, int] complexityRiskMap = getComplexityRiskMap(complexityMap);
  int totalLOC = getLOCForComplexityMap(complexityMap);
  map[str, real] riskEvaluationPercentageMap = calculateRiskEvaluationPercentage(complexityRiskMap, totalLOC);
  map[str, str] complexityRankMap = calculateComplexityRankMap(riskEvaluationPercentageMap);
  str projectComplexityRank = findLowesComplexityRank(complexityRankMap);

  tuple[str, map[str, real]] result = <projectComplexityRank, riskEvaluationPercentageMap>;
  return result;
}

// This method take one parameter which a list declaration type.
// The method returns a complexity map which consists of a key (location of each unit) and a value (tuple[complexity of unit, linesOfCode of unit])
map[loc, tuple[int,int]] getcalculatedUnitComplexityMap(list[Declaration] asts) {
    map[loc, tuple[int,int]] complexityMap = ();

    visit(asts){
        case \method(_, _, _, _, Statement statement):
            complexityMap += (statement.src:<calculateUnitComplexity(statement), FindUnitSize(statement.src)>);
        case \constructor(_, _, _, Statement statement):
            complexityMap += (statement.src:<calculateUnitComplexity(statement), FindUnitSize(statement.src)>);
    }

    return complexityMap;
}

// This method takes one parameter which is a complexity map which consists of a key (location of each unit) and a value (tuple[complexity of unit, linesOfCode of unit])
// This method return a map consisting of four different keys (one for each Risk evaluation type). The name of of the risk is the key and the correspanding 
// value is how many lines of code in the project have the risk evaluation.
map[str, int] getComplexityRiskMap(map[loc, tuple[int, int]] unitComplexityMap) {
	map[str, int] complexityRiskMap = ();
  complexityRiskMap[EVALUATION_VERY_HIGH_RISK] = 0;
  complexityRiskMap[EVALUATION_HIGH_RISK] = 0;
  complexityRiskMap[EVALUATION_MODERATE_RISK] = 0;
	complexityRiskMap[EVALUATION_WITHOUT_MUCH_RISK] = 0;
	
	complexityMapKeys = unitComplexityMap<0>;
	for(loc key <- complexityMapKeys){
		tuple[int complexity, int numLines] complexityLOCTuple = unitComplexityMap[key];
		str riskEvaluation = getUnitComplexityEvaluation(complexityLOCTuple.complexity);
		complexityRiskMap[riskEvaluation] += complexityLOCTuple.numLines;
	}

	return complexityRiskMap;
}

// This method takes two parameters. The first is a map consisting of four different keys (one for each Risk evaluation type). 
// The name of of the risk is the key and the correspanding value is how many lines of code in the project have the risk evaluation.
// The second parameter is the total amount of lines of code in the project
// The method returns a map consisting of four keys which is the four types of evaluations (See SIG paper). Each key has a value which is percentage of the total project lines of code.
map[str, real] calculateRiskEvaluationPercentage(map[str, int] complexityRiskMap, int totalProjectLOC){
	map[str, real] riskEvaluationPercentageMap = ();

  riskEvaluationPercentageMap[EVALUATION_VERY_HIGH_RISK] = toReal(complexityRiskMap[EVALUATION_VERY_HIGH_RISK]) / toReal(totalProjectLOC) * 100; 
  riskEvaluationPercentageMap[EVALUATION_HIGH_RISK] = toReal(complexityRiskMap[EVALUATION_HIGH_RISK]) / toReal(totalProjectLOC) * 100;
  riskEvaluationPercentageMap[EVALUATION_MODERATE_RISK] = toReal(complexityRiskMap[EVALUATION_MODERATE_RISK]) / toReal(totalProjectLOC) * 100; 
  riskEvaluationPercentageMap[EVALUATION_WITHOUT_MUCH_RISK] = toReal(complexityRiskMap[EVALUATION_WITHOUT_MUCH_RISK]) / toReal(totalProjectLOC) * 100; 

	return riskEvaluationPercentageMap;
}

// Method takes one parameter which is a map consisting of three keys - one for each risk bracket(moderate, high and very high). 
// Each key has a value which is the percentage of total LOC.
// Returns a map of three keys - one for each risk bracket(moderate, high and very high). Each key has a value which is the rank (string)
map[str, str] calculateComplexityRankMap(map[str, real] riskEvaluationPercentageMap) {
	map[str, str] complexityRankMap = ();

	complexityRankMap[EVALUATION_MODERATE_RISK] = calculateModerateRisk(riskEvaluationPercentageMap[EVALUATION_MODERATE_RISK]);
	complexityRankMap[EVALUATION_HIGH_RISK] = calculateHighRisk(riskEvaluationPercentageMap[EVALUATION_HIGH_RISK]);
	complexityRankMap[EVALUATION_VERY_HIGH_RISK] = calculateVeryHighRisk(riskEvaluationPercentageMap[EVALUATION_VERY_HIGH_RISK]);

	return complexityRankMap;
}

// str calculateRiskProfile(map[str, real] riskEvaluationPercentageMap) {
// 	str rank = "";

// 	return rank;
// }

// The method takes one parameter which is a map of two strings. The key is the risk type (moderate, high or very high) and its corresponding value is rank. 
// Returns an overall complexity rank for a project. 
str findLowesComplexityRank(map[str, str] complexityRankMap) {
  int projectComplexityRank = 0;

  complexityMapKeys = complexityRankMap<0>;
	for(str key <- complexityMapKeys) {
    int numRank = convertRankStrToInt(complexityRankMap[key]);
    if (numRank > projectComplexityRank) {
      projectComplexityRank = numRank;
    }
	}

  return convertRankIntToStr(projectComplexityRank);
}

// Calcualates the a complexity of a unit (method) in a project and returns the complexity (integer)
int calculateUnitComplexity(Statement unit) {
  int result = 0;
  visit (unit) {
    // case \break() : result += 1;
    // case \break(_) : result += 1;
    // case \continue() : result += 1;
    // case \continue(_) : result += 1;
    case \do(_,_) : result += 1;
    // case \empty() : result += 1;
    case \foreach(_,_,_) : result += 1;
    case \for(_,_,_,_) : result += 1;
    case \for(_,_,_) : result += 1;
    case \if(_,_) : result += 1;
    case \if(_,_,_) : result += 1;
    // case \label(_,_) : result += 1;
    // case \return(_) : result += 1;
    // case \return() : result += 1;
    // case \switch(_,_) : result += 1;
    case \case(_) : result += 1;
    case \defaultCase() : result += 1;
    // case \synchronizedStatement(_,_) : result += 1;
    case \throw(_) : result += 1;
    // case \try(_,_) : result += 1;
    // case \try(_,_,_) : result += 1;
    case \catch(_,_) : result += 1;
    // case \declarationStatement(_) : result += 1;
    case \while(_,_) : result += 1;
    // case \expressionStatement(_) : result += 1;
    // case \constructorCall(_,_,_) : result += 1;
    // case \constructorCall(_,_) : result += 1;
    case infix(_,"&&",_) : result+= 1;
    case infix(_,"||",_) : result+= 1;
  } 

  return result;
}

// Method determines what risk evaluation should be returned (string) based on one parameter which is an integer that holds unitComplexity
str getUnitComplexityEvaluation(int complexity) {
	str riskEvaluation = "";
		if(complexity <= 10) {
			riskEvaluation = EVALUATION_WITHOUT_MUCH_RISK;
		} else if (complexity <= 20) {
			riskEvaluation = EVALUATION_MODERATE_RISK;	
		} else if (complexity <= 50) {
			riskEvaluation = EVALUATION_HIGH_RISK;	
		} else {
			riskEvaluation = EVALUATION_VERY_HIGH_RISK;	
		}
	return riskEvaluation;
}

// Method takes one parameter which is the percentage complexity for moderate risk.
// Returns rank as a string corresponding to the complexity percentage.
str calculateModerateRisk(real complexity) {
  if (complexity <= 25.0) {
		return RANK_VERY_HIGH;
  } else if (complexity <= 30.0) {
		return RANK_HIGH;
  } else if (complexity <= 40.0) {
		return RANK_NEUTRAL;
  } else if (complexity <= 50.0) {
		return RANK_LOW;
  } else {
		return RANK_VERY_LOW;
  }
}

// Method takes one parameter which is the percentage complexity for high risk.
// Returns rank as a string corresponding to the complexity percentage.
str calculateHighRisk(real complexity) {
  if (complexity <= 0.0) {
		return RANK_VERY_HIGH;
  } else if (complexity <= 5.0) {
		return RANK_HIGH;
  } else if (complexity <= 10.0) {
		return RANK_NEUTRAL;
  } else if (complexity <= 15.0) {
		return RANK_LOW;
  } else {
		return RANK_VERY_LOW;
  }
}

// Method takes one parameter which is the percentage complexity for very high risk.
// Returns rank as a string corresponding to the complexity percentage.
str calculateVeryHighRisk(real complexity) {
  if (complexity <= 0.0) {
		return RANK_VERY_HIGH;
  } else if (complexity <= 0.0) {
		return RANK_HIGH;
  } else if (complexity <= 0.0) {
		return RANK_NEUTRAL;
  } else if (complexity <= 5.0) {
		return RANK_LOW;
  } else {
		return RANK_VERY_LOW;
  }
}

// Takes one parameter wich is the complexity map and returns the total amount of lines of code in it.
int getLOCForComplexityMap(map[loc, tuple[int, int]] complexityMap){
	int complexityLOC = 0;
	
	locations = complexityMap<0>;
	for(loc key <- locations){
		complexityLOC += FindUnitSize(key);
	}
	return complexityLOC;
}
