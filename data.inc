%ifndef __DATA
%define __DATA

[section .data]
;;;
;;; General
;;;
ERR_MSG db ""
	db 10, 27, "[1;31m"
	db "Erro!", 10
	db 27, "[0m", 0

ERR_INVALID_DATA db ""
	db 27,"[1;31m",
	db "Dados inválidos!"
	db 27,"[0m",10, 0

;;;
;;; helpers.asm exclusive
;;;
HELPERS_LOCALE_NAME_PROMPT db ""
	db "    Nome                              : ", 0

HELPERS_LOCALE_LATITUDE_PROMPT db ""
	db "    Lat.  <graus, minutos, orientação>: ", 0

HELPERS_LOCALE_LONGITUDE_PROMPT db ""
	db "    Long. <graus, minutos, orientação>: ", 0


;;;
;;; grav.asm exclusive
;;;
GRAV_FANCY_PROGRAM_HEADER db ""
	db 27, "[1;32m"
	db "Universidade Federal da Bahia", 10
	db "MATA49 Programação de Software Básico", 10, 10
	db "Gravação de coordenadas geográficas", 10, 10
	db 27, "[0m", 0

GRAV_NEW_LOCALE_HEADER db ""
	db 27, "[1;34m"
	db "Nova localidade (↵ encerra)", 10
	db 27,"[0m", 0

GRAV_FILENAME_PROMPT db ""
	db "Arquivo de coordenadas (↵ encerra): ", 0


;;;
;;; {calc,bulk,interactive}.asm exclusive
;;;
CALC_PROGRAM_HEADER db ""
	db "Universidade Federal da Bahia", 10
	db "MATA49 Programação de Software Básico", 10, 10
	db "Cálculo de distâncias geodésicas", 10, 10, 0
	
CALC_FANCY_PROGRAM_HEADER db ""
	db 27, "[1;32m"
	db "Universidade Federal da Bahia", 10
	db "MATA49 Programação de Software Básico", 10, 10
	db "Cálculo de distâncias geodésicas", 10, 10
	db 27, "[0m", 0

CALC_ORIGIN_PROMPT db ""
	db "Informe a origem (↵ encerra): ", 10, 0

CALC_DECIDE_MODE_PROMPT db ""
	db 10, "Arquivo de coordenadas ou destino (↵ encerra) : ", 0

CALC_ORIGIN_HEADER db ""
	db "Origem                        Latitude   Longitude",10,0

CALC_DESTINATION_HEADER db ""
	db "Destino                       Latitude   Longitude   Distância (km)",10,0
	
BULK_OUTPUT_FILE_PROMPT db ""
	db "Arquivo para salvar relatório (↵ STDOUT): ",0

%endif
