/* Bounded exact computation of the equational inductor for a unary function symbol f.

   Signature {0, S, f}, variables x, y. A term is a word over {S, f} applied to a leaf (0, x or y),
   so a ground term is a string over {S, f}; numerals are the strings S^n. An identity set T
   generates the least equivalence on strings that is closed under putting any word in front
   (congruence) and contains, for all words p, w, w':
       u(x) = v(x):   p u w ~ p v w
       u(x) = v(y):   p u w ~ p v w'
       u(x) = v(0):   p u w ~ p v
       u(0) = v(0):   p u   ~ p v
   The program closes these within the strings of length <= L. So an equation counts as proved
   essentially only if it has a derivation through terms of at most L symbols above the leaf
   (sound, not complete), and T counts as consistent if no two numerals of length <= L are
   identified within that bound. One departure from this description: for the second and third
   kind, when p v is too long to be represented, the instances p u w are still identified with
   each other (they are all equal to p v); and for the second kind, when p u is too long, the
   instances p v w' are identified with each other. These unions are valid consequences.

   Every identity set of total size <= CAP is enumerated (as a multiset of identities up to
   renaming of variables and swapping of sides; each carries the number of strings that encode
   it). For each consistent one the program computes its profile: for x = 0..XMAX, the y with
   f(S^x 0) = S^y 0 proved, or -1. Output: one line per profile with the total prior weight
   6^-(size+1) of the encodings, the least size, and a set of least size.

   Usage: eq_unary CAP L > out.txt
          eq_unary CAP L count          only the total prior weight
          eq_unary CAP L dump           also print, on lines starting with D, every consistent set
                                        that determines f at 0, 1 and 2
          eq_unary 0 L check < sets     for each line of identities such as "S0=f0 fSx=SS0", say
                                        whether it is consistent within the bound L, and its profile */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define XMAX 7
#define MAXID 200000
#define MAXDEPTH 8

static int L, CAP, N, count_only, dump;
struct IdS; static void show_id(int i, char *out);
typedef struct { int type, lu, ub, lv, vb, size, mult, trivial; } Id;
static Id ids[MAXID];
static int nids;
static int *uf[MAXDEPTH + 1];

static inline int idx(int len, int bits) { return (1 << len) - 1 + bits; }
static inline int find(int *p, int a) { while (p[a] != a) { p[a] = p[p[a]]; a = p[a]; } return a; }
static inline void unite(int *p, int a, int b) {
    a = find(p, a); b = find(p, b);
    if (a < b) p[b] = a; else if (b < a) p[a] = b;
}

