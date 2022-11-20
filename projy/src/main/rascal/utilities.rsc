module utilities

import lang::java::m3::Core;
import lang::java::m3::AST;

// Project locations
public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;

// Ranks (As strings described in the SIG paper)
public str RANK_VERY_HIGH = "++";
public str RANK_HIGH = "+";
public str RANK_NEUTRAL = "o";
public str RANK_LOW = "-";
public str RANK_VERY_LOW = "--";

// Ranks in numbers (Used to better compare the values)
public int NUM_RANK_VERY_HIGH = 1;
public int NUM_RANK_HIGH = 2;
public int NUM_RANK_NEUTRAL = 3;
public int NUM_RANK_LOW = 4;
public int NUM_RANK_VERY_LOW = 5;

// Risk evaluatons
public str EVALUATION_VERY_HIGH_RISK = "Very High Risk";
public str EVALUATION_HIGH_RISK = "High Risk";
public str EVALUATION_MODERATE_RISK = "Moderate Risk";
public str EVALUATION_WITHOUT_MUCH_RISK = "Without Much Risk";

// Get AST for a project location and return a list of Declaration type (provided by lectures)
list[Declaration] getASTs(loc projectLocation) {
  M3 model = createM3FromMavenProject(projectLocation);
  list[Declaration] asts = [createAstFromFile(f, true)
    | f <- files(model.containment), isCompilationUnit(f)];
  
  return asts;
}

// Method takes one parameter which is the complexity rank as a string.
// Returns the rank converted to the corresponding integer value.
int convertRankStrToInt(str rank) {
  if (rank == RANK_VERY_HIGH) {
		return NUM_RANK_VERY_HIGH;
  } 
  else if (rank == RANK_HIGH) {
		return NUM_RANK_HIGH;
  } 
  else if (rank == RANK_NEUTRAL) {
		return NUM_RANK_NEUTRAL;
  } 
  else if (rank == RANK_LOW) {
		return NUM_RANK_LOW;
  } 
  else  {
		return NUM_RANK_VERY_LOW;
  }
}

// Method takes one parameter which is the complexity rank as an integer.
// Returns the rank converted to the corresponding string value.
str convertRankIntToStr(int rank) {
  if (rank == NUM_RANK_VERY_HIGH) {
		return RANK_VERY_HIGH;
  } else if (rank == NUM_RANK_HIGH) {
		return RANK_HIGH;
  } else if (rank == NUM_RANK_NEUTRAL) {
		return RANK_NEUTRAL;
  } else if (rank == NUM_RANK_LOW) {
		return RANK_LOW;
  } else {
		return RANK_VERY_LOW;
  }
}