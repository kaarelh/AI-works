/* Referee's own distance profile: for each function i of the dump written by independent_full,
   out[i][d] = least size of a function j != i at Hamming distance exactly d (0 if none), d = 0..36.
   Usage: ./independent_profile DUMP OUT        Build: gcc -O3 -fopenmp -o independent_profile independent_profile.c */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int main(int argc, char **argv) {
    if (argc < 3) return 2;
    FILE *f = fopen(argv[1], "rb");
    int32_t n;
    if (fread(&n, 4, 1, f) != 1) return 1;
    uint8_t *rec = malloc((size_t)n * 37);
    if (fread(rec, 37, n, f) != (size_t)n) return 1;
    fclose(f);
    uint8_t *out = calloc((size_t)n * 37, 1);
    #pragma omp parallel for schedule(dynamic, 64)
    for (int i = 0; i < n; i++) {
        const uint8_t *a = rec + (size_t)i * 37;
        uint8_t *o = out + (size_t)i * 37;
        for (int j = 0; j < n; j++) {
            if (j == i) continue;
            const uint8_t *b = rec + (size_t)j * 37;
            int d = 0;
            for (int t = 0; t < 36; t++) d += (a[t] != b[t]);
            uint8_t k = b[36];
            if (o[d] == 0 || k < o[d]) o[d] = k;
        }
    }
    f = fopen(argv[2], "wb");
    fwrite(out, 37, n, f);
    fclose(f);
    return 0;
}
