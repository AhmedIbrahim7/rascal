module Main

import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;

import complexity;
import volume;
import utilities;
import maintainability;
import unitsize;
import duplication;
import autoTests;

void main() {
  // General
  list[Declaration] smallSqlASTs = getASTs(smallSqlProject);
  // list[Declaration] hsqldbASTs = getASTs(hsqldbProject);

  // Volume
  int smallSqlVolumeLOC = VolumeChecker(GetLocFiles(smallSqlProject));
  str smallSqlVolumeRank = VolumeRank(VolumeChecker(GetLocFiles(smallSqlProject)));
  
  // int hsqldbVolumeLOC = VolumeChecker(GetLocFiles(hsqldbProject));
  // str hsqldbVolumeRank = VolumeRank(VolumeChecker(GetLocFiles(hsqldbProject)));
  
  // Unit Size
  str smallSqlUnitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(smallSqlProject)));
  list[real] smallSqlUnitSizRisk = FindUnitSizeRiskSpread(getASTs(smallSqlProject));

  // str hsqldbUnitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(hsqldbProject)));
  // str hsqldbUnitSizRisk = FindUnitSizeRiskSpread(getASTs(hsqldbProject));

  // Unit Complexity
  tuple[str, map[str, real]] smallSqlComplexityResults = getProjectComplexityRankAndriskProfile(smallSqlASTs);
  str smallSqlComplexityRank = smallSqlComplexityResults[0];
  map[str, real] smallSqlRiskProfile = smallSqlComplexityResults[1];

  // tuple[str, map[str, real]] hsqldbComplexityResults = getProjectComplexityRankAndriskProfile(hsqldbASTs);
  // str hsqldbComplexityRank = hsqldbComplexityResults[0];
  // map[str, real] hsqldbRiskEvalutationPercentageMap = hsqldbComplexityResults[1];

  // Duplication
  tuple[real, str] smallSqlDuplicationRankAndValue =  getDuplicationRankAndValue(smallSqlProject);
  real smallSqlDuplicationValue = smallSqlDuplicationRankAndValue[0];
  str smallSqlDuplicationRank = smallSqlDuplicationRankAndValue[1];

  // tuple[real, str] hsqldbDuplicationRankAndRisk =  getDuplicationRankAndValue(hsqldbProject);
  // real hsqldbDuplicationvalue = hsqldbDuplicationRankAndRisk[0];
  // str hsqldbDuplicationRank = hsqldbDuplicationRankAndRisk[1];

  // Maintainability // TODO: Needs duplication do be done
  // str smallSqlAnalysability = getAnalysabilityRating(smallSqlUnitSizeRank, smallSqlVolumeRank, smallSqlDuplicationRank);
  // str smallSqlChangeability = getChangeabilityRating(smallSqlDuplicationRank, smallSqlComplexityRank);
  str smallSqlTestability = getTestabilityRating(smallSqlUnitSizeRank, smallSqlComplexityRank); 
  // str smallSqlMaintainability = getMaintainabilityRating(smallSqlAnalysability, smallSqlChangeability, smallSqlTestability);

  // str hsqldbAnalysability = getAnalysabilityRating(hsqldbUnitSizeRank, hsqldbVolumeRank, hsqldbDuplicationRank); 
  // str hsqldbChangeability = getChangeabilityRating(hsqldbDuplicationRank, hsqldbComplexityRank);
  // str hsqldbTestability = getTestabilityRating(hsqldbUnitSizeRank, hsqldbComplexityRank); 
  // str hsqldbMaintainability = getMaintainabilityRating(hsqldbAnalysability, hsqldbChangeability, hsqldbTestability);

  // Metrics (SmallSql)
  println("========================= SmallSql Project ================================");
  println("--------------------------- METRICS ---------------------------");
  println("Volume Value(LOC): <smallSqlVolumeLOC>");
  println("Volume Rank: <smallSqlVolumeRank>");
  println("Unit Size Rank: <smallSqlUnitSizeRank>");
  println("Unit Complexity Rank: <smallSqlComplexityRank>");
  println("Duplication Value(%): <smallSqlDuplicationValue>");
  println("Duplication Rank: <smallSqlDuplicationRank>");
  

  // Risk Profile (SmallSql)
  println("--------------------------- RISK PROFILE -------------------------------------------------------------------------");
	println("|                     | Without Much Risk |   Moderate Risk   |   High Risk       |   Very High Risk  |");
  println("|   Unit Size         |   <smallSqlUnitSizRisk[0]>     |   <smallSqlUnitSizRisk[1]>     |   <smallSqlUnitSizRisk[2]>     |   <smallSqlUnitSizRisk[3]>     |");
  println("|   Unit Complexity   |   <smallSqlRiskProfile[EVALUATION_WITHOUT_MUCH_RISK]>   |   <smallSqlRiskProfile[EVALUATION_MODERATE_RISK]>   |   <smallSqlRiskProfile[EVALUATION_HIGH_RISK]>   |   <smallSqlRiskProfile[EVALUATION_VERY_HIGH_RISK]>   |");
	println("------------------------------------------------------------------------------------------------------------------");

  // Maintanability (SmallSql)
  // TODO: Needs duplication do be done
  println("--------------------------------------- Maintainability -----------------------------------------------------------");
	println("| System-level Score  |   Rank |");
  // println("| Analyseability      |   <smallSqlAnalysability>   |");
  // println("| Changeability       |   <smallSqlChangeability>   |");
  println("| Testability         |   <smallSqlTestability>   |");
  // println("| Maintainability     |   <smallSqlMaintainability>   |");
	println("--------------------------------------------------------------------------------------------------------------------");

  // Metrics (hsqldb)
  // TODO: just copy paste from smallSql

  // Risk Profile (hsqldb)
  // TODO: just copy paste from smallSql

  // Maintanability (hsqldb)
  // TODO: just copy paste from smallSql

  // Automated Tests
  // Import autoTests;
  // type <:test> in CLI
  // This runs tests for both SmallSql and hsqldb (They are completely the same so for performance can the hsqldb tests be commented out)
}