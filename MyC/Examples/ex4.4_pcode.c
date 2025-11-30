// PCode Header
   	#include "PCode.h"
   	
   	void pcode_main();
   	void init_glob_var();
   	
   	int main() {
   	init_glob_var();
   	pcode_main();
   	return stack[sp-1].int_value;
   	}
   	

void init_glob_var(){
    LOADI(0);
    LOADI(0);
    LOADI(0);
}

void pcode_main() {
    LOADI(1);
    LOADI(0);
    STORE;
    LOADI(10);
    LOADI(1);
    STORE;
    LOADI(5);
    LOADI(2);
    STORE;
Loop_0:
    LOADI(0);
    LOAD;
    LOADI(1);
    LOAD;
    LTI;
    IFN(EndLoop_0);
    SAVEBP;
    LOADI(2);
    LOAD;
    LOADI(0);
    LOAD;
    GTI;
    IFN(False_2);
    LOADI(2);
    LOAD;
    LOADI(1);
    LOAD;
    ADDI;
    LOADI(2);
    STORE;
    // la condition 2 est vraie
    GOTO(End_2);
False_2:
    // la condition 2 est fausse
    LOADI(2);
    LOAD;
    LOADI(1);
    LOAD;
    SUBI;
    LOADI(2);
    STORE;
End_2:
//fin de conditionnelle
    LOADI(2);
    LOAD;
    RESTOREBP;
    GOTO(Loop_0);
EndLoop_0:
}

