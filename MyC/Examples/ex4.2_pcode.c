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
    LOADI(3);
    LOADI(0);
    STORE;
    LOADI(5);
    LOADI(1);
    STORE;
    LOADI(0);
    LOAD;
    IFN(False_0);
    SAVEBP;
    LOADI(1);
    LOAD;
    IFN(False_1);
    LOADI(1);
    LOADI(2);
    STORE;
    // la condition 1 est vraie
    GOTO(End_1);
False_1:
    // la condition 1 est fausse
    LOADI(2);
    LOADI(2);
    STORE;
End_1:
//fin de conditionnelle
    RESTOREBP;
    // la condition 0 est vraie
    GOTO(End_0);
False_0:
    // la condition 0 est fausse
    SAVEBP;
    LOADI(2);
    LOAD;
    IFN(False_2);
    LOADI(3);
    LOADI(2);
    STORE;
    // la condition 2 est vraie
    GOTO(End_2);
False_2:
    // la condition 2 est fausse
    LOADI(4);
    LOADI(2);
    STORE;
End_2:
//fin de conditionnelle
    RESTOREBP;
End_0:
//fin de conditionnelle
    LOADI(2);
    LOAD;
}

