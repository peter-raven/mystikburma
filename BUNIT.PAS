UNIT BUnit;

INTERFACE

  USES
    Crt, Dos,
    PRSounds;

  TYPE
    TlType        = (Lang, MedSyn, Kort, Lille, KunOrd);
    FlagType      = ARRAY[1 .. 115] OF Boolean;
    FlagType2     = ARRAY[1 .. 25] OF Boolean;
    TingDataRec   = RECORD
                      Placering,
                      Vaegt      : Byte;
                    END;
    TingData      = ARRAY[1 .. 115] OF TingDataRec;
    HjType        = ARRAY[1 .. 35] OF STRING[80];
    Kompas        = (Nord, Syd, Oest, Vest, Op, Ned);
    Retningstype  = ARRAY[1 .. 115, Nord .. Ned] OF Byte;
    DataTypeI     = ARRAY[1 .. 440] OF STRING[80];
    BitFilType    = FILE OF Byte;

  CONST
    AntalTing  = 97;

  VAR
    Ksted     : STRING[80];
    BaaretVaegt, Nyhed, Hunger, Kasse, Sejl, KokOp, Flint, Passw, Loronov,
    Heli, StedNummer, AnLn, OrdNummer, Alt, NuOrd, FundetOrd, DenDetNr,
    GFord, Samlnr
              : Byte;
    Score, AntalTraek     : Word;
    Kyats, Indkoeb
              : Real;
    FlagB     : FlagType2;
    Retning   : RetningsType;
    Objekt    : TingData;
    Hjlp      : HjType;
    RetKompas : Kompas;
    Tf        : Boolean;
    Flag      : FlagType;
    Obj       : DataTypeI;
    BitFil,
    GemFil    : BitFilType;
    FilNavn   : STRING;

  FUNCTION Ucase(Uch : Char) : Char;
  FUNCTION UcaseStr(Ustr : STRING) : STRING;
  FUNCTION ObjTekst(Tnr : Byte ; Tl : TlType) : STRING;
  PROCEDURE Writelc(SkrLin : STRING);
  PROCEDURE Byt(VAR Byt1, Byt2 : Byte);
  PROCEDURE LinieInput(VAR Ordre : STRING ; SkilTegn : Boolean);
  PROCEDURE LF(AntalLF : Byte);
  PROCEDURE TrykTast;
  PROCEDURE StartSkaerm;
  PROCEDURE DisplaySted(StedNummer : Byte ; LangBskr : Boolean);
  PROCEDURE Besked(MsgNr : Byte);
  PROCEDURE UndTekst(Unr : Byte);
  PROCEDURE Hjaelp;
  PROCEDURE DisplayTing;
  PROCEDURE TegnStatus;
  PROCEDURE Save;
  PROCEDURE Load;
  PROCEDURE VisSted;

IMPLEMENTATION

TYPE
  DataTypeII    = ARRAY[1 .. 100] OF STRING[80];

VAR
  Loc,
  Msg      : DataTypeII;
  TekstFil : Text;
  A,
  Locsnr,
  Msgsnr   : Byte;
  B        : Word;

PROCEDURE LaesLocs;

VAR
  B    : Word;

BEGIN
  Assign(TekstFil, FExpand('BLOCS.DAT'));
  Reset(TekstFil);
  FOR B:= 1 TO ((Locsnr - 1) * 100) DO
    Readln(TekstFil,Loc[1]);
  B := 0;
  REPEAT
    Inc(B);
    Readln(TekstFil,Loc[B]);
  UNTIL B = 100;
  Close(TekstFil);
END;

PROCEDURE LaesMsgs;

VAR
  B    : Word;

BEGIN
  Assign(TekstFil, FExpand('BMSGS.DAT'));
  Reset(TekstFil);
  FOR B:= 1 TO ((Msgsnr - 1) * 100) DO
    Readln(TekstFil,Msg[1]);
  B := 0;
  REPEAT
    Inc(B);
    Readln(TekstFil,Msg[B]);
  UNTIL B = 100;
  Close(TekstFil);
