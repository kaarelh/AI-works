/* bf8enum.c -- exhaustive enumeration of the BF8 monotone machine.
 *
 * BF8: eight commands, three input bits each, read lazily from the input tape:
 *   0 '+'  cell := cell+1 (mod CELLMOD)      4 '['  if cell==0 jump past matching ']'
 *   1 '-'  cell := cell-1 (mod CELLMOD)      5 ']'  if cell!=0 jump back to matching '['
 *   2 '>'  pointer right                            (no matching '[': jump to command 0)
 *   3 '<'  pointer left                      6 '.'  output cell mod 2
 *                                            7 ':'  output [cell != 0]
 * The machine reads a new command from its input only when the instruction
 * pointer (or a forward bracket scan) reaches the end of what it has read, so
 * the set of inputs read before an event is prefix-free.  With fair coin flips
 * on the input tape,
 *   xi(x) = Pr[ output starts with x; for every k<=|x| the k-th output bit is
 *               emitted at a step <= T0+T1*k; at most LC commands have been read
 *               when the last bit of x is emitted ].
 * Every executed command is one step; a bracket jump is one step.
 *
 * Usage: bf8enum LC N T0 T1 CELLMOD out.txt
 * Output lines: "<len> <bits as 0/1 string> <mass as hex float> <mass as %.17g>"
 * for every x with xi(x)>0 and 1<=|x|<=N.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MAXLC 16
static int LC, N, CELLMOD; static long T0, T1;
static int TS;                       /* tape size */
typedef struct { int ip, ptr, nread, outlen, scan, lo, hi; long steps; uint64_t out; } St;
static unsigned char *tape;
static unsigned char cmds[MAXLC];
static unsigned char *snapbuf[MAXLC + 1];
static double w8[MAXLC + 1];

/* hash table (outlen,out) -> mass */
typedef struct { uint64_t out; int len; int used; double mass; } Ent;
static Ent *tab; static uint64_t tabsz, tabcnt;
static inline uint64_t hsh(uint64_t out, int len) {
    uint64_t h = out * 0x9E3779B97F4A7C15ULL ^ ((uint64_t)len * 0xC2B2AE3D27D4EB4FULL);
    h ^= h >> 29; h *= 0xBF58476D1CE4E5B9ULL; h ^= h >> 32; return h;
}
static void grow(void);
static void add(uint64_t out, int len, double m) {
    if (tabcnt * 2 > tabsz) grow();
    uint64_t i = hsh(out, len) & (tabsz - 1);
    while (tab[i].used) {
        if (tab[i].out == out && tab[i].len == len) { tab[i].mass += m; return; }
        i = (i + 1) & (tabsz - 1);
    }
    tab[i].used = 1; tab[i].out = out; tab[i].len = len; tab[i].mass = m; tabcnt++;
}
static void grow(void) {
    Ent *old = tab; uint64_t osz = tabsz;
    tabsz *= 2; tab = calloc(tabsz, sizeof(Ent)); tabcnt = 0;
    for (uint64_t i = 0; i < osz; i++) if (old[i].used) add(old[i].out, old[i].len, old[i].mass);
    free(old);
}

static uint64_t nleaves = 0, nsteps = 0;

