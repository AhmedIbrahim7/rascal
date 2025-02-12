@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Jouke Stoel - stoel@cwi.nl (CWI)}
@doc{
	Synopsis: Parse the response that a SMT solver returns
}

module lang::smtlib2::command::response::Parse

import lang::smtlib2::command::response::Syntax;

import ParseTree;

Response parseResponse(str response) = parse(#start[Response], response).top;
