#!/bin/gawk -f
function max(left,right) {
  if (left<right)
    return right;
  return left;
}
function min_not_done() {
  min=100000;
  for (i in dist)
  {
    if (done[i]==0 && dist[i]<min)
      min = dist[i];
  }
  if (min == 100000)
    exit 0;
  for (i in dist)
  {
    if (done[i]==0 && dist[i] == min)
      return i;
  }
  print "min_not_done unsuccessful";
  exit 1;
}
function weight(left,right) 
{
  return sqrt((x[left]-x[right])^2 + (y[left]-y[right])^2) - alpha*max(h[right]-h[left],0);
}
function dijkstra()
{
  dist[start] = 0;
  while (1)
  {
    i = min_not_done();
    for (j in nn[i])
    {
      k = nn[i][j];
      d = weight(i,k);
      if (d<0)
      {
        print  " negative weight " name[i] " -> " name[k];
        print " max alpha: " sqrt((x[i]-x[k])^2 + (y[i]-y[k])^2)/(h[k]-h[i]);
      }
      if (dist[k]>dist[i]+d)
      {
        dist[k]=dist[i]+d;
        from[k]=i;
        horiz[k]=horiz[i] + sqrt((x[i]-x[k])^2 + (y[i]-y[k])^2);
        vert[k]=vert[i] + max(h[k]-h[i],0);
      }
    }
    done[i] = 1;
    printf("%2d %5d %3d (from %2d) %s\n", i,horiz[i],vert[i], from[i], name[i]);
  }
}
function path(to)
{
  result = "";
  H=0;
  V=0;
  while (to != start)
  {
    last = to;
    to = from[to];
    H=H+sqrt((x[last]-x[to])^2+(y[last]-y[to])^2);
    V=V+max(h[last]-h[to],0);
    result=result "<-" to;
  }
  return result " " H"+"V;
}
function bellman()
{
  dist[start] = 0;
  for (i=1; i<length(name); ++i)
  {
    for (u in name)
      for (w in nn[u])
      {
        v=nn[u][w];
        if (dist[u] + weight(u,v) < dist[v])
        {
          dist[v] = dist[u]+weight(u,v);
          from[v]=u;
        }
      }
  }
  for (u in name)
  {
    for (w in nn[u])
    {
      v = nn[u][w];
      if (dist[u]+weight(u,v) < dist[v])
      {
        print "negative cycle detected";
        exit 1;
      }
    }
  }
  for (u in dist)
  {
    printf("%2d (from %2d): %4d %s, %s\n", u,from[u],dist[u],name[u],path(u));
  }
  exit;
}

{ name[$1] = $2;
  x[$1] = $3;
  y[$1] = $4;
  h[$1] = $5;
  for (i=6; i<=NF; ++i)
    nn[$1][i-5]=$i;
  done[$1] = 0;
  dist[$1] = 100000; 
  horiz[$1] = 0;
  vert[$1] = 0;
}
BEGIN { nn[0][0] = ""; 
  from[start] = start;
  if (algo == "")
    algo = "dijkstra";
  print "using start=" start;
  print "      alpha=" alpha;
  print "      algo =" algo;

}
END {
  if (algo == "dijkstra")
    dijkstra();
  if (algo == "bellman")
    bellman();
  print "unknown algorithm";
}


