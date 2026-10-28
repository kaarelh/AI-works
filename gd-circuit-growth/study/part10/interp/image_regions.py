"""Region checks for the per-class contribution maps (IMAGE_INTERP.md section 3).  For each region named in the write-up
(a union of rectangles, or a thick segment, on the true 28 x 28 grid; chosen by looking at the maps): its share of the
class's net evidence (sum of the map over the region / sum over the image), its area share, the part of the region's
evidence on pixels blank in the point (x <= 0.1), and the class's mean ink in the region against the other classes'.
Maps: <booster>_contrib and <booster>_contrib_inked of the v3 analysis at n = 10000, seed 0 (image_structure.py).
usage: INTERP_OUT=... python image_regions.py      writes tables/img_regions.md and tables/img_regions.json"""
import os, json, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__))
IMG = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "image", "v3")
R_, C_ = np.mgrid[0:28, 0:28]


def rect(*rs):                       # rects (r0, r1, c0, c1), end-exclusive
    m = np.zeros((28, 28), bool)
    for r0, r1, c0, c1 in rs:
        m[r0:r1, c0:c1] = True
    return m.ravel()


def seg(p, q, w=1.5):                # pixels within w of the segment p-q (row, col)
    p, q = np.array(p, float), np.array(q, float); d = q - p; P = np.stack([R_, C_], -1).astype(float) - p
    t = np.clip((P @ d) / (d @ d), 0, 1); return (np.linalg.norm(P - t[..., None] * d, axis=-1) <= w).ravel()


REG = {
    "qd_dev": [
        (0, "horizon line (rows 13-15)", rect((13, 16, 0, 28))),
        (0, "ends of the horizon at the edges", rect((12, 17, 0, 4), (12, 17, 24, 28))),
        (0, "diagonal band, left edge to bottom centre", seg((12, 2), (25, 13))),
        (1, "gap between the wheels, bottom centre", rect((21, 26, 12, 16))),
        (2, "left of the stick", rect((10, 18, 7, 11))),
        (2, "head of the stick", rect((0, 4, 12, 16))),
        (3, "dense centre", rect((9, 18, 11, 17))),
        (4, "top end of the clip", rect((0, 4, 11, 17))),
        (4, "left and right sides", rect((11, 18, 1, 4), (11, 18, 24, 27))),
        (5, "base of the fire", rect((16, 23, 9, 18))),
        (5, "left and right sides", rect((11, 19, 0, 3), (11, 19, 25, 28))),
        (6, "upper corners", rect((3, 9, 2, 8), (3, 9, 19, 25))),
        (7, "upper-left arc", seg((10, 2), (2, 12))),
        (7, "left and right sides", rect((11, 18, 0, 4), (11, 18, 23, 28))),
        (8, "ends at the left and right edges", rect((12, 17, 0, 3), (12, 17, 25, 28))),
        (8, "below the pan", rect((21, 26, 8, 19))),
        (9, "sole", rect((23, 27, 7, 19))),
        (9, "middle", rect((8, 18, 9, 15))),
    ],
    "fashion_mnist": [
        (0, "sleeve ends", rect((4, 9, 3, 7), (4, 9, 20, 25))),
        (0, "lower sides", rect((16, 27, 1, 7), (16, 27, 21, 27))),
        (1, "gap between the legs", rect((14, 28, 13, 16))),
        (2, "neckline", rect((0, 3, 8, 12))),
        (2, "below the hem", rect((25, 28, 9, 19))),
        (3, "beside the waist", rect((8, 13, 7, 10), (8, 13, 18, 21))),
        (3, "hem", rect((24, 28, 10, 19))),
        (4, "outside the shoulders", rect((0, 8, 4, 9), (0, 8, 19, 27))),
        (4, "below the hem", rect((25, 28, 9, 19))),
        (5, "upper left", rect((2, 10, 5, 11))),
        (5, "heel", rect((11, 18, 22, 27))),
        (5, "middle of the shoe", rect((12, 16, 11, 16))),
        (6, "left shoulder", rect((2, 10, 5, 9))),
        (7, "upper left", rect((3, 9, 6, 12))),
        (7, "heel", rect((12, 17, 24, 28))),
        (8, "handle", rect((0, 4, 9, 16))),
        (8, "inside the handle", rect((4, 9, 12, 16))),
        (8, "left edge", rect((6, 13, 0, 3))),
        (9, "left of the shaft", rect((1, 13, 7, 10))),
        (9, "ankle", rect((9, 13, 18, 22))),
    ],
    "mnist": [
        (0, "centre (the hole)", rect((12, 17, 12, 17))),
        (1, "beside the stroke", rect((10, 19, 16, 20), (10, 19, 8, 12))),
        (2, "left of the upper bowl (row 10-12)", rect((10, 13, 4, 13))),
        (2, "base", rect((16, 22, 8, 23))),
        (3, "open left side", rect((8, 18, 7, 13))),
        (4, "open top", rect((5, 10, 13, 18))),
        (5, "right, below the top bar", rect((9, 12, 15, 23))),
        (6, "right of the stem, above the loop", rect((6, 11, 16, 21))),
        (7, "diagonal band left of the stem", seg((14, 13), (22, 7))),
        (7, "bottom of the stem", rect((23, 26, 9, 16))),
        (8, "centre crossing", rect((11, 18, 10, 15))),
        (9, "bottom rows 23-25", rect((23, 26, 9, 18))),
        (9, "lower left rows 19-21", rect((19, 22, 7, 13))),
    ],
}
LAB = {"fashion_mnist": ["T-shirt", "trouser", "pullover", "dress", "coat", "sandal", "shirt", "sneaker", "bag", "boot"],
       "mnist": [str(i) for i in range(10)]}
