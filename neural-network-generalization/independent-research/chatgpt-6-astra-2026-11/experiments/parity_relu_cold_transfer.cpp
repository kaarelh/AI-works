// Coordinate Gibbs, exact-output gauge slice moves, and feasible-angle pair rotations.
// Gauge log-density follows from polar incoming coordinates: p=d/2, standardized product AS fixed.
// Gaussian density is invariant under simultaneous SO(2) rotation of two neuron rows.
// Generated from parity_softplus_gibbs.cpp; readout and incoming scales differ.
// Conditionals are exact truncated Gaussians; mixing is not certified.
#include <algorithm>
#include <chrono>
#include <cmath>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
const double INF=std::numeric_limits<double>::infinity();
double sp(double x){return std::max(x,0.);}
double isp(double x){return x;}
struct RNG{
 std::mt19937_64 gen;std::normal_distribution<double> norm;
 RNG(int s):gen(s),norm(0,1){}
 size_t index(size_t count){return std::uniform_int_distribution<size_t>(0,count-1)(gen);}
 double u(){return (double(gen()>>11)+.5)*0x1.0p-53;}
 double trunc(double l,double h){
  if(!(l<h))throw std::runtime_error("empty interval");
  if(h<=0)return -trunc(-h,-l);
  if(l>=0){double alpha=(l+std::hypot(l,2.))/2;
   double mass=std::isinf(h)?1.:-std::expm1(-alpha*(h-l));
   for(;;){double z=l-std::log1p(-u()*mass)/alpha;
    if(z<h&&std::log(u())<=-.5*(z-alpha)*(z-alpha))return z;}}
  if(h-l<1.5){for(;;){double z=l+(h-l)*u();if(std::log(u())<=-.5*z*z)return z;}}
  for(;;){double z=norm(gen);if(z>l&&z<h)return z;}
 }
};
struct Chain{
 int d,n,m,k,seed,D;double tau,sa,s;std::string mode,profile;RNG rng;
 std::vector<double> theta,X,y,total,pre,rest,tmp;
 std::vector<int> observed;int train_draws=0,data_seed=0,distinct=0;
 Chain(int dim,int width,int sd,std::string init,double margin,std::string prior):
  d(dim),n(width),m(1<<d),k(m/2),seed(sd),D(d+2),tau(prior=="isotropic"?1:1/std::sqrt(double(d))),sa(prior=="small"?1/std::sqrt(double(d)):1),s(margin),mode(init),profile(prior),rng(sd),
  theta(n*D,0),X(m*(d+1),1),y(m,1),total(m,0),pre(m),rest(m),tmp(m){
  observed.assign(m,1);distinct=m;
  if(prior.rfind("cold-",0)==0){tau=sa=std::stod(prior.substr(5));if(!(tau>0&&std::isfinite(tau)))throw std::runtime_error("invalid cold scale");}
  if(d<4||d%2||n<k||n%k)throw std::runtime_error("even d>=4 and width multiple of 2^(d-1) required");
  for(int x=0;x<m;x++)for(int i=0;i<d;i++){X[x*(d+1)+1+i]=(x>>i&1)?1:-1;y[x]*=X[x*(d+1)+1+i];}
  int reserve=mode=="condensed"?k:n;
  for(int j=reserve;j<n;j++)for(int q=0;q<D;q++)theta[j*D+q]=(q==0?sa:tau)*rng.norm(rng.gen);
  double R=.1,sign=((d/2-1)%2)?-1:1;
  for(;;){
   for(int j=0;j<reserve;j++){int x=2*(j%k)+1;double *v=&theta[j*D];v[0]=sa*sign*y[x]*R;v[1]=0;
    for(int i=0;i<d;i++)v[2+i]=tau*R*X[x*(d+1)+1+i]/std::sqrt(double(d));}
   recompute();double low=INF;for(int x=0;x<m;x++)low=std::min(low,y[x]*total[x]/n);
   if(low>s+.05)break;R*=1.025;
  }
 }
 void neuron(const double *v,std::vector<double>&out){
  for(int x=0;x<m;x++){double z=0;for(int q=1;q<D;q++)z+=v[q]*X[x*(d+1)+q-1];out[x]=v[0]*sp(z);}
 }
 void recompute(){std::fill(total.begin(),total.end(),0.);for(int j=0;j<n;j++){neuron(&theta[j*D],tmp);for(int x=0;x<m;x++)total[x]+=tmp[x];}}
 void update(int j){
  double *v=&theta[j*D];double lo=-INF,hi=INF;
  for(int x=0;x<m;x++){
   double z=0;for(int q=1;q<D;q++)z+=v[q]*X[x*(d+1)+q-1];pre[x]=z;double phi=sp(z);rest[x]=total[x]-v[0]*phi;
   if(!observed[x])continue;
   if(phi==0){if(y[x]*rest[x]<=n*s-1e-9)throw std::runtime_error("inactive infeasibility");continue;}
   double b=(y[x]*n*s-rest[x])/phi;if(y[x]>0)lo=std::max(lo,b);else hi=std::min(hi,b);
  }
  v[0]=sa*rng.trunc(lo/sa,hi/sa);
  for(int q=1;q<D;q++){
   lo=-INF;hi=INF;double old=v[q];
   for(int x=0;x<m;x++){
    if(!observed[x])continue;
    double A=y[x]*v[0],value=(n*s-y[x]*rest[x])/A;
    if(A>0&&value<0)continue;
    if(A<0&&value<=0)throw std::runtime_error("infeasible coordinate");
    double xq=X[x*(d+1)+q-1],b=(isp(value)-pre[x]+old*xq)/xq;
    if(A*xq>0)lo=std::max(lo,b);else hi=std::min(hi,b);
   }
   v[q]=tau*rng.trunc(lo/tau,hi/tau);double change=v[q]-old;
   for(int x=0;x<m;x++)pre[x]+=change*X[x*(d+1)+q-1];
  }
  for(int x=0;x<m;x++)total[x]=rest[x]+v[0]*sp(pre[x]);
 }

