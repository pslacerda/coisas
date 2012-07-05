%ifndef __DATA
%define __DATA

[section .data]
ERR_MSG db ""
	db 10, 27, "[1;31m"
	db "Erro!", 10
	db 27, "[0m", 0

GRAV_FANCY_PROGRAM_HEADER db ""
	db 27, "[1;32m"
	db "Universidade Federal da Bahia", 10
	db "MATA49 Programação de Software Básico", 10, 10
	db "Gravação de coordenadas geográficas", 10, 10
	db 27, "[0m", 0

GRAV_NEW_LOCALE_HEADER db ""
	db 27, "[1;34m", "Nova localidade (↵ encerra)", 10
	db 27,"[0m", 0

GRAV_FILENAME_PROMPT db ""
	db "Arquivo de coordenadas (↵ encerra): ", 0


%endif
