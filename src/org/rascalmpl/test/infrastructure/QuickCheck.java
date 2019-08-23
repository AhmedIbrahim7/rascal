/** 
 * Copyright (c) 2017, Davy Landman, SWAT.engineering 
 * All rights reserved. 
 *  
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met: 
 *  
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
 *  
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
 *  
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */ 
package org.rascalmpl.test.infrastructure;

import java.io.PrintWriter;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Random;
import java.util.function.BiFunction;

import org.rascalmpl.interpreter.control_exceptions.Throw;
import org.rascalmpl.library.experiments.Compiler.RVM.Interpreter.Thrown;

import io.usethesource.vallang.IConstructor;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValue;
import io.usethesource.vallang.IValueFactory;
import io.usethesource.vallang.random.RandomValueGenerator;
import io.usethesource.vallang.random.util.TypeParameterBinder;
import io.usethesource.vallang.type.Type;
import io.usethesource.vallang.type.TypeStore;

public class QuickCheck {

    public static final String TRIES = "tries";
    public static final String MAXDEPTH = "maxDepth";
    public static final String MAXWIDTH = "maxWidth";
    public static final String EXPECT_TAG = "expected";
    public static final String IGNORE_ANNOTATIONS_TAG = "ignoreAnnotations";

    
    public static final TestResult SUCCESS = new TestResult(true, null);

    public static class TestResult {
        protected boolean succeeded;
        protected Throwable thrownException;
        public TestResult(boolean succeeded, Throwable thrownException) {
            this.succeeded = succeeded;
            this.thrownException = thrownException;

        }
        public boolean succeeded() { return succeeded; }
        public void writeMessage(PrintWriter out) { }
        public Throwable thrownException() { return thrownException; }
    }

    private final Random random;
    private final IValueFactory vf;


    public QuickCheck(Random random, IValueFactory vf) {
        this.random = random;
        this.vf = vf;
    }

    public TestResult test(String functionName, Type formals, String expectedException, BiFunction<Type[], IValue[], TestResult> executeTest, TypeStore store, int tries, int maxDepth, int maxWidth, boolean ignoreAnnotations) {
        if (formals.getArity() == 0) {
            tries = 1; // no randomization needed
        }

        Type[] types = new Type[formals.getArity()];
        for (int n = 0; n < formals.getArity(); n++) {
            types[n] = formals.getFieldType(n);
        }

        Map<Type, Type> tpbindings = TypeParameterBinder.bind(formals);
        Type[] actualTypes = new Type[types.length];
        for(int j = 0; j < types.length; j ++) {
            actualTypes[j] = types[j].instantiate(tpbindings);
        }

        IValue[] values = new IValue[formals.getArity()];
        // first we try to break the function
        RandomValueGenerator generator = new RandomValueGenerator(vf, random, maxDepth, maxWidth, !ignoreAnnotations);
        for (int i = 0; i < tries; i++) {
            for (int n = 0; n < values.length; n++) {
                values[n] = generator.generate(types[n], store, tpbindings);
            }
            TestResult result = executeTest.apply(actualTypes, values);

            if (!result.succeeded() || (result.succeeded() && expectedException != null)) {
                Throwable thrownException = result.thrownException();
                if (wasExpectedException(expectedException, thrownException)) {
                    continue;
                }

                // now we try to find a smaller case
                boolean smallerFound = false;
                IValue[] smallerValues = new IValue[formals.getArity()];
                for (int depth = 1; depth < maxDepth && !smallerFound; depth++) {
                    for (int width = 1; width < maxWidth && !smallerFound; width++) {
                        RandomValueGenerator gen = new RandomValueGenerator(vf, random, depth, width, !ignoreAnnotations);
                        for (int j = 0; j < tries && !smallerFound; j++) {
                            for (int n = 0; n < values.length; n++) {
                                smallerValues[n] = gen.generate(types[n], store, tpbindings);
                            }
                            TestResult smallerResult = executeTest.apply(actualTypes, smallerValues);
                            if (!smallerResult.succeeded() || (smallerResult.succeeded() && expectedException != null) ) {
                                Throwable thrownException2 = smallerResult.thrownException();
                                if (!wasExpectedException(expectedException, thrownException2)) {
                                    values = smallerValues;
                                    result = smallerResult;
                                    thrownException = thrownException2;
                                    smallerFound = true;
                                }
                            }
                        }
                    }
                }

                // we have a (hopefully smaller) case, let's report it
                if (thrownException != null && !wasExpectedException(expectedException, thrownException)) {
                    return new UnExpectedExceptionThrownResult(functionName, actualTypes, tpbindings, values, thrownException);
                }
                else if (expectedException != null && thrownException == null) {
                    return new ExceptionNotThrownResult(functionName, actualTypes, tpbindings, values, expectedException);
                }
                else {
                    return new TestFailedResult(functionName, "test returned false", actualTypes, tpbindings, values);
                }
            }
        }
        return SUCCESS;
    }


