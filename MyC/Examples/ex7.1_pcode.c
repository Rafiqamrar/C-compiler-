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

void pcode_one() {
    LOADI(1);
}

void pcode_main() {
    // Appel de fonction one
    // Type de retour: void
    // La fonction one est de type void
    SAVEBP;
    CALL(pcode_one);
    RESTOREBP;
}