 void gauge(int j){
  double *w=&theta[j*D];double S=0;
  for(int q=1;q<D;q++)S+=(w[q]/tau)*(w[q]/tau);
  double A=(w[0]/sa)*(w[0]/sa),product=A*S;
  if(!(S>0&&A>0))return;
  double p=.5*d,mode=p+std::hypot(p,std::sqrt(product)),ratio=product/mode;
  double u=std::log(S/mode);
  auto h=[&](double z){return p*z-.5*(mode*std::expm1(z)+ratio*std::expm1(-z));};
  double level=h(u)+std::log(rng.u()),left=-1,right=1;
  while(h(left)>level)left*=2;
  while(h(right)>level)right*=2;
  double l=left,r=0;
  for(int k=0;k<55;k++){double mid=(l+r)/2;if(h(mid)<level)l=mid;else r=mid;}
  left=(l+r)/2;l=0;r=right;
  for(int k=0;k<55;k++){double mid=(l+r)/2;if(h(mid)>level)l=mid;else r=mid;}
  right=(l+r)/2;
  double next=left+(right-left)*rng.u(),scale=std::exp(.5*(next-u));
  w[0]/=scale;for(int q=1;q<D;q++)w[q]*=scale;
  // Positive homogeneity preserves this neuron's output exactly in real arithmetic.
 }

