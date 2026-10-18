#!/usr/bin/env python3
"""Fetch public standard IDX datasets; preserve sources and content hashes."""
import gzip,hashlib,json,struct,urllib.request
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parent
SOURCES={
 'mnist':'https://raw.githubusercontent.com/fgnt/mnist/master/',
 'fashion':'https://raw.githubusercontent.com/zalandoresearch/fashion-mnist/master/data/fashion/',
}
FILES=['train-images-idx3-ubyte.gz','train-labels-idx1-ubyte.gz',
       't10k-images-idx3-ubyte.gz','t10k-labels-idx1-ubyte.gz']

def read_idx(path):
    raw=gzip.decompress(path.read_bytes());magic,=struct.unpack('>I',raw[:4]);ndim=magic&255
    assert magic>>8==8
    shape=struct.unpack('>'+'I'*ndim,raw[4:4+4*ndim])
    return np.frombuffer(raw,dtype=np.uint8,offset=4+4*ndim).reshape(shape).copy()

def main():
    dest=ROOT/'data';dest.mkdir(parents=True,exist_ok=True);manifest=[]
    for name,base in SOURCES.items():
        arrays={}
        for fn in FILES:
            path=dest/(name+'-'+fn);url=base+fn
            if not path.exists():
                with urllib.request.urlopen(url,timeout=90) as response:
                    data=response.read()
                path.write_bytes(data)
            array=read_idx(path)
            manifest.append(dict(dataset=name,file=path.name,url=url,bytes=path.stat().st_size,
                                 sha256=hashlib.sha256(path.read_bytes()).hexdigest(),shape=list(array.shape)))
            arrays[('train' if fn.startswith('train') else 'test')+('_images' if 'images' in fn else '_labels')]=array
            print(json.dumps(manifest[-1]),flush=True)
        np.savez_compressed(dest/(name+'.npz'),**arrays)
    (dest/'source-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')

if __name__=='__main__':main()
