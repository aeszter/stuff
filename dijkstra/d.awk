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
  print "using start=" start;
  print "      alpha=" alpha;

}
END {
  dist[start] = 0;
  while (1)
  {
    i = min_not_done();
    for (j in nn[i])
    {
      k = nn[i][j];
      d = sqrt((x[i]-x[k])**2 + (y[i]-y[k])**2) - alpha*max(h[k]-h[i],0);
      if (d<0)
      {
        print  " negative weight " name[i] " -> " name[k];
        print " max alpha: " sqrt((x[i]-x[k])**2 + (y[i]-y[k])**2)/(h[k]-h[i]);
      }
      if (dist[k]>dist[i]+d)
      {
        dist[k]=dist[i]+d;
        from[k]=i;
        horiz[k]=horiz[i] + sqrt((x[i]-x[k])**2 + (y[i]-y[k])**2);
        vert[k]=vert[i] + max(h[k]-h[i],0);
      }
    }
    done[i] = 1;
    print i,name[i],horiz[i],vert[i],"from " from[i];
  }
}


