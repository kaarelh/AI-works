/* For every function f (row of F, NXY bytes) compute, for each Hamming distance r = 1..NXY,
   the least K(g) over functions g != f at distance exactly r (0 if none).
   Input (stdin, binary): int32 n, int32 nxy, then n*nxy bytes of tables, then n int16 sizes.
   Output (stdout, binary): n*(nxy+1) int16, entry [i][r] as described (entry [i][0] unused). */
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

int main(void) {
    int32_t n, nxy;
    if (fread(&n, 4, 1, stdin) != 1 || fread(&nxy, 4, 1, stdin) != 1) return 1;
    uint8_t *F = malloc((size_t)n * nxy);
    int16_t *K = malloc((size_t)n * 2);
    if (fread(F, 1, (size_t)n * nxy, stdin) != (size_t)n * nxy) return 1;
    if (fread(K, 2, n, stdin) != (size_t)n) return 1;
    int16_t *out = calloc((size_t)n * (nxy + 1), 2);
    #pragma omp parallel for schedule(dynamic, 64)
    for (int i = 0; i < n; i++) {
        const uint8_t *fi = F + (size_t)i * nxy;
        int16_t *o = out + (size_t)i * (nxy + 1);
        for (int j = 0; j < n; j++) {
            if (j == i) continue;
            const uint8_t *fj = F + (size_t)j * nxy;
            int d = 0;
            for (int t = 0; t < nxy; t++) d += (fi[t] != fj[t]);
            if (o[d] == 0 || K[j] < o[d]) o[d] = K[j];
        }
    }
    fwrite(out, 2, (size_t)n * (nxy + 1), stdout);
    return 0;
}
