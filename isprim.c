bool prim(int n){

	register int x;

	//////////////////////

        if(n<2) return false;
	if(n==2) return true;

	if(n%2==0) return false;

	for(x=3;x<=sqrt(n);x+=2){
		if(n%x==0)
			return false;
	}

	return true;

	//////////////////////

}