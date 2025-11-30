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
    LOADI(2);
    LOAD;
    LOADI(1);
    LOAD;
    ADDI;
    LOADI(2);
    STORE;
    GOTO(Loop_0);
EndLoop_0:
    LOADI(2);
    LOAD;
}

