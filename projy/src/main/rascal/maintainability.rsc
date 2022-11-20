module maintainability

import Set;
import util::Math;
import utilities;

// A system-level score is derived for each sub-characteristic by taking a weighted average of the scores of relevant code properties. 
// By default, all weights are equal. (See the SIG paper page 37 for more info)

// Method calculates the Maintainability Rating according to the SIG paper (page 37)
str getMaintainabilityRating(str analysabilityStr, str changeabilityStr, str testabilityStr) {
  int analysabilityInt = convertRankStrToInt(analysabilityStr);
  int changeabilityInt = convertRankStrToInt(changeabilityStr);
  int testabiltiyInt = convertRankStrToInt(testabilityStr);

	int resultInt = round((toReal(analysabilityInt) + toReal(changeabilityInt) + toReal(testabiltiyInt)) / 3);
  str resultStr = convertRankIntToStr(resultInt);

  return resultStr;
}

// Method calculates the Analysability Rating according to the SIG paper (page 37)
str getAnalysabilityRating(str unitSizeRankStr, str volumeRankStr, str duplicationRankStr) {
  int unitSizeRankInt = convertRankStrToInt(unitSizeRankStr);
  int volumeRankInt = convertRankStrToInt(volumeRankStr);
  int duplicationRankInt = convertRankStrToInt(duplicationRankStr);

	int resultInt = round((toReal(unitSizeRankInt) + toReal(volumeRankInt) + toReal(duplicationRankInt)) / 3);
  str resultStr = convertRankIntToStr(resultInt);

  return resultStr;
}

// Method calculates the Changeability Rating according to the SIG paper (page 37)
str getChangeabilityRating(str duplicationRankStr, str complexityRankStr) {
  int complexityRankInt = convertRankStrToInt(complexityRankStr);
  int duplicationRankInt = convertRankStrToInt(duplicationRankStr);

	int resultInt = round((toReal(duplicationRankInt) + toReal(complexityRankInt)) / 2);
  str resultStr = convertRankIntToStr(resultInt);

  return resultStr;
}

// Method calculates the Testability Rating according to the SIG paper (page 37)
str getTestabilityRating(str unitSizeRankStr, str complexityRankStr) {
  int unitSizeRankInt = convertRankStrToInt(unitSizeRankStr);
  int complexityRankInt = convertRankStrToInt(complexityRankStr);

	int resultInt = round((toReal(unitSizeRankInt) + toReal(complexityRankInt)) / 2);
  str resultStr = convertRankIntToStr(resultInt);

  return resultStr;
}