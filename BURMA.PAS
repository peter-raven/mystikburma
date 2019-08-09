PROGRAM BurmaEventyr;

  USES Crt, Dos,
       PRSounds,
       BUnit;

  TYPE
    LinieType     = STRING[80];
    OrdType       = ARRAY[1 .. 40] OF LinieType;
    PrisType      = ARRAY[1 .. 12] OF Real;
    ValgSet       = SET OF Char;

  VAR
    Valg         : ValgSet;
    KommandoOrd, KlartOrd : OrdType;
    LaestLinie, Kord, KKord, Ordet, Sord1, Sord2 : LinieType;
    Ordre  : STRING;
    A            : Byte;
    B            : Word;
    Pris         : PrisType;

PROCEDURE OrdDeler; (* Skërer variablen Ordre ud i ord *)

  VAR
    OrdLaengde,
    StartAfOrd,
    A          : Byte;

BEGIN

OrdLaengde := 0;
OrdNummer := 0;
StartAfOrd := 1;

FOR A:=1 TO 40 DO
  BEGIN
    KommandoOrd[A]:='';
    KlartOrd[A]:='';
  END;

FOR A:=1 TO Length(Ordre) DO
  BEGIN
    IF Copy(Ordre,A,1) = ' ' THEN
      BEGIN
        IF Copy(Ordre,StartAfOrd,OrdLaengde) <> '' THEN
          BEGIN
            Sord1 := Copy(Ordre,StartAfOrd,OrdLaengde);
            Sord2 := Copy(Sord1,1,4);
            Sord2 := Ucasestr(Sord2);
            StartAfOrd := A+1;
            OrdLaengde := 0;
            IF (Sord2='OG') OR (Sord2='Gè') OR (Sord2='KRAV') OR (Sord2='LùB')
               OR (Sord2='SEJL') OR (Sord2='EN') OR (Sord2='ET') THEN
              (* Intet *)
            ELSE
              BEGIN
                Inc(OrdNummer);
                KlartOrd[OrdNummer] := Sord1;
                KommandoOrd[OrdNummer] := Sord2;
              END;
            END;
          END
        ELSE
          Inc(OrdLaengde);
  END;
END;

PROCEDURE FindOrd;

VAR
  A,
  FstChk,
  ScnChk    : Byte;

BEGIN
  FundetOrd := 0;
  FlagB[7]     := False;
  FlagB[8]     := False;
  FlagB[14]     := False;
  IF (Kord = 'DEN') OR (Kord = 'DET') THEN
    FundetOrd := DenDetNr;
  IF (FundetOrd = 0) AND (Kord <> '') AND (Kord <> ' ') THEN
    BEGIN
      A := 0;
      REPEAT
        Inc(A);
        IF Pos(Copy(Kord + '   ',1,4), Ucasestr(ObjTekst(A, MedSyn))) > 0 THEN
          BEGIN
            IF FundetOrd = 0 THEN
              FundetOrd := A
            ELSE
              BEGIN (* Tvivl *)
                IF (FlagB[9] = False) AND (NOT (Objekt[FundetOrd].Placering IN [250, 252, StedNummer]))
                   AND (Objekt[A].Placering IN [250, 252, StedNummer]) THEN
                     FundetOrd := A
                ELSE
                  IF (FlagB[9] = True) AND (Objekt[A].Placering = 0)
                     AND (Objekt[FundetOrd].Placering <> 0) THEN
                        FundetOrd := A
                  ELSE
                    IF ((FlagB[9] = False) AND (Objekt[FundetOrd].Placering IN [250, 252, StedNummer])
                       AND (Objekt[A].Placering IN [250, 252, StedNummer]))
                       OR ((FlagB[9] = True) AND (Objekt[FundetOrd].Placering = 0)
                       AND (Objekt[A].Placering = 0)) THEN
                  BEGIN
                    REPEAT
                      Writeln('Hvilken ', KlartOrd[NuOrd], ' mener du : ',
                      ObjTekst(FundetOrd,Lille), ' eller ', ObjTekst(A,Lille), ' ?');
                      LinieInput(Ordre, True);
                      FstChk := Pos(Ucasestr(Ordre),Ucasestr(ObjTekst(A,MedSyn) + '   '));
                      ScnChk := Pos(Ucasestr(Ordre),Ucasestr(ObjTekst(FundetOrd,MedSyn) + '   '));
                    UNTIL ((FstChk <> 0) AND (ScnChk = 0)) OR ((FstChk = 0) AND (ScnChk <> 0));
                    IF FstChk > 0 THEN
                      FundetOrd := A;
                  END;
              END;
          END;
      UNTIL A = AntalTing;
    END;
  IF FundetOrd <> 0 THEN
    BEGIN
      DenDetNr := FundetOrd;
      IF Objekt[FundetOrd].Placering = 250 THEN
        FlagB[7] := True;
      IF Objekt[FundetOrd].Placering = StedNummer THEN
        FlagB[8] := True;
      IF Objekt[FundetOrd].Placering = 252 THEN
        FlagB[14] := True;
    END;
END;

PROCEDURE NytOrd;

BEGIN
  Inc(NuOrd);
  Kord := KommandoOrd[NuOrd];
  KKord := KommandoOrd[NuOrd] + ' ' + KommandoOrd[NuOrd + 1];
  FindOrd;
END;

PROCEDURE Rens;

BEGIN
  Kord := '';
  KKord := '';
  FundetOrd := 0;
END;

PROCEDURE FjernObj(FjObnr : Byte);

BEGIN
  Objekt[FjObnr].Placering := 0;
  Dec(BaaretVaegt, Objekt[FjObnr].Vaegt);
END;

PROCEDURE DesObj(DesObnr : Byte);

BEGIN
  Objekt[DesObnr].Placering := 251;
  Dec(BaaretVaegt, Objekt[DesObnr].Vaegt);
END;

PROCEDURE SkabObj(SkObnr : Byte);

BEGIN
  Objekt[SkObnr].Placering := 250;
  Inc(BaaretVaegt, Objekt[SkObnr].Vaegt);
END;

PROCEDURE DuHarIkke;

BEGIN
  Writeln('Du har ikke ', ObjTekst(FundetOrd,Lille), '.');
  NuOrd := 41;
END;

PROCEDURE HerErIkke;

BEGIN
  Writeln('Jeg ser ingen ', ObjTekst(FundetOrd,KunOrd), ' her.');
  NuOrd := 41;
END;

PROCEDURE KenderIkke;