 void rotate_pair(int j,int l){
  if(j==l)return;
  const double pi=std::acos(-1.);double *v=&theta[j*D],*w=&theta[l*D];
  std::vector<double> p(m),q(m),old(m),cut{0.,2*pi},nv(D),nw(D);
  auto add=[&](double t){t=std::fmod(t,2*pi);if(t<0)t+=2*pi;cut.push_back(t);};
  for(int x=0;x<m;x++){
   p[x]=q[x]=0;for(int z=1;z<D;z++){p[x]+=v[z]*X[x*(d+1)+z-1];q[x]+=w[z]*X[x*(d+1)+z-1];}
   old[x]=v[0]*sp(p[x])+w[0]*sp(q[x]);
   if(p[x]!=0||q[x]!=0){double phase=std::atan2(q[x],p[x]);for(int z=0;z<4;z++)add(phase+z*pi/2);}
   // In a cell with precisely one active feature, the output is C+A cos2t+B sin2t.
   double C=(v[0]*p[x]+w[0]*q[x])/2,A=(v[0]*p[x]-w[0]*q[x])/2,B=(v[0]*q[x]+w[0]*p[x])/2;
   double radius=std::hypot(A,B),required=y[x]*n*s-total[x]+old[x];
   if(radius>0){double rat=(required-C)/radius;if(std::abs(rat)<=1){double ph=std::atan2(B,A),ac=std::acos(rat);for(int z=0;z<2;z++){add((ph+ac)/2+z*pi);add((ph-ac)/2+z*pi);add((ph+pi+ac)/2+z*pi);add((ph+pi-ac)/2+z*pi);}}}
  }
  std::sort(cut.begin(),cut.end());std::vector<std::pair<double,double>> intervals;double length=0;
  for(size_t t=1;t<cut.size();t++){
   double lo=cut[t-1],hi=cut[t];if(hi-lo<1e-14)continue;double angle=(lo+hi)/2,c=std::cos(angle),ss=std::sin(angle),aa=c*v[0]+ss*w[0],bb=-ss*v[0]+c*w[0];bool ok=true;
   for(int x=0;x<m;x++){if(!observed[x])continue;double out=aa*sp(c*p[x]+ss*q[x])+bb*sp(-ss*p[x]+c*q[x]);if(y[x]*(total[x]-old[x]+out)<=n*s){ok=false;break;}}
   if(ok){intervals.push_back({lo,hi});length+=hi-lo;}
  }
  if(length==0)return;double pick=rng.u()*length,angle=0;
  for(auto interval:intervals){double len=interval.second-interval.first;if(pick<len){angle=interval.first+pick;break;}pick-=len;}
  double c=std::cos(angle),ss=std::sin(angle);
  for(int z=0;z<D;z++){nv[z]=c*v[z]+ss*w[z];nw[z]=-ss*v[z]+c*w[z];}
  for(int x=0;x<m;x++)total[x]+=nv[0]*sp(c*p[x]+ss*q[x])+nw[0]*sp(-ss*p[x]+c*q[x])-old[x];
  std::copy(nv.begin(),nv.end(),v);std::copy(nw.begin(),nw.end(),w);
 }
 void sweep(){
  for(int j=0;j<n;j++){int chosen=int(rng.index(n));update(chosen);gauge(chosen);}
  // The first index is uniform. Prefer a same-orientation partner with
  // a symmetric state-dependent pair rule (counts unchanged by swapping).
  // To avoid a state-dependent-selection bias, use ONLY uniform random pairs.
  for(int b=0;b<4;b++)rotate_pair(int(rng.index(n)),int(rng.index(n)));
 }

 static bool chol(std::vector<double>&A,int m,double&logdet){
  logdet=0;
  for(int i=0;i<m;i++)for(int j=0;j<=i;j++){
   double x=A[i*m+j];for(int k=0;k<j;k++)x-=A[i*m+k]*A[j*m+k];
   if(i==j){if(!(x>0))return false;A[i*m+j]=std::sqrt(x);logdet+=std::log(x);}
   else A[i*m+j]=x/A[j*m+j];
  }return true;
 }
 static std::vector<double> solve(const std::vector<double>&L,const std::vector<double>&b,int m){
  std::vector<double>x=b;
  for(int i=0;i<m;i++){for(int j=0;j<i;j++)x[i]-=L[i*m+j]*x[j];x[i]/=L[i*m+i];}
  for(int i=m-1;i>=0;i--){for(int j=i+1;j<m;j++)x[i]-=L[j*m+i]*x[j];x[i]/=L[i*m+i];}return x;
 }

