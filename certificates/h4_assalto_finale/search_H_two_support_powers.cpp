#include <bits/stdc++.h>
#include <omp.h>
using namespace std;using u64=uint64_t;using u128=__uint128_t;
u64 mulm(u64 a,u64 b,u64 m){return (u128)a*b%m;}u64 powm(u64 a,u64 e,u64 m){u64 r=1;while(e){if(e&1)r=mulm(r,a,m);a=mulm(a,a,m);e>>=1;}return r;}
bool prime64(u64 n){if(n<2)return 0;for(u64 p:{2ULL,3ULL,5ULL,7ULL,11ULL,13ULL,17ULL,19ULL,23ULL,29ULL,31ULL,37ULL}){if(n%p==0)return n==p;}u64 d=n-1,s=0;while(!(d&1)){d>>=1;s++;}for(u64 a:{2ULL,325ULL,9375ULL,28178ULL,450775ULL,9780504ULL,1795265022ULL}){if(a%n==0)continue;u64 x=powm(a%n,d,n);if(x==1||x==n-1)continue;bool comp=1;for(u64 i=1;i<s;i++){x=mulm(x,x,n);if(x==n-1){comp=0;break;}}if(comp)return 0;}return 1;}
u64 tonelli(u64 n,u64 p){if(powm(n,(p-1)/2,p)!=1)return 0;if(p%4==3)return powm(n,(p+1)/4,p);u64 q=p-1,s=0;while(!(q&1)){q>>=1;s++;}u64 z=2;while(powm(z,(p-1)/2,p)!=p-1)z++;u64 c=powm(z,q,p),x=powm(n,(q+1)/2,p),t=powm(n,q,p),m=s;while(t!=1){u64 i=1,tt=mulm(t,t,p);while(tt!=1){tt=mulm(tt,tt,p);i++;if(i>=m)return 0;}u64 bb=powm(c,1ULL<<(m-i-1),p);x=mulm(x,bb,p);c=mulm(bb,bb,p);t=mulm(t,c,p);m=i;}return x;}
u64 exactOrder(u64 a,u64 p,u64 N,const vector<u64>&fs){u64 o=N;for(u64 f:fs)while(o%f==0&&powm(a,o/f,p)==1)o/=f;return o;}
vector<int>sieve(int n){vector<bool>isp(n+1,true);isp[0]=isp[1]=false;for(int i=2;1LL*i*i<=n;i++)if(isp[i])for(long long j=1LL*i*i;j<=n;j+=i)isp[j]=false;vector<int>ps;for(int i=3;i<=n;i+=2)if(isp[i]&&i!=5)ps.push_back(i);return ps;}
vector<u64> powers(u64 q,u64 lim){vector<u64>v;u64 x=q;while(x<=lim){v.push_back(x);if(x>lim/q)break;x*=q;}return v;}
int main(int ac,char**av){if(ac<4){cerr<<"Q out pmax\n";return 2;}int Q=stoi(av[1]);string out=av[2];u64 PMAX=stoull(av[3]);auto ps=sieve(Q);ofstream f(out);atomic<unsigned long long>variants(0),primes(0),dyad(0),hits(0);double st=omp_get_wtime();
#pragma omp parallel for schedule(dynamic,1)
for(size_t i=0;i<ps.size();i++){u64 q=ps[i];auto qp=powers(q,PMAX/8);vector<string>local;for(size_t j=i+1;j<ps.size();j++){u64 t=ps[j];auto tp=powers(t,PMAX/8);for(u64 qa:qp)for(u64 tc:tp){u128 odd=(u128)qa*tc;if(odd>=PMAX/8)break;
// p = 4 mod 5 branch
for(int b=3;b<=60;b++){u128 NN=odd<<b;if(NN>=PMAX)break;u64 N=(u64)NN,p=N+1;if(p%5!=4)continue;variants++;if(!prime64(p))continue;primes++;u64 sq=tonelli(5,p);if(!sq)continue;u64 x=mulm((3+sq)%p,(p+1)/2,p);vector<u64>fs{2,q,t};u64 R=exactOrder(5,p,N,fs),E=exactOrder(x,p,N,fs);int aR=__builtin_ctzll(R),aE=__builtin_ctzll(E);if(!((aR==1&&aE>=2)||(aE==1&&aR>=2)))continue;dyad++;u64 r=R/2,s=E/2;if(gcd(r,s)==1&&r%5&&s%5&&((r+s)&1)){hits++;ostringstream z;z<<"p="<<p<<" branch=4 b="<<b<<" q="<<q<<" qa="<<qa<<" t="<<t<<" tc="<<tc<<" R="<<R<<" E="<<E<<" r="<<r<<" s="<<s;local.push_back(z.str());}}
// p = 1 mod 5 branch
u128 five=5;for(int ef=1;ef<=30;ef++,five*=5){if(odd*five>=PMAX/16)break;for(int b=4;b<=60;b++){u128 NN=odd*five;NN<<=b;if(NN>=PMAX)break;u64 N=(u64)NN,p=N+1;variants++;if(!prime64(p))continue;primes++;u64 sq=tonelli(5,p);if(!sq)continue;u64 x=mulm((3+sq)%p,(p+1)/2,p);vector<u64>fs{2,5,q,t};u64 R=exactOrder(5,p,N,fs),E=exactOrder(x,p,N,fs);int aR=__builtin_ctzll(R),aE=__builtin_ctzll(E);if(!((aR==1&&aE>=2)||(aE==1&&aR>=2)))continue;dyad++;u64 r=R/2,s=E/2;if(gcd(r,s)==1&&r%5&&s%5&&((r+s)&1)){hits++;ostringstream z;z<<"p="<<p<<" branch=1 b="<<b<<" f="<<ef<<" q="<<q<<" qa="<<qa<<" t="<<t<<" tc="<<tc<<" R="<<R<<" E="<<E<<" r="<<r<<" s="<<s;local.push_back(z.str());}}}
}}
if(!local.empty()){
#pragma omp critical
{for(auto&z:local)f<<z<<"\n";}}
}
cerr<<"DONE Q="<<Q<<" primes_base="<<ps.size()<<" PMAX="<<PMAX<<" variants="<<variants<<" primes="<<primes<<" dyad="<<dyad<<" hits="<<hits<<" sec="<<omp_get_wtime()-st<<"\n";
}