END;


FUNCTION Ucase(Uch : Char) : Char;

BEGIN
  CASE Uch OF
    'a' .. 'z' : Ucase := UpCase(Uch);
    'ë'        : Ucase := 'í';
    'õ'        : Ucase := 'ù';
    'Ü'        : Ucase := 'è';
  ELSE
    Ucase := Uch;
  END;
END;

FUNCTION UcaseStr(Ustr : STRING) : STRING;

  VAR
    A : Byte;

BEGIN
  FOR A := 1 to Length(Ustr) DO
    Ustr[A] := Ucase(Ustr[A]);
  UcaseStr := Ustr;
END;

PROCEDURE Byt(VAR Byt1, Byt2 : Byte);

  VAR
    Temp : Byte;

BEGIN
  Temp := Byt1;
  Byt1 := Byt2;
  Byt2 := Temp;
END;

PROCEDURE TrykTast;

BEGIN
  Writeln;
  Writeln('Tryk en tast.');
  Writeln;
  REPEAT
    (* Bla *)
  UNTIL ReadKey <> '';
END;

PROCEDURE Writelc(SkrLin : STRING);

BEGIN
  IF Anln = 23 THEN
    BEGIN
      Write('<MERE>');
      TrykTast;
      GotoXY(1,25);
      Anln := 0
    END;
  Writeln(SkrLin);
  Inc(Anln);
END;

PROCEDURE LinieInput(VAR Ordre : STRING ; SkilTegn : Boolean); (* Indlës kommandolinie *)

  TYPE
    SkilleTegnSet = SET OF Char;

  VAR
    Y          : Byte;
    Tegn       : Char;
    PaaSkaerm  : STRING[80];
    SkilleTegn : SkilleTegnSet;

