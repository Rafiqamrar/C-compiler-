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

void pcode_intMult() {
    LOADF(0.0);
    LOADI(0);
    LOADI(0);
    I2F2;
    LOADBP; 
    SHIFT(1);
    STORE;
    LOADBP;
    SHIFT(-2);
    LOAD;
    LOADI(0);
    LTI;
    IFN(False_0);
    LOADBP;
    SHIFT(-2);
    LOAD;
    MINUSI;
    LOADBP; 
    SHIFT(2);
    STORE;
    // la condition 0 est vraie
    GOTO(End_0);
False_0:
    // la condition 0 est fausse
    LOADBP;
    SHIFT(-2);
    LOAD;
    LOADBP; 
    SHIFT(2);
    STORE;
End_0:
//fin de conditionnelle
Loop_1:
    LOADBP; 
    SHIFT(2);
    LOAD;
    LOADI(0);
    GTI;
    IFN(EndLoop_1);
    SAVEBP;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(1);
    LOAD;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(-1);
    LOAD;
    ADDF;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(1);
    STORE;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(2);
    LOAD;
    LOADI(1);
    SUBI;
    LOADBP;
    LOAD; // accessing upper block depth 2
    SHIFT(2);
    STORE;
    RESTOREBP;
    GOTO(Loop_1);
EndLoop_1:
    LOADBP;
    SHIFT(-2);
    LOAD;
    LOADI(0);
    LTI;
    IFN(False_3);
    LOADBP; 
    SHIFT(1);
    LOAD;
    MINUSF;
    LOADBP;
    SHIFT(-3);
    STORE; 
    // la condition 3 est vraie
    GOTO(End_3);
False_3:
    // la condition 3 est fausse
    LOADBP; 
    SHIFT(1);
    LOAD;
    LOADBP;
    SHIFT(-3);
    STORE; 
End_3:
//fin de conditionnelle
}

void pcode_main() {
    LOADF(0.0);
    // Appel de fonction intMult
    // Type de retour: float
    // La fonction intMult retourne une valeur
    LOADI(0);   // RÃ©server de l'espace pour la valeur de retour
    LOADI(4);
    LOADF(2.300000);
    SAVEBP;
    CALL(pcode_intMult);
    RESTOREBP;
    DROP(2);   // Depilement arguments
    LOADBP; 
    SHIFT(1);
    STORE;
}

