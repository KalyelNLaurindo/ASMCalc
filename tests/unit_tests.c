/* ==============================================================================
 *                      ASMCalc - Unit Test Harness
 * ==============================================================================
 * Author: Kalyel N. Laurindo / Software Engineer
 * Date: 2026-06-17
 * Description: C test harness for asserting ASMCalc assembly math subroutines.
 *              Includes standard math validations and strict register preservation checks.
 * ==============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

// External assembly functions (cdecl convention)
extern int math_add(int a, int b);
extern int math_sub(int a, int b);
extern int math_imul(int a, int b);
extern int math_idiv(int a, int b);

// Static variables to save/restore registers. Using static variables ensures 
// GCC generates absolute memory relocations rather than ESP-relative offsets,
// preventing stack layout mismatch bugs inside the inline assembly block.
static int saved_ebx;
static int saved_esi;
static int saved_edi;
static int post_ebx;
static int post_esi;
static int post_edi;

// Helper function to test register preservation (EBX, ESI, EDI)
int test_call_with_preservation_check(int (*func)(int, int), int a, int b, const char* func_name) {
    int result = 0;
    
    // Explicitly mapping:
    // a -> EAX ("a")
    // b -> ECX ("c")
    // func -> EDX ("d")
    // This guarantees that GCC will not assign EBX, ESI, or EDI for these inputs,
    // avoiding register corruption segfaults when we overwrite them with test patterns.
    asm volatile (
        // Save current GCC registers to absolute static locations
        "movl %%ebx, %[s_ebx]\n\t"
        "movl %%esi, %[s_esi]\n\t"
        "movl %%edi, %[s_edi]\n\t"
        
        // Load test patterns
        "movl $0x11111111, %%ebx\n\t"
        "movl $0x22222222, %%esi\n\t"
        "movl $0x33333333, %%edi\n\t"
        
        // Push arguments (b then a for cdecl stack order)
        "pushl %%ecx\n\t"
        "pushl %%eax\n\t"
        
        // Call function pointer (stored in EDX)
        "call *%%edx\n\t"
        "addl $8, %%esp\n\t"
        
        // Save post-call values
        "movl %%ebx, %[p_ebx]\n\t"
        "movl %%esi, %[p_esi]\n\t"
        "movl %%edi, %[p_edi]\n\t"
        
        // Restore original GCC registers from static locations
        "movl %[s_ebx], %%ebx\n\t"
        "movl %[s_esi], %%esi\n\t"
        "movl %[s_edi], %%edi\n\t"
        
        // Move return value
        "movl %%eax, %[res]\n"
        
        : [res] "=r" (result),
          [s_ebx] "=m" (saved_ebx), [s_esi] "=m" (saved_esi), [s_edi] "=m" (saved_edi),
          [p_ebx] "=m" (post_ebx), [p_esi] "=m" (post_esi), [p_edi] "=m" (post_edi)
        : [a] "a" (a), [b] "c" (b), [func] "d" (func)
        : "memory"
    );
    
    if (post_ebx != 0x11111111 || post_esi != 0x22222222 || post_edi != 0x33333333) {
        fprintf(stderr, "FAIL: Register preservation check failed in %s!\n", func_name);
        fprintf(stderr, "  EBX: 0x%08X (Expected: 0x11111111)\n", post_ebx);
        fprintf(stderr, "  ESI: 0x%08X (Expected: 0x22222222)\n", post_esi);
        fprintf(stderr, "  EDI: 0x%08X (Expected: 0x33333333)\n", post_edi);
        exit(1);
    }
    
    return result;
}

int main() {
    setvbuf(stdout, NULL, _IONBF, 0);

    printf("Starting ASMCalc Unit Tests...\n\n");

    // ----------------------------------------------------
    // 1. Test addition (math_add)
    // ----------------------------------------------------
    printf("Testing math_add...\n");
    assert(test_call_with_preservation_check(math_add, 5, 3, "math_add") == 8);
    assert(test_call_with_preservation_check(math_add, -5, -3, "math_add") == -8);
    assert(test_call_with_preservation_check(math_add, 0, 0, "math_add") == 0);
    assert(test_call_with_preservation_check(math_add, 2147483640, 7, "math_add") == 2147483647); // INT_MAX boundary
    printf("math_add passed.\n\n");

    // ----------------------------------------------------
    // 2. Test subtraction (math_sub)
    // ----------------------------------------------------
    printf("Testing math_sub...\n");
    assert(test_call_with_preservation_check(math_sub, 10, 4, "math_sub") == 6);
    assert(test_call_with_preservation_check(math_sub, 5, 10, "math_sub") == -5);
    assert(test_call_with_preservation_check(math_sub, -5, -10, "math_sub") == 5);
    assert(test_call_with_preservation_check(math_sub, -2147483647, 1, "math_sub") == -2147483648); // INT_MIN boundary
    printf("math_sub passed.\n\n");

    // ----------------------------------------------------
    // 3. Test multiplication (math_imul)
    // ----------------------------------------------------
    printf("Testing math_imul...\n");
    assert(test_call_with_preservation_check(math_imul, 3, 4, "math_imul") == 12);
    assert(test_call_with_preservation_check(math_imul, -3, 4, "math_imul") == -12);
    assert(test_call_with_preservation_check(math_imul, -3, -4, "math_imul") == 12);
    assert(test_call_with_preservation_check(math_imul, 100, 0, "math_imul") == 0);
    printf("math_imul passed.\n\n");

    // ----------------------------------------------------
    // 4. Test division (math_idiv)
    // ----------------------------------------------------
    printf("Testing math_idiv...\n");
    assert(test_call_with_preservation_check(math_idiv, 12, 3, "math_idiv") == 4);
    assert(test_call_with_preservation_check(math_idiv, -12, 3, "math_idiv") == -4);
    assert(test_call_with_preservation_check(math_idiv, 12, -3, "math_idiv") == -4);
    assert(test_call_with_preservation_check(math_idiv, 0, 5, "math_idiv") == 0);
    
    // Safety guard test: Division by zero should return -1
    assert(test_call_with_preservation_check(math_idiv, 10, 0, "math_idiv") == -1);
    printf("math_idiv passed.\n\n");

    printf("===================================================\n");
    printf(" ALL TESTS PASSED SUCCESSFULLY (GREEN)\n");
    printf("===================================================\n");

    return 0;
}
