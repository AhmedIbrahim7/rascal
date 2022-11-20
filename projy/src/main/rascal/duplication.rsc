module duplication
// This module gauges the value and score of Duplication, which is defined as:
// "the percentage of all code that occurs more than once in equal code blocks of at least 6 lines." 
// The implementation should adhere to the following rules: "if a single line is repeated many
//  times, but the lines before and after differ every time, we do not count it as duplicated.
//  If however, a group of 6 lines appears unchanged in more than one place, we count it as duplicated.

import util::Math;
import List;
import volume;
import lang::java::m3::Core;
import lang::java::m3::AST;
import utilities;
import Set;
import String;

//crucial function to obtain list of file locations for any project, adopted from the given GetASTs function
//sample to call: GetLocFiles(|project://smallsql0.21_src|)
list[loc] GetLocFiles(loc projectLocation) {
M3 model = createM3FromMavenProject(projectLocation);
	list[loc] filelocs = [f | f <- files(model.containment), isCompilationUnit(f)];
	return filelocs;
}

// As evident, the methodology by which we compute the total number of lines in a project is a modification of 
// the functions present in volume.rsc
// After obtaining the total lines in a project, we must compute how many of them are duplicated lines (to eventually determine percentage)

// Now we want to determine the amount of duplicated blocks within the project, where we start with blocks of size 6 [6 lines per block] 
// as outlined in the paper. All non-duplicate blocks of size 6 are discarded.
// Following this, we iteratively increment the block size by 1 (to become n+1 or 7 for now) and add these newfound duplicate blocks
// to the list. We continually check for duplicate sub-blocks contained within established duplicate blocks, since once there are no 
// further sub-blocks, it is an indication that no further duplicate blocks are existent.

//The following function computes all the blocks of a certain size within a project's files (referred to as Filelines)
// Sample to call:GetAllBlocksinProj(ValidLinesProject(GetLocFiles(|project://smallsql0.21_src|)),6)
list[list[list[str]]] GetAllBlocksinProj(list[list[str]] Filelines,int BlockSize) {
	AllBlocks = [];
	while (size(Filelines) >= BlockSize && !isEmpty(Filelines)) { //While the file's lines are larger than a single block's size and non-empty
		AllBlocks += [take(BlockSize, Filelines)];                // Add a block size's worth of lines to the list of blocks
        Filelines = drop(1, Filelines);                           // Eliminate one line from the file's lines and repeat the process to compute all possible blocks
	}
	return AllBlocks;
}
// sample implementation of the above function for blocksize 3 and filelines==7: (1-3),(2-4),(3-5),(4-6),(5-7)
// After dropping 5, the remaining filelines are only 2, therefore the loop breaks since (filelines size < block size)

// Now we are interested in computing all the numbers of duplicated blocks following iterative increments and checking for sub-blocks
// Sample to call: GetDuplicateBlocks(ValidLinesProject(GetLocFiles(|project://smallsql0.21_src|)))

// Sample to call: GetDuplBlocks(GetAllBlocksinProj(ValidLinesProject(GetLocFiles(|project://smallsql0.21_src|)),6))
map[list[list[str]], int] GetDuplBlocks(list[list[list[str]]] AllBlocks) {
    DupeBlockList = ();
		// the DupeBlockList is a map with keys of duplicate blocks and values of their respective frequencies
        // The following routine is essentially the core of the duplication metric, as it detects any sub-blocks
        // and deletes them in order to obtain an accurate result of the number of duplicate blocks in a project. 
        // for example, if there's a duplicate block of size 6 contained in a duplicate block of size 9, the initial
        // duplicate block is now rendered a sub-block and must be deleted. The iterations halt once there are no new sub-blocks
    list[list[list[str]]] blocklist =[];
    for (block <- AllBlocks){
        blocklist +=GetAllBlocksinProj(block, 3);
    }
    DupeBlocksandOccurrs = distribution(blocklist);
    DupeBlockList = (dupeblock : DupeBlocksandOccurrs[dupeblock] | dupeblock <- DupeBlocksandOccurrs, DupeBlocksandOccurrs[dupeblock] >= 2);
    return DupeBlockList;
}

// Get the total number of lines which are duplicated, calculated by multiplying the duplicate blocks' sizes by their amount of occurrences
// alt: GetDupeLines(GetDuplBlocks(GetAllBlocksinProj(ValidLinesProject(GetLocFiles(|project://smallsql0.21_src|)),6)))
int GetDupeLines(map[list[list[str]], int] DupeBlocks) {
    int TotalDupeLines=0;
    for (block <- DupeBlocks){
        TotalDupeLines+=(DupeBlocks[block] * size(block));
    }
    return TotalDupeLines;
}
// function to compute the duplication score in accordance to its percentage
str DupeRank(real val) {
	if (val < 3) {
        return "++";
    } else if (val < 5) {
        return "+";
    } else if (val < 10) {
        return "o";
    } else if (val < 20) {
        return "-";
    } else {
    	return "--";
	}
}
//Sample to call: getDuplicationRankAndValue(|project://smallsql0.21_src|)
tuple[real, str] getDuplicationRankAndValue(loc projectLocation) {
  int DuplicateLines = GetDupeLines(GetDuplBlocks(GetAllBlocksinProj(ValidLinesProject(GetLocFiles(projectLocation)),6))); 
  int TotalValidLines = VolumeChecker(GetLocFiles(projectLocation));
  real duplicationValue=precision(((toReal(DuplicateLines)/TotalValidLines)*100),3);
  str duplicationRank=DupeRank(duplicationValue);
  tuple[real, str] result = <duplicationValue, duplicationRank>;
  return result;
}