f = "/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad/std/data/quickdraw/qd_dev_categories.txt"
LAB["qd_dev"] = [c for c in open(f).read().split("\n") if c] if os.path.exists(f) else [str(i) for i in range(10)]

out, rows = {}, []
for ds, regs in REG.items():
    p = os.path.join(IMG, f"{ds}__n10000__s0.npz")
    if not os.path.exists(p):
        continue
    M = np.load(p); mu = M["class_mean"]
    for c, name, m in regs:
        oth = np.delete(mu, c, 0)[:, m].mean()
        d = dict(area=float(m.mean()), class_ink=float(mu[c, m].mean()), other_ink=float(oth))
        for b in ("cgbt", "ggbt"):
            cm, ik = M[f"{b}_contrib"][c], M[f"{b}_contrib_inked"][c]
            d[b] = dict(share=float(cm[m].sum() / cm.sum()), blank_frac=float((cm[m] - ik[m]).sum() / cm[m].sum()))
        out[f"{ds}/{LAB[ds][c]}/{name}"] = d
        rows.append(f"| {ds} | {LAB[ds][c]} | {name} | {d['area']:.3f} | {d['class_ink']:.3f} / {d['other_ink']:.3f} | "
                    f"{d['cgbt']['share']:.3f} | {d['cgbt']['blank_frac']:.2f} | {d['ggbt']['share']:.3f} | {d['ggbt']['blank_frac']:.2f} |")
os.makedirs(os.path.join(HERE, "tables"), exist_ok=True)
json.dump(out, open(os.path.join(HERE, "tables", "img_regions.json"), "w"), indent=1)
open(os.path.join(HERE, "tables", "img_regions.md"), "w").write(
    "# Regions of the contribution maps (v3, n = 10000, seed 0)\n\n"
    "Source: $SCRATCH/p10/interp_out_final/image/v3/<dataset>__n10000__s0.npz (image_regions.py; regions in the script). "
    "share = the region's part of the class's net evidence (map summed over the region / over the image); blank = the part "
    "of the region's evidence on pixels blank in the point (x <= 0.1); ink = mean of the class's mean image over the region / "
    "the same for the other 9 classes.\n\n"
    "| dataset | class | region | area share | ink: class / others | cgbt share | cgbt blank | ggbt share | ggbt blank |\n"
    "|---|---|---|---|---|---|---|---|---|\n" + "\n".join(rows) + "\n")
print("\n".join(rows))
