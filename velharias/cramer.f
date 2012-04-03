! cramer.f
!
! Resolve sistemas de equações utilizando a Regra de Cramer.
!  Para permutações: algoritmo lexográfico de Knuth
!  Para determinantes: fórmula de Leibniz
!
! Autor: Pedro Sousa Lacerda, 2010
!
! ATENÇÃO: Isso é lixo. Fico impressionado com a quantidade sintaxes
!          bizarras que programadores conseguem aprender. (Também com
!          as gambiarras introduzidas para concluir o software :-)

program cramer
	implicit none

	! variáveis usadas em múltiplas funções (como funcionam os escopos?)
	integer :: seq(0:8), perms(0:362880,0:8), paridades(0:362880)

	integer :: n=0, i, j
	real	:: sis(9,10), temp(9,9), det

	! ler n
	do while (n<1 .or. n>9)
		10	write(*,'(a)',advance='no') "n: "
			read(*,*,err=10) n
	end do

	! ler sistema
	do i=1,n
		do j=1,n+1
			20	write(*,'(a,i1,a,i1,a)',advance='no') 'mat(', i , ',' , j , ')= '
				read(*,*,err=20) sis(i,j)
		end do
	end do

	! determinante
	det = determinante(sis, n)
	do i=1,n
		do j=1,n
			if (j==i) then
				temp(:,j) = sis(:,n+1)
			else
				temp(:,j) = sis(:,j)
			end if
		end do
		write(*,'(a,a,f5.2)') 'a'+i-1, '= ', determinante(temp, n)/det
	end do
	
	contains
		real function determinante(mat, n)
			implicit none
	
			real, intent(in)	:: mat(0:8,0:8)
			integer, intent(in)	:: n

			integer :: i, j, k, fat
			real	:: soma, produto

			! gera sequência para permutar
			fat = 1
			do k=0,n-1
				seq(k) = k+1
				fat = fat*(k+1)
			end do
	
			call permutacoes(seq)

			! calcula determinante pela fórmula de Leibniz
			soma = 0
			do j=0,fat-1
				produto = 1
				do i=0,n-1
					produto = produto * mat(i, perms(j,i)-1)
				end do
				soma = soma + paridades(j)*produto
			end do
	
			determinante = soma

		end function
		
		
		subroutine permutacoes(seq)
			! passeia pelas permutações usando o algoritmo lexicográfico de Knuth

			integer tam, i, j, k, l, seq(0:n-1)
			k=0
			l=0
			call add_perm(k,l)
			tam = size(seq)
			do while (.true.)
				j = tam-2
				do while (j >= 0 .and. seq(j) >= seq(j+1))
					j = j-1
				end do
		
				if (j < 0) exit
		
				i = tam-1
				do while (i > j .and. seq(i) < seq(j))
					i = i-1
				end do
		
				call troca(i,j) ! inverteu,
				k = k+1 		! aumente o número

				seq(j+1:) = seq(n-1:j:-1) 			! inverteu?,
				if (mod((n-j-1)/2,2)==1) k = k+1 	! aumente o número
				l = l+1
				call add_perm(k,l)
			end do
	
		end subroutine

		subroutine troca(x, y)
			integer x, y, temp
			temp = seq(x)
			seq(x) = seq(y)
			seq(y) = temp
		end subroutine
		
		subroutine add_perm(inv, pos)
			integer inv, pos, i
			do i=0,n-1
				perms(pos,i) = seq(i)
			end do
			if (mod(inv,2)==0) then
				paridades(pos) = 1
			else
				paridades(pos) = -1
			end if
		end subroutine
		
end program
