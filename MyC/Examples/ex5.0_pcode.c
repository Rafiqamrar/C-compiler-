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
}

void pcode_main() {
    LOADI(0);
    LOADI(0);
    LOADI(0);
    LOADI(10);
    LOADBP; 
    SHIFT(1);
    STORE;
    LOADI(0);
    LOADBP; 
    SHIFT(2);
    STORE;
    LOADBP; 
    SHIFT(1);
    LOAD;
    LOADI(5);
    GTI;
    IFT(Ltrue_0);
    LOADBP; 
    SHIFT(1);
    LOAD;
    LOADBP; 
    SHIFT(2);
    LOAD;
    GTI;
    IFN(Lfalse_0);
Ltrue_0:
    LOADI(1);
    GOTO(Lend_0);
Lfalse_0:
    LOADI(0);
Lend_0:
    LOADBP; 
    SHIFT(3);
    STORE;
}