 void training(int draws,int seed){
  train_draws=draws;data_seed=seed;observed.assign(m,0);RNG data(seed);
  if(draws<=0)throw std::runtime_error("positive IID training count required");
  for(int i=0;i<draws;i++)observed[data.index(m)]=1;
  distinct=std::accumulate(observed.begin(),observed.end(),0);
  if(mode!="prior_fit")return;
  std::vector<int> ids;for(int x=0;x<m;x++)if(observed[x])ids.push_back(x);
  int t=ids.size();std::vector<double> H(t*n),gram(t*t,0),diff(t);double logdet;
  bool ready=false;
  for(int attempt=0;attempt<20&&!ready;attempt++){
   for(int j=0;j<n;j++)for(int q=0;q<D;q++)theta[j*D+q]=(q?tau:sa)*rng.norm(rng.gen);
   for(int i=0;i<t;i++)for(int j=0;j<n;j++){
    double z=0;for(int q=1;q<D;q++)z+=theta[j*D+q]*X[ids[i]*(d+1)+q-1];H[i*n+j]=sp(z);
   }
   std::fill(gram.begin(),gram.end(),0);
   for(int i=0;i<t;i++)for(int h=0;h<t;h++)for(int j=0;j<n;j++)gram[i*t+h]+=H[i*n+j]*H[h*n+j];
   ready=chol(gram,t,logdet);
  }
  if(!ready)throw std::runtime_error("rank-deficient initialization");
  recompute();for(int i=0;i<t;i++)diff[i]=n*(s+.25)*y[ids[i]]-total[ids[i]];
  auto adjust=solve(gram,diff,t);
  for(int j=0;j<n;j++)for(int i=0;i<t;i++)theta[j*D]+=H[i*n+j]*adjust[i];
  recompute();
 }

