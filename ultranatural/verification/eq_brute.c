/* eq_brute.c -- referee's independent brute-force version of the bounded equational inductor
   for a unary function symbol f (vocabulary 0, S, f; variables x, y).

   Written from the definition, sharing no code with code/eq_unary.c:

   * A hypothesis is an ORDERED LIST of CONCRETE identities (strings such as "fSx=SS0", with the
     variable names and the order of the two sides as written).  No canonical forms and no
     multiplicities are used: every string that encodes an identity set is visited on its own
     and gets the weight 6^-(number of symbols + 1).
   * A ground term is a word over {S, f} applied to 0.  The ground instances of an identity
     s = t are obtained by substituting words for the variables; "replacement of equals inside a
     term" is putting a word p in front.  The closure is the least equivalence on the words of at
     most L letters that contains every pair (p.s[sigma], p.t[sigma]) BOTH of whose members have at
     most L letters.  This is MODE strict: a derivation all of whose terms have at most L letters.
   * MODE loose adds what code/eq_unary.c adds (found by reading it): for an identity u(x) = v(y)
     or u(x) = v(0), all instances p.u.w of the variable side are united with each other even when
     the other side p.v is longer than L (and likewise the instances p.v.w' for u(x) = v(y)).
     These unions are valid consequences, but their derivation passes through a term longer than L.

   Usage: eq_brute CAP L strict|loose [noprune] [canon] [K R]
     noprune   visit the extensions of inconsistent lists too (they are inconsistent; this checks
               that pruning loses nothing and gives the true number of inconsistent lists)
     canon     also count the distinct lists up to order, renaming of variables and swapping of sides
     K R       only the lists whose first identity has index = R mod K (for running K processes;
               the empty list is visited by the process with R = 0)
   Also printed (lines starting with T): a test of Corollary 4(2) of the note against the run.
   For n = 0..7, among the consistent lists that prove f(i) = i+1 for all i < n and prove a wrong
   value f(x) != x+1 for some x <= 7, how many have all sides of at most n symbols.  By the
   corollary there is none, so any such list is inconsistent by a proof longer than the bound.
   Output: one line per profile:
     p0 .. p7 | weight | number of lists | least size | example | number of lists of each size 0..CAP
   The weight is the sum of 6^-(size+1) in floating point; the counts by size give it exactly.   */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define XMAX 7
#define MAXDEPTH 16

typedef struct { int lu, ub, lv, vb; char a, b; int size; } Ident;

static int CAP, L, LOOSE, NOPRUNE, CANON, NW;
static Ident *ids; static int nids;
static int *par[MAXDEPTH + 1];
static double pow6[64];

/* word code: a leading 1 bit, then one bit per letter, first (outermost) letter first; S = 1, f = 0 */
static inline int wcode(int len, int bits) { return (1 << len) | bits; }

static inline int root(int *p, int a) { while (p[a] != a) { p[a] = p[p[a]]; a = p[a]; } return a; }
static inline void join(int *p, int a, int b) { a = root(p, a); b = root(p, b); if (a != b) { if (a < b) p[b] = a; else p[a] = b; } }

