"""Where do the pooling sets' long links come from?  For each v3 image analysis at n = 10000 (seed 0): the active pixels i
whose S_i(k) has a member more than 2 grid steps away, the ink frequency of those pixels on the fit's training rows
(fraction of the n training images with x > 0; data split as hooks.fit_image), and how many of the far members are mirror
pixels of i (same row +- 1, columns summing to 27 +- 2).
usage: INTERP_OUT=... python image_far_members.py      writes tables/img_far_members.md and tables/img_far_members.json"""
import os, sys, json, glob, numpy as np
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
import hooks as H

IMG = os.path.join(os.environ.get("INTERP_OUT", os.path.join(HERE, "results")), "image", "v3")
out, rows = {}, []
for p in sorted(glob.glob(os.path.join(IMG, "*__n10000__s0.npz"))):
    ds = os.path.basename(p).split("__")[0]; M = np.load(p); n = 10000
    D = H.DATA.load(ds); pool, _ = H.DATA.splits(D, 0); g = H.grid_of(ds)
    freq = np.zeros(784); freq[g] = (D["X"][pool[:n]] > 0).mean(0); del D
    cen = M["pool_centres"].astype(int)
    for k in (4, 9, 16):
        mem = M[f"pool{k}_members"].astype(int); fc, far, mir = set(), 0, 0
        for c, m in zip(cen, mem):
            for j in m:
                if j != c and max(abs(c // 28 - j // 28), abs(c % 28 - j % 28)) > 2:
                    far += 1; fc.add(c); mir += int(abs(c // 28 - j // 28) <= 1 and abs(c % 28 + j % 28 - 27) <= 2)
        fc = np.array(sorted(fc), int)
        d = dict(centres_with_far=int(len(fc)), far_members=far, mirror=mir,
                 ink_freq_far_centres_median=float(np.median(freq[fc])) if len(fc) else None,
                 ink_freq_far_centres_max=float(freq[fc].max()) if len(fc) else None,
                 ink_freq_all_centres_median=float(np.median(freq[cen])))
        out[f"{ds}/k{k}"] = d
        rows.append(f"| {ds} | {k} | {d['centres_with_far']} | {far} | {mir} | "
                    f"{'–' if d['ink_freq_far_centres_median'] is None else format(d['ink_freq_far_centres_median'], '.4f')} | "
                    f"{'–' if d['ink_freq_far_centres_max'] is None else format(d['ink_freq_far_centres_max'], '.4f')} | {d['ink_freq_all_centres_median']:.4f} |")
os.makedirs(os.path.join(HERE, "tables"), exist_ok=True)
json.dump(out, open(os.path.join(HERE, "tables", "img_far_members.json"), "w"), indent=1)
open(os.path.join(HERE, "tables", "img_far_members.md"), "w").write(
    "# Pooling-set members more than 2 grid steps from their centre (v3, n = 10000, seed 0)\n\n"
    "Source: " + IMG.replace("/tmp/claude-0/-home-user-AI-works/addd33f6-5c52-5bee-997e-3f98d4e90609/scratchpad", "$SCRATCH") +
    "/<dataset>__n10000__s0.npz and the training rows of the fit (image_far_members.py). Ink frequency: fraction of the 10000 "
    "training images in which the pixel is non-zero.\n\n"
    "| dataset | k | centres with a far member | far members | of which mirror pixels | ink freq. of those centres: median | max | ink freq. of all active pixels: median |\n"
    "|---|---|---|---|---|---|---|---|\n" + "\n".join(rows) + "\n")
print("\n".join(rows))
