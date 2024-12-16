#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define hex2dec(c) isalpha(c) ? c - 'a' + 10 : c - '0'

#define special "000000"
#define lui "001111"
#define addi "001000"
#define andi "001100"
#define ori "001101"
#define lb "100000"
#define lh "100001"
#define lw "100011"
#define sb "101000"
#define sh "101001"
#define sw "101011"
#define beq "000100"
#define bne "000101"
#define jal "000011"
#define add "100000"
#define sub "100010"
#define and_ "100100"
#define or_ "100101"
#define slt "101010"
#define sltu "101011"
#define mult "011000"
#define multu "011001"
#define div "011010"
#define divu "011011"
#define mfhi "010000"
#define mflo "010010"
#define mthi "010001"
#define mtlo "010011"
#define jr "001000"
#define nop "000000"

char hex2bin[20][10] = {"0000", "0001", "0010", "0011", 
            "0100", "0101", "0110", "0111",
            "1000", "1001", "1010", "1011", 
            "1100", "1101", "1110", "1111"};
FILE *mips;

void machineCode2Mips(char *instr);
char *mipsFormat(char *binCode);
int intPow(int a, int b);

int main() {
    puts("input the route of MachineCode.txt:");
    char route2MachineCode[1000];
    gets(route2MachineCode);
    FILE *machineCode = fopen(route2MachineCode, "r");
    puts("input the route of mips.asm:");
    char route2Mips[1000];
    gets(route2Mips);    
    mips = fopen(route2Mips, "w");

    char instr[40];
    while (fscanf(machineCode, "%s", instr) != EOF) {
        machineCode2Mips(instr);
    }

    // fclose(machineCode);
    // fclose(mips);
}

void machineCode2Mips(char *instr) {
    for (int i = 7; i >= 0; i--) {
        strncpy(instr + 4 * i, hex2bin[hex2dec(instr[i])], 4);
    }
    instr[32] = '\0';

    char opcode[10], rs[10], rt[10], rd[10], imm26[30], imm16[20], func[10];
    strncpy(opcode, instr, 6);
    opcode[6] = '\0';
    strncpy(rs, instr + 6, 5);
    rs[5] = '\0';
    strncpy(rt, instr + 11, 5);
    rt[5] = '\0';
    strncpy(rd, instr + 16, 5);
    rd[5] = '\0';
    strncpy(imm26, instr + 10, 26);
    imm26[26] = '\0';
    strncpy(imm16, instr + 16, 16);
    imm16[16] = '\0';
    strncpy(func, instr + 26, 6);
    func[6] = '\0';

    if (!strcmp(opcode, special)) {
        if (!strcmp(func, add) || !strcmp(func, sub) || !strcmp(func, and_) || 
        !strcmp(func, or_) || !strcmp(func, slt) || !strcmp(func, sltu)) {
            if (!strcmp(func, add)) {
                fprintf(mips, "add ");
            } else if (!strcmp(func, sub)) {
                fprintf(mips, "sub ");
            } else if (!strcmp(func, and_)) {
                fprintf(mips, "and ");
            } else if (!strcmp(func, or_)) {
                fprintf(mips, "or ");
            } else if (!strcmp(func, slt)) {
                fprintf(mips, "slt ");
            } else if (!strcmp(func, sltu)) {
                fprintf(mips, "sltu ");
            } else {
                // printf("error: no such instruction\n");
            }
            fprintf(mips, "$%s, $%s, $%s\n", 
                mipsFormat(rd), mipsFormat(rs), mipsFormat(rt));
        } else if (!strcmp(func, mult) || !strcmp(func, multu) ||
        !strcmp(func, div) || !strcmp(func, divu)) {
            if (!strcmp(func, mult)) {
                fprintf(mips, "mult ");
            } else if (!strcmp(func, multu)) {
                fprintf(mips, "multu ");
            } else if (!strcmp(func, div)) {
                fprintf(mips, "div ");
            } else if (!strcmp(func, divu)) {
                fprintf(mips, "divu ");
            } else {
                // printf("error: no such instruction\n");
            }
            fprintf(mips, "$%s, $%s\n", mipsFormat(rs), mipsFormat(rt));
        } else if (!strcmp(func, mfhi) || !strcmp(func, mflo)) {
            if (!strcmp(func, mfhi)) {
                fprintf(mips, "mfhi ");
            } else if (!strcmp(func, mflo)) {
                fprintf(mips, "mflo ");
            } else {
                // printf("error: no such instruction\n");
            }
            fprintf(mips, "$%s\n", mipsFormat(rd));
        } else if (!strcmp(func, mthi) || !strcmp(func, mtlo)) {
            if (!strcmp(func, mthi)) {
                fprintf(mips, "mthi ");
            } else if (!strcmp(func, mtlo)) {
                fprintf(mips, "mtlo ");
            } else {
                // printf("error: no such instruction\n");
            }
            fprintf(mips, "$%s\n", mipsFormat(rs));
        } else if (!strcmp(func, jr)) {
            fprintf(mips, "jr $%s\n", mipsFormat(rs));
        } else if (!strcmp(func, nop)) {
            fprintf(mips, "nop\n");
        } else {
            // printf("error: no such instruction\n");
        }
    } else if (!strcmp(opcode, lui)) {
        fprintf(mips, "lui $%s, %s\n", mipsFormat(rt), mipsFormat(imm16));
    } else if (!strcmp(opcode, addi) || !strcmp(opcode, andi) || !strcmp(opcode, ori)) {
        if (!strcmp(opcode, addi)) {
            fprintf(mips, "addi ");
        } else if (!strcmp(opcode, andi)) {
            fprintf(mips, "andi ");
        } else if (!strcmp(opcode, ori)) {
            fprintf(mips, "ori ");
        } else {
            // printf("error: no such instruction\n");
        }
        fprintf(mips, "$%s, $%s, %s\n", mipsFormat(rt), mipsFormat(rs), mipsFormat(imm16));
    } else if (!strcmp(opcode, lb) || !strcmp(opcode, lh) || !strcmp(opcode, lw) ||
    !strcmp(opcode, sb) || !strcmp(opcode, sh) || !strcmp(opcode, sw)) {
        if (!strcmp(opcode, lb)) {
            fprintf(mips, "lb ");
        } else if (!strcmp(opcode, lh)) {
            fprintf(mips, "lh ");
        } else if (!strcmp(opcode, lw)) {
            fprintf(mips, "lw ");
        } else if (!strcmp(opcode, sb)) {
            fprintf(mips, "sb ");
        } else if (!strcmp(opcode, sh)) {
            fprintf(mips, "sh ");
        } else if (!strcmp(opcode, sw)) {
            fprintf(mips, "sw ");
        } else {
            // printf("error: no such instruction\n");
        }
        fprintf(mips, "$%s, %s($%s)\n", 
            mipsFormat(rt), mipsFormat(imm16), mipsFormat(rs));
    } else if (!strcmp(opcode, beq) || !strcmp(opcode, bne)) {
        if (!strcmp(opcode, beq)) {
            fprintf(mips, "beq ");
        } else if (!strcmp(opcode, bne)) {
            fprintf(mips, "bne ");
        } else {
            // printf("error: no such instruction\n");
        }
        fprintf(mips, "$%s, $%s, %s\n", 
            mipsFormat(rs), mipsFormat(rt), mipsFormat(imm16));
    } else if (!strcmp(opcode, jal)) {
        fprintf(mips, "jal %s\n", mipsFormat(imm26));
    } else {
        // printf("error: no such instruction\n");
    }
}