BEGIN
  Writeln('Jeg kender ikke ordet ''', KlartOrd[NuOrd], '''.');
  NuOrd := 41;
END;

PROCEDURE KendPas;

BEGIN
  GFord := FundetOrd;
  NytOrd;
  FlagB[5] := False;
  IF (Kord = '') OR (Kord = ' ') THEN
    Writeln('Jeg forstÜr ikke hvad du mener.')
  ELSE
    IF FundetOrd = 0 THEN
      KenderIkke
    ELSE
      FlagB[5] := True;
END;

PROCEDURE KendHavesPas;

BEGIN
  KendPas;
  IF FlagB[5] = True THEN
    IF FlagB[7] = False THEN
      BEGIN
        DuHarIkke;
        FlagB[5] := False;
      END
    ELSE
      FlagB[5] := True;
END;

PROCEDURE KendErHerPas;

BEGIN
  KendPas;
  IF FlagB[5] = True THEN
    IF (FlagB[8] = False) AND (FlagB[7] = False) THEN
      BEGIN
        HerErIkke;
        FlagB[5] := False;
      END
    ELSE
      FlagB[5] := True;
END;

PROCEDURE Traek;

BEGIN
  Tf := True;
  IF FlagB[4] = True THEN Exit;
  Dec(Hunger);
  Inc(AntalTraek);
  TegnStatus;
  IF (Hunger = 15) OR (Hunger = 14) THEN
    Besked(16);
  IF Hunger < 5 THEN
    Besked(17);
  IF Hunger = 0 THEN
    BEGIN
      Besked(15);
      FlagB[4] := True;
    END;
  Rens;
  IF StedNummer = 5 THEN
    BEGIN
      Indkoeb := 0;
      FOR A := 4 TO 8 DO
        IF Objekt[A].Placering = 250 THEN
          Indkoeb := Indkoeb + Pris[A - 3];
    END;
  IF StedNummer = 18 THEN
    IF (Objekt[31].Placering = 250) OR (Objekt[31].Placering = 18) THEN
      Besked(45);
  IF (StedNummer = 23) AND (FlagB[10] = False) THEN
    BEGIN
      Besked(50);
      FlagB[10] := True;
    END;
  IF StedNummer IN [20, 38, 52] THEN
    FlagB[4] := True;
  IF StedNummer = 24 THEN
    BEGIN
      IF Kasse = 4 THEN
        BEGIN
          Besked(58);
          FlagB[4] := True;
        END;
      IF Kasse = 3 THEN
        BEGIN
          Besked(57);
          Inc(Kasse);
        END;
      IF Kasse = 2 THEN
        BEGIN
          Besked(56);
          Inc(Kasse);
        END;
      IF Kasse = 1 THEN
        BEGIN
          Besked(53);
          BilStart;
          TrykTast;
          Besked(54);
          Delay(5000);
          Besked(55);
          BilBang;
          Inc(Kasse);
          Inc(Score, 10);
        END;
    END;
  IF StedNummer = 25 THEN
    BEGIN
      IF Kasse = 7 THEN
        BEGIN
          Ratata(11);
          Aaargh;
          Besked(69);
          FlagB[4] := True;
        END;
      IF Kasse = 6 THEN
        BEGIN
          Besked(68);
          Inc(Kasse);
          Objekt[45].Placering := 25;
        END;
      IF Kasse = 5 THEN
        BEGIN
          Besked(61);
          Ratata(8);
          Aaargh;
          FlagB[4] := True;
        END;
    END;
  IF Sejl = 3 THEN
    BEGIN
      IF StedNummer = 39 THEN
        BEGIN
          Besked(78);
          Krash;
          FlagB[4] := True;
        END;
      IF StedNummer = 40 THEN
        BEGIN
          Besked(79);
          Bang;
          Retning[40,Vest] := 0;
          Inc(Sejl);
        END;
      IF StedNummer = 41 THEN
        BEGIN
          Besked(80);
          Bang;
          Retning[40,Vest] := 0;
          StedNummer := 40;
          Inc(Sejl);
        END;
    END;
  IF (SEJL > 0) AND (Sejl < 3) THEN
    Inc(Sejl);
  IF (StedNummer = 58) AND (FlagB[13] = True) THEN
    BEGIN
      Besked(93);
      Ratata(11);
      Aaargh;
      FlagB[4] := True;
    END;
  IF StedNummer = 58 THEN
    FlagB[13] := True;
  IF KokOp > 0 THEN Dec(KokOp);
  IF (StedNummer = 68) AND (KokOp = 0) THEN
    BEGIN
      Besked(104);
      Ratata(1);
      Argh;
      FlagB[4] := True;
    END;
  IF Flint = 1 THEN
    BEGIN
      Besked(111);
      FlagB[4] := True;
    END;
  IF Flint = 3 THEN
    Besked(114);
  IF Flint = 2 THEN
    Inc(Flint);
  IF (StedNummer = 91) AND (Flint = 0) THEN
    BEGIN
      Besked(165);
      Flint := 1;
      IF (Objekt[38].Placering = 250) AND (Objekt[67].Placering = 250) THEN
        BEGIN
          Writeln('Han tager din pistol og din gasspray.');
          FjernObj(38);
          FjernObj(67);
        END
      ELSE
        IF Objekt[38].Placering = 250 THEN
          BEGIN
            Writeln('Han tager din pistol.');
            FjernObj(38);
          END
        ELSE
          IF Objekt[67].Placering = 250 THEN
            BEGIN
              Writeln('Han tager din gasspray.');
              FjernObj(67);
            END;
      Besked(166);
    END;
  IF (StedNummer = 94) AND (Loronov = 1) THEN
    Besked(149);
  IF (StedNummer = 94) AND (Passw = 2) AND (Loronov = 0) THEN
    BEGIN
      IF Retning[94, Vest] = 250 THEN
        BEGIN
          Besked(146);
          Inc(Loronov);
          Objekt[79].Placering := 94;
        END
      ELSE
        BEGIN
          Besked(147);
          Objekt[79].Placering := 115;
          Inc(Loronov,2);
        END;
    END;
  IF Heli = 3 THEN
    BEGIN
      TrykTast;
      Besked(159);
      TrykTast;
      FlagB[3] := True;
      Inc(score, 80);
    END;
  IF Heli = 2 THEN
    BEGIN
      Besked(156);
      FlagB[4] := True;
    END;
  IF Heli = 1 THEN
    BEGIN
      Besked(164);
      Inc(Heli);
    END;
  IF (StedNummer = 115) AND (Loronov = 3) AND (Heli = 0) THEN
    Besked(162);
  IF (StedNummer = 115) AND (Loronov = 2) AND (Heli = 0) THEN
    BEGIN
      Besked(163);
      Inc(Loronov);
    END;
  IF (StedNummer > 78) AND (FlagB[4] = False) THEN
    IF (Objekt[71].Placering <> 252) OR (Objekt[35].Placering = 252) THEN
      BEGIN
        Besked(116);
        FlagB[4] := True;
      END
    ELSE
      IF (Objekt[71].Placering = 252) AND (Objekt[62].Placering <> 252) THEN
        BEGIN
          Besked(167);
          FlagB[4] := True;
        END;
  IF (StedNummer = 15) AND (FlagB[21] = False) THEN
    BEGIN
      IF Objekt[2].Placering = 250 THEN
        BEGIN
          Besked(172);
          FjernObj(2);
        END
      ELSE
        Besked(173);
      FlagB[21] := True;
    END;
  IF StedNummer = 63 THEN
    BEGIN
      Writeln('Mens du sidder i dit skjul kommer en stor flok snavsede burmesiske arbejdere');
      Writeln('GÜende. Det er sikkert et hold skift. De gÜr tët forbi dig, sÜ de spërrer for');
      Writeln('Vagternes udsyn. En af arbejderne holder lidt igen og kigger diskret hen mod');
      Writeln('Buskene, hvor du gemmer dig.');
    END;
END;

PROCEDURE GaaNord;

BEGIN
  IF StedNummer = 5 THEN
    BEGIN
      IF Indkoeb > 0 THEN
        BEGIN
          Writeln('Dõren vil ikke Übnes og pÜ displayet over sprëkken kan du nu lëse :');
          Writeln('''Betal venligst ', Indkoeb : 3 : 2, ' kyats for varer.''');
          Retning[5,Nord] := 250;
        END
      ELSE
        Retning[5,Nord] := 4;
    END;
  IF StedNummer = 58 THEN
    BEGIN
      Besked(91);
      Ratata(11);
      Aaargh;
      FlagB[4] := True;
      Retning[58,Nord] := 250;
    END;
  IF Retning[StedNummer,Nord] = 253 THEN
    Besked(110)
  ELSE
    IF Retning[StedNummer,Nord] = 0 THEN
      Writeln('Du kan ikke gÜ nord her.')
    ELSE
      IF Retning[StedNummer,Nord] = 250 THEN
        (* Bla *)
      ELSE
        BEGIN
          Writeln('Du gÜr nord.');
          StedNummer := Retning[StedNummer,Nord];
          VisSted;
          Traek;
        END;
    Rens;
END;

PROCEDURE GaaSyd;

BEGIN
  IF (StedNummer = 66) AND (FlagB[15] = True) THEN
    FlagB[15] := False;
  IF (StedNummer = 18) AND (Objekt[27].Placering = 18) THEN
    BEGIN
      Retning[18,Syd] := 250;
      Besked(28);
    END;
  IF (StedNummer = 7) AND (Objekt[34].Placering = 251) THEN
    BEGIN
      Besked(42);
      Retning[7,Syd] := 250;
    END;
  IF (StedNummer = 91) AND (Flint = 3) THEN
    BEGIN
      Besked(113);
      Retning[91,Syd] := 250;
    END;
  IF (Retning[StedNummer,Syd] = 0) THEN
    Writeln('Du kan ikke gÜ syd her.')
  ELSE
    IF Retning[StedNummer,Syd] = 250 THEN
      (* Bla *)
    ELSE
      BEGIN
        Writeln('Du gÜr syd.');
        StedNummer := Retning[StedNummer,Syd];
        VisSted;
        Traek;
      END;
    Rens;
END;

PROCEDURE GaaOest;

BEGIN
  IF (StedNummer = 66) AND (FlagB[15] = True) THEN
    FlagB[15] := False;
  IF StedNummer = 58 THEN
    BEGIN
      Besked(91);
      Ratata(11);
      Aaargh;
      FlagB[4] := True;
      Retning[58,Oest] := 250;
    END;
  IF StedNummer = 63 THEN
    BEGIN
      IF Objekt[41].Placering <> 252 THEN
        BEGIN
          Besked(96);
          Ratata(7);
          Aaargh;
          FlagB[4] := True;
          Retning[63,Oest] := 250;
        END;
      IF (Objekt[35].Placering <> 252) AND (FlagB[4] = False) THEN
        BEGIN
          Besked(95);
          FlagB[4] := True;
          Retning[63,Oest] := 250;
        END;
      IF (Objekt[68].Placering = 252) AND (FlagB[4] = False) THEN
        BEGIN
          Besked(97);
          Ratata(5);
          Delay(6);
          Ratata(7);
          FlagB[4] := True;
          Retning[63,Oest] := 250;
        END;
      IF (Objekt[35].Placering = 252) AND (Objekt[41].Placering = 252) THEN
        BEGIN
          SkabObj(61);
          SkabObj(62);
          Inc(Score, 30);
        END;
    END;
  IF (StedNummer = 66) AND (Objekt[66].Placering = 0) THEN
    BEGIN
      IF (Objekt[41].Placering = 252) AND (Objekt[38].Placering = 250) THEN
        BEGIN
          Besked(100);
          KokSkyd;
          FlagB[4] := True;
          Retning[66,Oest] := 250;
        END;
      IF (Objekt[41].Placering = 252) AND (Objekt[38].Placering <> 250) THEN
        BEGIN
          Besked(170);
          Skud;
          FlagB[4] := True;
          Retning[66,Oest] := 250;
        END;
      IF (Objekt[41].Placering <> 252) THEN
        BEGIN
          Besked(169);
          FlagB[4] := True;
          Retning[66,Oest] := 250;
        END;
    END;
  IF StedNummer = 115 THEN
    BEGIN
      IF Heli > 0 THEN
        BEGIN
          Writeln('Hups, AAAEEEIIIIIAAAAaaaaaa............>*SPLAT*<');
          FlagB[4] := True;
          Retning[115, Oest] := 250;
        END
      ELSE
        Retning[115, Oest] := 114;
    END;
  IF Retning[StedNummer,Oest] = 0 THEN
    Writeln('Du kan ikke gÜ õst her.')
  ELSE
    IF Retning[StedNummer,Oest] = 250 THEN
      (* Bla *)
    ELSE
      BEGIN
        Writeln('Du gÜr õst.');
        StedNummer := Retning[StedNummer,Oest];
        VisSted;
        Traek;
      END;
  Rens;
END;

PROCEDURE GaaVest;

BEGIN
  IF (StedNummer = 66) AND (FlagB[15] = True) THEN
    FlagB[15] := False;
  IF (StedNummer = 72) AND (Objekt[69].Placering = 72) THEN
    Besked(105);
  IF (StedNummer = 94) AND (Retning[94, Vest] = 250) THEN
    Writeln('Du kan ikke fÜ dõren op. Dens gamle lÜs er rustet fast.');
  IF Retning[StedNummer,Vest] = 0 THEN
    Writeln('Du kan ikke gÜ vest her.')
  ELSE
    IF Retning[StedNummer,Vest] = 250 THEN
      (* Absolut intet *)
    ELSE
      BEGIN
        Writeln('Du gÜr vest.');
        StedNummer := Retning[StedNummer,Vest];
        VisSted;
        Traek;
      END;
  Rens;
END;

PROCEDURE GaaOp;

BEGIN
  (* Check *)

  IF Retning[StedNummer,Op] = 0 THEN
    Writeln('Du kan ikke gÜ op her.')
  ELSE
    BEGIN
      Writeln('Du gÜr op.');
      StedNummer := Retning[StedNummer,Op];
      VisSted;
      Traek;
    END;
  Rens;
END;

PROCEDURE GaaNed;

BEGIN
  (*Check *)

  IF Retning[StedNummer,Ned] = 0 THEN
    Writeln('Du kan ikke gÜ ned her.')
  ELSE
    BEGIN
      Writeln('Du gÜr ned.');
      StedNummer := Retning[StedNummer,Ned];
      VisSted;
      Traek;
    END;
  Rens;
END;

PROCEDURE Slut;

BEGIN
  Writeln('ùnsker du at stoppe dette spil ?');
  LinieInput(Ordre, True);
  OrdDeler;
  IF KommandoOrd[1] = 'JA' THEN
    FlagB[3] := True;
  Rens;
END;

PROCEDURE Tag;

PROCEDURE Paa;

BEGIN
  IF FlagB[8] = True THEN
    Writeln('Saml tingen op, fõr du prõver at tage den pÜ.');
  IF (FlagB[8] = False) AND (FlagB[14] = False) AND (FlagB[7] = False) THEN
    HerErIkke;
  If FlagB[14] = True THEN
    Writeln('Du har allerede ', ObjTekst(FundetOrd,Lille), ' pÜ.');
  IF FlagB[7] = True THEN
    BEGIN
      IF NOT (FundetOrd IN [35, 41, 62, 68, 71, 91]) THEN
        Writeln('Du kan da ikke tage ', ObjTekst(FundetOrd,Lille), ' pÜ.')
      ELSE
        BEGIN
          Writeln('Du tager ', ObjTekst(FundetOrd,Lille), ' pÜ.');
          IF (FundetOrd = 71) AND (Objekt[41].Placering = 252) THEN
            BEGIN
              Writeln('(Du tager risbondeklëdedragten af fõrst).');
              SkabObj(41);
            END;
          IF (FundetOrd = 41) AND (Objekt[71].Placering = 252) THEN
            BEGIN
              Writeln('(Du tager din hvide uniform af fõrst).');
              SkabObj(71);
            END;
          Objekt[FundetOrd].Placering := 252;
          BaaretVaegt := BaaretVaegt - Objekt[FundetOrd].Vaegt;
          Traek;
        END;
    END;
  Alt := 0;
  FlagB[1] := False;
  Inc(NuOrd);
  Rens;
END;

PROCEDURE Af;

BEGIN
  IF (FlagB[8] = True) OR (FlagB[7] = True) THEN
    Writeln('Du har jo slet ikke ', ObjTekst(FundetOrd,Lille), ' pÜ.');
  IF (FlagB[8] = False) AND (FlagB[14] = False) AND (FlagB[7] = False) THEN
    HerErIkke;
  IF FlagB[14] = True THEN
    BEGIN
      Writeln('Du tager ', ObjTekst(FundetOrd,Lille), ' af.');
      SkabObj(FundetOrd);
      Traek;
    END;
  Alt := 0;
  FlagB[1] := False;
  Inc(NuOrd);
  Rens;
END;

BEGIN
  IF Alt <> 0 THEN
    BEGIN
      REPEAT
        IF Objekt[Alt].Placering = StedNummer THEN
          BEGIN
            FundetOrd := Alt;
            FlagB[8] := True;
          END;
        Inc(Alt);
      UNTIL (FundetOrd <> 0) OR (Alt > AntalTing);
      IF Alt > AntalTing THEN
        BEGIN
          Alt := 0;
          FlagB[1] := False;
          Rens;
        END;
    END;
  IF FundetOrd <> 0 THEN
    BEGIN
      IF KommandoOrd[NuOrd + 1] = 'Pè' THEN
        Paa
      ELSE
        IF KommandoOrd[NuOrd + 1] = 'AF' THEN
          Af
        ELSE
          BEGIN
            IF FlagB[8] = True THEN
              BEGIN
                IF FundetOrd = 56 THEN
                  BEGIN
                    Besked(81);
                    Bang;
                    FlagB[4] := True;
                    Alt := 0;
                    FlagB[1] := False;
                  END
                ELSE
                  BEGIN
                    Write(ObjTekst(FundetOrd,Kort), ' : ');
                    IF Objekt[FundetOrd].Vaegt = 21 THEN
                      Writeln('Kan da ikke samles op !')
                    ELSE
                      IF BaaretVaegt + Objekt[FundetOrd].Vaegt > 23 THEN
                        Writeln('Du kan ikke bëre mere.')
                      ELSE
                        BEGIN
                          SkabObj(FundetOrd);
                          Writeln('Taget.');
                          Traek;
                        END;
                    Rens;
                  END;
              END
            ELSE
              IF FlagB[7] = True THEN
                BEGIN
                  Writeln('Du har allerede ', ObjTekst(FundetOrd,Lille), '.');
                  Rens;
                END
              ELSE
                BEGIN
                  HerErIkke;
                  Rens;
                END;
          END
    END
  ELSE
    BEGIN
      IF Kord = 'ALT' THEN
        Alt := 1
      ELSE
        IF FlagB[1] = True THEN
          BEGIN
            FlagB[1] := False;
            Alt := 0;
          END;
    END;
END;

PROCEDURE Kast;

BEGIN
  KendHavesPas;
  IF FlagB[5] = True THEN
    IF FundetOrd IN [24, 31, 40, 54] THEN
      BEGIN
        IF FundetOrd = 31 THEN
          Besked(83);
        IF FundetOrd = 54 THEN
          BEGIN
            IF StedNummer <> 46 THEN
            Besked(85)
            ELSE
              BEGIN
                Besked(84);
                Bang;
                DesObj(54);
                Objekt[55].Placering := 251;
                Objekt[56].Placering := 251;
                Objekt[57].Placering := 46;
                Objekt[58].Placering := 46;
                Inc(Score, 20);
                Traek;
              END;
          END;
        IF (FundetOrd = 40) AND (Flint = 1) THEN
          BEGIN
            Besked(112);
            Argh;
            Ratata(17);
            Byt(Objekt[78].Placering,Objekt[80].Placering);
            IF Objekt[38].Placering = 0 THEN
              Objekt[38].Placering := 91;
            IF Objekt[67].Placering = 0 THEN
              Objekt[67].Placering := 91;
            Objekt[40].Placering := 91;
            Dec(BaaretVaegt);
            Inc(Flint);
            Inc(Score, 30);
            Traek;
          END;
        IF (FundetOrd = 24) THEN
          BEGIN
            IF Flint = 1 THEN
              BEGIN
                Besked(168);
                Ratata(9);
                Argh;
                FlagB[4] := True;
              END
            ELSE
              Writeln('Der er ingen grund til at kaste rundt med hammeren her.');
          END;
      END
    ELSE
      Writeln('Der ingen grund til at kaste med ', ObjTekst(FundetOrd, Lille), '.');
  Rens;
END;

PROCEDURE Smid;

BEGIN
  IF Alt <> 0 THEN
    BEGIN
      REPEAT
        IF (Objekt[Alt].Placering = 250) OR
           (Objekt[Alt].Placering = 252) THEN
          FundetOrd := Alt;
        Inc(Alt);
      UNTIL (FundetOrd <> 0) OR (Alt > AntalTing);
      IF Alt > AntalTing THEN
        BEGIN
          Alt := 0;
          FlagB[2] := False;
          Rens;
        END;
    END;
  IF FundetOrd <> 0 THEN
    BEGIN
      IF (Objekt[FundetOrd].Placering = 250) OR
         (Objekt[FundetOrd].Placering = 252) THEN
        BEGIN
          IF (FundetOrd = 40) AND (Flint = 1) THEN
            BEGIN
              Dec(NuOrd);
              Kast;
            END
          ELSE
            BEGIN
              Write(ObjTekst(FundetOrd,Kort), ' : ');
              IF Objekt[FundetOrd].Placering = 252 THEN
                Writeln('Smidt (Taget af fõrst).')
              ELSE
                BEGIN
                  Writeln('Smidt.');
                  Dec(BaaretVaegt, Objekt[FundetOrd].Vaegt);
                END;
              Objekt[FundetOrd].Placering := StedNummer;
            END;
          Traek;
        END
      ELSE
        BEGIN
          DuHarIkke;
          Rens;
        END;
    END
  ELSE
    BEGIN
      IF Kord = 'ALT' THEN
        Alt := 1
      ELSE
        IF FlagB[2] = True THEN
          BEGIN
            FlagB[2] := False;
            Alt := 0;
          END;
    END;
END;

PROCEDURE Liste;

  VAR
    A       : Byte;
    IngFlag : Boolean;

BEGIN
  Writeln('Du bërer pÜ : ');
  Writeln;
  IngFlag := True;
  FOR A := 1 TO AntalTing DO
    BEGIN
      IF (Objekt[A].Placering = 250) OR (Objekt[A].Placering = 252) THEN
        BEGIN
          Write(ObjTekst(A, Kort));
          IF Objekt[A].Placering = 252 THEN
            Write(' (Taget pÜ).');
          Writeln;
          IngFlag := False;
        END;
    END;
  IF IngFlag = True THEN
    Writeln('Ingenting.');
  Rens;
END;

PROCEDURE Undersoeg;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    BEGIN
      UndTekst(FundetOrd);
      Traek;
    END;
  Rens;
END;

PROCEDURE Koeb;

BEGIN
  FlagB[9] := True;
  KendPas;
  IF FlagB[5] = True THEN
    IF (StedNummer = 8) AND (FundetOrd IN [11 .. 16]) THEN
      BEGIN
        IF Objekt[FundetOrd].Placering <> 0 THEN
          Writeln('Du har allerede bestilt ', ObjTekst(FundetOrd,Lille), '.')
        ELSE
          IF Objekt[2].Placering <> 250 THEN
            Besked(11)
          ELSE
            IF Kyats - Pris[FundetOrd - 5] < 0 THEN
              Besked(7)
            ELSE
              BEGIN
                SkabObj(FundetOrd);
                Kyats := Kyats - Pris[FundetOrd - 5];
                Writeln('Du bestiller ', ObjTekst(FundetOrd,Lille),
                ' for ', Pris[FundetOrd - 5] : 2 : 2, ' kyats. ');
                Besked(12);
                Traek;
              END;
      END
    ELSE
      IF (StedNummer = 2) AND (FundetOrd = 34) THEN
        BEGIN
          IF Objekt[34].Placering <> 0 THEN
            Besked(40)
          ELSE
            IF Objekt[2].Placering <> 250 THEN
              Besked(11)
            ELSE
              IF Kyats < 300 THEN
                Besked(7)
              ELSE
                BEGIN
                  Kyats := Kyats - 300;
                  Besked(37);
                  SkabObj(34);
                  Inc(Score, 10);
                  Traek;
                END;
        END
      ELSE
        IF (FlagB[7] = False) AND (FlagB[8] = False) THEN
          HerErIkke
        ELSE
          IF (FundetOrd > 20) AND (FundetOrd < 24) THEN
            Besked(8)
          ELSE
            IF ((FundetOrd > 3) AND (FundetOrd < 9)) AND (StedNummer = 5) THEN
              Besked(9)
            ELSE
              Besked(2);
  Rens;
  FlagB[9] := False;
END;

PROCEDURE Indsaet;

VAR
  A   : Byte;

  PROCEDURE LockTrack(Hvor, Bag : Byte);
    BEGIN
      IF Retning[Hvor,Nord] = 253 THEN
        BEGIN
          Besked(108);
          LockBip;
          Retning[Hvor,Nord] := Bag;
        END
      ELSE
        Besked(109);
  END;

BEGIN
  Tf := False;
  KendHavesPas;
  IF FlagB[5] = True THEN
    BEGIN
      IF KommandoOrd[NuOrd + 1] <> 'I' THEN
        Writeln('Du skal ogsÜ sige, hvad du vil indsëtte tingen i.')
      ELSE
        BEGIN
          Inc(NuOrd);
          GFord := FundetOrd;
          NytOrd;
          IF FundetOrd = 0 THEN
            Writeln('Indsët ', ObjTekst(GFord, Lille), ' i hvad for noget ?')
          ELSE
            IF (FlagB[8] = False) AND (FlagB[7] = False) THEN
              HerErIkke
            ELSE
              BEGIN
                IF (GFord = 2) AND (FundetOrd = 25) THEN
                  BEGIN
                    IF Indkoeb = 0 THEN
                      Besked(10)
                    ELSE
                      IF Kyats - Indkoeb < 0 THEN
                        BEGIN
                          Besked(3);
                          Bip;
                          Traek;
                        END
                      ELSE
                        BEGIN
                          Besked(4);
                          Kyats := Kyats - IndKoeb;
                          IndKoeb := 0;
                          FOR A := 4 TO 8 DO
                            IF Objekt[A].Placering = 250 THEN
                              Pris[A - 3] := 0;
                          Retning[5, Nord] := 4;
                          Traek;
                        END;
                  END;
                IF (GFord = 28) AND (FundetOrd = 30) THEN
                  BEGIN
                    Besked(34);
                    FjernObj(30);
                    FjernObj(28);
                    SkabObj(31);
                    Inc(Score, 15);
                    Traek;
                  END;
                IF (GFord = 67) AND (FundetOrd = 64) THEN
                  BEGIN
                    Besked(102);
                    FlagB[15] := True;
                    Traek;
                  END;
                IF (GFord = 39) THEN
                  BEGIN
                    CASE FundetOrd OF
                      73 : BEGIN
                             LockTrack(78,79);
                             Traek;
                           END;
                      76 : BEGIN
                             LockTrack(88,91);
                             Traek;
                           END;
                      75 : BEGIN
                             LockTrack(86,92);
                             Traek;
                           END;
                    ELSE
                      BEGIN
                        Besked(1);
                        Tf := True;
                      END;
                    END;
                  END;
                IF GFord = 94 THEN
                  BEGIN
                    IF (FundetOrd = 95) AND (FlagB[20] = False) THEN
                      BEGIN
                        Besked(135);
                        FjernObj(94);
                        Traek;
                      END
                    ELSE
                      IF (FundetOrd = 93) AND (FlagB[19] = False) THEN
                        BEGIN
                          Besked(138);
                          Bip;
                          FlagB[19] := True;
                          Traek;
                        END
                      ELSE
                        Besked(2);
                  END;
                IF (GFord = 26) AND (FundetOrd = 10) THEN
                  BEGIN
                    Besked(171);
                    Spil;
                    FjernObj(26);
                    Inc(Score, 5);
                    Traek;
                  END;
                IF (GFord = 40) AND (FundetOrd = 78) AND (Flint = 1) THEN
                  BEGIN
                    Writeln('Steve Flint er for langt vëk. Men du kunne jo gõre noget andet med kniven.');
                    Tf := True;
                  END;
                IF (FundetOrd IN [18, 19, 20, 29]) OR
                   ((GFord <> 28) AND (FundetOrd = 30)) THEN
                  Besked(41)
                  ELSE
                    IF Tf = False THEN
                      Besked(1);
              END;
          END;
    END;
  Rens;
END;

PROCEDURE Spis;

BEGIN
  KendPas;
  IF FlagB[5] = True THEN
    IF (FlagB[7] = False) AND (FlagB[8] = True) THEN
      Besked(6)
    ELSE
      IF (FlagB[7] = False) AND (FlagB[8] = False) THEN
        HerErIkke
      ELSE
        BEGIN
          IF NOT (FundetOrd IN [5, 15 .. 17, 59]) THEN
            Writeln('Jeg har aldrig hõrt, at man skulle kunne spise ',
            ObjTekst(FundetOrd, Lille), '.');
          IF FundetOrd = 5 THEN
            BEGIN
              Besked(13);
              Inc(Hunger,105);
              FjernObj(5);
              Traek;
            END;
          IF FundetOrd = 15 THEN
            BEGIN
              Besked(18);
              Inc(Hunger,32);
              FjernObj(15);
              Traek;
            END;
          IF FundetOrd = 16 THEN
            BEGIN
              Besked(19);
              Inc(Hunger,37);
              FjernObj(16);
              Traek;
            END;
          IF FundetOrd = 17 THEN
            BEGIN
              Besked(20);
              Inc(Hunger,63);
              FjernObj(17);
              Traek;
            END;
          IF FundetOrd = 59 THEN
            Writeln('YRF! YRF! Nej tak.');
          IF Hunger > 135 THEN
            BEGIN
              Besked(14);
              FlagB[4] := True;
            END;
        END;
  Rens;
END;

PROCEDURE Drik;

BEGIN
  KendPas;
  IF FlagB[5] = True THEN
    IF (FlagB[7] = False) AND (FlagB[8] = True) THEN
      Besked(25)
    ELSE
      IF (FlagB[7] = False) AND (FlagB[8] = False) THEN
        HerErIkke
      ELSE
        BEGIN
          IF NOT (FundetOrd IN [11 .. 14]) THEN
            Writeln('Du kan da ikke drikke ', ObjTekst(FundetOrd, Lille), '.');
          IF FundetOrd = 11 THEN
            BEGIN
              Besked(21);
              Inc(Hunger, 15);
              DesObj(11);
              Traek;
            END;
          IF FundetOrd = 12 THEN
            BEGIN
              Besked(22);
              Inc(Hunger,25);
              DesObj(12);
              SkabObj(19);
              Inc(Score,5);
              Traek;
            END;
          IF FundetOrd = 13 THEN
            BEGIN
              Besked(23);
              Inc(Hunger, 17);
              DesObj(13);
              SkabObj(18);
              Traek;
            END;
          IF FundetOrd = 14 THEN
            BEGIN
              Besked(24);
              Inc(Hunger, 19);
              DesObj(14);
              SkabObj(20);
              Traek;
            END;

        END;
  Rens;
END;

PROCEDURE Fyld;

BEGIN
  KendErHerPas;
  Inc(NuOrd);
  IF FlagB[5] = True THEN
    IF (KommandoOrd[NuOrd] <> 'I') AND (KommandoOrd[NuOrd] <> 'MED') THEN
      Besked(32)
    ELSE
      BEGIN
        KendErHerPas;
        IF FlagB[5] = True THEN
          BEGIN
            IF KommandoOrd[NuOrd - 1] = 'MED' THEN
              Byt(GFord,FundetOrd);
            IF (GFord = 29) AND (FundetOrd = 19) THEN
              BEGIN
                Besked(33);
                Byt(Objekt[32].Placering,Objekt[29].Placering);
                Byt(Objekt[19].Placering,Objekt[30].PLacering);
                Traek;
              END
            ELSE
              Besked(2);
          END;
      END;
  Rens;
END;

PROCEDURE Giv;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    BEGIN
      IF KommandoOrd[NuOrd + 1] = 'TIL' THEN
        Inc(NuOrd);
      KendErHerPas;
      IF FlagB[5] = True THEN
        BEGIN
          IF KommandoOrd[NuOrd - 1] = 'TIL' THEN
            Byt(GFord,FundetOrd);
          IF (GFord = 21) OR (GFord = 22) THEN
            BEGIN
              IF (GFord = 21) AND (FundetOrd <> 34) THEN
                Besked(35);
              IF (GFord = 22) AND (FundetOrd <> 34) THEN
                Besked(36);
              IF FundetOrd = 34 THEN
                BEGIN
                  IF GFord = 21 THEN
                    Besked(39)
                  ELSE
                    Besked(38);
                  DesObj(34);
                  SkabObj(28);
                  SkabObj(35);
                  SkabObj(36);
                  Inc(Score, 15);
                  Traek;
                  StedNummer := 7;
                END;
            END
          ELSE
            IF GFord = 27 THEN
              BEGIN
                IF FundetOrd = 1 THEN
                  Besked(44)
                ELSE
                  IF FundetOrd = 31 THEN
                    BEGIN
                      Besked(46);
                      FjernObj(31);
                      Objekt[27].Placering := 0;
                      Retning[18,Syd] := 19;
                      Inc(Score, 25);
                      Traek;
                    END
                  ELSE
                    Besked(43);
              END
            ELSE
              Writeln('Du kan ikke give ', ObjTekst(GFord,Lille), ' ',
              ObjTekst(FundetOrd,Lille), '.');
          END;
      END;
  Rens;
END;

PROCEDURE Tal;

VAR
  SagtStreng  : LinieType;
  A           : Byte;

BEGIN
  SagtStreng := '';
  Write('"');
  WHILE (KlartOrd[NuOrd] <> '') AND (KlartOrd[NuOrd + 1] <> '') DO
    BEGIN
      NytOrd;
      Write(KlartOrd[NuOrd],' ');
      SagtStreng := SagtStreng + Ucasestr(KlartOrd[NuOrd]) + ' ';
    END;
  Writeln('".');
  IF (Pos('DAO SING',SagtStreng) > 0) AND (StedNummer = 23) THEN
    BEGIN
      Besked(51);
      Inc(Score, 15);
      TrykTast;
      Besked(52);
      FOR A := 38 TO 40 DO
        SkabObj(A);
      Objekt[41].Placering := 252;
      SkabObj(67);
      SkabObj(68);
      StedNummer := 24;
      Kasse := 1;
      Inc(Score, 5);
      TrykTast;
      VisSted;
    END
  ELSE
    IF ((Pos('MY BONNIE',SagtStreng) > 0) OR (Pos('MY BONIE',SagtStreng) > 0))
       AND (StedNummer = 58) THEN
      BEGIN
        Besked(94);
        StedNummer := 59;
        Inc(Score, 15);
        VisSted;
      END
    ELSE
      IF (Pos('CLASSIC',SagtStreng) > 0) AND (Heli > 0) THEN
        BEGIN
          Besked(157);
          Inc(score, 20);
          Heli := 3;
        END
      ELSE
        BEGIN
          IF (Pos('REALWARE',SagtStreng) > 0) THEN
            Writeln('RealWare er bare den sejeste danske software !!!');
          IF StedNummer = 10 THEN Besked(47);
          IF Objekt[27].Placering = StedNummer THEN Besked(48);
          IF StedNummer = 23 THEN Besked(49);
        END;
  Rens;
  Traek;
END;

PROCEDURE Taend;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    IF FundetOrd IN [7, 34, 31, 8, 83, 93, 95] THEN
      BEGIN
        IF FundetOrd = 7 THEN
          Besked(63);
        IF FundetOrd = 34 THEN
          Besked(64);
        IF FundetOrd = 31 THEN
          Besked(66);
        IF FundetOrd = 8 THEN
          BEGIN
            IF StedNummer = 24 THEN
              Besked(60)
            ELSE
              Besked(65);
            Traek;
          END;
        IF FundetOrd = 83 THEN
          BEGIN
            IF FlagB[17] = False THEN
              BEGIN
                Besked(127);
                FlagB[17] := True;
                Inc(Score, 10);
                Traek;
              END
            ELSE
              Besked(41);
          END;
        IF FundetOrd = 95 THEN
          IF Objekt[94].Placering = 0 THEN
            BEGIN
              Besked(136);
              SkabObj(94);
              FlagB[20] := True;
              Inc(Score, 5);
              Traek;
            END
          ELSE
            BEGIN
              Writeln('Ok. Intet sker.');
              Traek;
            END;
        IF FundetOrd = 93 THEN
          BEGIN
            IF (FlagB[19] = False) THEN
              Besked(139);
            IF (FlagB[20] = False) AND (FlagB[19] = True) THEN
              Besked(158);
            IF (FlagB[20] = True) AND (FlagB[19] = True) AND (FlagB[18] = False) THEN
              BEGIN
                Besked(140);
                FlagB[4] := True;
              END;
            IF (FlagB[20] = True) AND (FlagB[19] = True) AND (FlagB[18] = True) AND (Flint = 0) THEN
              Besked(141);
            IF Passw = 2 THEN
              Besked(41);
            IF Passw = 1 THEN
              Besked(160);
            IF (FlagB[20] = True) AND (FlagB[19] = True) AND (FlagB[18] = True) AND (Flint <> 0) AND (Passw = 0) THEN
              BEGIN
                Besked(142);
                Passw := 1;
                Traek;
              END;
          END;
      END
    ELSE
      Writeln('Du kan ikke tënde ',ObjTekst(FundetOrd,Lille));
  Rens;
END;

PROCEDURE Hiv;

BEGIN
  IF KommandoOrd[NuOrd + 1] = 'I' THEN Inc(NuOrd);
  FlagB[9] := True;
  NytOrd;
  FlagB[9] := False;
  IF (FundetOrd <> 42) AND (FlagB[7] = False) AND (FlagB[8] = False) THEN
    HerErIkke
  ELSE
    IF FundetOrd = 0 THEN
      KenderIkke
    ELSE
      IF FundetOrd IN [42] THEN
        BEGIN
          IF FundetOrd = 42 THEN
            IF StedNummer = 24 THEN
              BEGIN
                StedNummer := 25;
                Kasse := 5;
                VisSted;
                Ratata(10);
              END
            ELSE
              HerErIkke;
        END
      ELSE
        Writeln('Du kan ikke trëkke i ', ObjTekst(FundetOrd,Lille), '.');
  Rens;
END;

PROCEDURE Skyd;

BEGIN
  IF KommandoOrd[NuOrd + 1] = '' THEN
    BEGIN
      Writeln('Du skal ogsÜ sige, hvad du vil skyde');
      Rens;
      Exit;
    END;
  NytOrd;
  IF Objekt[38].Placering <> 250 THEN
    Besked(67)
  ELSE
    IF FundetOrd = 0 THEN
      KenderIkke
    ELSE
      IF (FlagB[7] = False) AND (FlagB[8] = False) THEN
        HerErIkke
      ELSE
        IF FundetOrd IN [43, 45, 60] THEN
          BEGIN
            IF FundetOrd = 43 THEN
              BEGIN
                Besked(62);
                Ratata(3);
                Argh;
                Byt(Objekt[43].Placering,Objekt[44].Placering);
                Inc(Kasse);
                Inc(Score, 10);
                Traek;
              END;
            IF FundetOrd = 45 THEN
              BEGIN
                Besked(70);
                SolArg;
                Byt(Objekt[45].Placering,Objekt[46].Placering);
                Inc(Kasse);
                Retning[25,Nord] := 26;
                Retning[25,Syd] := 27;
                Inc(Score, 10);
                Traek;
              END;
            IF FundetOrd = 60 THEN
              BEGIN
                Besked(92);
                Ratata(11);
                Aaargh;
                FlagB[4] := True;
              END;
          END
        ELSE
          Writeln('Jeg synes ikke du skulle skyde ', ObjTekst(FundetOrd,Lille), '.');
  Rens;
END;

PROCEDURE Aaben;

BEGIN
  NytOrd;
  IF (FlagB[7] = False) AND (FlagB[8] = False) AND (Kord <> 'KASS') AND (Kord <> 'LèG') THEN
    HerErIkke
  ELSE
    IF FundetOrd IN [0, 6, 12, 14, 15, 17, 52, 53, 63, 65, 69, 73, 75, 76, 84, 87] THEN
      BEGIN
        IF FundetOrd = 0 THEN
          Besked(59);
        IF FundetOrd = 6 THEN Besked(41);
        IF (FundetOrd > 11) AND (FundetOrd < 18) THEN Besked(71);
        IF FundetOrd = 69 THEN Besked(110);
        IF FundetOrd = 84 THEN Besked(121);
        IF FundetOrd IN [63, 73, 75, 76] THEN Besked(119);
        IF FundetOrd = 87 THEN Besked(132);
        IF (FundetOrd = 52) OR (FundetOrd = 53) THEN
          BEGIN
            IF FlagB[11] = True THEN
              Besked(71)
            ELSE
              BEGIN
                FlagB[11] := True;
                Besked(72);
                IF StedNummer = 37 THEN
                  BEGIN
                    Retning[37,Ned] := 39;
                    Retning[39,Op] := 37;
                    Writeln('Du kan gÜ ned nu.');
                  END;
                IF Sejl > 0 THEN
                  BEGIN
                    Retning[39,Op] := 41;
                    Retning[41,Ned] := 39;
                    Writeln('Du kan gÜ op nu.');
                  END;
                IF (Sejl = 0) AND (StedNummer = 39) THEN
                  BEGIN
                    Retning[39,Op] := 37;
                    Retning[37,Ned] := 39;
                    Writeln('Du kan gÜ op nu.');
                  END;
                Traek;
              END;
          END;
        IF FundetOrd = 65 THEN
          BEGIN
            IF Objekt[85].Placering = 0 THEN
              BEGIN
                Besked(122);
                Objekt[85].Placering := 68;
                Inc(Score, 10);
                Traek;
              END
            ELSE
              Besked(123);
          END;
      END
    ELSE
      Writeln('Du kan ikke Übne ', ObjTekst(FundetOrd,Lille), '.');
  Rens;
END;

PROCEDURE Luk;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    IF FundetOrd IN [12, 14, 15, 17, 52, 53] THEN
      BEGIN
        IF (FundetOrd > 11) AND (FundetOrd < 18) THEN
          Besked(2);
        IF (FundetOrd = 52) OR (FundetOrd = 53) THEN
          BEGIN
            IF FlagB[11] = False THEN
              Besked(73)
            ELSE
              BEGIN
                FlagB[11] := False;
                Retning[39,Op] := 0;
                Retning[37,Ned] := 0;
                Retning[41,Ned] := 0;
                Retning[40,Ned] := 0;
                Besked(74);
                Traek;
              END;
          END;
      END
    ELSE
      Writeln('Du kan ikke lukke ', ObjTekst(FundetOrd, Lille), '.');
  Rens;
END;

PROCEDURE Tryk;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    IF FundetOrd IN [50, 57, 67, 82] THEN
      BEGIN
        IF FundetOrd = 50 THEN
          BEGIN
            IF Sejl > 0 THEN
              BEGIN
                Besked(75);
                Traek;
              END;
            IF (FlagB[11] = True) AND (Sejl = 0) THEN
              BEGIN
                Besked(76);
                Aaargh;
                FlagB[4] := True;
              END;
            IF (Sejl = 0) AND (FlagB[11] = False) THEN
              BEGIN
                Besked(77);
                Inc(Sejl);
                Inc(Score, 30);
                Traek;
              END;
          END;
        IF FundetOrd = 57 THEN
          BEGIN
            IF FlagB[12] = True THEN Besked(75)
            ELSE
              BEGIN
                Besked(90);
                FlagB[12] := True;
                Inc(Score, 5);
                Traek;
              END;
          END;
        IF FundetOrd = 67 THEN
          BEGIN
            Besked(98);
            Hvsss;
            Traek;
            IF (FlagB[15] = True) OR (StedNummer = 68) THEN
              BEGIN
                FlagB[15] := False;
                Objekt[66].Placering := 68;
                Inc(KokOp, 5);
              END;
            IF Objekt[68].Placering <> 252 THEN
              BEGIN
                Besked(99);
                IF KokOp > 3 THEN
                  Dec(KokOp,3)
                ELSE IF KokOp > 0 THEN
                  KokOp := 0;
              END;
          END;
        IF FundetOrd = 82 THEN
          BEGIN
            IF (StedNummer = 104) AND (Retning[104, Nord] = 253) THEN
              BEGIN
                Besked(137);
                Retning[104, Nord] := 105;
              END
            ELSE
              Besked(75);
          END;
      END
    ELSE
      Writeln('Trykke pÜ ', ObjTekst(FundetOrd, Lille), ' - tsk, tsk, tsk.');
  Rens;
END;

PROCEDURE Tril;

BEGIN
  KendHavesPas;
  IF FlagB[5] = True THEN
    IF FundetOrd IN [54] THEN
      BEGIN
        IF FundetOrd = 54 THEN
          BEGIN
            IF StedNummer <> 46 THEN
              Besked(86)
            ELSE
              BEGIN
                Besked(87);
                Bang;
                DesObj(54);
                Objekt[55].Placering := 251;
                Objekt[56].Placering := 251;
                Objekt[57].Placering := 46;
                Objekt[58].Placering := 46;
                Inc(Score, 20);
                Traek;
              END;
          END;
      END
    ELSE
      Writeln('Der er inge grund til at trille med ', ObjTekst(FundetOrd, Lille), '.');
  Rens;
END;

PROCEDURE Knus;

BEGIN
  KendErHerPas;
  IF FlagB[5] = False THEN
    BEGIN
      Rens;
      Exit;
    END;
  IF KommandoOrd[NuOrd + 1] = 'OP' THEN
    Inc(NuOrd);
  IF KommandoOrd[NuOrd + 1] <> 'MED' THEN
    Writeln('Du skal ogsÜ sige, hvad du vil õdelëgge ', ObjTekst(FundetOrd, Lille), ' med.')
  ELSE
    BEGIN
      Inc(NuOrd);
      KendHavesPas;
      IF FlagB[5] = True THEN
        BEGIN (* Rutine starter her *)
          IF (GFord = 69) AND (FundetOrd = 24) THEN
            BEGIN
              Besked(106);
              Krak;
              Delay(700);
              Krak;
              Byt(Objekt[69].Placering,Objekt[70].Placering);
              Retning[72,Vest] := 73;
              Inc(Score, 15);
              Traek;
              Rens;
              Exit;
            END;
          IF GFord = 88 THEN
            BEGIN
              Besked(134);
              Rens;
              Exit;
            END;
          IF (GFord = 92) THEN
            BEGIN
              IF FundetOrd = 24 THEN
                BEGIN
                  IF Loronov = 0 THEN
                    Besked(151)
                  ELSE
                    IF Loronov = 1 THEN
                      Besked(150)
                    ELSE
                      Besked(2);
                  Rens;
                  Exit;
                END;
              IF FundetOrd = 90 THEN
                BEGIN
                  IF Loronov = 0 THEN
                    BEGIN
                      Besked(153);
                      Retning[94, Vest] := 113;
                      Inc(Score, 15);
                      Traek;
                    END
                  ELSE
                    IF Loronov = 1 THEN
                      BEGIN
                        Besked(152);
                        Retning[94, Vest] := 113;
                        Objekt[79].Placering := 115;
                        Inc(Loronov);
                        Inc(Score, 15);
                        Traek;
                      END
                    ELSE
                      Besked(2);
                  Exit;
                END;
              IF (FundetOrd IN [24, 90]) = False THEN
                Besked(1);
            END
          ELSE
            Besked(1);
        END;
    END;
  Rens;
END;

PROCEDURE KigI;

BEGIN
  Inc(NuOrd);
  KendErHerPas;
  IF FlagB[5] = True THEN
    BEGIN
      IF FundetOrd IN [72] THEN
        BEGIN
          IF FundetOrd = 72 THEN
            BEGIN
              Besked(107);
              Traek;
            END;
        END
      ELSE
        BEGIN
          Dec(NuOrd);
          Undersoeg;
        END;
    END;
  Rens;
END;

PROCEDURE Laas;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    IF KommandoOrd[NuOrd + 1] = 'OP' THEN
      BEGIN
        Inc(NuOrd);
        IF KommandoOrd[NuOrd + 1] <> 'MED' THEN
          Writeln('Du skal ogsÜ sige, hvad du vil lÜse op med.')
        ELSE
          BEGIN
            Inc(NuOrd,1);
            KendHavesPas;
            IF FlagB[5] = True THEN
              BEGIN
                IF (GFord IN [73, 75, 76]) AND (FundetOrd = 39) THEN
                  Besked(120)
                ELSE
                IF (GFord = 84) AND (FundetOrd = 81) AND (FlagB[16] = True) THEN
                  BEGIN
                    Besked(115);
                    Flint := 4;
                    FlagB[16] := False;
                    Objekt[79].Placering := 0;
                    Objekt[84].Vaegt := 1;
                    Retning[91,Syd] := 88;
                    Traek;
                  END
                ELSE
                  Besked(1);
              END;
          END;
      END
    ELSE
      BEGIN
        IF KommandoOrd[NuOrd + 1] = 'MED' THEN
          Inc(NuOrd,2);
        IF FundetOrd IN [69,73,75,76,84] THEN
          Besked(41)
        ELSE
          Besked(1);
      END;
  Rens;
END;

PROCEDURE Skru;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    BEGIN
      IF (KommandoOrd[NuOrd + 1] = 'AF') OR (KommandoOrd[NuOrd + 1] = 'UD') THEN
        Inc(NuOrd);
      IF KommandoOrd[NuOrd + 1] <> 'MED' THEN
        Writeln('Du skal ogsÜ sige, hvad du vil skrue af med.')
      ELSE
        Inc(NuOrd);
        KendHavesPas;
        IF FlagB[5] = True THEN
          BEGIN
            IF (GFord = 87) AND (FundetOrd = 85) AND (Objekt[88].Placering = 0) THEN
              BEGIN
                Besked(130);
                Objekt[88].Placering := 97;
                Inc(Score, 15);
                Traek;
              END
            ELSE
              Besked(1);
          END;
    END;
  Rens;
END;

PROCEDURE Kortslut;

BEGIN
  KendErHerPas;
  IF FlagB[5] = True THEN
    IF KommandoOrd[NuOrd + 1] <> 'MED' THEN
      Writeln('Du skal ogsÜ sige hvad du vil kortslutte med.')
    ELSE
      BEGIN
        Inc(NuOrd);
        KendHavesPas;
        IF FlagB[5] = True THEN
          BEGIN
            IF (GFord = 88) AND (FundetOrd = 89) AND (FlagB[18] = False) THEN
              BEGIN
                Besked(131);
                FlagB[18] := True;
                Inc(Score, 25);
                Traek;
              END
            ELSE
              Besked(1);
          END;
      END;
  Rens;
END;

PROCEDURE Skriv;

BEGIN
  IF StedNummer <> 105 THEN
    Besked(143)
  ELSE
    BEGIN
      IF Passw = 0 THEN
        Besked(161);
      IF Passw = 2 THEN
        Besked(41);
      IF Passw = 1 THEN
        BEGIN
          IF Ucasestr(KlartOrd[NuOrd + 1]) = 'MELBOURNE' THEN
            BEGIN
              Besked(145);
              Passw := 2;
              Inc(Score, 30);
              Traek;
            END
          ELSE
            Besked(144);
        END;
    END;
  Inc(NuOrd);
  Rens;
END;

PROCEDURE Flyv;

BEGIN
  IF StedNummer <> 115 THEN
    Writeln('MÜske kunne du flyve, hvis du legede pipfugl, men ellers ikke.')
  ELSE
    IF (StedNummer = 115) THEN
      BEGIN
        IF Heli > 0 THEN
          BEGIN
            Writeln('Du sëtter helikopteren pÜ den rette kurs og begynder at flyve afsted.');
            Traek;
          END;
        IF Heli = 0 THEN
          IF Objekt[91].Placering <> 252 THEN
            Besked(154);
        IF (Heli = 0) AND (Objekt[91].Placering = 252) AND (Loronov < 3) THEN
          Writeln('Du kan ikke bare stikke af, Sansom! Du mangler en vigtig del af din mission!');
        IF (Heli = 0) AND (Objekt[91].Placering = 252) AND (Loronov = 3) THEN
          BEGIN
            Besked(155);
            Inc(Loronov);
            Inc(Score, 15);
            Traek;
            Inc(Heli);
          END;
      END
    ELSE
      Besked(2);
  Rens;
END;

PROCEDURE Smil;

BEGIN
  IF StedNummer = 10 THEN
    Writeln('Konen og den lille pige smiler igen.')
  ELSE
    IF StedNummer = 23 THEN
      Writeln('Den gamle burmeser smiler venligt igen.')
    ELSE
      IF (Flint = 3) OR ((Loronov = 1) AND (StedNummer = 94)) OR (StedNummer = 115) THEN
        Writeln('Loronov smiler hurtigt til dig.')
      ELSE
        Writeln('Du smiler lõs. Intet sker.');
  Rens;
END;

PROCEDURE Betal;

BEGIN
  IF StedNummer = 5 THEN
    Writeln('Man betaler ved at stikke sit pengekort i sprëkken ved dõren.')
  ELSE
    IF (StedNummer = 2) OR (StedNummer = 8) THEN
      Writeln('Du skal kõbe noget for at betale.')
    ELSE
      Writeln('Her er ikke noget, du kan betale.');
  Rens;
END;

PROCEDURE KommandoFortolker;

BEGIN
  IF Alt = 0 THEN
    BEGIN
      Inc(NuOrd);
      IF NuOrd > OrdNummer THEN
        BEGIN
          FlagB[1] := False;
          FlagB[2] := False;
          Alt := 0;
          Writeln;
          LinieInput(Ordre, True);
          OrdDeler;
          NuOrd := 1;
        END;
    END;
  Kord  := KommandoOrd[NuOrd];
  KKord := KommandoOrd[NuOrd] + ' ' + KommandoOrd[NuOrd + 1];
  IF (Alt = 0) AND ((FlagB[1] = True) OR (FlagB[2] = True)) THEN FindOrd;
  IF FlagB[1] = True THEN
    Tag;
  IF FlagB[2] = True THEN
    Smid;
  IF (Kord = 'N') OR (Kord = 'NORD') THEN GaaNord;
  IF (Kord = 'S') OR (Kord = 'SYD') THEN GaaSyd;
  IF (Kord = 'ù') OR (Kord = 'ùST') THEN GaaOest;
  IF (Kord = 'V') OR (Kord = 'VEST') THEN GaaVest;
  IF (Kord = 'O') OR (Kord = 'OP') THEN GaaOp;
  IF (Kord = 'NE') OR (Kord = 'NED') THEN GaaNed;
  IF Kord = 'TAG' THEN
    BEGIN
      FlagB[1] := True;
      IF KommandoOrd[NuOrd + 1] = 'ALT' THEN
        BEGIN
          Inc(NuOrd);
          Alt := 1;
        END
      ELSE
        Alt := 0;
      Rens;
    END;
  IF (Kord = 'SMID') OR (Kord = 'DROP') OR (Kord = 'LíG') OR (Kord = 'STIL') THEN
    BEGIN
      FlagB[2] := True;
      IF KommandoOrd[NuOrd + 1] = 'ALT' THEN
        BEGIN
          Inc(NuOrd);
          Alt := 1;
        END
      ELSE
        Alt := 0;
      Rens;
    END;
  IF (KKord = 'KIG I') OR (KKord = 'KIK I') OR (KKord = 'SE I') THEN
    KigI;
  IF (Kord = 'UNDE') OR (Kord = 'U') OR (Kord = 'CHECK') OR (Kord = 'LíS') THEN UnderSoeg;
  IF (KKord = 'SE Pè') OR (KKord = 'KIG Pè') OR (KKord = 'KIK Pè') THEN
    BEGIN
      Inc(NuOrd);
      UnderSoeg;
    END;
  IF (Kord = 'LIST') OR (Kord = 'BAGA') OR (Kord = 'BèRE') THEN Liste;
  IF (Kord = 'QUIT') OR (Kord = 'STOP') OR (Kord = 'SLUT') THEN Slut;
  IF (Kord = 'KIG') OR (Kord = 'SE') THEN
    BEGIN
      VisSted;
      Rens;
    END;
  IF (Kord = 'KùB') OR (Kord = 'BEST') THEN Koeb;
    IF (Kord = 'STIK') OR (Kord = 'INDS') OR (Kord = 'INDK') OR
       (Kord = 'PUT') OR (Kord = 'PROP') OR (Kord = 'SíT') THEN Indsaet;
  IF Kord = 'SPIS' THEN Spis;
  IF Kord = 'DRIK' THEN Drik;
  IF (Kord = 'FYLD') OR (Kord = 'HíLD') THEN Fyld;
  IF (Kord = 'GIV') OR (Kord = 'FORí') THEN Giv;
  IF (Kord = 'SIG') OR (Kord = 'RèB') THEN Tal;
  IF KKord = 'SPùR EFTE' THEN
    BEGIN
      Inc(NuOrd);
      Tal;
    END;
  IF (KKord = 'TíND HELI') OR (KKord = 'STAR HELI') THEN Flyv;
  IF (Kord = 'TíND') OR (Kord = 'STAR') THEN Taend;
  IF (Kord = 'TRíK') OR (Kord = 'HIV') OR (Kord = 'RYK') THEN Hiv;
  IF (Kord = 'SKYD') THEN Skyd;
  IF (Kord = 'èBEN') OR (Kord = 'èBN') THEN Aaben;
  IF (Kord = 'LUK') OR (Kord = 'SMíK') THEN Luk;
  IF KKord = 'TRYK Pè' THEN
    BEGIN
      Inc(NuOrd);
      Tryk;
    END;
  IF (Kord = 'TRYK') THEN Tryk;
  IF (Kord = 'KAST') THEN Kast;
  IF (Kord = 'TRIL') THEN Tril;
  IF (Kord = 'HJíL') OR (Kord = 'TIPS') THEN
    BEGIN
       Hjaelp;
       Rens;
    END;
  IF (Kord = 'KNUS') OR (Kord = 'SMAD') OR (Kord = 'BRYD') OR (Kord = 'ùDEL') OR (Kord = 'BRíK') THEN Knus;
  IF Kord = 'LèS' THEN Laas;
  IF Kord = 'SKRU' THEN Skru;
  IF Kord = 'KORT' THEN Kortslut;
  IF Kord = 'SKRI' THEN Skriv;
  IF (Kord = 'FLYV') OR (Kord = 'LET') THEN Flyv;
  IF (Kord = 'SAVE') OR (Kord = 'GEM') THEN BEGIN Save; Rens; END;
  IF (Kord = 'LOAD') OR (Kord = 'HENT') THEN BEGIN Load; Rens; END;
  IF Kord = 'DRíB' THEN
    BEGIN
      Inc(NuOrd);
      Writeln('Hvis du vil drëbe nogen, mÜ du fortëlle hvordan du vil gõre.');
      Rens;
    END;
  IF (Kord = 'FUCK') OR (Kord = 'IDIO') OR (Kord = 'SKID') OR (Kord = 'LORT') THEN
    BEGIN
      Writeln('Der er ikke brugt dyr programplads pÜ at svare pÜ sÜdanne fornërmelser.');
      Rens;
    END;
  IF (Kord = 'SOV') THEN
    BEGIN
      Writeln('Du mÜ blive ved til du ikke kan mere, Sansom. Du har jo din mission.');
      Rens;
    END;
  IF Kord = 'BRUG' THEN
    BEGIN
      Writeln('Hvis du vil bruge noget, mÜ du komme nërmere ind pÜ, hvad du vil gõre.');
      Inc(NuOrd);
      Rens;
    END;
  IF Kord = 'SMIL' THEN Smil;
  IF (Kord = 'SNAK') OR (Kord = 'TAL') THEN
    BEGIN
      Writeln('Hvis du vil tale med nogen, sÜ sig hvad du vil sige.');
      Rens;
    END;
  IF Kord = 'BETA' THEN Betal;
  IF (Kord = 'PIS') OR (Kord = 'SKID') THEN
    BEGIN
      IF StedNummer = 100 THEN
        Writeln('Spil Larry Laffer i stedet for, hvis det er sÜdan noget du vil.')
      ELSE
        Writeln('#&$&#$%/(&) !!!!!');
      Rens;
    END;
  IF (Kord = 'MEDI') THEN
    BEGIN
      IF StedNummer = 9 THEN
        BEGIN
          Writeln('Du tager skoene af, sëtter dig ned og mediterer. Du koncentrerer dig om din');
          Writeln('Mission. Lidt efter rejser du dig og tager skoene pÜ igen.');
        END
      ELSE
        Writeln('Her ???');
      Rens;
    END;

  IF Kord <> '' THEN KenderIkke;
END;

BEGIN

REPEAT
  Window(1, 1, 80, 25);
  ClrScr;
  Writeln('Indlëser datafiler...');
  FOR A := 1 TO 115 DO
    FOR RetKompas := Nord TO Ned DO
      Retning[A,RetKompas] := 0;
  FOR A := 1 TO 115 DO
    BEGIN
      Objekt[A].placering := 0;
      Objekt[A].Vaegt := 0;
    END;
  Assign(BitFil, FExpand('BDATA.DAT'));
  Reset(BitFil);
  FOR A := 1 TO 115 DO
    FOR RetKompas := Nord to Ned DO
      Read(BitFil,Retning[A,RetKompas]);
  FOR A := 1 TO 115 DO
    BEGIN
      Read(BitFil,Objekt[A].Placering);
      Read(BitFil,Objekt[A].Vaegt);
    END;
  Close(BitFil);
  FOR A := 1 to 25 DO
  FlagB[A] := False;
  FOR A := 1 to 115 DO
    Flag[A] := True;
  Nyhed        := 1;
  Kyats        := 750;
  Indkoeb      := 0;
  FlagB[16]    := True;
  BaaretVaegt  := 0;
  Sejl         := 0;
  KokOp        := 0;
  Flint        := 0;
  Passw        := 0;
  Loronov      := 0;
  Heli         := 0;
  Hunger       := 105;
  Score        := 0;
  StedNummer   := 1;
  AnLn         := 0;
  AntalTraek   := 0;
  Tf           := False;
  DenDetNr     := 1;
  Alt          := 0;
  NuOrd        := 0;
  OrdNummer    := 0;
  AntalTraek   := 0;
  GFord        := 0;
  Pris[1]      := 24.50;
  Pris[2]      := 30;
  Pris[3]      := 49.95;
  Pris[4]      := 649.95;
  Pris[5]      := 19.95;
  Pris[6]      := 35;
  Pris[7]      := 29.95;
  Pris[8]      := 39.95;
  Pris[9]      := 9.95;
  Pris[10]     := 15;
  Pris[11]     := 9.95;
  Pris[12]     := 5;

(* Check-StarSted kan vëre her : *)

(* Start og indledning *)
(* TextMode(7); *)
StartSkaerm;
LF(24);
KSted := 'Ved udkanten af Taunggyi';
TegnStatus;
Besked(5);
Writeln;
VisSted;

REPEAT
  KommandoFortolker
UNTIL (FlagB[3] = True) OR (FlagB[4] = True);

Writeln;
Writeln('Din score er ', Score, ' points ud af 500. Du har brugt ', AntalTraek, ' trëk.');
Writeln;
IF FlagB[4] = True THEN
  BEGIN
    Besked(26);
    Writeln;
  END;
Writeln('Vil du prõve et spil mere ? (Svar "ja" eller "nej")');
LinieInput(Ordre, True);
OrdDeler;

UNTIL KommandoOrd[1] = 'NEJ';
Besked(27);
REPEAT
  (* Bla *)
UNTIL KeyPressed;

END.
