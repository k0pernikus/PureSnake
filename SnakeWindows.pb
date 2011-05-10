Declare sn_SetzeApfel()

InitSprite() And InitKeyboard()

;{ Definiere alle Konstanten und globale Variablen/Listen/Arrays

Enumeration
  ;Reihenfolge und Nummer beibehalten, zum Laden der Sprites!
  
  #Feld  = 0						
  #Apfel						
  
  #Schlangen_Kopf_Oben				
  #Schlangen_Kopf_Unten
  #Schlangen_Kopf_Links
  #Schlangen_Kopf_Rechts
  
  #Schlangen_Koerper_Gerade_Horizontal
  #Schlangen_Koerper_Gerade_Vertikal
  
  #Schlangen_Koerper_Beuge_Oben_Links
  #Schlangen_Koerper_Beuge_Oben_Rechts
  #Schlangen_Koerper_Beuge_Unten_Links
  #Schlangen_Koerper_Beuge_Unten_Rechts
  
  #Schlangen_Schwanz_Oben
  #Schlangen_Schwanz_Unten
  #Schlangen_Schwanz_Rechts
  #Schlangen_Schwanz_Links
  
  #Hindernis
  
  #Schlange ; kein Sprite
  #Hintergrund
  
  ;Reihenfolge uninteressant
  
  ;bewegungen des schlangenkopfes
    #rechts
    #links
    #oben
    #unten
  
  #Sprite_Seitenlaenge = 30 ; 30 Pixel
EndEnumeration

Global NochEineChance.b=6 ; So viele Schleifendurchläufe werden noch erlaubt, wenn eine eigentlich tödliche Kollision statt findet
Global tod.b=#False  

ExamineDesktops()
  Global width=DesktopWidth(0)
  Global height=DesktopHeight(0)
  Global depth=DesktopDepth(0)
  Global title$ = "Ein weiterer Snake-Klon"

Global xMax, yMax, maxSpielfeld ; Diese Variablen bestimmen die Feldhöhe und -breite,
  xMax = (width/#Sprite_Seitenlaenge)-1      ; Je nach Bildschirmauflösung unterschiedlich große Felder
  yMax = (height/#Sprite_Seitenlaenge)-1     ; -1 um Ränder nicht zu überdecken
  
  maxSpielfeld = (yMax-1) * (xMax-1)  ; die äußere Felder sind Wände

Structure Eigenschaften ; der einzelnen Schlangenglieder
  art.c ; welches körperteil -- kopf, körper, schwanz und ausrichtung 
   
  x.c   ; Koordinaten der einzelnen Glieder
  y.c
EndStructure
  
Global NewList SchlangenGlied.Eigenschaften()

Global Dim Spielfeld(xMax,yMax)
  
For x=0 To xMax
  For y=0 To yMax
    If x=0 Or y=0 Or x=xMax Or y=yMax
      Spielfeld(x,y)=#Hindernis
    Else
      Spielfeld(x,y)=#Feld
    EndIf
  Next
Next


; zusätzliche hindernisse um schwierigkeitsgrad zu erhöhen
; man müsste aber lösbarkeit garantieren
; For x=0 To maxSpielfeld/20;Random(maxSpielfeld/2)
;   Spielfeld(Random(xMax-2)+1,Random((yMax-2)+1))=#Hindernis
; Next
  


  
Global ApfelX, ApfelY

;}

Procedure sn_LoadSprites()
    ;Erstelle Sprites aus den geordneten BMP-Bild-Dateien
    ;Die Nummern sind wichtig, werden dann über die Konstanten angesprochen
    For i=0 To 16
        LoadSprite(i,"data/"+Str(i)+".bmp")
        TransparentSpriteColor(i,RGB(255,0,255))
    Next  
EndProcedure

Procedure sn_Bewegung(x,y,richtung,alteBewegung)
  FirstElement(SchlangenGlied())
    NeuerKopfX = SchlangenGlied()\x+x
    NeuerKopfY = SchlangenGlied()\y+y
  
  If Spielfeld(NeuerKopfX,NeuerKopfY)<>#Apfel And Spielfeld(NeuerKopfX,NeuerKopfY)<>#Feld
      tod=#True
  Else
   If richtung=alteBewegung
    ;dann kann es nur horizontal oder vertikal weitergehen
      If richtung=#links Or richtung=#rechts
        SchlangenGlied()\art = #Schlangen_Koerper_Gerade_Horizontal
      Else
        SchlangenGlied()\art = #Schlangen_Koerper_Gerade_Vertikal
      EndIf
   Else   
   ;dann kommt es zur beugung -- wobei es jeweils zwei möglichkeiten gibt
   ;     1. / | 4.  \        1. quadrant #Schlangen_Koerper_Beuge_Oben_Links 
   ;     ------------        2. quadrant #Schlangen_Koerper_Beuge_Unten_Links
   ;     2 .\ | 3.  /        3. quadrant #Schlangen_Koerper_Beuge_Unten_Rechts
   ;                         4. quadrant #Schlangen_Koerper_Beuge_Oben_Rechts
   
    If (alteBewegung=#oben And richtung=#rechts) Or (alteBewegung=#links And richtung=#unten)
        SchlangenGlied()\art = #Schlangen_Koerper_Beuge_Oben_Links
      ElseIf (alteBewegung=#unten And richtung=#rechts) Or (alteBewegung=#links And richtung=#oben)
        SchlangenGlied()\art = #Schlangen_Koerper_Beuge_Unten_Links
      ElseIf (alteBewegung=#rechts And richtung=#oben) Or (alteBewegung=#unten And richtung=#links)
        SchlangenGlied()\art = #Schlangen_Koerper_Beuge_Unten_Rechts
      ElseIf (alteBewegung=#rechts And richtung=#unten) Or (alteBewegung=#oben And richtung=#links)
        SchlangenGlied()\art = #Schlangen_Koerper_Beuge_Oben_Rechts
    EndIf
            
   EndIf     
    
   Select richtung
      Case #oben
        NeuerKopfTyp = #Schlangen_Kopf_Oben
      Case #unten
        NeuerKopfTyp = #Schlangen_Kopf_Unten
      Case #rechts
        NeuerKopfTyp = #Schlangen_Kopf_Rechts
      Case #links
        NeuerKopfTyp = #Schlangen_Kopf_Links
    EndSelect
    
  InsertElement(SchlangenGlied())
    SchlangenGlied()\art = NeuerKopfTyp
    SchlangenGlied()\x   = NeuerKopfX
    SchlangenGlied()\y   = NeuerKopfY
    Spielfeld(NeuerKopfX,NeuerKopfY)=#Schlange  ; "Registrierung" im Spielffeld
    
  If NeuerKopfX = ApfelX And NeuerKopfY=ApfelY
    ;Apfel wurde gegessen -- berechne Position des neuen
    sn_SetzeApfel()
  Else
    ;Apfel wurde nicht gegessen, nutze den Schwanz als "Radierer" 
  
    LastElement(SchlangenGlied())
      schwanzX = SchlangenGlied()\x
      schwanzY = SchlangenGlied()\y
      Spielfeld(schwanzX,schwanzY)=#Feld    
      DeleteElement(SchlangenGlied())  
    
    LastElement(SchlangenGlied()) ; nicht notwendig
    
    ;-TODO Wenn Schlange 2 Elemente hat wird die Schwanz-Ausrichtung falsch berechnet
    ;      wenn der Spieler sich der Spieler zuerst entweder nach OBEN oder UNTEN bewegt
    ; Workaround: Setze Anfangsrichtung auf #links
    
    If tod=#False
      ;sonst richtet er auch das "kollidierte" Element aus
      If schwanzX > SchlangenGlied()\x
        Select SchlangenGlied()\art
          Case #Schlangen_Koerper_Beuge_Unten_Links
            SchlangenGlied()\art = #Schlangen_Schwanz_Unten  
          Case #Schlangen_Koerper_Beuge_Oben_Links
            SchlangenGlied()\art= #Schlangen_Schwanz_Oben    
          Default
            SchlangenGlied()\art = #Schlangen_Schwanz_Rechts
        EndSelect
       ElseIf  schwanzX < SchlangenGlied()\x
        Select SchlangenGlied()\art
          Case #Schlangen_Koerper_Beuge_Unten_Rechts
            SchlangenGlied()\art = #Schlangen_Schwanz_Unten  
          Case #Schlangen_Koerper_Beuge_Oben_Rechts
            SchlangenGlied()\art= #Schlangen_Schwanz_Oben
          Default
            SchlangenGlied()\art = #Schlangen_Schwanz_Links
        EndSelect
      ElseIf  schwanzY > SchlangenGlied()\y
         Select SchlangenGlied()\art
          Case #Schlangen_Koerper_Beuge_Oben_Rechts
            SchlangenGlied()\art = #Schlangen_Schwanz_Rechts
          Case #Schlangen_Koerper_Beuge_Oben_Links
            SchlangenGlied()\art = #Schlangen_Schwanz_Links
          Default
              SchlangenGlied()\art = #Schlangen_Schwanz_Unten
         EndSelect
      ElseIf  schwanzY < SchlangenGlied()\y
        Select SchlangenGlied()\art
          Case #Schlangen_Koerper_Beuge_Unten_Rechts
            SchlangenGlied()\art = #Schlangen_Schwanz_Rechts
          Case #Schlangen_Koerper_Beuge_Unten_Links
            SchlangenGlied()\art = #Schlangen_Schwanz_Links
          Default
            SchlangenGlied()\art = #Schlangen_Schwanz_Oben      
        EndSelect
      EndIf
    EndIf
    NochEineChance=6
  EndIf
EndIf
EndProcedure

Procedure sn_MaleHintergrund()
  CreateSprite(#Hintergrund,width,height)
  UseBuffer(#Hintergrund); die Zeichenoperationen werden auf dem Sprite ausgeführt
  For x=0 To xMax
    For y=0 To yMax
      DisplaySprite(Spielfeld(x,y),x*#Sprite_Seitenlaenge,y*#Sprite_Seitenlaenge)
    Next
  Next
  UseBuffer(#PB_Default); Rücksetzung, sodass zukünftige Zeichenoperationen auf dem Bildschirm ausgegeben werden
EndProcedure

;- Ende der Prozeduredefinioten

If OpenScreen(width,height,depth,title$)
    sn_LoadSprites() ; Der Befehl braucht ein geöffnetes Fenster!
    sn_MaleHintergrund()
  Else
    MessageRequester("Error","Konnte kein Fenster öffnen",#PB_MessageRequester_Ok)
    End
EndIf

Procedure sn_ErzeugeSchlange()

AddElement(SchlangenGlied())
  SchlangenGlied()\art  = #Schlangen_Kopf_Links
  SchlangenGlied()\x    = xMax/2
  SchlangenGlied()\y    = yMax/2
AddElement(SchlangenGlied())
  SchlangenGlied()\art  = #Schlangen_Schwanz_Rechts
  SchlangenGlied()\x    = xMax/2+1
  SchlangenGlied()\y    = yMax/2
  
ForEach SchlangenGlied()
  Spielfeld(SchlangenGlied()\x,SchlangenGlied()\y) = #Schlange
Next

EndProcedure

Procedure sn_SetzeApfel()
    If ListSize(SchlangenGlied()) < maxSpielfeld ; überhaupt noch ein Feld frei? sonst fiese Endlosschleife
      Repeat  
        ApfelX=Random(xMax-2)+1
        ApfelY=Random(yMax-2)+1
      Until Spielfeld(ApfelX,ApfelY)=#Feld
      Spielfeld(ApfelX,ApfelY)=#Apfel
    Else
      ;Beendung des Programmes aus einer Prozedur heraus deren Namen das nicht hergibt -.-
      Delay(150)
      CloseScreen()
      MessageRequester("Erfolg!","Du hast die bestmögliche Punktzahl erreicht.")
      End
    EndIf    
EndProcedure


sn_ErzeugeSchlange()
sn_SetzeApfel()


;workaround des Ausrichtungsbug
bewegung = #links


;-Hauptschleife
Repeat
  ;-Anzeige
  DisplaySprite(#Hintergrund,0,0)
  
  
  
  ;-Windows zeigt Hintergrund nicht richtig an
  ;-Workaround
;   For x=0 To xMax
;     For y=0 To yMax
;       If Spielfeld(x,y)=#Hindernis
;         DisplaySprite(Spielfeld(x,y),x*#Sprite_Seitenlaenge,y*#Sprite_Seitenlaenge)
;       Else 
;         DisplaySprite(#Feld,x*#Sprite_Seitenlaenge,y*#Sprite_Seitenlaenge)
;       EndIf 
;     Next
;   Next
  ;-Workaround Ende
 
  
  
  
  ForEach SchlangenGlied()
    DisplayTransparentSprite(SchlangenGlied()\art,SchlangenGlied()\x*#Sprite_Seitenlaenge,SchlangenGlied()\y*#Sprite_Seitenlaenge)
  Next
  DisplayTransparentSprite(#Apfel,ApfelX*#Sprite_Seitenlaenge,ApfelY*#Sprite_Seitenlaenge)
  FlipBuffers()
  
  ;-Tastaturabfrage
  alteBewegung=bewegung
  ExamineKeyboard()  
  If KeyboardPushed(#PB_Key_A) Or KeyboardPushed(#PB_Key_Left)
    If bewegung<>#rechts:
      bewegung = #links
    EndIf
  ElseIf KeyboardPushed(#PB_Key_D) Or KeyboardPushed(#PB_Key_Right)
    If bewegung<>#links
      bewegung = #rechts
    EndIf
  ElseIf KeyboardReleased(#PB_Key_W) Or KeyboardPushed(#PB_Key_Up)
    If bewegung<>#unten
      bewegung = #oben
    EndIf
  ElseIf KeyboardPushed(#PB_Key_S) Or KeyboardPushed(#PB_Key_Down) 
    If bewegung<>#oben
      bewegung = #unten
    EndIf
  EndIf
  
  ;-Eigentlicher Bewegunsablauf
    
  Select bewegung
     Case #rechts
       sn_Bewegung(1,0,#rechts,alteBewegung)
     Case #links       
       sn_Bewegung(-1,0,#links,alteBewegung)
     Case #oben
       sn_Bewegung(0,-1,#oben,alteBewegung)
     Case #unten
       sn_Bewegung(0,1,#unten,alteBewegung)
   EndSelect  
 
  ;-Lebt die Schlange noch?
  If tod=#True
    If NochEineChance > 0
      tod=#False  
    EndIf
    NochEineChance-1
  EndIf
  Delay(75)  
Until KeyboardPushed(#PB_Key_Escape) Or tod = #True
CloseScreen()

;Punkteausgabe
Punkte = ListSize(SchlangenGlied())-2 ; Die Schlange hatte 2 Anfangsglieder -- jeder Apfel = 1 Punkt
  MessageRequester("Das Spiel ist zu Ende","Du hast "+Str(Punkte)+" Punkte von "+Str(maxSpielfeld)+" erreicht.",#PB_MessageRequester_Ok)
End
; IDE Options = PureBasic 4.40 (Linux - x64)
; CursorPosition = 301
; FirstLine = 283
; Folding = -----
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = snake_32.exe
; EnableCompileCount = 278
; EnableBuildCount = 4
; EnableExeConstant