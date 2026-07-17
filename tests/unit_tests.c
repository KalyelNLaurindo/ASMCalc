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

struct complex {
    double real;
    double imag;
};

struct fraction {
    int num;
    int den;
};

extern void math_complex_add(struct complex *res, const struct complex *a, const struct complex *b);
extern void math_complex_sub(struct complex *res, const struct complex *a, const struct complex *b);
extern void math_complex_mul(struct complex *res, const struct complex *a, const struct complex *b);
extern void math_complex_div(struct complex *res, const struct complex *a, const struct complex *b);

extern int math_gcd(int a, int b);
extern void math_fraction_simplify(struct fraction *f);
extern void math_fraction_add(struct fraction *res, const struct fraction *a, const struct fraction *b);
extern void math_fraction_sub(struct fraction *res, const struct fraction *a, const struct fraction *b);
extern void math_fraction_mul(struct fraction *res, const struct fraction *a, const struct fraction *b);
extern void math_fraction_div(struct fraction *res, const struct fraction *a, const struct fraction *b);

extern int parse_complex(const char *str, double *out_real, double *out_imag);
extern void format_complex(double real, double imag, char *buffer);
extern int parse_fraction(const char *str, int *out_num, int *out_den);
extern void format_fraction(int num, int den, char *buffer);


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
    // Negative bases with integer exponent
    assert_double(test_call_with_preservation_check(math_pow, -2.0, 3.0, "math_pow"), -8.0);
    assert_double(test_call_with_preservation_check(math_pow, -2.0, 4.0, "math_pow"), 16.0);
    assert_double(test_call_with_preservation_check(math_pow, -2.0, -3.0, "math_pow"), -0.125);
    // Negative bases with fractional exponent (NaN check)
    assert(isnan(test_call_with_preservation_check(math_pow, -4.0, 0.5, "math_pow")));
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
    
    // Multiple consecutive unary operators
    assert(atof_conv("  - -5.5", &val) == 0);
    assert_double(val, 5.5);
    assert(atof_conv("-+-3", &val) == 0);
    assert_double(val, 3.0);
    assert(atof_conv(" + - - 3.25", &val) == 0);
    assert_double(val, 3.25);
    
    assert(atof_conv("abc", &val) == -1);
    assert(atof_conv("12.3.4", &val) == -1);
    printf("atof_conv passed.\n\n");

    printf("Testing ftoa_conv...\n");
    char buf[64];
    ftoa_conv(123.45, buf);
    assert(strcmp(buf, "123.45") == 0);
    
    ftoa_conv(-0.0125, buf);
    assert(strcmp(buf, "-0.01") == 0);
    
    // Negative zero formatting check
    ftoa_conv(-0.0, buf);
    assert(strcmp(buf, "0.00") == 0);
    printf("ftoa_conv passed.\n\n");

    // ----------------------------------------------------
    // 8. Test complex numbers (TSK-11)
    // ----------------------------------------------------
    printf("Testing complex numbers...\n");
    struct complex c1 = { 3.0, 4.0 };   // 3 + 4i
    struct complex c2 = { 1.0, -2.0 };  // 1 - 2i
    struct complex cres;
    
    math_complex_add(&cres, &c1, &c2);
    assert_double(cres.real, 4.0);
    assert_double(cres.imag, 2.0);
    
    math_complex_sub(&cres, &c1, &c2);
    assert_double(cres.real, 2.0);
    assert_double(cres.imag, 6.0);
    
    math_complex_mul(&cres, &c1, &c2);
    // (3+4i)*(1-2i) = (3*1 - 4*-2) + (3*-2 + 4*1)i = (3 + 8) + (-6 + 4)i = 11 - 2i
    assert_double(cres.real, 11.0);
    assert_double(cres.imag, -2.0);
    
    math_complex_div(&cres, &c1, &c2);
    // (3+4i)/(1-2i) = [(3*1 + 4*-2)/5] + [(4*1 - 3*-2)/5]i = [(3 - 8)/5] + [(4 + 6)/5]i = -5/5 + 10/5 i = -1 + 2i
    assert_double(cres.real, -1.0);
    assert_double(cres.imag, 2.0);
    
    // Test complex parsing
    double cr = 0, ci = 0;
    assert(parse_complex("3.5 + 2.5i", &cr, &ci) == 0);
    assert_double(cr, 3.5);
    assert_double(ci, 2.5);
    
    assert(parse_complex("  -1.2-i", &cr, &ci) == 0);
    assert_double(cr, -1.2);
    assert_double(ci, -1.0);
    
    assert(parse_complex("i", &cr, &ci) == 0);
    assert_double(cr, 0.0);
    assert_double(ci, 1.0);
    
    assert(parse_complex("-i", &cr, &ci) == 0);
    assert_double(cr, 0.0);
    assert_double(ci, -1.0);

    // Test complex formatting
    char cbuf[64];
    format_complex(3.5, 2.0, cbuf);
    assert(strcmp(cbuf, "3.50 + 2.00i") == 0);
    format_complex(1.5, -4.25, cbuf);
    assert(strcmp(cbuf, "1.50 - 4.25i") == 0);
    printf("complex numbers passed.\n\n");

    // ----------------------------------------------------
    // 9. Test fractions (TSK-11)
    // ----------------------------------------------------
    printf("Testing fraction math...\n");
    struct fraction f1 = { 1, 3 };   // 1/3
    struct fraction f2 = { 2, 5 };   // 2/5
    struct fraction fres;
    
    math_fraction_add(&fres, &f1, &f2); // 1/3 + 2/5 = 11/15
    assert(fres.num == 11);
    assert(fres.den == 15);
    
    math_fraction_sub(&fres, &f1, &f2); // 1/3 - 2/5 = -1/15
    assert(fres.num == -1);
    assert(fres.den == 15);
    
    math_fraction_mul(&fres, &f1, &f2); // 1/3 * 2/5 = 2/15
    assert(fres.num == 2);
    assert(fres.den == 15);
    
    math_fraction_div(&fres, &f1, &f2); // (1/3) / (2/5) = 5/6
    assert(fres.num == 5);
    assert(fres.den == 6);
    
    // Fraction simplification
    struct fraction f3 = { -4, -8 }; // -4/-8 -> 1/2
    math_fraction_simplify(&f3);
    assert(f3.num == 1);
    assert(f3.den == 2);
    
    // Fraction parsing
    int fn = 0, fd = 0;
    assert(parse_fraction("3/4", &fn, &fd) == 0);
    assert(fn == 3);
    assert(fd == 4);
    
    assert(parse_fraction(" -5 ", &fn, &fd) == 0);
    assert(fn == -5);
    assert(fd == 1);
    
    // Fraction formatting
    char fbuf[64];
    format_fraction(3, 4, fbuf);
    assert(strcmp(fbuf, "3/4") == 0);
    format_fraction(-5, 1, fbuf);
    assert(strcmp(fbuf, "-5") == 0);
    printf("fraction math passed.\n\n");


    printf("===================================================\n");
    printf(" ALL FPU TESTS PASSED SUCCESSFULLY (GREEN)\n");
    printf("===================================================\n");

    return 0;
}
