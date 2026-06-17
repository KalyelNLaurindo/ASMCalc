/* ==============================================================================
 *                      ASMCalc - Unit Test Harness (FPU Version)
 * ==============================================================================
 * Author: Kalyel N. Laurindo / Software Engineer
 * Date: 2026-06-17
 * Description: C test harness for asserting ASMCalc assembly double subroutines.
 *              Includes standard FPU math validations and strict register checks.
 * ==============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <math.h>
#include <string.h>

// External assembly functions (cdecl convention returning double in ST(0))
extern double math_add(double a, double b);
extern double math_sub(double a, double b);
extern double math_imul(double a, double b);
extern double math_idiv(double a, double b);
extern double math_mod(double a, double b);
extern double math_pow(double base, double exp);
extern int atof_conv(const char *str, double *out_val);
extern void ftoa_conv(double val, char *buffer);

// Static variables to save/restore registers.
static int saved_ebx;
static int saved_esi;
static int saved_edi;
static int post_ebx;
static int post_esi;
static int post_edi;

// Macro for double precision assertions with small delta tolerance
#define assert_double(actual, expected) assert(fabs((actual) - (expected)) < 0.00001)

// Helper function to test register preservation (EBX, ESI, EDI)
double test_call_with_preservation_check(double (*func)(double, double), double a, double b, const char* func_name) {
    double result = 0;
    
    // Explicitly mapping:
    // &a -> EAX ("a")
    // &b -> ECX ("c")
    // func -> EDX ("d")
    // This allows us to push the 64-bit double values using offset pointer arithmetic
    // in AT&T syntax without compiler double-word formatting issues.
    asm volatile (
        // Save current GCC registers to absolute static locations
        "movl %%ebx, %[s_ebx]\n\t"
        "movl %%esi, %[s_esi]\n\t"
        "movl %%edi, %[s_edi]\n\t"
        
        // Load test patterns
        "movl $0x11111111, %%ebx\n\t"
        "movl $0x22222222, %%esi\n\t"
        "movl $0x33333333, %%edi\n\t"
        
        // Push double b (8 bytes, high then low)
        "pushl 4(%%ecx)\n\t"
        "pushl (%%ecx)\n\t"
        
        // Push double a (8 bytes, high then low)
        "pushl 4(%%eax)\n\t"
        "pushl (%%eax)\n\t"
        
        // Call function pointer (stored in EDX)
        "call *%%edx\n\t"
        "addl $16, %%esp\n\t"
        
        // Save post-call values
        "movl %%ebx, %[p_ebx]\n\t"
        "movl %%esi, %[p_esi]\n\t"
        "movl %%edi, %[p_edi]\n\t"
        
        // Restore original GCC registers from static locations
        "movl %[s_ebx], %%ebx\n\t"
        "movl %[s_esi], %%esi\n\t"
        "movl %[s_edi], %%edi\n\t"
        
        // Move return value from FPU ST(0) to result
        "fstpl %[res]\n"
        
        : [res] "=m" (result),
          [s_ebx] "=m" (saved_ebx), [s_esi] "=m" (saved_esi), [s_edi] "=m" (saved_edi),
          [p_ebx] "=m" (post_ebx), [p_esi] "=m" (post_esi), [p_edi] "=m" (post_edi)
        : [a_ptr] "a" (&a), [b_ptr] "c" (&b), [func] "d" (func)
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

    printf("Starting ASMCalc FPU Unit Tests...\n\n");

    // ----------------------------------------------------
    // 1. Test addition (math_add)
    // ----------------------------------------------------
    printf("Testing math_add...\n");
    assert_double(test_call_with_preservation_check(math_add, 5.5, 3.25, "math_add"), 8.75);
    assert_double(test_call_with_preservation_check(math_add, -5.5, -3.25, "math_add"), -8.75);
    assert_double(test_call_with_preservation_check(math_add, 0.0, 0.0, "math_add"), 0.0);
    printf("math_add passed.\n\n");

    // ----------------------------------------------------
    // 2. Test subtraction (math_sub)
    // ----------------------------------------------------
    printf("Testing math_sub...\n");
    assert_double(test_call_with_preservation_check(math_sub, 10.5, 4.25, "math_sub"), 6.25);
    assert_double(test_call_with_preservation_check(math_sub, 5.0, 10.5, "math_sub"), -5.5);
    printf("math_sub passed.\n\n");

    // ----------------------------------------------------
    // 3. Test multiplication (math_imul)
    // ----------------------------------------------------
    printf("Testing math_imul...\n");
    assert_double(test_call_with_preservation_check(math_imul, 3.5, 2.0, "math_imul"), 7.0);
    assert_double(test_call_with_preservation_check(math_imul, -3.5, 4.0, "math_imul"), -14.0);
    assert_double(test_call_with_preservation_check(math_imul, 100.5, 0.0, "math_imul"), 0.0);
    printf("math_imul passed.\n\n");

    // ----------------------------------------------------
    // 4. Test division (math_idiv)
    // ----------------------------------------------------
    printf("Testing math_idiv...\n");
    assert_double(test_call_with_preservation_check(math_idiv, 12.5, 2.5, "math_idiv"), 5.0);
    assert_double(test_call_with_preservation_check(math_idiv, -12.5, 2.5, "math_idiv"), -5.0);
    
    // Safety check: Div by zero returns NaN. (NaN != NaN is always true, and isnan is available)
    double div_zero_res = test_call_with_preservation_check(math_idiv, 10.0, 0.0, "math_idiv");
    assert(isnan(div_zero_res));
    printf("math_idiv passed.\n\n");

    // ----------------------------------------------------
    // 5. Test modulo (math_mod)
    // ----------------------------------------------------
    printf("Testing math_mod...\n");
    assert_double(test_call_with_preservation_check(math_mod, 5.0, 2.3, "math_mod"), 0.4);
    assert_double(test_call_with_preservation_check(math_mod, 10.5, 5.0, "math_mod"), 0.5);
    
    double mod_zero_res = test_call_with_preservation_check(math_mod, 10.0, 0.0, "math_mod");
    assert(isnan(mod_zero_res));
    printf("math_mod passed.\n\n");

    // ----------------------------------------------------
    // 6. Test power (math_pow)
    // ----------------------------------------------------
    printf("Testing math_pow...\n");
    assert_double(test_call_with_preservation_check(math_pow, 4.0, 0.5, "math_pow"), 2.0);
    assert_double(test_call_with_preservation_check(math_pow, 2.0, -3.0, "math_pow"), 0.125);
    assert_double(test_call_with_preservation_check(math_pow, 5.0, 0.0, "math_pow"), 1.0);
    printf("math_pow passed.\n\n");

    // ----------------------------------------------------
    // 7. Test string conversions (atof_conv / ftoa_conv)
    // ----------------------------------------------------
    printf("Testing atof_conv...\n");
    double val = 0.0;
    assert(atof_conv("123.45", &val) == 0);
    assert_double(val, 123.45);
    
    assert(atof_conv("   -456.78", &val) == 0);
    assert_double(val, -456.78);
    
    assert(atof_conv("abc", &val) == -1);
    assert(atof_conv("12.3.4", &val) == -1);
    printf("atof_conv passed.\n\n");

    printf("Testing ftoa_conv...\n");
    char buf[64];
    ftoa_conv(123.45, buf);
    assert(strcmp(buf, "123.45") == 0);
    
    ftoa_conv(-0.0125, buf);
    assert(strcmp(buf, "-0.01") == 0);
    printf("ftoa_conv passed.\n\n");

    printf("===================================================\n");
    printf(" ALL FPU TESTS PASSED SUCCESSFULLY (GREEN)\n");
    printf("===================================================\n");

    return 0;
}