char *mipsFormat(char *binCode) {
    char *ret;
    ret = (char*)malloc(20);
    if (strlen(binCode) == 5) {
        int dec = 0;
        for (int i = 0; i < 5; i++) {
            dec = dec * 2 + (binCode[i] - '0');
        }
        if (dec == 0) {
            strcpy(ret, "zero");
        } else if (dec == 1) {
            strcpy(ret, "at");
        } else if (dec >= 2 && dec <= 3) {
            ret[0] = 'v';
            ret[1] = dec - 2 + '0';
            ret[2] = '\0';
        } else if (dec >= 4 && dec <= 7) {
            ret[0] = 'a';
            ret[1] = dec - 4 + '0';
            ret[2] = '\0';
        } else if (dec >= 8 && dec <= 15) {
            ret[0] = 't';
            ret[1] = dec - 8 + '0';
            ret[2] = '\0';
        } else if (dec >= 16 && dec <= 23) {
            ret[0] = 's';
            ret[1] = dec - 16 + '0';
            ret[2] = '\0';
        } else if (dec >= 24 && dec <= 25) {
            ret[0] = 't';
            ret[1] = dec - 24 + '8';
            ret[2] = '\0';
        } else if (dec >= 26 && dec <= 27) {
            ret[0] = 'k';
            ret[1] = dec - 26 + '0';
            ret[2] = '\0';
        } else if (dec == 28) {
            strcpy(ret, "gp");
        } else if (dec == 29) {
            strcpy(ret, "sp");
        } else if (dec == 30) {
            strcpy(ret, "fp");
        } else if (dec == 31) {
            strcpy(ret, "ra");
        } else {
            // printf("error: 5 bit to reg but dec not in [0, 31]\n");
        }
    } // register
    else if (strlen(binCode) == 16) {
        // int dec = 0;
        // for (int i = 0; i < 16; i++) {
        //     dec = dec * 2 + (binCode[i] - '0');
        // }                   
        // int num = 0;
        // while (dec) {
        //     ret[num] = dec % 10 + '0';
        //     dec /= 10;
        //     num++;
        // }
        // ret[num] = '\0';
        char s[5];
        for (int i = 0; i < 4; i++) {
            s[0] = binCode[4 * i];
            s[1] = binCode[4 * i + 1];
            s[2] = binCode[4 * i + 2];
            s[3] = binCode[4 * i + 3];
            s[4] = '\0';
            for (int j = 0; j < 16; j++) {
                if (!strcmp(s, hex2bin[j])) {
                    if (j < 10) {
                        ret[i] = j + '0';
                    } else {
                        ret[i] = j - 10 + 'a';
                    }
                    break;
                }
            }
        }
        ret[4] = '\0';
        char s0[10] = "0x";
        strcat(s0, ret);
        strcpy(ret, s0);
    } // imm16
    else if (strlen(binCode) == 26) {
        int dec = 0;
        for (int i = 0; i < 26; i++) {
            dec = dec * 2 + (binCode[i] - '0');
            dec /= 10;
        }
        int num = 0;
        while (dec) {
            ret[num] = dec % 10 + '0';
            num++;
        }
        ret[num] = '\0';
    } // imm26
    else {
        // printf("error: no such length binCode\n");
    }
    return ret;
}