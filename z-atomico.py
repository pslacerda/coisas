#!/usr/bin/python
# *--encoding: utf-8--*

# Z Atômico
#	Encontra a camada mais energética de um átomo a partir de seu
#	número atômico Z. Facilmente expandível para camada mais externa.
#
# Autor: Pedro Sousa Lacerda, 2009

z = int(raw_input('Z: '))

# Diagrama de Linus Pauling na ordem de percorrimento
linus = ((1, 's',  2), (2, 's',  2), (2, 'p',  6), (3, 's', 2), 
	 (3, 'p',  6), (4, 's',  2), (3, 'd', 10), (4, 'p', 6), 
	 (5, 's',  2), (4, 'd', 10), (5, 'p',  6), (6, 's', 2), 
	 (4, 'f', 14), (5, 'd', 10), (6, 'p',  6), (7, 's', 2),
	 (5, 'f', 14), (6, 'd', 10), (7, 'p',  6))


soma = 0
for item in linus:
	# percorra o diagrama contado os elétrons
	soma = soma + item[2]

	if soma >= z:
		temp = item[2] - (soma - z) # remova os excessos da contagem

		print u"camada mais energética:"
		print item[0], item[1], temp
		break
