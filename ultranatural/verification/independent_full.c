/* Referee's independent exhaustive check of the Section 6 enumeration, up to MAXSIZE nodes.
   Shares no code or method with code/enumerate_pr.py: every term of every size is generated
   syntactically (no semantic pruning or deduplication of subterms) and evaluated by direct
   recursion on its syntax tree at the 36 inputs x, y < 6 with a = 0 at top level.

   Terms of size < MAXSIZE are stored as nodes; terms of size MAXSIZE are generated on the fly.

   Output: stdout = text report; file argv[2] = binary dump: int32 n, then n records of
   (36 bytes table in input order i = 6x + y, 1 byte least size).

   Build: gcc -O2 -fopenmp -o independent_full independent_full.c
   Usage: ./independent_full MAXSIZE DUMPFILE */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <omp.h>

enum { OX, OY, OA, OZ, OS, OP, OIT, OIF };
typedef struct { uint8_t op; int32_t c[3]; } Node;

static Node *T;
static long first[16], count_[16];
#define VMAX 31

static int ev(const Node *t, int x, int y, int a) {
    switch (t->op) {
    case OX: return x;
    case OY: return y;
    case OA: return a;
    case OZ: return 0;
    case OS: { int v = ev(T + t->c[0], x, y, a); return v < VMAX ? v + 1 : VMAX; }
    case OP: { int v = ev(T + t->c[0], x, y, a); return v > 0 ? v - 1 : 0; }
    case OIT: {
        int n = ev(T + t->c[0], x, y, a);
        int acc = ev(T + t->c[2], x, y, a);
        const Node *b = T + t->c[1];
        for (int k = 0; k < n; k++) acc = ev(b, x, y, acc);
        return acc;
    }
    default:
        return ev(T + t->c[0], x, y, a) == 0 ? ev(T + t->c[1], x, y, a) : ev(T + t->c[2], x, y, a);
    }
}

/* hash map: 36-byte table -> least size */
typedef struct { uint8_t *keys; uint8_t *val; long cap, n; } Map;
static void map_init(Map *m, long cap) { m->cap = cap; m->n = 0; m->keys = malloc(cap * 36); m->val = calloc(cap, 1); }
static uint64_t hash36(const uint8_t *k) {
    uint64_t h = 1469598103934665603ULL;
    for (int i = 0; i < 36; i++) { h ^= k[i]; h *= 1099511628211ULL; }
    return h ^ (h >> 29);
}
static void map_put(Map *m, const uint8_t *k, int size) {
    long i = hash36(k) % m->cap;
    while (m->val[i]) {
        if (memcmp(m->keys + i * 36, k, 36) == 0) { if (size < m->val[i]) m->val[i] = size; return; }
        if (++i == m->cap) i = 0;
    }
    memcpy(m->keys + i * 36, k, 36); m->val[i] = size; m->n++;
    if (m->n * 2 > m->cap) { fprintf(stderr, "hash table full\n"); exit(1); }
}

static void table_of(const Node *t, uint8_t *tab) {
    for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) tab[6 * x + y] = (uint8_t)ev(t, x, y, 0);
}

static int cmp_rec(const void *a, const void *b) {
    const uint8_t *p = a, *q = b;
    if (p[36] != q[36]) return (int)p[36] - (int)q[36];
    return memcmp(p, q, 36);
}

static int show(const Node *t, char *buf) {
    static const char *nm[] = { "x", "y", "a", "0", "S", "P", "It", "ifz" };
    int n = sprintf(buf, "%s", nm[t->op]);
    int ar = t->op < OS ? 0 : (t->op < OIT ? 1 : 3);
    if (ar) {
        buf[n++] = '(';
        for (int i = 0; i < ar; i++) { if (i) buf[n++] = ','; n += show(T + t->c[i], buf + n); }
        buf[n++] = ')'; buf[n] = 0;
    }
    return n;
}

