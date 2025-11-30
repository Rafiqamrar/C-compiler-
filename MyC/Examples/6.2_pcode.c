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
}

void pcode_main() {
    LOADI(0);
    LOADI(3);
    LOADI(0);
    STORE;
    SAVEBP;
    LOADI(0);
    LOADI(4);
    LOADBP; 
    SHIFT(1);
    STORE;
    LOADBP; 
    SHIFT(1);
    LOAD;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(1);
    STORE;
    RESTOREBP;
    LOADBP; 
    SHIFT(1);
    LOAD;
}

