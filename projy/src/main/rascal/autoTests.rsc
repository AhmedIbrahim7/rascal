module autoTests

import lang::java::m3::Core;
import lang::java::m3::AST;


import complexity;
import volume;
import utilities;
import maintainability;
import unitsize;
import duplication;

// Volume value test where the SmallSql project is the input  
test bool volumeSmallSqlValueTest () {
  // Arrange
  // Act
  int volumeLOC = VolumeChecker(GetLocFiles(smallSqlProject));

  // Assert
  return volumeLOC == 24185;
}

// Volume value test where the hsqldb project is the input  
// test bool volumeHsqldbValueTest () {
//   // Arrange
//   // Act
//   int volumeLOC = VolumeChecker(GetLocFiles(hsqldbProject));

//   // Assert
//   return volumeLOC == 24221;
// }

// Volume rank test where the SmallSql project is the input  
test bool volumeSmallSqlRankTest () {
  // Arrange
  // Act
  str volumeRank = VolumeRank(VolumeChecker(GetLocFiles(smallSqlProject)));

  // Assert
  return volumeRank == "++";
}

// Volume rank test where the hsqldb project is the input  
// test bool volumeHsqldbRankTest () {
//   // Arrange
//   // Act
//   str volumeRank = VolumeRank(VolumeChecker(GetLocFiles(hsqldbProject)));

//   // Assert
//   return volumeRank == "++";;
// }

// Unit Size risk test where the SmallSql project is the input  
test bool unitSizeSmallSqlRiskSpreadTest () {
  // Arrange
  // Act
  list[real] unitSizeRisk = FindUnitSizeRiskSpread(getASTs(smallSqlProject));

  // Assert
  return unitSizeRisk[0] == 80.99378882 && 
    unitSizeRisk[1] == 14.40993789 && 
    unitSizeRisk[2] == 2.484472050 && 
    unitSizeRisk[3] == 2.111801242;
}

// Unit Size risk test where the hsqldb project is the input  
// test bool unitSizeHsqldbRiskSpreadTest () {
//   // Arrange
//   // Act
//   list[real] unitSizeRisk = FindUnitSizeRiskSpread(getASTs(hsqldbProject));

//   // Assert
//   return unitSizeRisk[0] == 80.99378882 && 
//     unitSizeRisk[1] == 14.40993789 && 
//     unitSizeRisk[2] == 2.484472050 && 
//     unitSizeRisk[3] == 2.111801242;
// }

// Unit Size rank test where the SmallSql project is the input  
test bool unitSizeSmallSqlRankTest () {
  // Arrange
  // Act
  str unitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(smallSqlProject)));


  // Assert
  return unitSizeRank == "-";
}

// Unit Size rank test where the hsqldb project is the input  
// test bool unitSizeHsqldbRankTest () {
//   // Arrange
//   // Act
//   str unitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(hsqldbProject)));


//   // Assert
//   return unitSizeRank == "-";
// }

// Unit Complexity Risk and Rank Test where the SmallSql project is the input  
test bool unitComplexitySmallSqlRankAndRiskTest () {
  // Arrange
  list[Declaration] asts = getASTs(smallSqlProject);

  // Act
  tuple[str, map[str, real]] complexityResults = getProjectComplexityRankAndriskProfile(asts);
  str complexityRank = complexityResults[0];
  map[str, real] riskProfile = complexityResults[1];

  // Assert
  return riskProfile[EVALUATION_WITHOUT_MUCH_RISK] == 74.1242722200 && 
    riskProfile[EVALUATION_MODERATE_RISK] == 7.50214756100 && 
    riskProfile[EVALUATION_HIGH_RISK] == 12.3842703100 && 
    riskProfile[EVALUATION_VERY_HIGH_RISK] == 5.98930991700 &&
    complexityRank == "--";
}

// Unit Complexity Risk and Rank Test where the hsqldb project is the input  
// test bool unitComplexityHsqldbRankAndRiskTest () {
//   // Arrange
//   list[Declaration] asts = getASTs(hsqldbProject);

//   // Act
//   tuple[str, map[str, real]] complexityResults = getProjectComplexityRankAndriskProfile(asts);
//   str complexityRank = complexityResults[0];
//   map[str, real] riskProfile = complexityResults[1];

//   // Assert
//   return riskProfile[EVALUATION_WITHOUT_MUCH_RISK] == 74.1242722200 && 
//     riskProfile[EVALUATION_MODERATE_RISK] == 7.50214756100 && 
//     riskProfile[EVALUATION_HIGH_RISK] == 12.3842703100 && 
//     riskProfile[EVALUATION_VERY_HIGH_RISK] == 5.98930991700 &&
//     complexityRank == "--";
// }

// TODO: Needs duplication do be done
// test bool maintainabilitySmallSqlScoreTest() {
//   // Arrange
//   str unitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(smallSqlProject)));
//   str volumeRank = VolumeRank(VolumeChecker(GetLocFiles(smallSqlProject)));

//   list[Declaration] asts = getASTs(smallSqlProject);
//   tuple[str, map[str, real]] smallSqlComplexityResults = getProjectComplexityRankAndriskProfile(asts);
//   str complexityRank = smallSqlComplexityResults[0];

//   tuple[real, str] smallSqlDuplicationRankAndValue =  getDuplicationRankAndValue(smallSqlProject);
//   str duplicationRank = smallSqlDuplicationRankAndValue[1];

//   // Act
//   str analysability = getAnalysabilityRating(unitSizeRank, volumeRank, duplicationRank);
//   str changeability = getChangeabilityRating(duplicationRank, complexityRank);
//   str testability = getTestabilityRating(unitSizeRank, complexityRank); 
//   str maintainability = getMaintainabilityRating(analysability, changeability, testability);

//   // Assert
//   return smallSqlAnalysability == "o" &&
//     smallSqlChangeability == "o" &&
//     smallSqlTestability == "o" &&
//     smallSqlMaintainability == "o";
// }

// TODO: Needs duplication do be done
// test bool maintainabilityHsqldbScoreTest() {
//   // Arrange
//   str unitSizeRank = UnitSizeRank(FindUnitSizeRiskSpread(getASTs(hsqldbProject)));
//   str volumeRank = VolumeRank(VolumeChecker(GetLocFiles(hsqldbProject)));

//   list[Declaration] asts = getASTs(hsqldbProject);
//   tuple[str, map[str, real]] smallSqlComplexityResults = getProjectComplexityRankAndriskProfile(asts);
//   str complexityRank = smallSqlComplexityResults[0];

//   tuple[real, str] smallSqlDuplicationRankAndValue =  getDuplicationRankAndValue(hsqldbProject);
//   str duplicationRank = smallSqlDuplicationRankAndValue[1];

//   // Act
//   str analysability = getAnalysabilityRating(unitSizeRank, volumeRank, duplicationRank);
//   str changeability = getChangeabilityRating(duplicationRank, complexityRank);
//   str testability = getTestabilityRating(unitSizeRank, complexityRank); 
//   str maintainability = getMaintainabilityRating(analysability, changeability, testability);

//   // Assert
//   return smallSqlAnalysability == "o" &&
//     smallSqlChangeability == "o" &&
//     smallSqlTestability == "o" &&
//     smallSqlMaintainability == "o";
// }