int main(int argc, char **argv) {
    int N = argc > 1 ? atoi(argv[1]) : 9;
    /* count terms */
    double cnt[16]; cnt[1] = 4;
    for (int s = 2; s <= N; s++) {
        cnt[s] = 2 * cnt[s - 1];
        for (int s1 = 1; s1 <= s - 3; s1++) for (int s2 = 1; s1 + s2 <= s - 2; s2++)
            cnt[s] += 2 * cnt[s1] * cnt[s2] * cnt[s - 1 - s1 - s2];
    }
    long stored = 0;
    for (int s = 1; s < N; s++) stored += (long)cnt[s];
    T = malloc((size_t)(stored + 4) * sizeof(Node));
    long nT = 0;
    first[1] = 0;
    for (int op = OX; op <= OZ; op++) { T[nT].op = op; nT++; }
    count_[1] = 4;
    for (int s = 2; s < N; s++) {
        first[s] = nT;
        for (long i = first[s - 1]; i < first[s - 1] + count_[s - 1]; i++)
            for (int op = OS; op <= OP; op++) { T[nT].op = op; T[nT].c[0] = (int32_t)i; nT++; }
        for (int s1 = 1; s1 <= s - 3; s1++) for (int s2 = 1; s1 + s2 <= s - 2; s2++) {
            int s3 = s - 1 - s1 - s2;
            for (long i = first[s1]; i < first[s1] + count_[s1]; i++)
                for (long j = first[s2]; j < first[s2] + count_[s2]; j++)
                    for (long k = first[s3]; k < first[s3] + count_[s3]; k++)
                        for (int op = OIT; op <= OIF; op++) {
                            T[nT].op = op; T[nT].c[0] = (int32_t)i; T[nT].c[1] = (int32_t)j; T[nT].c[2] = (int32_t)k; nT++;
                        }
        }
        count_[s] = nT - first[s];
    }
    printf("syntactic terms by size:");
    for (int s = 1; s <= N; s++) printf(" %d:%.0f", s, cnt[s]);
    printf("\n"); fflush(stdout);

    int nth = omp_get_max_threads();
    Map *maps = malloc(nth * sizeof(Map));
    for (int t = 0; t < nth; t++) map_init(&maps[t], 1 << 20);

    /* stored sizes */
    for (int s = 1; s < N; s++) {
        #pragma omp parallel for schedule(dynamic, 4096)
        for (long i = first[s]; i < first[s] + count_[s]; i++) {
            uint8_t tab[36]; table_of(T + i, tab); map_put(&maps[omp_get_thread_num()], tab, s);
        }
    }
    /* size N on the fly */
    {
        int s = N;
        #pragma omp parallel for schedule(dynamic, 1024)
        for (long i = first[s - 1]; i < first[s - 1] + count_[s - 1]; i++) {
            uint8_t tab[36];
            Node *save = NULL; (void)save;
            for (int op = OS; op <= OP; op++) {
                /* evaluate unary node directly */
                for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) {
                    int v = ev(T + i, x, y, 0);
                    tab[6 * x + y] = (uint8_t)(op == OS ? (v < VMAX ? v + 1 : VMAX) : (v > 0 ? v - 1 : 0));
                }
                map_put(&maps[omp_get_thread_num()], tab, s);
            }
        }
        for (int s1 = 1; s1 <= s - 3; s1++) for (int s2 = 1; s1 + s2 <= s - 2; s2++) {
            int s3 = s - 1 - s1 - s2;
            long n1 = count_[s1], n2 = count_[s2];
            #pragma omp parallel for schedule(dynamic, 1)
            for (long ij = 0; ij < n1 * n2; ij++) {
                long i = first[s1] + ij / n2, j = first[s2] + ij % n2;
                uint8_t tab[36];
                int nv[36];
                for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) nv[6 * x + y] = ev(T + i, x, y, 0);
                Map *m = &maps[omp_get_thread_num()];
                for (long k = first[s3]; k < first[s3] + count_[s3]; k++) {
                    /* It(i, j, k): n = value of i, acc starts at value of k, body j */
                    for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++) {
                        int acc = ev(T + k, x, y, 0);
                        int n = nv[6 * x + y];
                        for (int q = 0; q < n; q++) acc = ev(T + j, x, y, acc);
                        tab[6 * x + y] = (uint8_t)acc;
                    }
                    map_put(m, tab, s);
                    /* ifz(i, j, k) */
                    for (int x = 0; x < 6; x++) for (int y = 0; y < 6; y++)
                        tab[6 * x + y] = (uint8_t)(nv[6 * x + y] == 0 ? ev(T + j, x, y, 0) : ev(T + k, x, y, 0));
                    map_put(m, tab, s);
                }
            }
        }
    }
    /* merge */
    Map g; map_init(&g, 1 << 20);
    for (int t = 0; t < nth; t++)
        for (long i = 0; i < maps[t].cap; i++) if (maps[t].val[i]) map_put(&g, maps[t].keys + i * 36, maps[t].val[i]);
    long byK[16] = {0};
    for (long i = 0; i < g.cap; i++) if (g.val[i]) byK[g.val[i]]++;
    printf("distinct functions by least size:");
    for (int s = 1; s <= N; s++) printf(" %d:%ld", s, byK[s]);
    printf("\ntotal: %ld\n", g.n);
    if (argc > 2) {
        /* records sorted by (least size, table) so that the dump does not depend on thread timing */
        uint8_t *recs = malloc((size_t)g.n * 37);
        long r = 0;
        for (long i = 0; i < g.cap; i++) if (g.val[i]) { memcpy(recs + r * 37, g.keys + i * 36, 36); recs[r * 37 + 36] = g.val[i]; r++; }
        qsort(recs, (size_t)g.n, 37, cmp_rec);
        FILE *f = fopen(argv[2], "wb");
        int32_t n = (int32_t)g.n; fwrite(&n, 4, 1, f);
        fwrite(recs, 37, (size_t)g.n, f);
        fclose(f);
    }
    (void)show;
    return 0;
}
