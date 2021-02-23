encodegln(s,n)={
  my(v);
  v=[if(x==32,0,x-96)|x<-Vec(Vecsmall(s))];
  if(#v>n^2,warning("string truncated to length ",n^2));
  v = Vec(v,n^2);
  matrix(n,n,i,j,v[(i-1)*n+j]);
}


\\ fonction de décodage prenant en argument une matrice et sa dimension
decodegln(mat,n)={
	my(v);
	v=vector(n*n);
	k=1;
	for(i=1,n,
	for(j=1,n,
		\\ on revient dans Z pour éviter l'erreur de "type incorrect"
		\\ avec Strchr quelques lignes plus bas
		l=lift(mat[i,j]);
		v[k]=if(l==0,32,l+96);
		k=k+1)
		);		
	\\ on "recadre" pour correspondre au checksum
	v=Vec(v,143); 
\\ on n'oublie pas de remettre en caractère ascii
   Strchr(v);
}


\\ On reprend la fonction qui calcule les puissance du précédent challenge
\\ en faisant attention à la dimension (ici c'est une matrice 12x12, et plus 40x40)
expoMat(m,n) = {
	if(n==0,return( matid(12)));
	if(n== 1,return (m));
	if(n%2==0,return (expoMat(m^2,n/2)), return (m*expoMat(m^2,(n-1)/2)));
}



\\fonction qui trouve le plus petit exposant de la matrice tel que m^k=id dans Z/27Z
ordre(m)={
	id=matid(12);
	k=1;
	tmp=Mod(m,27);
	\\ definie ainsi, tmp sera toujours à valeurs dans Z/27Z
	while(tmp!=id,tmp=tmp*m;k++);
	k;
}


\\ On récupère le texte du fichier
text=readstr("input.txt")[1];
\\ On encode, mtext est une matrice contenant les lettres chiffrées
mtext=encodegln(text,12);
\\ On s'assure de rester dans Z/27Z
mtext=Mod(mtext,27);
\\ On récupère l'exposant minimal de la matrice
d=ordre(mtext);

\\Maintenant qu'on connait cet exposant,
\\ on résout inv*65537=1[d] à l'aide de la fonction gcdext qui calcule les coefficients de la relation de Bezout
\\ On obtient alors inv, qui est l'inverse de e modulo d.

inv=gcdext(65537,d)[1];

\\ on a mtext=m^e, où m est le message d'origine
\\ on connait désormais inv tel que e*inv=1[d] et on sait que m^d=id,
\\ donc il faut élever mtext à la puissance inv pour retrouver le message :

mtext=expoMat(mtext,inv);
\\ il reste à déchiffrer 
m=decodegln(mtext,12);
print(m);
