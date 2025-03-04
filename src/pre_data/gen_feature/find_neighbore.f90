subroutine find_neighbore(iatom,natom,xatom,AL,Rc_type,num_neigh,list_neigh, &
        dR_neigh,iat_neigh,ntype,iat_type,m_neigh,Rc_M,map2neigh_M,list_neigh_M, &
        num_neigh_M,iat_neigh_M)
        
        implicit none
        integer natom,ntype
        real*8 Rc_type(100),Rc_M
        real*8 xatom(3,natom),AL(3,3)
        integer iatom(natom)
        real*8 dR_neigh(3,m_neigh,ntype,natom)
        integer iat_neigh(m_neigh,ntype,natom),list_neigh(m_neigh,ntype,natom)
        integer iat_neigh_M(m_neigh,ntype,natom)
        integer list_neigh_M(m_neigh,ntype,natom),map2neigh_M(m_neigh,ntype,natom)
        integer num_neigh(ntype,natom),num_neigh_M(ntype,natom)
        integer num_type(ntype),num_type_M(ntype)
        integer nperiod(3)
        integer iflag,i,j,k,num
        integer i1,i2,i3,itype
        integer iat_type(100)
        integer itype_atom(natom)
        real*8 d,Rc2,dx1,dx2,dx3,dx,dy,dz,dd
        integer m_neigh
        
        list_neigh = 0
        dR_neigh = 0
        iflag=0
        
        write(*,*) "AL"
        write(*,*) AL

        do i=1,3
            d=dsqrt(AL(1,i)**2+AL(2,i)**2+AL(3,i)**2)
            nperiod(i)=int(Rc_M/d)+1
            if(d.lt.2*Rc_M) iflag=1 
        enddo

        do i=1,natom
            xatom(1,i)=mod(xatom(1,i)+10.d0,1.d0)
            xatom(2,i)=mod(xatom(2,i)+10.d0,1.d0)
            xatom(3,i)=mod(xatom(3,i)+10.d0,1.d0)
        enddo
            
        itype_atom=0
        
        do i=1,natom
            do j=1,ntype
                if(iatom(i).eq.iat_type(j)) then
                    itype_atom(i)=j
                endif
            enddo
            if(itype_atom(i).eq.0) then
                write(6,*) "this atom type didn't found", iatom(i),iat_type(1:ntype)
                stop
            endif
        enddo
        
        Rc2=Rc_M**2

        do i=1,natom

            if(iflag.eq.1) then
                num_type=0
                num_type_M=0
                
                do  j=1,natom
                    do i1=-nperiod(1),nperiod(1)
                        do i2=-nperiod(2),nperiod(2)
                            do i3=-nperiod(3),nperiod(3) 
                                
                                dx1=xatom(1,j)-xatom(1,i)+i1
                                dx2=xatom(2,j)-xatom(2,i)+i2
                                dx3=xatom(3,j)-xatom(3,i)+i3

                                dx=AL(1,1)*dx1+AL(1,2)*dx2+AL(1,3)*dx3
                                dy=AL(2,1)*dx1+AL(2,2)*dx2+AL(2,3)*dx3
                                dz=AL(3,1)*dx1+AL(3,2)*dx2+AL(3,3)*dx3

                                dd=dx**2+dy**2+dz**2
                                
                                if(dd.lt.Rc2.and.dd.gt.1.D-8) then
                                    itype=itype_atom(j)
                                    num_type_M(itype)=num_type_M(itype)+1
                                    
                                    if(num_type_M(itype).gt.m_neigh) then
                                        write(6,*) "Error! maxNeighborNum too small", m_neigh
                                        stop
                                    endif
                                    
                                    list_neigh_M(num_type_M(itype),itype,i)=j
                                    iat_neigh_M(num_type_M(itype),itype,i)=iatom(j)

                                    if(dd.lt.Rc_type(itype_atom(i))**2.and.dd.gt.1.D-8) then
                                        num_type(itype)=num_type(itype)+1
                                        list_neigh(num_type(itype),itype,i)=j
                                        iat_neigh(num_type(itype),itype,i)=iatom(j)
                                        map2neigh_M(num_type(itype),itype,i)=num_type_M(itype)
                                        dR_neigh(1,num_type(itype),itype,i)=dx
                                        dR_neigh(2,num_type(itype),itype,i)=dy
                                        dR_neigh(3,num_type(itype),itype,i)=dz
                                    endif

                                endif
                            enddo
                        enddo
                    enddo
                enddo
                num_neigh(:,i)=num_type(:)
                num_neigh_M(:,i)=num_type_M(:)
                
            endif
            
            if(iflag.eq.0) then
                
                num_type=0
                num_type_M=0
                
                do  j=1,natom
                    dx1=xatom(1,j)-xatom(1,i)
                    if(abs(dx1+1).lt.abs(dx1)) dx1=dx1+1
                    if(abs(dx1-1).lt.abs(dx1)) dx1=dx1-1
                    
                    dx2=xatom(2,j)-xatom(2,i)
                    if(abs(dx2+1).lt.abs(dx2)) dx2=dx2+1
                    if(abs(dx2-1).lt.abs(dx2)) dx2=dx2-1
                    
                    dx3=xatom(3,j)-xatom(3,i)
                    if(abs(dx3+1).lt.abs(dx3)) dx3=dx3+1
                    if(abs(dx3-1).lt.abs(dx3)) dx3=dx3-1

                    dx=AL(1,1)*dx1+AL(1,2)*dx2+AL(1,3)*dx3
                    dy=AL(2,1)*dx1+AL(2,2)*dx2+AL(2,3)*dx3
                    dz=AL(3,1)*dx1+AL(3,2)*dx2+AL(3,3)*dx3

                    dd=dx**2+dy**2+dz**2
                    
                    if(dd.lt.Rc2.and.dd.gt.1.D-8) then
                    !if(dd.lt.Rc2.and.dd.gt.1.D-8) then
                        itype=itype_atom(j)
                        num_type_M(itype)=num_type_M(itype)+1

                        if(num_type_M(itype).gt.m_neigh) then
                            write(6,*) "Error! maxNeighborNum too small", m_neigh
                            stop
                        endif
                        
                        list_neigh_M(num_type_M(itype),itype,i)=j
                        iat_neigh_M(num_type_M(itype),itype,i)=iatom(j)
                        
                        if(dd.lt.Rc_type(itype_atom(i))**2.and.dd.gt.1.D-8) then
                            num_type(itype)=num_type(itype)+1
                            
                            list_neigh(num_type(itype),itype,i)=j
                            iat_neigh(num_type(itype),itype,i)=iatom(j)
                            map2neigh_M(num_type(itype),itype,i)=num_type_M(itype)

                            dR_neigh(1,num_type(itype),itype,i)=dx
                            dR_neigh(2,num_type(itype),itype,i)=dy
                            dR_neigh(3,num_type(itype),itype,i)=dz
                        endif
                    endif
                
                enddo
                num_neigh(:,i)=num_type(:)
                num_neigh_M(:,i)=num_type_M(:)
            endif
        enddo 
        
        !********************
        ! write dRneigh.dat
        !********************
        
        !print *, "print m_neigh:", m_neigh
        !print *, "print ntype:", ntype
        !print *, "print natom:", natom
        !open(1314, file='./PWdata/dRneigh.dat', access='append')
        ! m_neigh,ntype,natom
        !do k=1, natom
        !    do j=1, ntype
        !        do i=1, m_neigh
        !            ! wlj altered 
        !            ! match the selection criteria with on-the-fly calc (aboves)
        !            dd = dR_neigh(1, i, j, k) **2 + dR_neigh(2, i, j, k)**2 + dR_neigh(3, i, j, k)**2
        !            
        !            if ((dd < Rc2).and.(dd > 1.D-8)) then
        !            !if ((abs(dR_neigh(1, i, j, k)) + abs(dR_neigh(2, i, j, k)) + abs(dR_neigh(3, i, j, k))) > 1.D-8) then
        !                write(1314, "(3(E17.10,1x), 1x, i6)") dR_neigh(1, i, j, k), dR_neigh(2, i, j, k), dR_neigh(3, i, j, k), list_neigh(i,j,k)
        !            else
        !                write(1314, *) 0,0,0,0
        !            end if
        !
        !        enddo
        !    enddo
        !enddo
        
        !close(1314)

end subroutine find_neighbore
