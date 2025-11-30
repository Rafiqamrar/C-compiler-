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
    IFN(Lfalse_1);
    LOADBP; 
    SHIFT(1);
    LOAD;
    LOADBP; 
    SHIFT(2);
    LOAD;
    ADDI;
    LOADI(10);
    EQI;
    IFT(Ltrue_2);
    LOADBP; 
    SHIFT(2);
    LOAD;
    LOADI(10);
    GTI;
    IFN(Lfalse_2);
Ltrue_2:
    LOADI(1);
    GOTO(Lend_2);
Lfalse_2:
    LOADI(0);
Lend_2:
    IFT(Ltrue_1);
Lfalse_1:
    LOADI(0);
    GOTO(Lend_1);
Ltrue_1:
    LOADI(1);
Lend_1:
    LOADBP; 
    SHIFT(3);
    STORE;
}