static void close_under(int *p, const Ident *e) {
    int lu = e->lu, ub = e->ub, lv = e->lv, vb = e->vb;
    char a = e->a, b = e->b;
    for (int lp = 0; lp <= L; lp++) for (int pb = 0; pb < (1 << lp); pb++) {
        int fits_u = lp + lu <= L, fits_v = lp + lv <= L;
        if (a == '0' && b == '0') {                                   /* ground identity */
            if (fits_u && fits_v) join(p, wcode(lp + lu, (pb << lu) | ub), wcode(lp + lv, (pb << lv) | vb));
        } else if (a == b) {                                          /* the same variable on both sides */
            for (int lw = 0; lp + lu + lw <= L && lp + lv + lw <= L; lw++)
                for (int wb = 0; wb < (1 << lw); wb++)
                    join(p, wcode(lp + lu + lw, ((((pb << lu) | ub)) << lw) | wb),
                            wcode(lp + lv + lw, ((((pb << lv) | vb)) << lw) | wb));
        } else {
            /* one side has a variable that the other side does not have */
            int a_var = a != '0', b_var = b != '0';
            int anchor_u = -1, anchor_v = -1;
            /* instances of the u side: p.u.w (all w if a is a variable, only w = empty otherwise) */
            /* strict: a pair (p.u.w, p.v.w') exists iff both have at most L letters */
            if (fits_u && fits_v) {
                int base = wcode(lp + lu, (pb << lu) | ub);
                join(p, base, wcode(lp + lv, (pb << lv) | vb));
                if (a_var) for (int lw = 1; lp + lu + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                    join(p, base, wcode(lp + lu + lw, ((((pb << lu) | ub)) << lw) | wb));
                if (b_var) for (int lw = 1; lp + lv + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                    join(p, base, wcode(lp + lv + lw, ((((pb << lv) | vb)) << lw) | wb));
            } else if (LOOSE) {
                if (fits_u && a_var) {                                /* p.v too long: the p.u.w are still all equal */
                    anchor_u = wcode(lp + lu, (pb << lu) | ub);
                    for (int lw = 1; lp + lu + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                        join(p, anchor_u, wcode(lp + lu + lw, ((((pb << lu) | ub)) << lw) | wb));
                }
                if (fits_v && b_var) {
                    anchor_v = wcode(lp + lv, (pb << lv) | vb);
                    for (int lw = 1; lp + lv + lw <= L; lw++) for (int wb = 0; wb < (1 << lw); wb++)
                        join(p, anchor_v, wcode(lp + lv + lw, ((((pb << lv) | vb)) << lw) | wb));
                }
            }
        }
    }
}

/* returns 0 if two numerals of at most L letters are identified */
static int get_profile(int *p, int *prof) {
    int r[64];
    for (int y = 0; y <= L; y++) {
        r[y] = root(p, wcode(y, (1 << y) - 1));
        for (int z = 0; z < y; z++) if (r[z] == r[y]) return 0;
    }
    for (int x = 0; x <= XMAX; x++) {
        int q = root(p, wcode(x + 1, (1 << x) - 1));               /* f S^x */
        prof[x] = -1;
        for (int y = 0; y <= L; y++) if (r[y] == q) prof[x] = y;
    }
    return 1;
}

static void ident_text(const Ident *e, char *out) {
    int k = 0;
    for (int i = e->lu - 1; i >= 0; i--) out[k++] = ((e->ub >> i) & 1) ? 'S' : 'f';
    out[k++] = e->a; out[k++] = '=';
    for (int i = e->lv - 1; i >= 0; i--) out[k++] = ((e->vb >> i) & 1) ? 'S' : 'f';
    out[k++] = e->b; out[k] = 0;
}

/* ---- table of profiles ---- */
#define TSIZE (1 << 16)
typedef struct { int used, prof[XMAX + 1], minsize, exn, ex[MAXDEPTH]; double w; long long n, bysize[32]; } Row;
static Row *tab;
static long long n_lists = 0, n_cons = 0, n_incons = 0;
static double w_cons = 0, w_all = 0;

static void add_row(const int *prof, double w, int size, const int *stack, int depth) {
    unsigned h = 2166136261u;
    for (int x = 0; x <= XMAX; x++) h = (h ^ (unsigned)(prof[x] + 2)) * 16777619u;
    h &= TSIZE - 1;
    while (tab[h].used && memcmp(tab[h].prof, prof, sizeof tab[h].prof)) h = (h + 1) & (TSIZE - 1);
    Row *r = &tab[h];
    if (!r->used) { r->used = 1; memcpy(r->prof, prof, sizeof r->prof); r->w = 0; r->n = 0; r->minsize = 1 << 30; }
    r->w += w; r->n++; r->bysize[size]++;
    if (size < r->minsize) { r->minsize = size; r->exn = depth; memcpy(r->ex, stack, depth * sizeof(int)); }
}

/* ---- optional: distinct lists up to order, renaming and swapping ---- */
static char **canon_set; static long long canon_cap = 0, canon_n = 0;
static unsigned long long shash(const char *s) { unsigned long long h = 1469598103934665603ULL; while (*s) { h ^= (unsigned char)*s++; h *= 1099511628211ULL; } return h; }
static void canon_insert(const char *s) {
    if (!canon_set) { canon_cap = 1 << 22; canon_set = calloc(canon_cap, sizeof(char *)); }
    if (canon_n * 2 > canon_cap) {
        long long oc = canon_cap; char **old = canon_set; canon_cap *= 4; canon_set = calloc(canon_cap, sizeof(char *));
        for (long long i = 0; i < oc; i++) if (old[i]) { unsigned long long h = shash(old[i]) & (canon_cap - 1); while (canon_set[h]) h = (h + 1) & (canon_cap - 1); canon_set[h] = old[i]; }
        free(old);
    }
    unsigned long long h = shash(s) & (canon_cap - 1);
    while (canon_set[h]) { if (!strcmp(canon_set[h], s)) return; h = (h + 1) & (canon_cap - 1); }
    canon_set[h] = strdup(s); canon_n++;
}
static int cmpstr(const void *a, const void *b) { return strcmp((const char *)a, (const char *)b); }
static void canon_ident(const Ident *e, char *out) {
    /* both orientations, variables renamed in order of appearance; take the smaller string */
    char t[2][48];
    for (int o = 0; o < 2; o++) {
        Ident g = *e;
        if (o) { g.lu = e->lv; g.ub = e->vb; g.a = e->b; g.lv = e->lu; g.vb = e->ub; g.b = e->a; }
        if (g.a != '0') { if (g.b == g.a) g.b = 'x'; else if (g.b != '0') g.b = 'y'; g.a = 'x'; }
        else if (g.b != '0') g.b = 'x';
        ident_text(&g, t[o]);
    }
    strcpy(out, strcmp(t[0], t[1]) <= 0 ? t[0] : t[1]);
}
static void canon_list(const int *stack, int depth) {
    char items[MAXDEPTH][48], buf[MAXDEPTH * 48 + 8];
    for (int j = 0; j < depth; j++) canon_ident(&ids[stack[j]], items[j]);
    qsort(items, depth, 48, cmpstr);
    buf[0] = 0;
    for (int j = 0; j < depth; j++) { strcat(buf, items[j]); strcat(buf, " "); }
    canon_insert(buf);
}

static int modK = 1, modR = 0;

static long long dev_short[XMAX + 1], dev_long[XMAX + 1];
static double wdev_short[XMAX + 1], wdev_long[XMAX + 1];
static int dev_ex[XMAX + 1][MAXDEPTH], dev_exn[XMAX + 1];

static void corollary_test(const int *prof, double w, const int *stack, int depth) {
    int wrong = 0, maxside = 0;
    for (int x = 0; x <= XMAX; x++) if (prof[x] >= 0 && prof[x] != x + 1) wrong = 1;
    if (!wrong) return;
    for (int j = 0; j < depth; j++) {
        const Ident *e = &ids[stack[j]];
        if (e->lu + 1 > maxside) maxside = e->lu + 1;
        if (e->lv + 1 > maxside) maxside = e->lv + 1;
    }
    for (int n = 0; n <= XMAX; n++) {
        if (n > 0 && prof[n - 1] != n) break;            /* does not fit successor on 0..n-1 */
        if (maxside <= n) {
            if (!dev_short[n]) { dev_exn[n] = depth; memcpy(dev_ex[n], stack, depth * sizeof(int)); }
            dev_short[n]++; wdev_short[n] += w;
        } else { dev_long[n]++; wdev_long[n] += w; }
    }
}

static void visit(int depth, int size, int dead, int *stack) {
    int prof[XMAX + 1];
    double w = pow6[size + 1];
    int ok = 0;
    n_lists++; w_all += w;
    if (!dead) ok = get_profile(par[depth], prof);
    if (ok) { n_cons++; w_cons += w; add_row(prof, w, size, stack, depth); corollary_test(prof, w, stack, depth); if (CANON) canon_list(stack, depth); }
    else { n_incons++; if (!NOPRUNE) return; }
    if (depth == MAXDEPTH) return;
    for (int i = 0; i < nids && ids[i].size <= CAP - size; i++) {
        if (depth == 0 && i % modK != modR) continue;
        if (ok) { memcpy(par[depth + 1], par[depth], NW * sizeof(int)); close_under(par[depth + 1], &ids[i]); }
        stack[depth] = i;
        visit(depth + 1, size + ids[i].size, !ok, stack);
    }
}

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: eq_brute CAP L strict|loose [noprune] [canon] [FIRST_LO FIRST_HI]\n"); return 1; }
    CAP = atoi(argv[1]); L = atoi(argv[2]); LOOSE = !strcmp(argv[3], "loose");
    int k = 4;
    if (k < argc && !strcmp(argv[k], "noprune")) { NOPRUNE = 1; k++; }
    if (k < argc && !strcmp(argv[k], "canon")) { CANON = 1; k++; }
    if (k + 1 < argc) { modK = atoi(argv[k]); modR = atoi(argv[k + 1]); }
    NW = 1 << (L + 1);
    for (int i = 0; i < 64; i++) pow6[i] = pow(6.0, -i);
    /* all concrete identities, by increasing size: a term of n symbols is a word of n-1 letters and a leaf */
    long long cnt = 0;
    for (int s = 2; s <= CAP; s++) cnt += 9LL * (s - 1) * (1LL << (s - 2));
    ids = malloc(cnt * sizeof(Ident));
    const char leaves[3] = {'0', 'x', 'y'};
    for (int s = 2; s <= CAP; s++)
        for (int lu = 0; lu <= s - 2; lu++) { int lv = s - 2 - lu;
            for (int ub = 0; ub < (1 << lu); ub++) for (int vb = 0; vb < (1 << lv); vb++)
                for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++)
                    ids[nids++] = (Ident){lu, ub, lv, vb, leaves[i], leaves[j], s};
        }
    if (nids != cnt) { fprintf(stderr, "count\n"); return 1; }
    for (int d = 0; d <= MAXDEPTH && d <= CAP / 2 + 1; d++) par[d] = malloc(NW * sizeof(int));
    for (int i = 0; i < NW; i++) par[0][i] = i;
    tab = calloc(TSIZE, sizeof(Row));
    int stack[MAXDEPTH];
    if (modR == 0) visit(0, 0, 0, stack);
    else {                                   /* skip the empty list, visit only the chosen first identities */
        for (int i = 0; i < nids && ids[i].size <= CAP; i++) {
            if (i % modK != modR) continue;
            memcpy(par[1], par[0], NW * sizeof(int)); close_under(par[1], &ids[i]);
            stack[0] = i; visit(1, ids[i].size, 0, stack);
        }
    }
    printf("# eq_brute CAP %d L %d mode %s%s part %d of %d: concrete identities %d, lists visited %lld, consistent %lld, inconsistent (visited) %lld\n",
           CAP, L, LOOSE ? "loose" : "strict", NOPRUNE ? " noprune" : "", modR, modK, nids, n_lists, n_cons, n_incons);
    printf("# weight of the visited lists: %.12g\n", w_all);
    printf("# weight of the consistent lists: %.12g\n", w_cons);
    if (CANON) printf("# distinct consistent lists up to order, renaming and swapping: %lld\n", canon_n);
    for (int n = 0; n <= XMAX; n++) {
        printf("T n=%d lists that fit successor on 0..n-1 and prove a wrong value: with a side of more than n symbols %lld (weight %.6g); with all sides of at most n symbols %lld (weight %.6g)",
               n, dev_long[n], wdev_long[n], dev_short[n], wdev_short[n]);
        if (dev_short[n]) { printf("  e.g."); for (int j = 0; j < dev_exn[n]; j++) { char buf[48]; ident_text(&ids[dev_ex[n][j]], buf); printf(" %s", buf); } }
        printf("\n");
    }
    for (int h = 0; h < TSIZE; h++) if (tab[h].used) {
        Row *r = &tab[h];
        for (int x = 0; x <= XMAX; x++) printf("%d ", r->prof[x]);
        printf("| %.12g | %lld | %d |", r->w, r->n, r->minsize);
        for (int j = 0; j < r->exn; j++) { char buf[48]; ident_text(&ids[r->ex[j]], buf); printf(" %s", buf); }
        printf(" |");
        for (int z = 0; z <= CAP; z++) printf(" %lld", r->bysize[z]);
        printf("\n");
    }
    return 0;
}
