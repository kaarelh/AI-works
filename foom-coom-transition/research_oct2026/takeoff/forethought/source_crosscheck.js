/* Execute the archived official JS independently of our Python reconstruction. */
const fs = require('fs');
const path = require('path');
const Sim = require('./sources/simulation.js');
function rebuilt(f,r0,y,p) {
  let dt=3/f,t=0,r=r0,i=0;
  const times=[0],k=r0/(8*y);
  while(t<48 && i<8*y && r>0) {
    t+=dt;times.push(t);i++;r-=k;
    if(r>0) dt*=Math.pow(2,p*(1/r-1));
  }
  return times;
}
let maxRelative=0, cases=0;
for(const f of [2,8,32]) for(const r0 of [.4,1.2,3.6]) for(const y of [6,11,16]) for(const p of [.15,.3,.6]) {
  const source=Sim.dynamicSystemWithLambda(r0,2,3/f,y,Math.log(2)/5,f,f,p,.5,false,false,48).times;
  const ours=rebuilt(f,r0,y,p);
  if(source.length!==ours.length)throw new Error('Length mismatch');
  source.forEach((v,i)=>{ const rel=Math.abs(v-ours[i])/Math.max(1,Math.abs(v));maxRelative=Math.max(rel,maxRelative);if(rel>1e-10)throw new Error('Value mismatch');});
  cases++;
}
const single=Sim.runSingle({f:8,r0:1.2,yrLeft:11,lambda:.3,softwareContribution:.5});
const out={cases,max_relative_time_error:maxRelative,single_first_step_months:single.times[1],monte_carlo_first_step_months:3/8,median_ceiling_log10:Math.log10(single.ceiling)};
fs.writeFileSync(path.join(__dirname,'source_crosscheck.json'),JSON.stringify(out,null,2)+'\n');
console.log(out);
