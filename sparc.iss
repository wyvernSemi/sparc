
[Setup]
AppName                 = SPARC
AppVerName              = SPARC_1_0_0
DefaultDirName          = {pf}\sparc
DisableProgramGroupPage = yes
OutputBaseFilename      = setup_sparc_1_0_0

[Dirs]
Name: "{app}\objs"

[Files]
; This inno file
Source: "sparc.iss";                             DestDir: "{app}"

; Linux/cygwin make file
Source: "makefile";                              DestDir: "{app}"

; Documentation
Source: "docs\sparc_iss.html";                   DestDir: "{app}\doc";
Source: "docs\images\UltraSparc.png";            DestDir: "{app}\doc\images"
Source: "docs\images\wyvernbg.jpg";              DestDir: "{app}\doc\images"

; Visual studio files for 2010 express
Source: "msvc\sparc.sln";                        DestDir: "{app}\msvc"
Source: "msvc\sparc\sparc.vcxproj";              DestDir: "{app}\msvc\sparc"
Source: "msvc\sparc\sparc.vcxproj.filters";      DestDir: "{app}\msvc\sparc"

; Pre-compiled executable for windows
Source: "msvc\Release\sparc_iss.exe";            DestDir: "{app}"

; Source code
Source: "src\dis.c";                             DestDir: "{app}\src"
Source: "src\elf.c";                             DestDir: "{app}\src"
Source: "src\elf.h";                             DestDir: "{app}\src"
Source: "src\execute.c";                         DestDir: "{app}\src"
Source: "src\Getopt.c";                          DestDir: "{app}\src"
Source: "src\inst.c";                            DestDir: "{app}\src"
Source: "src\inst.h";                            DestDir: "{app}\src"
Source: "src\read_write.c";                      DestDir: "{app}\src"
Source: "src\sparc.h";                           DestDir: "{app}\src"
Source: "src\sparc_iss.h";                       DestDir: "{app}\src"
Source: "src\sparc_iss.c";                       DestDir: "{app}\src"

; Model test libs and scripts
Source: "test\libsparc.c";                       DestDir: "{app}\test"
Source: "test\libsparc.h";                       DestDir: "{app}\test"
Source: "test\compile";                          DestDir: "{app}\test"
Source: "test\mapfile";                          DestDir: "{app}\test"
Source: "test\runtests";                         DestDir: "{app}\test"

; Model test source code
Source: "test\add.s";                            DestDir: "{app}\test"
Source: "test\and.s";                            DestDir: "{app}\test"
Source: "test\bicc.s";                           DestDir: "{app}\test"
Source: "test\call.s";                           DestDir: "{app}\test"
Source: "test\div.s";                            DestDir: "{app}\test"
Source: "test\jmpl.s";                           DestDir: "{app}\test"
Source: "test\ld.s";                             DestDir: "{app}\test"
Source: "test\ldstub.s";                         DestDir: "{app}\test"
Source: "test\mul.s";                            DestDir: "{app}\test"
Source: "test\mulscc.s";                         DestDir: "{app}\test"
Source: "test\or.s";                             DestDir: "{app}\test"
Source: "test\rd_wr.s";                          DestDir: "{app}\test"
Source: "test\save_rest.s";                      DestDir: "{app}\test"
Source: "test\sethi.s";                          DestDir: "{app}\test"
Source: "test\shift.s";                          DestDir: "{app}\test"
Source: "test\speedo.s";                         DestDir: "{app}\test"
Source: "test\st.s";                             DestDir: "{app}\test"
Source: "test\sub.s";                            DestDir: "{app}\test"
Source: "test\swap.s";                           DestDir: "{app}\test"
Source: "test\tadd.s";                           DestDir: "{app}\test"
Source: "test\ticc.s";                           DestDir: "{app}\test"
Source: "test\trap_table.s";                     DestDir: "{app}\test"
Source: "test\tsub.s";                           DestDir: "{app}\test"
Source: "test\xor.s";                            DestDir: "{app}\test"