    protected boolean wasExpectedException(String expectedException, Throwable thrownException) {
        if (thrownException == null && expectedException != null) {
            return false;
        }
        if (thrownException != null && expectedException != null) {
            if (thrownException instanceof Throw || thrownException instanceof Thrown) {
                IValue rascalException = thrownException instanceof Throw  ? ((Throw)thrownException).getException() : ((Thrown)thrownException).getValue(); 
                if (rascalException instanceof IString && ((IString)rascalException).getValue().equals(expectedException)) {
                    return true;
                }
                if (rascalException instanceof IConstructor && ((IConstructor)rascalException).getName().equals(expectedException)) {
                    return true;
                }
            }
            else {
                if (thrownException.getClass().toString().endsWith("." + expectedException)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static class TestFailedResult extends TestResult {
        protected final String functionName;
        protected final IValue[] values;
        protected final Type[] actualTypes;
        protected final Map<Type, Type> typeBindings;
        protected final String msg;

        public TestFailedResult(String functionName, String msg, Type[] actualTypes, Map<Type, Type> typeBindings, IValue[] values) {
            super(false, null);
            this.functionName = functionName;
            this.msg = msg;
            this.actualTypes = actualTypes;
            this.typeBindings = typeBindings;
            this.values = values;

        }

        @Override
        public void writeMessage(PrintWriter out) {
            out.println("Test " + functionName + " failed due to\n\t" + msg + "\n");
            if(typeBindings.size() > 0){
                out.println("Type parameters:");
                for(Entry<Type,Type> ent : typeBindings.entrySet()){
                    out.println("\t" + ent.getKey() + " => " + ent.getValue());
                }
            }
            if (values.length > 0) {
                out.println("Actual parameters:");
                for (int i = 0; i < values.length; i++) {
                    IValue arg = values[i];
                    out.println("\t" + actualTypes[i] + " " + "=>" + arg);
                }
            }
            out.println();
        }
    }

    public class UnExpectedExceptionThrownResult extends TestFailedResult {

        public UnExpectedExceptionThrownResult(String functionName, Type[] actualTypes,
            Map<Type, Type> tpbindings, IValue[] values, Throwable thrownException) {
            super(functionName, "test threw unexpected exception", actualTypes, tpbindings, values);
            this.thrownException = thrownException;
        }

        @Override
        public void writeMessage(PrintWriter out) {
            super.writeMessage(out);
            out.println("Exception:");
            if (thrownException instanceof Throw) {
                out.println(((Throw)thrownException).getMessage());
            }
            else if (thrownException instanceof Thrown) {
                out.println(((Thrown)thrownException).getMessage());  
            }
            else {
                out.println(thrownException.toString());
                thrownException.printStackTrace(out);
            }
        }

    }

    public class ExceptionNotThrownResult extends TestFailedResult {
        public ExceptionNotThrownResult(String functionName, Type[] actualTypes,
            Map<Type, Type> tpbindings, IValue[] values, String expected) {
            super(functionName, "test did not throw '" + expected + "' exception", actualTypes, tpbindings, values);
        }
    }


}
