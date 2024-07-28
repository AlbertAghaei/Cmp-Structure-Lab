/*
 * File:   main.c
 * Author: Sina Radmehr
 * Note: This file works as a test
 * Created on December 9, 2017, 4:14 PM
 */
#include "mcc_generated_files/mcc.h"
#include "mcc_generated_files/lcd.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

// Macros for keypad buttons
#define B12     PORTBbits.RB12
#define B13     PORTBbits.RB13
#define B14     PORTBbits.RB14
#define B15     PORTBbits.RB15
#define MAX_INPUT_LENGTH 50
// Function declarations
char checkKeypad();
void showString(const char *str, int row);
int checkvalidExpression(char *input);
void intToAsciiArray(int num, char* str);
void getInputString();
int parseExpression(int *pos, char *expr, int *error);
int parseTerm(int *pos, char *expr, int *error);
int parseFactor(int *pos, char *expr, int *error);

// Global variables
char inputStr[16];
char resultStr[16];
int result = 0;
int inputLength = 0;

void main(void) {
    // Initialize the device
    SYSTEM_Initialize();
    LCD_Initialize();
    LCDClear();

    ANSELA = 0x0000;
    ANSELB = 0x0000;
    TRISA = 0x0000;
    TRISB = 0xF000;
    PORTB = 0x0000;

    LCDPutCmd(LCD_CURSOR_ON);
    LCDGoto(0, 0);
    LCDPutStr("Please Enter");
    LCDGoto(0, 1);
    LCDPutStr("Your Expression");

    while (1) {
        getInputString();
        LCDClear();
        int error = checkvalidExpression(inputStr);

        if (error == 0) {
            showString(inputStr, 0);
            LCDGoto(0, 1);
            LCDPutStr("Invalid");
        } else {
            intToAsciiArray(result, resultStr);
            showString(inputStr, 0);
            showString(resultStr, 1);
        }

        memset(inputStr, 0, sizeof(inputStr));
        memset(resultStr, 0, sizeof(resultStr));
    }
}

// Function to convert integer to ASCII string
void intToAsciiArray(int num, char* str) {
    sprintf(str, "%d", num);
}

// Function to display a string on the LCD
void showString(const char *str, int row) {
    LCDGoto(0, row);
    LCDPutStr(str);
}

// Function to get the input string from the keypad
void getInputString() {
    char input = ' ';
    inputLength = 0;
    while (input != '=') {
        input = checkKeypad();
        __delay_ms(100);
        if (input != '=' && input != 'e') {
            inputStr[inputLength++] = input;
        } else if (input == 'e' && inputLength > 0) {
            inputStr[--inputLength] = '\0';
        }
        LCDClear();
        showString(inputStr, 0);
    }
    inputStr[inputLength] = '\0';
}

// Function to evaluate the expression
int checkvalidExpression(char *expr) {
    if (!expr || !*expr) {
        return 0;
    }
    int pos = 0;
    int error = 0;
    result = parseExpression(&pos, expr, &error);
    return (error == 0 && expr[pos] == '\0') ? 1 : 0;
}

// Function to parse an expression


int parseExpression(int *pos, char *expr, int *error) {
    int result = 0;
    int operand;
    char operator;
    // Helper functions inside parseExpression
    int parseFactor(int *pos, char *expr, int *error) {
        int result;
        if (expr[*pos] == '(') {
            (*pos)++;
            result = parseExpression(pos, expr, error);
            if (*error) return 0;
            if (expr[*pos] == ')') {
                (*pos)++;
                return result;
            } else {
                *error = 1; // Missing closing parenthesis
                return 0;
            }
        } else if (isdigit(expr[*pos])) {
            result = 0;
            while (isdigit(expr[*pos])) {
                result = result * 10 + (expr[*pos] - '0');
                (*pos)++;
            }
            return result;
        } else {
            *error = 1; // Invalid character
            return 0;
        }
    }

    int parseTerm(int *pos, char *expr, int *error) {
        int result = parseFactor(pos, expr, error);
        while (expr[*pos] == '*' || expr[*pos] == '/') {
            char operator = expr[*pos];
            (*pos)++;
            int operand = parseFactor(pos, expr, error);
            if (*error) return 0;
            if (operator == '*') {
                result *= operand;
            } else {
                if (operand != 0) {
                    result /= operand;
                } else {
                    *error = 1;  // Division by zero error
                    return 0;
                }
            }
        }
        return result;
    }

    result = parseTerm(pos, expr, error);
    while (expr[*pos] == '+' || expr[*pos] == '-') {
        operator = expr[*pos];
        (*pos)++;
        operand = parseTerm(pos, expr, error);
        if (*error) return 0;
        result = (operator == '+') ? result + operand : result - operand;
    }

    return result;
}

char checkKeypad() {
    while (1) {
        LATA = 0b0001; 
        __delay_ms(10);
        if (B12) return '1'; if (B13) return '4'; if (B14) return '7'; if (B15) return '(';
        LATA = 0b0010; __delay_ms(10);
        if (B12) return '2'; if (B13) return '5'; if (B14) return '8'; if (B15) return '0';
        LATA = 0b0100; __delay_ms(10);
        if (B12) return '3'; if (B13) return '6'; if (B14) return '9'; if (B15) return ')';
        LATA = 0b1000; __delay_ms(10);
        if (B12) return '+'; if (B13) return '*'; if (B14) return '.'; if (B15) return 'a';
        LATA = 0b10000; __delay_ms(10);
        if (B12) return '-'; if (B13) return '/'; if (B14) return 'e'; if (B15) return '=';
    }
}