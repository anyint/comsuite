	subroutine sym_left_tt(ig,f0,f,key,nfn,isort)
c	key=1 conjugated rotation  (D*)     Important only
c	key=2 usual                (D )       for irel=2
	use atom_mod
	use manager_mod
	use solid_mod
	use units_mod
	implicit none
	integer, intent(in) :: ig,key,nfn,isort
	complex*16, intent(in) :: f0(nfn)
	complex*16, intent(out) :: f(nfn)
	integer :: l,ie,m,lm,km,lm0,in,jn,li,ist,ii,jj,mj
	real*8 :: y0(2*maxb+1),y1(2*maxb+1),t0(2*maxb+1)
	complex*16 :: y0j(2*maxb+2),t0j(2*maxb+2)
      if(irel<=1) then
	  do l=0,lmb(isort)
          do ie=1,ntle(l,isort)
	      in=1
		    if(augm(ie,l,isort)/='LOC') in=2
		    do jn=1,in
c ------------- Real components ----------------------------------
              do m=-l,l
                lm=l*(l+1)+m+1
                km=indbasa(jn,ie,lm,isort)
	          lm0=l+m+1
	          t0(lm0)=dreal(f0(km))
	        enddo
	        call rotate1(t0,y0,l,u(1,ig),1)
c ------------- Imaginary components ----------------------------------
              do m=-l,l
                lm=l*(l+1)+m+1
                km=indbasa(jn,ie,lm,isort)
	          lm0=l+m+1
	          t0(lm0)=dimag(f0(km))
	        enddo
	        call rotate1(t0,y1,l,u(1,ig),1)
              do m=-l,l
                lm=l*(l+1)+m+1
                km=indbasa(jn,ie,lm,isort)
	          lm0=l+m+1
	          f(km)=dcmplx(y0(lm0),y1(lm0))
	        enddo
	      enddo
	    enddo  !! over ie
	  enddo   !! over l
      else if(irel==2) then
        li=0
        do l=0,lmb(isort)
          ist=-1
          if(l==0) ist=1
          do ii=ist,1,2
            li=li+1
            jj=l+l+ii
            do ie=1,ntle(l,isort)
	        in=1
		      if(augm(ie,l,isort)/='LOC') in=2
		      do jn=1,in
	          lm0=0
                do mj=-jj,jj,2
                  lm0=lm0+1
		          call getlimj(lm,l,ii,mj,li,1)
                  km=indbasa(jn,ie,lm,isort)
	            t0j(lm0)=f0(km)
	          enddo
	          call rotate2(t0j,y0j,l,ii,uj(1,ig),1,key)
                do mj=-jj,jj,2
			      call getlimj(lm,l,ii,mj,li,1)
                  km=indbasa(jn,ie,lm,isort)
	            if(ifia(ig).eq.1) then
	              lm0=(jj+mj)/2+1
	              f(km)=y0j(lm0)
	            else if(ifia(ig).eq.-1) then
	              lm0=(jj-mj)/2+1
	              f(km)=y0j(lm0)*(-1)**((ii-mj)/2)
	            endif
	          enddo
	        enddo
	      enddo
	    enddo
	  enddo   !! over l
      endif
	end