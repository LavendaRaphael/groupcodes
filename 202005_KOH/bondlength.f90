!==========================================================================================
!===============================================================[VERSION]
!2020.06.25
!===============================================================[FUNCTION]
!Calculate bond length.
!===============================================================[NOTES]
!Using the intel compiler version >= 2019.
!===============================================================[USE]
!./bondlength.x bondlength.in
!===============================================================[INFILE]
!winfile        'wannier90.win'
!bond_type
!       Sb      O       2.5d0   #atom_name1, atom_name2, bond_length
!end bond_type
!bond_targ      1
!===============================================================[DATAFILE]
!wannier90.win
!===============================================================[OUTFILE]
![my.err]       #if program exit unexpected
!bondlength.log
!bondlength.out
!=========================================================================================
program main
implicit none

integer, parameter               :: DP = 8
real (DP), parameter             :: pi = 3.14159265359, bohr2angstrom=0.529177210903, eang2debye=4.799d0
integer                          :: clock_start, clock_end, clock_rate
integer (DP)                     :: i, j, k, l, m, ios, temp_int0, input_tot
real (DP)                        :: temp_real0, temp_real (10)
character (len=100)              :: temp_char0, temp_char (10), leng=" (65 ('='), ", infile, datafile, outfile, errfile='my.err', logfile
integer, parameter               :: errfile_unit=11, infile_unit=12, datafile_unit=13, outfile_unit=15
character (len=100), allocatable :: input_list(:), temp_chararray(:)
integer (DP), allocatable        :: temp_intarray(:)

integer (DP)                    :: atomtype_tot, atom_tot, bond_tot, modify, mol_tot, bond_targ
integer (DP), allocatable       :: bond_type(:,:), atom_neighbor(:,:), coor_num(:), atom_mol(:), atom_type (:), mol_head(:), mol_structure(:,:), atomtype_count(:), atom_mark(:), coor_type(:,:), atom_no(:)
character (len=100), allocatable :: bond_name(:,:), atomtype_name(:)
real (DP), allocatable           :: bond_rc(:), atom_posi(:,:), coor_posi(:,:,:)
real (DP)                        :: cell_size(3), delta(3), dist