BEGIN
  SkilleTegn := [',', '.', '!', '?', '"', ''''];
  Y := WhereY;
  Ordre := '';
  PaaSkaerm := '-> ';
  GotoXY(1,Y);
  Write(PaaSkaerm);
  REPEAT
    REPEAT
      Tegn := ReadKey;
    UNTIL Tegn <> '';
    IF (Tegn = #8) AND (Length(PaaSkaerm) > 3) THEN
      BEGIN
        Delete(PaaSkaerm,Length(PaaSkaerm),1);
        Delete(Ordre,Length(Ordre),1);
        GotoXY(1,Y);
        Write(PaaSkaerm,' ');
        GotoXY(1,Y);
        Write(PaaSkaerm);
      END;
    IF Length(PaaSkaerm) = 79 THEN
      BEGIN
        Sound(1000);
        Delay(20);
        NoSound;
      END;
    IF (Length(PaaSkaerm) <> 79) AND (Tegn <> #13) AND (Tegn <> #8) THEN
      BEGIN
        PaaSkaerm := PaaSkaerm + Tegn;
        IF (Tegn IN SkilleTegn) AND (SkilTegn = True) THEN
          (* Her sker intet *)
        ELSE
          Ordre := Ordre + Tegn;
        GotoXY(1,Y);
        Write(PaaSkaerm);
      END;
  UNTIL Tegn = #13;
  Ordre := Ordre + ' ';
  GotoXY(1,Y);
  Writeln(PaaSkaerm);
END;

PROCEDURE LF(AntalLF : Byte);

  VAR
    A : Byte;

BEGIN
  FOR A:=1 TO AntalLF DO
    Writeln;
END;



PROCEDURE StartSkaerm;

BEGIN
  ClrScr;
  GotoXY(1,25);
  Writeln('       ***--- Mystik i Burma ---***');
  Writeln('            Med Captain Sansom');
  Writeln('              (Version 1.1)');
  Writeln;
  Writeln('   Endnu et DANSK fremtidseventyrspil !');
  Writeln;
  Writeln('         (C) Peter Ravnholt 1990');
  Writeln;
  Writeln('    En produktion fra RealWare Games !');
  LF(2);
  Writeln('Dette program er ShareWare, som frit mÜ kopieres og deles ud, MEN -');
  Writeln('Hvis du vil bruge programmet, SKAL du registrere dig som bruger af');
  Writeln('Programmet. Prisen er kun 60,- kr., sÜ gõr det venligst. Som ');
  Writeln('registreret bruger fÜr du bl.a. information om alle nye programmer,');
  Writeln('der udkommer fra RealWare - beskrivelser, bestillingstilbud, o.lign.');
  Writeln('For mere information om spillet, brugerregistrering og andet, kan');
  Writeln('du udprinte og lëse filen "BURMA.DOC".');
  Writeln;
  TrykTast;
END;

PROCEDURE DisplaySted(StedNummer : Byte ; LangBskr : Boolean);

  VAR
    FundetNummer,
    A,
    B             : Byte;

BEGIN
  IF (StedNummer < 16) AND (Locsnr > 1) THEN
    BEGIN
      Locsnr := 1;
      LaesLocs;
    END;
  IF (StedNummer > 15) AND (StedNummer < 31) AND (Locsnr <> 2) THEN
    BEGIN
      Locsnr := 2;
      LaesLocs;
    END;
  IF (StedNummer > 30) AND (StedNummer < 47) AND (Locsnr <> 3) THEN
    BEGIN
      Locsnr := 3;
      LaesLocs;
    END;
  IF (StedNummer > 46) AND (StedNummer < 63) AND (Locsnr <> 4) THEN
    BEGIN
      Locsnr := 4;
      LaesLocs;
    END;
  IF (StedNummer > 62) AND (StedNummer < 81) AND (Locsnr <> 5) THEN
    BEGIN
      Locsnr := 5;
      LaesLocs;
    END;
  IF (StedNummer > 80) AND (StedNummer < 96) AND (Locsnr <> 6) THEN
    BEGIN
      Locsnr := 6;
      LaesLocs;
    END;
  IF (StedNummer > 95) AND (StedNummer < 112) AND (Locsnr <> 7) THEN
    BEGIN
      Locsnr := 7;
      LaesLocs;
    END;
  IF (StedNummer > 111) AND (Locsnr <> 8) THEN
    BEGIN
      Locsnr := 8;
      LaesLocs;
    END;
  CASE Locsnr OF
    1 : FundetNummer := 0;
    2 : FundetNummer := 15;
    3 : FundetNummer := 30;
    4 : FundetNummer := 46;
    5 : FundetNummer := 62;
    6 : FundetNummer := 80;
    7 : FundetNummer := 95;
    8 : FundetNummer := 111;
  END;
  A := 1;
  REPEAT
    IF Loc[A, 1] = '+' THEN
      Inc(FundetNummer);
    Inc(A);
  UNTIL FundetNummer = StedNummer;
  Ksted := Loc[A];
  IF LangBskr = True THEN
    BEGIN
      Writeln(Loc[A]);
      Writeln;
      B := 2;
      REPEAT
        IF Loc[A + B, 1] <> '+' THEN
          Writeln(Loc[A + B]);
        Inc(B);
      UNTIL Loc[A + B, 1] = '+';
    END
  ELSE
    Writeln('Du er ', Loc[A + 1]);
END;

PROCEDURE Besked(Msgnr : Byte);

  VAR
    FundetNummer,
    A,
    B             : Byte;

BEGIN
  IF (Msgnr < 37) AND (Msgsnr > 1) THEN
    BEGIN
      Msgsnr := 1;
      LaesMsgs;
    END;
  IF (Msgnr > 36) AND (Msgnr < 67) AND (Msgsnr <> 2) THEN
    BEGIN
      Msgsnr := 2;
      LaesMsgs;
    END;
  IF (Msgnr > 66) AND (Msgnr < 96) AND (Msgsnr <> 3) THEN
    BEGIN
      Msgsnr := 3;
      LaesMsgs;
    END;
  IF (Msgnr > 95) AND (Msgnr < 126) AND (Msgsnr <> 4) THEN
    BEGIN
      Msgsnr := 4;
      LaesMsgs;
    END;
  IF (Msgnr > 125) AND (Msgnr < 158) AND (Msgsnr <> 5) THEN
    BEGIN
      Msgsnr := 5;
      LaesMsgs;
    END;
  IF (Msgnr > 157) AND (Msgsnr <> 6) THEN
    BEGIN
      Msgsnr := 6;
      LaesMsgs;
    END;
  CASE Msgsnr OF
    1 : FundetNummer := 0;
    2 : FundetNummer := 36;
    3 : FundetNummer := 66;
    4 : FundetNummer := 95;
    5 : FundetNummer := 125;
    6 : FundetNummer := 157;
  END;
  A := 1;
  REPEAT
    IF (Msg[A, 1] = ':') AND (Msg[A] <> '') THEN
      Inc(FundetNummer);
    Inc(A);
  UNTIL FundetNummer = Msgnr;
  B:= 0;
  WHILE (Msg[A + B, 1] <> ':') OR (Msg[A + B] = '') DO
    BEGIN
      Writeln(Msg[A + B]);
      Inc(B);
    END;
END;

FUNCTION ObjTekst(Tnr : Byte; Tl : TlType) : STRING;

  VAR
    A               : Word;
    FundetNummer,
    B               : Byte;
    TempObj         : STRING[80];

BEGIN
  FundetNummer := 0;
  TempObj := '';
  A := 1;
  REPEAT
    IF Obj[A, 1] = '-' THEN
      Inc(FundetNummer);
    Inc(A);
  UNTIL FundetNummer = Tnr;
  IF Tl = Lang THEN
    ObjTekst := Obj[A + 1]
  ELSE
    IF Tl = MedSyn THEN
      ObjTekst := Obj[A]
    ELSE
      IF Tl = Kort THEN
        TempObj := Copy(Obj[A],1,30)
      ELSE
        IF Tl = Lille THEN
          TempObj := 'e' + Copy(Obj[A],2,30)
        ELSE
          TempObj := Copy(Obj[A],4,30);
  IF (Tl = Kort) OR (Tl = Lille) OR (Tl = KunOrd) THEN
    BEGIN
      B := 30;
      REPEAT
        TempObj := Copy(TempObj,1,B-1);
        Dec(B);
      UNTIL (B=1) OR (TempObj[B] <> ' ');
      ObjTekst := TempObj;
    END;
END;

PROCEDURE UndTekst(Unr : Byte);

  VAR
    FundetNummer,
    B             : Byte;
    A             : Word;

BEGIN
  FundetNummer := 0;
  A := 1;
  REPEAT
    IF Obj[A, 1] = '-' THEN
      Inc(FundetNummer);
    Inc(A);
  UNTIL FundetNummer = Unr;
  B := 2;
  REPEAT
    IF Obj[A + B, 1] <> '-' THEN
      BEGIN
        IF Obj[A + B, 1] = 'x' THEN
          Writeln('Der er ikke noget specielt at se.')
        ELSE
          IF Obj[A + B, 1] = 'z' THEN
            BEGIN
              IF Unr = 2 THEN
                Writeln('Der er ', kyats : 4 : 2, ' kyats tilbage pÜ det.');
              IF Unr = 3 THEN
                BEGIN
                  IF Nyhed = 3 THEN
                    Besked(31);
                  IF Nyhed = 2 THEN
                    BEGIN
                      Besked(30);
                      Inc(Nyhed);
                    END;
                  IF Nyhed = 1 THEN
                    BEGIN
                      Besked(29);
                      Inc(Nyhed);
                    END;
                END;
              IF Unr = 48 THEN
                BEGIN
                  Byt(Objekt[48].Placering,Objekt[49].Placering);
                  Objekt[53].Placering := 37;
                  Objekt[49].Placering := 37;
                  Inc(Score, 5);
                END;
              IF (Unr = 52) OR (Unr = 53) THEN
                IF FlagB[11] = True THEN
                  Writeln('Den er Üben.')
                ELSE
                  Writeln('Den er lukket.');
              IF Unr = 51 THEN
                IF Sejl = 0 THEN
                  Writeln('Den lyser ikke.')
                ELSE
                  Writeln('Den blinker heftigt med "Self-destruct"');
              IF Unr = 56 THEN
                BEGIN
                  Besked(82);
                  Bang;
                  FlagB[4] := True;
                END;
              IF Unr = 55 THEN
                Objekt[56].Placering := 46;
              IF Unr = 64 THEN
                BEGIN
                  IF Objekt[66].Placering = 68 THEN
                    Besked(103)
                  ELSE
                    Besked(101);
                END;
              IF Unr IN [73, 75, 76] THEN
                IF Retning[StedNummer, Nord] = 253 THEN
                  Writeln('Den er lÜst.')
                ELSE
                  Writeln('Den er ikke lÜst.');
              IF Unr = 79 THEN
                BEGIN
                  IF Flint = 1 THEN
                    Writeln('Loronov prõver sikkert at aflede Flints opmërksomhed, udnyt det!');
                  IF Flint = 3 THEN
                    Writeln('Han ser lidt medtaget ud, sÜ lÜs da hans hÜndjern op!');
                  IF Loronov = 1 THEN
                    Writeln('Han stÜr og tënker, mens han klõr sig i nakken.');
                  IF Loronov = 3 THEN
                    Writeln('Han venter spëndt pÜ at du fÜr startet helikopteren.');
                  IF Loronov = 4 THEN
                    Writeln('Han ser glad ud. Missionen er jo nësten fuldfõrt.');
                END;
              IF Unr = 80 THEN
                BEGIN
                  IF Objekt[81].Placering = 0 THEN
                    BEGIN
                      Besked(117);
                      Objekt[81].Placering := 91;
                      Objekt[82].Placering := 91;
                    END
                  ELSE
                    Besked(118);
                END;
              IF Unr = 84 THEN
                IF FlagB[16] = True THEN
                  Writeln('De er lÜst fast om Loronovs hÜndled og et rõr i gulvet.')
                ELSE
                  Writeln('Der er ikke noget specielt at se.');
              IF Unr = 86 THEN
                BEGIN
                  IF Objekt[87].Placering = 0 THEN
                    BEGIN
                      Besked(124);
                      Objekt[87].Placering := 97;
                    END
                  ELSE
                    IF Objekt[88].Placering = 97 THEN
                      Besked(125)
                    ELSE
                      Besked(133);
                END;
              IF Unr = 87 THEN
                BEGIN
                  IF Objekt[88].Placering = 0 THEN
                    Besked(126)
                  ELSE
                    Besked(125);
                END;
              IF Unr = 88 THEN
                BEGIN
                  IF FlagB[18] = True THEN
                    Besked(129)
                  ELSE
                    Besked(128);
                END;
              IF Unr = 92 THEN
                BEGIN
                  IF Loronov < 2 THEN
                    Writeln('Den er tynd, bulet og rusten, men den er ikke til at Übne med de bare nëver.');
                  IF Loronov > 1 THEN
                    Writeln('Den er jo brudt op og den er lige ved at falde af.');
                END;
              IF Unr = 93 THEN
                BEGIN
                  IF (PassW = 0) OR (PassW = 2) THEN
                    Writeln('Den er ikke tëndt.');
                  IF PassW = 1 THEN
                    Writeln('Den er tëndt og stÜr og venter pÜ at du skriver et password pÜ den.');
                END;
              IF Unr = 94 THEN
                IF FlagB[20] = False THEN
                  Writeln('Det skal sikkert ren-brëndes, fõr det kan bruges.')
                ELSE
                  Writeln('Det er blevet ren-brëndt.');
            END
          ELSE
            Writeln(Obj[A + B]);
      END;
    Inc(B);
  UNTIL Obj[A + B, 1] = '-';
END;

PROCEDURE Hjaelp;

PROCEDURE Hjlptxt(HjNr : Byte);

VAR
  A,
  FundetHjlp  : Byte;

BEGIN
  FundetHjlp := 0;
  A := 1;
  REPEAT
    IF Hjlp[A, 1] = '+' THEN
      Inc(FundetHjlp);
    Inc(A);
  UNTIL FundetHjlp = HjNr;
  Writeln(Hjlp[A]);
  Inc(A);
  IF Hjlp[A, 1] <> '+' THEN
    Writeln(Hjlp[A]);
END;

BEGIN
  CASE StedNummer OF
    46   : Besked(88);
    10   : Hjlptxt(1);
    18   : Hjlptxt(2);
    63   : Hjlptxt(3);
    64   : Hjlptxt(4);
    66   : Hjlptxt(5);
    91   : Hjlptxt(6);
    97   : Hjlptxt(7);
    104  : Hjlptxt(8);
    105  : Hjlptxt(9);
    115  : Hjlptxt(10);
    8    : Hjlptxt(11);
  ELSE
    Besked(89);
  END;
END;

PROCEDURE DisplayTing;

  VAR
    A             : Byte;

BEGIN
  FlagB[6] := False;
  FOR A:= 1 TO AntalTing DO
    BEGIN
      IF Objekt[A].Placering = StedNummer THEN
        BEGIN
          FlagB[6] := True;
          IF Flag[StedNummer] = True THEN
            Write(ObjTekst(A, Lang))
          ELSE
            Write('Der er ', ObjTekst(A, Lille), ' her. ');
        END;
    END;
  IF FlagB[6] = True THEN
    Writeln;
END;

PROCEDURE TegnStatus;

BEGIN
  Window(1, 1, 80, 1);
  TextBackground(7);
  TextColor(0);
  ClrScr;
  Write(KSted);
  GotoXY(37,1);
  Write('SCORE : ', Score : 3, ' ud af 500    Trëk : ', AntalTraek);
  TextBackground(1);
  TextColor(7);
  Window(1, 2, 80, 25);
  GotoXY(1,24);
END;

PROCEDURE Save;

{$I-}

VAR
  Tal    : Byte;
  Tal2   : LongInt;

PROCEDURE BitFlag(BFlag : Boolean);

BEGIN
  IF BFlag = True THEN
    Tal := 1
  ELSE
    Tal := 0;
  Write(GemFil,Tal);
END;

PROCEDURE WordToByte(WTal : Word);

BEGIN
  Tal := (WTal MOD 256);
  Write(GemFil,Tal);
  Tal := (Wtal DIV 256);
  Write(GemFil,Tal);
END;

BEGIN
  Writeln('Under hvilket filnavn skal dette spils position gemmes ?');
  Linieinput(FilNavn, False);
  Writeln('Positionen bliver nu gemt.');
  Assign(GemFil,FilNavn);
  Rewrite(GemFil);
  FOR A := 1 TO 115 DO
  FOR RetKompas := Nord to Ned DO
    Write(GemFil,Retning[A,RetKompas]);
  FOR A := 1 TO 115 DO
    BEGIN
      Write(GemFil,Objekt[A].Placering);
      Write(GemFil,Objekt[A].Vaegt);
    END;
  FOR A := 1 TO 115 DO
    BitFlag(Flag[A]);
  FOR A := 1 TO 25 DO
    BitFlag(FlagB[A]);
  Write(GemFil,StedNummer,OrdNummer,Alt,NuOrd,DenDetNr,FundetOrd,
        GFord,Samlnr,BaaretVaegt,Nyhed,Hunger,Kasse,Sejl,KokOp,Flint,Passw,
        Loronov,Heli);
  WordToByte(AntalTraek);
  WordToByte(Score);
  Tal2 := Round((Kyats * 100));
  WordToByte(Tal2 MOD 256);
  WordToByte(Tal2 DIV 256);
  Tal2 := Round((Indkoeb * 100));
  WordToByte(Tal2 MOD 256);
  WordToByte(Tal2 DIV 256);
  Close(GemFil);
  {$I+}
  IF IOResult = 0 THEN
    Writeln('Alt ok.')
  ELSE
    Writeln('Fejl ved filoperationerne. Positionen er IKKE blevet gemt.');
END;

PROCEDURE Load;

{$I-}
VAR
  Tal    : Byte;
  Tal2, Gemt1, Gemt2  : Word;
  Gemt3, Gemt4  : Real;

PROCEDURE ByteToWord(VAR WTal : Word);

BEGIN
  Read(GemFil, Tal);
  Wtal := Tal;
  Read(GemFil, Tal);
  Inc(Wtal, (Tal * 256));
END;

BEGIN
  Writeln('Hvad er navnet pÜ den spil-position, som skal hentes ?');
  LinieInput(FilNavn, False);
  Writeln('Positionen bliver nu hentet.');
  Tal := 0;
  Tal2 := 0;
  Gemt1 := AntalTraek;
  Gemt2 := Score;
  Gemt3 := Kyats;
  Gemt4 := Indkoeb;
  Assign(GemFil,FilNavn);
  Reset(GemFil);
  FOR A := 1 TO 115 DO
  FOR RetKompas := Nord to Ned DO
    Read(GemFil,Retning[A,RetKompas]);
  FOR A := 1 TO 115 DO
    BEGIN
      Read(GemFil,Objekt[A].Placering);
      Read(GemFil,Objekt[A].Vaegt);
    END;
  FOR A := 1 TO 115 DO
    BEGIN
      Read(GemFil, Tal);
      IF Tal = 1 THEN
        Flag[A] := True
      ELSE
        Flag[A] := False;
    END;
  FOR A := 1 TO 25 DO
    BEGIN
      Read(GemFil, Tal);
      IF Tal = 1 THEN
        FlagB[A] := True
      ELSE
        FlagB[A] := False;
    END;
  Read(GemFil,StedNummer,OrdNummer,Alt,NuOrd,DenDetNr,FundetOrd,
        GFord,Samlnr,BaaretVaegt,Nyhed,Hunger,Kasse,Sejl,KokOp,Flint,Passw,
        Loronov,Heli);
  ByteToWord(AntalTraek);
  ByteToWord(Score);
  ByteToWord(Tal2);
  Kyats := Tal2;
  ByteToWord(Tal2);
  Kyats := (Kyats + (Tal2 * 256)) / 100;
  ByteToWord(Tal2);
  Indkoeb := Tal2;
  ByteToWord(Tal2);
  Indkoeb := (Indkoeb + (Tal2 * 256)) / 100;
  Close(GemFil);
  {$I+}
  IF IOResult = 0 THEN
    Writeln('Alt ok.')
  ELSE
    BEGIN
      Writeln('Fejl ved load af spil. Spillet er IKKE blevet hentet.');
      AntalTraek := Gemt1;
      Score := Gemt2;
      Kyats := Gemt3;
      INdkoeb := Gemt4;
    END;
  Vissted;
END;

PROCEDURE VisSted;

BEGIN
  Writeln;
  IF Flag[StedNummer] = True THEN
    DisplaySted(StedNummer, TRUE)
  ELSE
    DisplaySted(StedNummer, FALSE);
  TegnStatus;
  DisplayTing;
  Flag[StedNummer] := False;
END;

BEGIN
  TextBackground(1);
  TextColor(7);
  ClrScr;
  LF(2);
  Writeln('  **  MYSTIK I BURMA  **   ');
  Writeln('  Af Peter Ravnholt   (C) RealWare Games 1990');
  Assign(TekstFil, FExpand('BOBJ.DAT'));
  Reset(TekstFil);
  B := 0;
  REPEAT
    Inc(B);
    Readln(TekstFil,Obj[B]);
  UNTIL Obj[B, 1] = '≠';
  Close(TekstFil);
  Assign(TekstFil, FExpand('BHELP.DAT'));
  Reset(TekstFil);
  B := 0;
  REPEAT
    Inc(B);
    Readln(TekstFil, Hjlp[B]);
  UNTIL Hjlp[B, 1] = 'Ò';
  Close(TekstFil);
  Locsnr := 1;
  Msgsnr := 1;
  LaesLocs;
  LaesMsgs;
  Ksted := '';
END.