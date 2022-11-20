module volume

/* This model aims to gauge the 'volume' metric of software code by computing the LoC (lines of code), 
 * as outlined in 'A Practical Model for Measuring Maintainability', section B.1. 
 * The emphasis is on counting every single source code line except for comments and blank lines. 
 */

import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;
import String;

 /* 
 * The LineCounter function returns the number of lines within a source code file, making use of the 
 * readFileLines function present within Rascal's IO module inside the Standard Library. Its synopsis (copied from the library):
 * "Read the contents of a file location and return it as a list of strings."
 * Implementation(from the library): list[str] readFileLines(loc file, str charset=DEFAULT_CHARSET) throws PathNotFound, IO
 */

// sample to call: LineCounter(|java+compilationUnit:///src/smallsql/database/CreateFile.java|)
int LineCounter(loc fileloc) {
	int lines=0;

	for (str codeline <- readFileLines(fileloc)){
 	/* 
	 We will be making use of the built-in 'trim' function {str trim(str s)} within the String module in the Rascal Standard Library
 	 Its synopsis: "Returns string with leading and trailing whitespace removed." This aids us greatly as it mitigates confusion arising
 	 from regex expressions attempting to map values (to check validity) to whitespace, whether it be at the start or end of the string,
	 as well as accounting for nested statements.  
	*/
	str pureline = trim(codeline);
	/*
	 We must deal with several scenarios that would result in a line deduction if the pureline adheres to them, namely:
	 1. A pureline starting with a single line comment (//)
	 2. A pureline starting with a multi line comment initialization (/*)
	 3. A pureline within a multi line comment (starting with *),
	 4. A pureline culminating with the multi line ending (* /) 
	 5. A pureline possessing a newline signal (/n) 
	 
	*/
	// regex patterns courtesy of https://www.oreilly.com/library/view/regular-expressions-cookbook/9781449327453/ch07s06.html, 
	// in addition to personal efforts.
	// for single line comments: (^(\/\/+))
	// for multiline comment beginnings (/*): (^(\/\*)+)
	// for multiline comment body lines (*): (^(\*)+)
	// for multiline comment endings: (*/): ((\*\/))
	// for newlines (blank lines): (^\n*$)
	// we can group the aforementioned into one statement to check for the existence of any of them:
	if (/(^(\/\/+))|(^(\/\*)+)|(^(\*)+)|((\*\/))|(^\n*$)/ := pureline){
		continue;
	}
	// Otherwise, the pureline represents a valid source code line that we must take into account:
	else {
		lines+=1; 
	}
	//If the trimmed line adheres to any of the aforementioned regular expressions, then it is rendered void (via the continue statement).
	//Otherwise, the lines counter is incremented. This variable is then returned at the end to reflect the number of valid lines. 
	}
	return lines;
}

//crucial function to obtain list of file locations for any project, adopted from the given GetASTs function
//sample to call: GetLocFiles(|project://smallsql0.21_src|)
list[loc] GetLocFiles(loc projectLoc) {
M3 model = createM3FromMavenProject(projectLoc);
	list[loc] filelocs = [f | f <- files(model.containment), isCompilationUnit(f)];
	return filelocs;
}

// The following function is a re-implementation of the lines counter, but instead returns a list of the valid lines, needed for duplication
// Sample to call: ValidLinesList(|java+compilationUnit:///src/smallsql/database/CreateFile.java|)
list[str] ValidLinesList(loc fileloc) {
	list[str] codeLines = [];
	for (str codeline <- readFileLines(fileloc)){
	str pureline = trim(codeline);
	if (/(^(\/\/+))|(^(\/\*)+)|(^(\*)+)|((\*\/))|(^\n*$)/ := pureline){
		continue;
	}
	else {
		codeLines+=pureline;
	}
	}
	return codeLines;
}

//A function to compute the function above for every file in a project:
//sample to call: ValidLinesProject(GetLocFiles(|project://smallsql0.21_src|))
list[list[str]] ValidLinesProject(list[loc] ProjLoc) {
	return [ValidLinesList(f) | f <- ProjLoc];
}

//main function to obtain the volume metric of a project, by accounting for the LoC of every file (f) within the project
//sample to call: VolumeChecker(GetLocFiles(|project://smallsql0.21_src|))
int VolumeChecker(list[loc] projectloc) {
	int volumecounter=0;
	for (f <- projectloc){
		volumecounter += LineCounter(f);
	}
	return volumecounter;
}


// SIG Score for Volume calculator:
// sample to call: VolumeRank(VolumeChecker(GetLocFiles(|project://smallsql0.21_src|)))
str VolumeRank (int vol){
if (vol < 66000){
	return "++";
}
else if (vol < 246000){
	return "+";
}
else if (vol < 665000){
	return "o";
}
else if (vol < 1310000){
	return "-";
}
else {
	return "--";
}
}
