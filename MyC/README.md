# MyC Compiler

A compiler that translates **MyC** source code into **PCode**, a stack-based intermediate representation. Built with **Flex** and **Bison**.

## Features

### Core Compilation
- **Integer & Float Expressions** — Arithmetic operations (`+`, `-`, `*`, `/`) with automatic type promotion (INT → FLOAT)
- **Type System** — Static typing with INT, FLOAT, and VOID types
- **Variables** — Global and local variable declarations with proper memory allocation

### Control Flow
- **Conditionals** — `if` and `if-else` statements
- **Loops** — `while` loops
- **Short-Circuit Evaluation** — Lazy boolean evaluation for `&&`, `||`, `!`

### Functions
- **Typed Functions** — Support for INT, FLOAT, and VOID return types
- **Parameters** — Typed function parameters with automatic conversion
- **Nested Blocks** — Local scoping with block-level variable declarations
- **Recursion** — Full support for recursive function calls

## Project Structure

```
MyC/
├── lang.l                   # Flex lexer specification
├── lang.y                   # Bison parser & code generator
├── Table_des_symboles.c/h   # Symbol table implementation
├── PCode/                   # PCode virtual machine
│   ├── PCode.c
│   └── PCode.h
├── Examples/                # Test programs (.myc) and outputs (_pcode.c)
├── runComp                  # Compilation helper script
└── Makefile
```

## Build

```bash
make
```

This generates the `lang` executable.

## Usage

### Using the helper script (recommended)

```bash
./runComp example
```

Compiles `example.myc` → `example_pcode.c`

### Manual compilation

```bash
./lang < input.myc > output_pcode.c
```

### Running the generated PCode

```bash
cd Examples
gcc -o program example_pcode.c PCode.c
./program
```

## Example

**Input** (`example.myc`):
```c
int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

int main() {
    int result;
    result = factorial(5);
    return result;
}
```

**Output**: Generated PCode with stack operations (`LOADI`, `CALL`, `RET`, etc.)

## Clean

```bash
make clean
```

## Technical Details

- **Symbol Table**: Stack-based structure supporting lexical scoping
- **Label Generation**: Unique labels for control flow jumps
- **Activation Records**: Proper stack frame management for recursive calls
- **Type Coercion**: Automatic INT to FLOAT conversion via `I2F` instructions


