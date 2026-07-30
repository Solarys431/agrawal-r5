#include <bits/stdc++.h>
using namespace std; using u64=uint64_t; using u128=__uint128_t;
struct Mat{u64 a,b,c,d;};
u64 mulm(u64 a,u64 b,u64 m){return (u128)a*b%m;}
u64 powm(u64 a,u64 e,u64 m){u64 r=1;while(e){if(e&1)r=mulm(r,a,m);a=mulm(a,a,m);e>>=1;}return r;}
Mat mmul(Mat x,Mat y,u64 p){return {(mulm(x.a,y.a,p)+mulm(x.b,y.c,p))%p,(mulm(x.a,y.b,p)+mulm(x.b,y.d,p))%p,(mulm(x.c,y.a,p)+mulm(x.d,y.c,p))%p,(mulm(x.c,y.b,p)+mulm(x.d,y.d,p))%p};}
Mat mpow(Mat x,u64 e,u64 p){Mat r{1,0,0,1};while(e){if(e&1)r=mmul(r,x,p);x=mmul(x,x,p);e>>=1;}return r;}
bool id(Mat x){return x.a==1&&x.b==0&&x.c==0&&x.d==1;}
vector<pair<int,int>> fac(int n,const vector<int>&spf){vector<pair<int,int>>f;while(n>1){int q=spf[n],e=0;while(n%q==0){n/=q;e++;}f.push_back({q,e});}return f;}
u64 ordint(u64 a,u64 p,u64 N,const vector<pair<int,int>>&f){u64 o=N;for(auto [q,e]:f)for(int i=0;i<e;i++){if(powm(a,o/q,p)==1)o/=q;else break;}return o;}
u64 ordmat(u64 p,u64 N,const vector<pair<int,int>>&f){Mat D{2,1,1,1};u64 o=N;for(auto [q,e]:f)for(int i=0;i<e;i++){if(id(mpow(D,o/q,p)))o/=q;else break;}return o;}
int main(int ac,char**av){int N=ac>1?stoi(av[1]):50000000;if(N<2||N>numeric_limits<int>::max()-2){cerr<<"N out of range\n";return 2;}string out=ac>2?av[2]:"inert_pk.txt";vector<int>spf(static_cast<size_t>(N)+2U);vector<int>pr;for(int i=2;i<=N+1;i++){if(!spf[i]){spf[i]=i;pr.push_back(i);}for(int q:pr){if(q>spf[i]||1LL*i*q>N+1)break;spf[static_cast<size_t>(i)*static_cast<size_t>(q)]=q;}}ofstream f(out);long long inert=0,adm=0,gt=0;long double minratio=1e100;int minp=0;u64 minR=0,minE=0;for(int p:pr){if(p<3||p>N)continue;if(p%5!=2&&p%5!=3)continue;inert++;auto fm=fac(p-1,spf),fp=fac(p+1,spf);u64 R=ordint(5,p,p-1,fm),E=ordmat(p,p+1,fp);if(R%2||E%2)continue;u64 r=R/2,s=E/2;if(gcd(r,s)!=1||((r+s)&1)!=1||r%5==0||s%5==0)continue;adm++;u128 m=(u128)R*E;long double ratio=(long double)m/p;if(ratio<minratio){minratio=ratio;minp=p;minR=R;minE=E;}if(m<(u128)p){gt++;f<<"p="<<p<<" R="<<R<<" E="<<E<<" r="<<r<<" s="<<s<<" m="<<(u64)m<<" k="<<(p%(u64)m)<<"\n";}}cerr<<"DONE N="<<N<<" inert="<<inert<<" admissible="<<adm<<" p_gt_m="<<gt<<" minratio="<<(double)minratio<<" minp="<<minp<<" R="<<minR<<" E="<<minE<<"\n";}