typedef struct { int lo, hi; } Rg;
static Rg run(St s) {
    for (;;) {
        Rg r; r.lo = s.lo; r.hi = s.hi;
        if (s.outlen == N) { nleaves++; return r; }
        if (s.ip == s.nread) {                      /* need a new command */
            if (s.nread == LC) { nleaves++; return r; }
            int d = s.nread, lo = s.lo, hi = s.hi;
            if (hi >= lo) memcpy(snapbuf[d], tape + lo, (size_t)(hi - lo + 1));
            Rg all = r;
            for (int c = 0; c < 8; c++) {
                St t = s; cmds[d] = (unsigned char)c; t.nread = d + 1;
                Rg cr = run(t);
                /* restore: zero everything the child touched, then put the snapshot back */
                if (cr.hi >= cr.lo) memset(tape + cr.lo, 0, (size_t)(cr.hi - cr.lo + 1));
                if (hi >= lo) memcpy(tape + lo, snapbuf[d], (size_t)(hi - lo + 1));
                if (cr.lo < all.lo) all.lo = cr.lo;
                if (cr.hi > all.hi) all.hi = cr.hi;
            }
            return all;
        }
        int c = cmds[s.ip];
        if (s.scan > 0) {                           /* forward bracket scan, no time cost */
            if (c == 4) s.scan++; else if (c == 5) s.scan--;
            s.ip++; continue;
        }
        if (s.steps >= T0 + T1 * (long)(s.outlen + 1)) { nleaves++; return r; }   /* off schedule */
        s.steps++; nsteps++;
        unsigned char *cell = tape + s.ptr;
        switch (c) {
        case 0: *cell = (unsigned char)((*cell + 1) % CELLMOD); break;
        case 1: *cell = (unsigned char)((*cell + CELLMOD - 1) % CELLMOD); break;
        case 2: s.ptr++; break;
        case 3: s.ptr--; break;
        case 4: if (*cell == 0) { s.scan = 1; } break;
        case 5:
            if (*cell != 0) {
                int depth = 1, j = s.ip - 1;
                while (j >= 0) {
                    if (cmds[j] == 5) depth++; else if (cmds[j] == 4) { depth--; if (depth == 0) break; }
                    j--;
                }
                s.ip = j;                           /* j = -1 if unmatched: restart at command 0 */
            }
            break;
        case 6: case 7: {
            uint64_t b = (c == 6) ? (uint64_t)(*cell & 1) : (uint64_t)(*cell != 0);
            s.out |= b << s.outlen; s.outlen++;
            add(s.out, s.outlen, w8[s.nread]);
        } break;
        }
        if (c == 0 || c == 1) { if (s.ptr < s.lo) s.lo = s.ptr; if (s.ptr > s.hi) s.hi = s.ptr; }
        s.ip++;
    }
}

int main(int argc, char **argv) {
    if (argc < 7) { fprintf(stderr, "usage: %s LC N T0 T1 CELLMOD out.txt\n", argv[0]); return 1; }
    LC = atoi(argv[1]); N = atoi(argv[2]); T0 = atol(argv[3]); T1 = atol(argv[4]); CELLMOD = atoi(argv[5]);
    if (LC > MAXLC || N > 62 || CELLMOD > 256 || CELLMOD < 2) { fprintf(stderr, "bad params\n"); return 1; }
    long maxsteps = T0 + T1 * (long)N + 8;
    TS = (int)(2 * maxsteps + 16);
    tape = calloc((size_t)TS, 1);
    for (int d = 0; d <= MAXLC; d++) snapbuf[d] = malloc((size_t)TS);
    w8[0] = 1.0; for (int d = 1; d <= MAXLC; d++) w8[d] = w8[d - 1] / 8.0;
    tabsz = 1 << 20; tab = calloc(tabsz, sizeof(Ent));
    St s; memset(&s, 0, sizeof s); s.ptr = TS / 2; s.lo = TS; s.hi = -1;
    run(s);
    FILE *f = fopen(argv[6], "w");
    if (!f) { perror("open"); return 1; }
    for (uint64_t i = 0; i < tabsz; i++) if (tab[i].used) {
        fprintf(f, "%d ", tab[i].len);
        for (int k = 0; k < tab[i].len; k++) fputc('0' + (int)((tab[i].out >> k) & 1), f);
        fprintf(f, " %a %.17g\n", tab[i].mass, tab[i].mass);
    }
    fclose(f);
    fprintf(stderr, "LC=%d N=%d T0=%ld T1=%ld CELLMOD=%d nodes=%llu leaves=%llu steps=%llu\n",
            LC, N, T0, T1, CELLMOD, (unsigned long long)tabcnt, (unsigned long long)nleaves, (unsigned long long)nsteps);
    return 0;
}
