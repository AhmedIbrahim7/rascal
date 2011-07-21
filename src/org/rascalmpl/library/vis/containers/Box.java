/*******************************************************************************
 * Copyright (c) 2009-2011 CWI
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:

 *   * Paul Klint - Paul.Klint@cwi.nl - CWI
*******************************************************************************/
package org.rascalmpl.library.vis.containers;

import org.rascalmpl.library.vis.Figure;
import org.rascalmpl.library.vis.IFigureApplet;
import org.rascalmpl.library.vis.graphics.GraphicsContext;
import org.rascalmpl.library.vis.properties.PropertyManager;

/**
 * Rectangular box that can act as container
 * 
 * @author paulk
 *
 */
public class Box extends Container {

	public Box(IFigureApplet fpa, Figure inner, PropertyManager properties) {
		super(fpa, inner, properties);
	}

	@Override
	void drawContainer(GraphicsContext gc){
		double lw = getLineWidthProperty();
		gc.rect(getLeft()-lw, getTop()-lw, size.getWidth() + lw, size.getHeight() + lw);
	}
	
	@Override
	String containerName(){
		return "box";
	}
}