 void record(std::ostream&out,long sweep,double sec){
  recompute();double low=INF,high=-INF,energy=0;
  for(int x=0;x<m;x++){if(observed[x])low=std::min(low,y[x]*total[x]/n);high=std::max(high,y[x]*total[x]/n);}
  if(low<s-1e-8)throw std::runtime_error("margin violated");
  double readenergy=0,inenergy=0,keigen=0,paritytotal=0;
  for(int x=0;x<m;x++)paritytotal+=y[x]*total[x]/(double(n)*m);
  for(int j=0;j<n;j++){
   const double *v=&theta[j*D];readenergy+=v[0]*v[0];
   for(int z=1;z<D;z++)inenergy+=v[z]*v[z];
   double G=0;for(int x=0;x<m;x++){double preact=0;for(int z=1;z<D;z++)preact+=v[z]*X[x*(d+1)+z-1];G+=y[x]*sp(preact)/m;}keigen+=G*G/n;
  }

  std::vector<std::pair<double,int>> order;
  for(int j=0;j<n;j++){double e=0;for(int q=0;q<D;q++)e+=theta[j*D+q]*theta[j*D+q];energy+=e;order.push_back({e,j});}
  std::sort(order.rbegin(),order.rend());std::vector<double> bulk=total;std::set<int> orientations,pairs;int aligned=0;
  double sig=((d/2-1)%2)?-1:1;
  for(int a=0;a<k;a++){
   auto *v=&theta[order[a].second*D];neuron(v,tmp);for(int x=0;x<m;x++)bulk[x]-=tmp[x];
   int orient=0;double chi=1;for(int i=0;i<d;i++){if(v[i+2]>0)orient|=1<<i;else chi=-chi;}
   orientations.insert(orient);pairs.insert(std::min(orient,(m-1)^orient));if(v[0]*sig*chi>0)aligned++;
  }
  double bm=0,br=0;for(int x=0;x<m;x++){bm+=y[x]*bulk[x]/(n*m);br+=bulk[x]*bulk[x]/(double(n)*n*m);}
  out<<std::setprecision(15)<<"{\"algorithm\":\"partial-data-coordinate-gauge-rotation\",\"prior\":\""<<profile<<"\",\"readout_std\":"<<sa<<",\"incoming_std\":"<<tau<<",\"dimension\":"<<d<<",\"width\":"<<n<<",\"seed\":"<<seed<<",\"initialization\":\""<<mode<<"\",\"sweep\":"<<sweep<<",\"seconds\":"<<sec<<",\"min_margin\":"<<low<<",\"max_margin\":"<<high<<",\"energy_per_neuron\":"<<energy/n<<",\"readout_energy\":"<<readenergy/n<<",\"incoming_energy\":"<<inenergy/n<<",\"parity_kernel\":"<<keigen<<",\"parity_output\":"<<paritytotal<<",\"bulk_parity\":"<<bm<<",\"bulk_rms\":"<<std::sqrt(br)<<",\"top_orientation_count\":"<<orientations.size()<<",\"top_pair_count\":"<<pairs.size()<<",\"top_readout_alignment_count\":"<<aligned<<",\"top_scaled_norms\":[";
  for(int a=0;a<std::min(n,k+8);a++){if(a)out<<',';out<<std::sqrt(order[a].first/n);}out<<"]";
  double error=0,unseen_error=0,hinge=0;
  for(int x=0;x<m;x++){double margin=y[x]*total[x]/n;error+=margin<=0;if(!observed[x])unseen_error+=margin<=0;hinge+=std::max(.5-margin,0.);}
  std::vector<double> transfer(m,0);double nearby_kernel=0;
  for(int j=0;j<n;j++){
   const double *v=&theta[j*D];
   double modifier=(v[2]>=0?1.:-1.)*(v[3]>=0?1.:-1.),coef=0;
   for(int x=0;x<m;x++){
    double z=0;for(int q=1;q<D;q++)z+=v[q]*X[x*(d+1)+q-1];
    double hx=sp(z),g=y[x]*X[x*(d+1)+1]*X[x*(d+1)+2];
    transfer[x]+=v[0]*modifier*hx/n;
    coef+=g*hx/m;
   }
   nearby_kernel+=coef*coef/n;
  }
  double transfer_error=0,transfer_l2=0,transfer_hinge=0;
  for(int x=0;x<m;x++){
   double q=-(d-3)*(transfer[x]+transfer[m-1-x])/(2*s);
   double g=y[x]*X[x*(d+1)+1]*X[x*(d+1)+2];
   transfer_error+=q*g<=0;transfer_l2+=(q-g)*(q-g);transfer_hinge+=std::max(1-q*g,0.);
  }
  double central=1;for(int j=1;j<=(d-2)/2;j++)central*=double(d-1-j)/j;
  double rho=central/(std::pow(2.,d-1)*std::sqrt(double(d)));
  out<<",\"training_draws\":"<<train_draws<<",\"data_seed\":"<<data_seed<<",\"distinct_observations\":"<<distinct<<",\"uniform_error\":"<<error/m<<",\"unseen_error\":"<<(distinct<m?unseen_error/(m-distinct):0)<<",\"uniform_hinge\":"<<hinge/m
     <<",\"physical_energy\":"<<energy/(2*n)<<",\"energy_ratio\":"<<energy*rho/(2*n*s)
     <<",\"nearby_parity_kernel\":"<<nearby_kernel<<",\"transfer_comparator_error\":"<<transfer_error/m
     <<",\"transfer_comparator_l2\":"<<std::sqrt(transfer_l2/m)<<",\"transfer_comparator_hinge\":"<<transfer_hinge/m<<"}\n";out.flush();
 }
};
int main(int argc,char**argv){
 if(argc<8){std::cerr<<"dimension width seed initialization sweeps record_every output [margin] [prior: isotropic/fan-in/small]\n";return 2;}
 int d=std::stoi(argv[1]),n=std::stoi(argv[2]),seed=std::stoi(argv[3]);std::string mode=argv[4];long sweeps=std::stol(argv[5]),every=std::stol(argv[6]);double s=argc>8?std::stod(argv[8]):.5;
 auto start=std::chrono::steady_clock::now();std::string prior=argc>9?argv[9]:"isotropic";if(prior!="isotropic"&&prior!="fan-in"&&prior!="small"&&prior.rfind("cold-",0)!=0)throw std::runtime_error("invalid prior");Chain c(d,n,seed,mode,s,prior);c.training(argc>10?std::stoi(argv[10]):32,argc>11?std::stoi(argv[11]):1);std::ofstream out(argv[7]);
 std::ofstream states(std::string(argv[7])+".theta",std::ios::binary);
 if(!out||!states)throw std::runtime_error("cannot open output");
 for(long j=0;j<=sweeps;j++){
  if(j%every==0){double sec=std::chrono::duration<double>(std::chrono::steady_clock::now()-start).count();c.record(out,j,sec);states.write(reinterpret_cast<const char*>(c.theta.data()),std::streamsize(c.theta.size()*sizeof(double)));states.flush();if(j%(100*every)==0)std::cout<<"sweep "<<j<<" seconds "<<sec<<std::endl;}
  if(j<sweeps)c.sweep();
 }
}
