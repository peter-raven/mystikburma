PROGRAM EventyrEditor;

  USES
    Crt,
    WinTTT5,
    FastTTT5,
    MenuTTT5,
    ReadTTT5;

  TYPE
    BitFilType = FILE OF Byte;
    Kompas        = (Nord, Syd, Oest, Vest, Op, Ned);
    RetningsType  = ARRAY[1 .. 115, Nord .. Ned] OF Byte;
    TingDataRec   = RECORD
                      Placering,
                      Vaegt      : Byte;
                    END;
    TingData      = ARRAY[1 .. 115] OF TingDataRec;

  VAR
    BitFil      : BitFilType;
    Retning     : RetningsType;
    Objekt      : TingData;
    A           : Byte;
    B           : Kompas;
    HovedMenu   : Menu_Record;
    TastTrykket,
    Fejl        : Integer;


PROCEDURE EditRetninger;

  VAR
    Nr   : Byte;

BEGIN
  FBox(1,1,80,25,WHITE,BLUE,1);
  WriteCenter(1,WHITE,BLUE,'Editere retninger');
  Read_Byte(3,4,3, 'Hvilket stednummer õnskes editeret ? ',0,Nr,1,255);
  GotoXY(3,7);
  Writeln('Sted nr. ', Nr,' :');
  GotoXY(3,9);
  Write('Nord : ', Retning[Nr,Nord],'  Syd : ', Retning[Nr,Syd]);
  Write('  ùst : ', Retning[Nr,Oest],'  Vest : ', Retning[Nr,Vest]);
  GotoXY(3,10);
  Writeln('  Op : ', Retning[Nr,Op],'  Ned : ', Retning[Nr,Ned]);
  Writeln('Skriv nu numre for nord, syd, õst, vest, op og ned, adskilt af mellemrum.');
  Readln(Retning[Nr,Nord], Retning[Nr,Syd], Retning[Nr,Oest], Retning[Nr,Vest], Retning[Nr, Op], Retning[Nr, Ned]);
  Writeln;
  Writeln('Ok.');
  Delay(1000);
END;


PROCEDURE EditObjekter;

  VAR
    Nr      : Byte;

BEGIN
  Nr := 1;
  FBox(1,1,80,25,WHITE,BLUE,1);
  WriteCenter(1,WHITE,BLUE,'Editere Objektdata');
  Read_Byte(3,4,3, 'Hvilket objektnummer õnskes editeret ? ',0,Nr,1,255);
  GotoXY(3,7);
  Writeln('Objekt nr. ', Nr,' :');
  GotoXY(3,9);
  Writeln('Startplacering : ', Objekt[Nr].Placering,'  Vëgt : ', Objekt[Nr].Vaegt);
  Read_Byte(3,13,3, 'Ny startplacering : ',0,Objekt[Nr].Placering,0,255);
  Read_Byte(3,14,3, 'Ny vëgt           : ',0,Objekt[Nr].Vaegt,0,21);
  GotoXY(3,16);
  Writeln('Ok.');
  Delay(1000);
END;


PROCEDURE Save;

BEGIN
  ClrScr;
  FBox(19,8,61,12,YELLOW,RED,1);
  WriteAt(30,10,YELLOW,RED,'BDATA.DAT gemmes.');
  ASSIGN(BitFil, 'C:\TPASCAL\PRG\BDATA.DAT');
  ReWrite(BitFil);
  FOR A := 1 TO 115 DO
    FOR B:= Nord to Ned DO
      Write(BitFil,Retning[A,B]);
  FOR A := 1 TO 115 DO
    BEGIN
      Write(BitFil,Objekt[A].placering);
      Write(BitFil,Objekt[A].Vaegt);
    END;
  Close(BitFil);
END;


BEGIN
  Menu_Set(HovedMenu);
    With HovedMenu DO
      BEGIN
        Heading1 := 'Burma - Data Editor';
        Topic[1] := 'Editere retninger';
        Topic[2] := 'Editere objektdata';
        Topic[3] := 'Save & Quit';
        TotalPicks := 3;
        AddPrefix := 1;
        BoxType := 1;
      END;
  ClrScr;
  FBox(19,8,61,12,YELLOW,RED,1);
  WriteAt(30,10,YELLOW,RED,'BDATA.DAT indlëses.');
  ASSIGN(BitFil, 'C:\TPASCAL\PRG\BDATA.DAT');
  Reset(BitFil);
  FOR A := 1 TO 115 DO
    FOR B:= Nord to Ned DO
      Read(BitFil,Retning[A,B]);
  FOR A := 1 TO 115 DO
    BEGIN
      Read(BitFil,Objekt[A].placering);
      Read(BitFil,Objekt[A].Vaegt);
    END;
  Close(BitFil);

  REPEAT
    ClrScr;
    DisplayMenu(HovedMenu,False,TastTrykket,Fejl);
    CASE TastTrykket OF
      1 : EditRetninger;
      2 : EditObjekter;
      3 : Save;
    END;
  UNTIL TastTrykket = 3;

END.
