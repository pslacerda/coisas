%ifndef IO
%define IO
;'

%define SYS_CREAT  8
%define SYS_READ   3
%define SYS_WRITE  4

%define STDIN  0
%define STDOUT 1


;; Oflag values for open().  POSIX Table 6-4.
%define O_CREAT        0q0100    ; creat file if it doesnt exist
%define O_EXCL         0q0200    ; exclusive use flag
%define O_NOCTTY       0q0400    ; do not assign a controlling terminal
%define O_TRUNC        0q1000    ; truncate flag

;; File status flags for open() and fcntl().  POSIX Table 6-5.
%define O_APPEND       0q2000    ; set append mode
%define O_NONBLOCK     0q4000    ; no delay
 
;; File access modes for open() and fcntl().  POSIX Table 6-6.
%define O_RDONLY           0    ; open(name, O_RDONLY) opens read only
%define O_WRONLY           1    ; open(name, O_WRONLY) opens write only
%define O_RDWR             2    ; open(name, O_RDWR) opens read/write

;; POSIX masks for st_mode.
%define S_IRWXU        0q700 ; owner has read, write and execute permission
%define S_IRUSR        0q400 ; owner has read permission
%define S_IWUSR        0q200 ; owner has write permission
%define S_IXUSR        0q100 ; owner has execute permission
%define S_IRWXG        0q070 ; group has read, write and execute permission
%define S_IRGRP        0q040 ; group has read permission
%define S_IWGRP        0q020 ; group has write permission
%define S_IXGRP        0q010 ; group has execute permission
%define S_IRWXO        0q007 ; others have read, write and execute permission
%define S_IROTH        0q004 ; others have read permission
%define S_IWOTH        0q002 ; others have write permission
%define S_IXOTH        0q001 ; others have execute permission

%endif