static void apply(int *p, const Id *e) {
    int lu = e->lu, ub = e->ub, lv = e->lv, vb = e->vb;
    for (int lp = 0; lp <= L; lp++) for (int pb = 0; pb < (1 << lp); pb++) {
        if (e->type == 0) {                       /* u(x) = v(x) */
            int mx = lu > lv ? lu : lv;
            for (int lw = 0; lp + mx + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                unite(p, idx(lp + lu + lw, (((pb << lu) | ub) << lw) | wb),
                         idx(lp + lv + lw, (((pb << lv) | vb) << lw) | wb));
        } else if (e->type == 3) {                /* u(0) = v(0) */
            if (lp + lu <= L && lp + lv <= L)
                unite(p, idx(lp + lu, (pb << lu) | ub), idx(lp + lv, (pb << lv) | vb));
        } else {                                  /* u(x) = v(y)  or  u(x) = v(0) */
            int anchor = -1;
            if (lp + lv <= L) anchor = idx(lp + lv, (pb << lv) | vb);
            for (int lw = 0; lp + lu + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++) {
                int a = idx(lp + lu + lw, (((pb << lu) | ub) << lw) | wb);
                if (anchor < 0) anchor = a; else unite(p, anchor, a);
            }
            if (e->type == 1)
                for (int lw = 1; lp + lv + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                    unite(p, anchor, idx(lp + lv + lw, (((pb << lv) | vb) << lw) | wb));
        }
    }
}

/* profile: returns 0 if inconsistent */
static int profile(int *p, int *prof) {
    int root[32];
    for (int y = 0; y <= L; y++) {
        root[y] = find(p, idx(y, 0));
        for (int z = 0; z < y; z++) if (root[z] == root[y]) return 0;
    }
    for (int x = 0; x <= XMAX; x++) {
        int r = find(p, idx(x + 1, 1 << x));
        prof[x] = -1;
        for (int y = 0; y <= L; y++) if (root[y] == r) { prof[x] = y; break; }
    }
    return 1;
}

/* table of profiles */
#define HSIZE (1 << 20)
typedef struct { unsigned long long key; int used, minsize, ex[MAXDEPTH], exn; double w; } Entry;
static Entry *table;
static double total_w = 0, total_all = 0;
static long long n_nodes = 0, n_incons = 0;

static void record(const int *prof, double w, int size, const int *stack, int depth) {
    unsigned long long key = 0;
    for (int x = 0; x <= XMAX; x++) key = key * 32 + (unsigned)(prof[x] + 1);
    unsigned long long h = (key * 0x9E3779B97F4A7C15ULL) >> 44;
    while (table[h].used && table[h].key != key) h = (h + 1) & (HSIZE - 1);
    Entry *e = &table[h];
    if (!e->used) { e->used = 1; e->key = key; e->w = 0; e->minsize = 1 << 30; }
    e->w += w;
    if (size < e->minsize) { e->minsize = size; e->exn = depth; memcpy(e->ex, stack, depth * sizeof(int)); }
}

static void rec(int depth, int start, int size, double fac, int run, int *stack) {
    int prof[XMAX + 1];
    double w = fac * pow(6.0, -(size + 1));
    n_nodes++;
    total_all += w;
    if (!count_only) {
        if (!profile(uf[depth], prof)) { n_incons++; return; }
        total_w += w;
        record(prof, w, size, stack, depth);
        if (dump && prof[0] >= 0 && prof[1] >= 0 && prof[2] >= 0) {
            printf("D %.12g %d |", w, size);
            for (int x = 0; x <= XMAX; x++) printf(" %d", prof[x]);
            printf(" |");
            for (int j = 0; j < depth; j++) { char buf[100]; show_id(stack[j], buf); printf(" %s", buf); }
            printf("\n");
        }
    }
    if (depth == MAXDEPTH) return;
    for (int i = start; i < nids && ids[i].size <= CAP - size; i++) {
        int same = depth > 0 && stack[depth - 1] == i;
        int newrun = same ? run + 1 : 1;
        if (!count_only) {
            memcpy(uf[depth + 1], uf[depth], N * sizeof(int));
            if (!ids[i].trivial && !same) apply(uf[depth + 1], &ids[i]);
        }
        stack[depth] = i;
        rec(depth + 1, i, size + ids[i].size, fac * ids[i].mult * (depth + 1) / newrun, newrun, stack);
    }
}

static void word(char *out, int len, int bits) {
    for (int i = 0; i < len; i++) out[i] = ((bits >> (len - 1 - i)) & 1) ? 'f' : 'S';
    out[len] = 0;
}
static void show(const Id *e, char *out) {
    char a[40], b[40];
    word(a, e->lu, e->ub); word(b, e->lv, e->vb);
    const char *l1 = e->type == 3 ? "0" : "x", *l2 = e->type == 0 ? "x" : e->type == 1 ? "y" : "0";
    sprintf(out, "%s%s=%s%s", a, l1, b, l2);
}
static void show_id(int i, char *out) { show(&ids[i], out); }

/* parse "fSx=SS0" into an identity; returns 0 on failure */
static int parse(const char *str, Id *e) {
    const char *eq = strchr(str, '=');
    if (!eq) return 0;
    int len[2], bits[2]; char leaf[2];
    const char *side[2] = {str, eq + 1};
    for (int k = 0; k < 2; k++) {
        const char *p = side[k]; len[k] = 0; bits[k] = 0;
        while (*p == 'S' || *p == 'f') { bits[k] = (bits[k] << 1) | (*p == 'f'); len[k]++; p++; }
        leaf[k] = *p;
        if (leaf[k] != '0' && leaf[k] != 'x' && leaf[k] != 'y') return 0;
    }
    int a = 0, b = 1, type;
    if (leaf[0] == '0' && leaf[1] == '0') type = 3;
    else if (leaf[0] == '0') { type = 2; a = 1; b = 0; }       /* the variable side goes first */
    else if (leaf[1] == '0') type = 2;
    else type = leaf[0] == leaf[1] ? 0 : 1;
    *e = (Id){type, len[a], bits[a], len[b], bits[b], len[0] + len[1] + 2, 1, 0};
    return 1;
}

static int cmp(const void *a, const void *b) { return ((const Id *)a)->size - ((const Id *)b)->size; }

int main(int argc, char **argv) {
    CAP = atoi(argv[1]); L = atoi(argv[2]); N = (1 << (L + 1)) - 1;
    if (L > 30) { fprintf(stderr, "L must be at most 30\n"); return 1; }
    if (CAP > 2 * MAXDEPTH + 1) { fprintf(stderr, "CAP too large for MAXDEPTH\n"); return 1; }
    count_only = argc > 3 && !strcmp(argv[3], "count");   /* only add up the prior weights */
    dump = argc > 3 && !strcmp(argv[3], "dump");          /* also list the sets that determine f at 0, 1, 2 */
    if (argc > 3 && !strcmp(argv[3], "check")) {          /* check identity sets given on stdin, one per line */
        int *p = malloc(N * sizeof(int));
        char line[1000];
        while (fgets(line, sizeof line, stdin)) {
            for (int i = 0; i < N; i++) p[i] = i;
            int ok = 1, prof[XMAX + 1];
            for (char *tok = strtok(line, " \n"); tok; tok = strtok(NULL, " \n")) {
                Id e;
                if (!parse(tok, &e)) { ok = 0; break; }
                apply(p, &e);
            }
            if (!ok) { printf("cannot parse\n"); continue; }
            if (!profile(p, prof)) { printf("inconsistent\n"); continue; }
            printf("consistent");
            for (int x = 0; x <= XMAX; x++) printf(" %d", prof[x]);
            printf("\n");
        }
        return 0;
    }
    for (int s = 2; s <= CAP; s++) {
        long long check = 0;
        for (int lu = 0; lu <= s - 2; lu++) { int lv = s - 2 - lu;
            for (int ub = 0; ub < (1 << lu); ub++) for (int vb = 0; vb < (1 << lv); vb++) {
                int le = lu < lv || (lu == lv && ub <= vb), eq = lu == lv && ub == vb;
                for (int type = 0; type < 4; type++) {
                    if (type != 2 && !le) continue;         /* unordered except u(x) = v(0) */
                    int mult = type == 0 ? (eq ? 2 : 4) : type == 1 ? (eq ? 2 : 4) : type == 2 ? 4 : (eq ? 1 : 2);
                    if (nids >= MAXID) { fprintf(stderr, "too many identities: raise MAXID\n"); return 1; }
                    ids[nids++] = (Id){type, lu, ub, lv, vb, s, mult, eq && (type == 0 || type == 3)};
                    check += mult;
                }
            }
        }
        if (check != 9LL * (s - 1) * (1LL << (s - 2))) { fprintf(stderr, "count mismatch at size %d\n", s); return 1; }
    }
    qsort(ids, nids, sizeof(Id), cmp);
    for (int d = 0; d <= MAXDEPTH; d++) uf[d] = malloc(N * sizeof(int));
    for (int i = 0; i < N; i++) uf[0][i] = i;
    table = calloc(HSIZE, sizeof(Entry));
    int stack[MAXDEPTH];
    rec(0, 0, 0, 1.0, 0, stack);
    printf("# CAP %d L %d identities %d sets %lld inconsistent %lld\n", CAP, L, nids, n_nodes, n_incons);
    if (count_only) { printf("# prior weight of all encodings of size <= CAP: %.12g\n", total_all); return 0; }
    printf("# prior weight of the consistent sets and of the visited inconsistent ones: %.12g\n", total_all);
    printf("# prior weight of the consistent sets: %.12g\n", total_w);
    for (int h = 0; h < HSIZE; h++) if (table[h].used) {
        Entry *e = &table[h];
        unsigned long long key = e->key; int prof[XMAX + 1];
        for (int x = XMAX; x >= 0; x--) { prof[x] = (int)(key % 32) - 1; key /= 32; }
        for (int x = 0; x <= XMAX; x++) printf("%d ", prof[x]);
        printf("| %.12g | %d |", e->w, e->minsize);
        for (int j = 0; j < e->exn; j++) { char buf[100]; show(&ids[e->ex[j]], buf); printf(" %s", buf); }
        printf("\n");
    }
    return 0;
}
