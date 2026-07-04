#include <cstdio>

int main() {
    long bytes = 0;
    asm volatile("smstart sm" ::: "memory");
    asm volatile("rdsvl %0, #1" : "=r"(bytes) :: "memory");
    asm volatile("smstop sm" ::: "memory");
    std::printf("SME smstart/rdsvl/smstop passed, svl=%ld bytes\n", bytes);
    return 0;
}