open (errfile_unit, file=errfile, status='replace')
call system_clock (clock_start)
!===============================================================[READ INFILE]
call get_command_argument(1,infile)
write (errfile_unit, leng//"'[READ INFILE]: "//trim(infile)//"')")
open(infile_unit, file = infile, status = 'old')
input_tot = 3
allocate(input_list(input_tot))
input_list = (/'winfile', 'bond_type', 'bond_targ'/)
do i = 1, input_tot
do while (.true.)
        read (infile_unit, *, iostat = ios) temp_char0
        if (ios < 0) then
                write (errfile_unit, *) "ERROR: parameter'"//trim(input_list(i))//"' not found in "//trim(infile)//"!"
                stop
        endif
        if (temp_char0 /= input_list(i)) cycle
        backspace(infile_unit)
        exit
enddo
select case(i)
case(1)
        read (infile_unit, *) temp_char0, temp_char(2)
        write (errfile_unit, "(2A25)") trim(temp_char0), trim(temp_char(2))
        read (temp_char(2), *) datafile
case (2)
        read (infile_unit, *) temp_char0
        temp_int0 = 0
        do while (.true.)
              read (infile_unit, *) temp_char0
              if (temp_char0 == 'end') then
                      do j = 1, temp_int0 + 1
                              backspace(infile_unit)
                      enddo
                      exit
              else
                      temp_int0 = temp_int0 + 1
              endif
        enddo
        bond_tot = temp_int0
        allocate(temp_chararray(bond_tot*2))
        temp_chararray = "unkown"
        atomtype_tot = 0
        write (errfile_unit, ' (A25)') "atomtype_name"
        do j = 1, bond_tot
                read (infile_unit, *) temp_char(1:2)
                if (all(temp_chararray /= temp_char(1))) then
                        atomtype_tot = atomtype_tot + 1
                        temp_chararray(atomtype_tot) = temp_char(1)
                        write (errfile_unit, ' (A25, A25)') '',trim(temp_char(1))
                endif
                if (all(temp_chararray /= temp_char(2))) then
                        atomtype_tot = atomtype_tot + 1
                        temp_chararray(atomtype_tot) = temp_char(2)
                        write (errfile_unit, ' (A25, A25)') '',trim(temp_char(2))
                endif
        enddo
        allocate (atomtype_name(atomtype_tot))
        atomtype_name = temp_chararray(1:atomtype_tot)
        deallocate(temp_chararray)
        do j = 1, bond_tot
                backspace(infile_unit)
        enddo
        allocate(bond_type(bond_tot,2), bond_rc(bond_tot))
        write (errfile_unit, ' (A25)') "bond_type"
        do j = 1, bond_tot
                read (infile_unit, *) temp_char(1:3)
                write (errfile_unit, ' (A25, 3A25)') '',(/(trim(temp_char(k)), k = 1, 3)/)
                read (temp_char(3), *) bond_rc(j)
                bond_type(j,1) = findloc(atomtype_name, temp_char(1),dim=1)
                bond_type(j,2) = findloc(atomtype_name, temp_char(2),dim=1)
        enddo
case (3)
        read (infile_unit, *) temp_char0, temp_char(2)
        write (errfile_unit, "(2A25)") trim(temp_char0), trim(temp_char(2))
        read (temp_char(2), *) bond_targ
endselect
rewind (infile_unit)
enddo
close (infile_unit)
deallocate(input_list)
!===============================================================[READ DATAFILE]
write (errfile_unit, leng//"'[READ DATAFILE]: "//trim(datafile)//"')")
open(datafile_unit, file = datafile, status = 'old')
input_tot = 2
allocate(input_list(input_tot))
input_list = (/'begin unit_cell_cart', 'begin atoms_cart'/)
do i = 1, input_tot
do while (.true.)
        read (datafile_unit, '(A)', iostat = ios) temp_char0
        if (ios < 0) then
                write (errfile_unit, *) "ERROR: parameter'"//trim(input_list(i))//"' not found in "//trim(datafile)//"!"
                stop
        endif
        if (temp_char0 /= input_list(i)) cycle
        write (errfile_unit, "(A25)") trim(input_list(i))
        exit
enddo
select case (i)
case (1)
        read (datafile_unit, *) cell_size(1)
        read (datafile_unit, *) temp_char(1),cell_size(2)
        read (datafile_unit, *) temp_char(1:2),cell_size(3)
        write (errfile_unit, ' (A25, 3F25.10)') 'cell_size',cell_size
case (2)
        allocate (atomtype_count(atomtype_tot))
        atomtype_count = 0
        l = 0
        do while (.true.)
                read (datafile_unit, *) temp_char0
                if (temp_char0 == 'end') exit
                temp_int0 = findloc(atomtype_name, temp_char0, dim=1)
                if (temp_int0 == 0) then
                        l = l + 1
                        cycle
                endif
                atomtype_count(temp_int0) = atomtype_count(temp_int0) + 1
        enddo
        atom_tot = sum(atomtype_count)
        do j = 1, atom_tot + l + 1
                backspace(datafile_unit)
        enddo
        write (errfile_unit, ' (A25,I25)') 'atom_unkown', l
        do j = 1, atomtype_tot
                write (errfile_unit, ' (A25,I25)') trim(atomtype_name(j)),atomtype_count(j)
        enddo
        write (errfile_unit, ' (A25,I25)') 'atom_tot', atom_tot
        allocate (atom_posi(atom_tot, 3), atom_type(atom_tot))
        k = 0
        do while (k < atom_tot)
                read (datafile_unit, *) temp_char0, temp_real(1:3)
                temp_int0 = findloc(atomtype_name, temp_char0, dim=1)
                if (temp_int0 == 0) cycle
                k = k + 1
                atom_type(k) = temp_int0
                atom_posi(k,:) = temp_real(1:3) - floor(temp_real(1:3)/cell_size)*cell_size
        enddo
endselect
rewind (datafile_unit)
enddo
close (datafile_unit)
!===============================================================[FIND_MOLECULE]
write (errfile_unit, leng//"'[FIND_MOLECULE]')")
allocate(atom_neighbor(atom_tot,atom_tot),coor_num(atom_tot),coor_posi(atom_tot,atom_tot,3),coor_type(atom_tot,atom_tot))
coor_num = 0
do i = 1,atom_tot
do j = i+1,atom_tot
do k = 1,bond_tot
        if (not ((bond_type(k,1)==atom_type(i) .and. bond_type(k,2)==atom_type(j)) .or. (bond_type(k,1)==atom_type(j) .and. bond_type(k,2)==atom_type(i)))) cycle
        delta = atom_posi (j, :) - atom_posi (i, :)
        delta = delta - nint (delta / cell_size) * cell_size
        if (maxval (abs (delta)) > bond_rc(k)) cycle
        dist = sqrt (delta (1) ** 2 + delta (2) ** 2 + delta (3) ** 2)
        if (dist > bond_rc(k)) cycle
        coor_num(i) = coor_num(i) + 1
        coor_posi(i, coor_num(i), :) = delta
        atom_neighbor(i,coor_num(i)) = j
        coor_type(i,coor_num(i)) = k
enddo
enddo
enddo
allocate(atom_mol(atom_tot))
atom_mol = (/(i,i=1,atom_tot)/)
modify = 1
k=0
write (errfile_unit, '(2A25)') 'iterate','modify'
do while (modify>0)
        modify = 0
        do i = 1, atom_tot
                if ( coor_num(i)==0 ) cycle
                if (any((/(atom_mol(atom_neighbor(i,j)),j=1,coor_num(i))/) /= atom_mol(i))) then
                        modify = modify + 1
                        atom_mol(i) = minval((/(atom_mol(atom_neighbor(i,j)),j=1,coor_num(i))/))
                        do j = 1, coor_num(i)
                                atom_mol(atom_neighbor(i,j)) = atom_mol(i)
                        enddo
                endif
        enddo
        k = k + 1
        write (errfile_unit, '(2I25)') k, modify
enddo
mol_tot = 1
allocate(temp_intarray(atom_tot))
temp_intarray(1) = atom_mol(1)
do i = 2, atom_tot
        if (any(temp_intarray(1:mol_tot) == atom_mol(i))) cycle
        mol_tot = mol_tot + 1
        temp_intarray(mol_tot) = atom_mol(i)
enddo
write (errfile_unit, '(A25,I25)') 'mol_tot', mol_tot
allocate(mol_head(mol_tot))
mol_head = temp_intarray(1:mol_tot)
deallocate(temp_intarray)
allocate(mol_structure(mol_tot,atomtype_tot))
mol_structure = 0
do i = 1, atom_tot
        atom_mol(i) = findloc(mol_head,atom_mol(i),dim=1)
        mol_structure(atom_mol(i),atom_type(i)) = mol_structure(atom_mol(i),atom_type(i)) + 1
enddo
!===============================================================[CONSTRUCT MOL]
write (errfile_unit, leng//"'[CONSTRUCT MOL]')")
allocate(atom_mark(atom_tot))
atom_mark = 0
do i = 1, mol_tot
        atom_mark (mol_head(i)) = 1
enddo
modify = 1
k=0
write (errfile_unit, '(2A25)') 'iterate','modify'
do while (modify>0)
        modify = 0
        do i = 1, atom_tot
                if ( coor_num(i)==0 ) cycle
                if (all((/(atom_mark(atom_neighbor(i,j)),j=1,coor_num(i))/) == atom_mark(i))) cycle
                modify = modify + 1
                if (atom_mark(i)==0) then
                        atom_mark(i)=1
                        temp_int0 = findloc((/(atom_mark(atom_neighbor(i,j)),j=1,coor_num(i))/),1,dim=1)
                        atom_posi(i,:) = atom_posi(atom_neighbor(i,temp_int0),:) - coor_posi(i,temp_int0,:)
                endif
                do j = 1, coor_num(i)
                        atom_posi(atom_neighbor(i,j),:) = atom_posi(i,:) + coor_posi(i,j,:)
                        atom_mark(atom_neighbor(i,j)) = 1 
                enddo
        enddo
        k = k + 1
        write (errfile_unit, '(2I25)') k, modify
enddo
!===============================================================[MOLECULE STRUCTURE]
write (errfile_unit, leng//"'[MOLECULE STRUCTURE]')")
write (errfile_unit, '(A25)') 'mol_structure'
write (temp_char0,*) atomtype_tot
write (errfile_unit, "(A25,"//temp_char0//"A25)") '',(/(trim(atomtype_name(i)),i=1,atomtype_tot)/)
do i = 1, mol_tot
        write (errfile_unit, "(I25,"//temp_char0//"I25)") i,mol_structure(i,1:)
enddo
write (errfile_unit, "(A25,"//temp_char0//"I25)") 'SUM',(/(sum(mol_structure(:,i)),i=1,atomtype_tot)/)
!===============================================================[ATOM MARK]
allocate(atom_no(atom_tot))
atom_no = 0
do i = 1, atomtype_tot
k = 0
do j = 1, atom_tot
        if (atom_type(j) /= i) cycle
        k = k + 1
        atom_no(j) = k
enddo
enddo
!===============================================================[OUTPUT]
outfile = 'bondlength.out'
write (errfile_unit, leng//"'[OUTPUT]:"//trim(outfile)//"')")
open (outfile_unit, file=outfile, status='replace')
write(outfile_unit, "(A, A24, 4A25)") '#','mol','bond','bondlength','atom_1','atom_2'
do i=1, mol_tot
        l=0
        do j=1, atom_tot
                if (atom_mol(j) /= i) cycle
                if ( coor_num(j)==0 ) cycle
                do k=1, coor_num(j)
                        if (coor_type(j,k) /= bond_targ) cycle
                        l = l + 1
                        temp_real0 = sqrt(coor_posi(j,k,1)**2+coor_posi(j,k,2)**2+coor_posi(j,k,3)**2)
                        write(temp_char(1), *) atom_no(j)
                        temp_char(1) = trim(atomtype_name(atom_type(j)))//trim(adjustl(temp_char(1)))
                        write(temp_char(2), *) atom_no(atom_neighbor(j,k))
                        temp_char(2) = trim(atomtype_name(atom_type(atom_neighbor(j,k))))//trim(adjustl(temp_char(2)))
                        write(outfile_unit, "(2I25, F25.10, 2A25)") i, l, temp_real0, trim(temp_char(1)),trim(temp_char(2))
                enddo
        enddo
enddo
close(outfile_unit)
!===============================================================[FINALIZE]
call system_clock (clock_end, clock_rate)
write (errfile_unit, ' (A25, F)') 'Elapsed time (s)', (clock_end-clock_start)/real(clock_rate)
close(errfile_unit)
logfile='bondlength.log'
call rename(errfile, logfile)
end program main
