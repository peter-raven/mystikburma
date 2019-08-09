UNIT PRSounds;

INTERFACE

  USES
    Crt;

  PROCEDURE Aaargh;
  PROCEDURE Argh;
  PROCEDURE BilStart;
  PROCEDURE Ratata(Antal : Byte);
  PROCEDURE Bang;
  PROCEDURE Krash;
  PROCEDURE Krak;
  PROCEDURE Bip;
  PROCEDURE Biiip;
  PROCEDURE Hvsss;
  PROCEDURE BilBang;
  PROCEDURE SolArg;
  PROCEDURE LockBip;
  PROCEDURE KokSkyd;
  PROCEDURE Skud;
  PROCEDURE Bip2;
  PROCEDURE Spil;

IMPLEMENTATION

  PROCEDURE Aaargh;

  VAR
    S     : Word;

  BEGIN
    FOR S := 700 DOWNTO 100 DO
      BEGIN
        Sound(S);
        Sound(S + 100);
        Delay(2);
        Sound(Random(500) + 200);
        Sound(190);
        Delay(1);
      END;
      NoSound;
  END;

  PROCEDURE Argh;

  VAR
    S    : Word;

  BEGIN
    FOR S := 700 DOWNTO 500 DO
      BEGIN
        Sound(S + 80);
        Sound(S);
        Delay(1);
        Sound(Random(500) + 100);
        Sound(170);
        Delay(1);
      END;
      NoSound;
  END;

  PROCEDURE Ratata(Antal : Byte);

  VAR
    A,
    B      : Byte;

  BEGIN
    FOR A := 1 TO Antal DO
      BEGIN
        FOR B := 200 DOWNTO 100 DO
          BEGIN
            Sound(Random(2000) + 50);
            Sound(B);
            Sound(Random(2000) + 1000);
            Sound(Random(2000) + 50);
            Sound(Random(2000) + 1000);
            Sound(Random(3000) + 1000);
            Sound(250);
          END;
        NoSound;
        Delay(20);
      END;
    NoSound;
  END;

  PROCEDURE BilStart;

  VAR
    S,
    S2,
    S3    : Byte;

  PROCEDURE VarmOp;

  VAR
    S     : Byte;

  BEGIN
    S2 := Random(20) + 50;
    S3 := Random(15) + 15;
    FOR S := 40 TO S2 DO
      BEGIN
        Sound(S);
        Delay(S3);
      END;
    FOR S := S2 DOWNTO 40 DO
      BEGIN
        Sound(S);
        Delay(S3 - 5);
      END;
  END;

  BEGIN
    FOR S := 1 to 4 DO
      VarmOp;
    FOR S := 40 to 65 DO
      BEGIN
        Sound(S);
        Delay(100);
      END;
  END;

  PROCEDURE Bang;

  VAR
    S    : Word;

  BEGIN
    FOR S := 1000 DOWNTO 40 DO
      BEGIN
        Sound(Random(3000) + 50);
        IF S < 600 THEN
          Sound(S)
        ELSE
          Sound(600);
        Sound(Random(3000) + 50);
        Sound(Random(3000) + 1000);
        Sound(Random(500) + 50);
      END;
    NoSound;
  END;

  PROCEDURE Krash;

  VAR
    S     : Word;

  BEGIN
    FOR S := 1 TO 1300 DO
      BEGIN
        Sound(Random(3000) + 50);
        Sound(400);
        Sound(Random(1000) + 1000);
        Sound(Random(3000) + 1000);
        Sound(Random(3000) + 50);
      END;
    FOR S := 800 DOWNTO 50 DO
      BEGIN
        Sound(S);
        Sound(Random(3000) + 50);
        Sound(Random(3000) + 1000);
        Sound(400);
        Sound(Random(1000) + 1000);
        Sound(Random(3000) + 50);
        Sound(S + Random(15));
      END;
    NoSound;

  END;

  PROCEDURE Krak;

  VAR
    S     : Word;

  BEGIN
    FOR S := 800 TO 1300 DO
      BEGIN
        Sound(1500 - S);
        Sound(Random(1000) + 50);
        Sound(Random(3000) + 50);
        Sound(Random(3000) + 50);
      END;
    NoSound;

  END;

  PROCEDURE Bip;

  BEGIN
    Sound(1000);
    Delay(10);
    Sound(900);
    Delay(7);
    Sound(800);
    Delay(5);
    Sound(1600);
    Delay(200);
    NoSound;
  END;

  PROCEDURE Biiip;

  VAR
    S    : Byte;

  BEGIN
    FOR S := 1 to 200 DO
      BEGIN
        Sound(1500);
        Delay(5);
        Sound(940);
      END;
    NoSound;
  END;

  PROCEDURE Hvsss;

  VAR
    S     : Word;

  BEGIN
    FOR S := 1 TO 600 DO
      BEGIN
        Sound(30000);
        Delay(1);
        Sound(3500);
        Sound(30000);
        Sound(Random(3000) + 4000);
        Sound(30000);
        Delay(1);
        Sound(Random(3000) + 4000);
        Sound(30000);
      END;
    NoSound;

  END;

PROCEDURE BilBang;

BEGIN
  Bang;
  Krash;
  Delay(200);
  Ratata(8);
  Delay(100);
  Ratata(16);
END;

PROCEDURE LockBip;

BEGIN
  Bip;
  Delay(100);
  Bip;
  Delay(200);
  Bip;
  Delay(50);
  Biiip;
END;

PROCEDURE KokSkyd;

BEGIN
  Ratata(1);
  Delay(100);
  Ratata(1);
  Delay(30);
  Ratata(1);
  Delay(800);
  Ratata(4);
  Argh;
  Ratata(5);
  Argh;
  Ratata(3);
  Delay(2000);
  Ratata(12);
  Aaargh;
END;

PROCEDURE SolArg;

BEGIN
  Ratata(2);
  Argh;
  Ratata(5);
  Argh;
  Ratata(2);
  Argh;
  Ratata(3);
  Argh;
END;

PROCEDURE Skud;

BEGIN
  Bang;
  Delay(500);
  Bang;
  Bang;
END;

PROCEDURE Bip2;

BEGIN
  Sound(2000);
  Delay(7);
  NoSound;
END;

PROCEDURE Spil;

VAR
  B     : Byte;

PROCEDURE Diuv(AnDiuv : Byte);

VAR A    : Word;
    C    : Byte;

BEGIN
  FOR C := 1 TO AnDiuv DO
    FOR A := 3000 DOWNTO 500 DO
      Sound(A);
  NoSound;
END;

BEGIN
  Bip2;
  Delay(5);
  Diuv(3);
  Bip;
  Argh;
  Krash;
  Diuv(2);
  Ratata(2);
  Bip;
  Bip2;
  Bang;
  Diuv(4);
  Ratata(3);
  Argh;
  Biiip;
END;

END.
