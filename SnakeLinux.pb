Declare sn_positionApple()

InitSprite() And InitKeyboard()

Enumeration
  ;START SPRITE IDs
  #grass = 0						
  #apple						
  
  #snakeHeadUp
  #snakeHeadDown
  #snakeHeadLeft
  #snakeHeadRight
  
  #snakeBodyHorizontal
  #snakeBodyVertical
  
  #snakeBody_Beuge_up_left
  #snakeBody_Beuge_up_right
  #snakeBody_Beuge_down_left
  #snakeBody_Beuge_down_right
  
  #snakeTail_up
  #snakeTail_down
  #snakeTailRight
  #snakeTail_left
  
  #wall
  ;END SPRITE IDs
  
  #snake ; kein Sprite
  #background
  
  ;Reihenfolge uninteressant
  
  ;directionen des schlangenkopfes
    #right
    #left
    #up
    #down
  
  #spriteLengthInPixel = 30
EndEnumeration

Global hasAnotherChance.b = 6 ; So viele Schleifendurchläufe werden noch erlaubt, wenn eine eigentlich tödliche Kollision statt findet
Global isDead.b = #False  

ExamineDesktops()
  Global width = DesktopWidth(0)
  Global height = DesktopHeight(0)
  Global depth = DesktopDepth(0)
  Global title$ = "Yet another snake clone"

Global xMax, yMax, maxSpielfeld
  xMax = (width/#spriteLengthInPixel) - 1
  yMax = (height/#spriteLengthInPixel) - 1
  
  maxSpielfeld = (yMax-1)  *  (xMax-1)
  
Structure Eigenschaften ; der einzelnen SnakeElementer
  art.c ; welches körperteil -- kopf, körper, schwanz und ausmovement 
   
  x.c   ; Koordinaten der einzelnen Glieder
  y.c
EndStructure
  
Global NewList SnakeElement.Eigenschaften()

Global Dim Spielfeld(xMax,yMax)
  
For x = 0 To xMax
  For y = 0 To yMax
    If x = 0 Or y = 0 Or x = xMax Or y = yMax
      Spielfeld(x,y) = #wall
    Else
      Spielfeld(x,y) = #grass
    EndIf
  Next
Next


; zusätzliche hindernisse um schwierigkeitsgrad zu erhöhen
; man müsste aber lösbarkeit garantieren
; For x = 0 To maxSpielfeld/20;Random(maxSpielfeld/2)
;   Spielfeld(Random(xMax-2)+1,Random((yMax-2)+1)) = #wall
; Next
  


  
Global ApfelX, ApfelY

;}

Procedure sn_LoadSprites()
    For i = 0 To 16
        LoadSprite(i,"data/" + Str(i) + ".bmp")
        TransparentSpriteColor(i, RGB(255,0,255))
    Next  
EndProcedure

Procedure sn_direction(x,y,movement,oldDirection)
  FirstElement(SnakeElement())
    newHeadxPos = SnakeElement()\x+x
    newHeadyPos = SnakeElement()\y+y
  
  If Spielfeld(newHeadxPos,newHeadyPos)<>#apple And Spielfeld(newHeadxPos,newHeadyPos)<>#grass
      isDead = #True
  Else
   If movement = oldDirection
    ;dann kann es nur horizontal oder vertikal weitergehen
      If movement = #left Or movement = #right
        SnakeElement()\art = #snakeBodyHorizontal
      Else
        SnakeElement()\art = #snakeBodyVertical
      EndIf
   Else   
   ;dann kommt es zur beugung -- wobei es jeweils zwei möglichkeiten gibt
   ;     1. / | 4.  \        1. quadrant #snakeBody_Beuge_up_left 
   ;     ------------        2. quadrant #snakeBody_Beuge_down_left
   ;     2 .\ | 3.  /        3. quadrant #snakeBody_Beuge_down_right
   ;                         4. quadrant #snakeBody_Beuge_up_right
   
    If (oldDirection = #up And movement = #right) Or (oldDirection = #left And movement = #down)
        SnakeElement()\art = #snakeBody_Beuge_up_left
      ElseIf (oldDirection = #down And movement = #right) Or (oldDirection = #left And movement = #up)
        SnakeElement()\art = #snakeBody_Beuge_down_left
      ElseIf (oldDirection = #right And movement = #up) Or (oldDirection = #down And movement = #left)
        SnakeElement()\art = #snakeBody_Beuge_down_right
      ElseIf (oldDirection = #right And movement = #down) Or (oldDirection = #up And movement = #left)
        SnakeElement()\art = #snakeBody_Beuge_up_right
    EndIf            
   EndIf     
    
   Select movement
      Case #up
        newHeadType = #snakeHeadUp
      Case #down
        newHeadType = #snakeHeadDown
      Case #right
        newHeadType = #snakeHeadRight
      Case #left
        newHeadType = #snakeHeadLeft
    EndSelect
    
  InsertElement(SnakeElement())
    SnakeElement()\art = newHeadType
    SnakeElement()\x = newHeadxPos
    SnakeElement()\y = newHeadyPos
    Spielfeld(newHeadxPos,newHeadyPos) = #snake  ; "Registrierung" im Spielffeld
    
  If newHeadxPos = ApfelX And newHeadyPos = ApfelY
    ;Apfel wurde gegessen -- berechne Position des neuen
    sn_positionApple()
  Else
    ;Apfel wurde nicht gegessen, nutze den Schwanz als "Radierer" 
  
    LastElement(SnakeElement())
      schwanzX = SnakeElement()\x
      schwanzY = SnakeElement()\y
      Spielfeld(schwanzX,schwanzY) = #grass    
      DeleteElement(SnakeElement())  
    
    LastElement(SnakeElement()) ; nicht notwendig
    
    ;-isDeadO Wenn Schlange 2 Elemente hat wird die Schwanz-Ausmovement falsch berechnet
    ;      wenn der Spieler sich der Spieler zuerst entweder nach up oder down bewegt
    ; Workaround: Setze Anfangsmovement auf #left
    
    If isDead = #False
      ;sonst richtet er auch das "kollidierte" Element aus
      If schwanzX > SnakeElement()\x
        Select SnakeElement()\art
          Case #snakeBody_Beuge_down_left
            SnakeElement()\art = #snakeTail_down  
          Case #snakeBody_Beuge_up_left
            SnakeElement()\art = #snakeTail_up    
          Default
            SnakeElement()\art = #snakeTailRight
        EndSelect
       ElseIf  schwanzX < SnakeElement()\x
        Select SnakeElement()\art
          Case #snakeBody_Beuge_down_right
            SnakeElement()\art = #snakeTail_down  
          Case #snakeBody_Beuge_up_right
            SnakeElement()\art = #snakeTail_up
          Default
            SnakeElement()\art = #snakeTail_left
        EndSelect
      ElseIf  schwanzY > SnakeElement()\y
         Select SnakeElement()\art
          Case #snakeBody_Beuge_up_right
            SnakeElement()\art = #snakeTailRight
          Case #snakeBody_Beuge_up_left
            SnakeElement()\art = #snakeTail_left
          Default
              SnakeElement()\art = #snakeTail_down
         EndSelect
      ElseIf  schwanzY < SnakeElement()\y
        Select SnakeElement()\art
          Case #snakeBody_Beuge_down_right
            SnakeElement()\art = #snakeTailRight
          Case #snakeBody_Beuge_down_left
            SnakeElement()\art = #snakeTail_left
          Default
            SnakeElement()\art = #snakeTail_up      
        EndSelect
      EndIf
    EndIf
    
    hasAnotherChance = 6
  EndIf
EndIf
EndProcedure

Procedure sn_createBackgroundSprite()
  CreateSprite(#background, width, height)
  UseBuffer(#background)
  For x = 0 To xMax
    For y = 0 To yMax
      DisplaySprite(Spielfeld(x, y), x  *  #spriteLengthInPixel, y  *  #spriteLengthInPixel)
    Next
  Next
  
  UseBuffer(#PB_Default)
EndProcedure

;- Ende der Prozeduredefinioten

If OpenScreen(width, height, depth, title$)
    sn_LoadSprites() 
    sn_createBackgroundSprite()
  Else
    MessageRequester("Error", "Konnte kein Fenster öffnen", #PB_MessageRequester_Ok)
    End
EndIf

Procedure sn_createSnake()

AddElement(SnakeElement())
  SnakeElement()\art = #snakeHeadLeft
  SnakeElement()\x = xMax/2
  SnakeElement()\y = yMax/2
AddElement(SnakeElement())
  SnakeElement()\art = #snakeTailRight
  SnakeElement()\x = xMax/2+1
  SnakeElement()\y = yMax/2
  
ForEach SnakeElement()
  Spielfeld(SnakeElement()\x,SnakeElement()\y) = #snake
Next

EndProcedure

Procedure sn_positionApple()
    If ListSize(SnakeElement()) < maxSpielfeld ; überhaupt noch ein Feld frei? sonst fiese Endlosschleife
      Repeat  
        ApfelX = Random(xMax-2)+1
        ApfelY = Random(yMax-2)+1
      Until Spielfeld(ApfelX,ApfelY) = #grass
      Spielfeld(ApfelX,ApfelY) = #apple
    Else
      ;Beendung des Programmes aus einer Prozedur heraus deren Namen das nicht hergibt -.-
      Delay(150)
      CloseScreen()
      MessageRequester("Erfolg!","Du hast die bestmögliche Punktzahl erreicht.")
      End
    EndIf    
EndProcedure


sn_createSnake()
sn_positionApple()


;workaround des Ausmovementsbug
direction = #left


;-Hauptschleife
Repeat
  
  DisplaySprite(#background,0,0)
  ForEach SnakeElement()
    DisplayTransparentSprite(SnakeElement()\art,SnakeElement()\x * #spriteLengthInPixel,SnakeElement()\y * #spriteLengthInPixel)
  Next
  DisplayTransparentSprite(#apple,ApfelX * #spriteLengthInPixel,ApfelY * #spriteLengthInPixel)
  FlipBuffers()
  
  oldDirection = direction
  
  ExamineKeyboard()  
  If KeyboardPushed(#PB_Key_A) Or KeyboardPushed(#PB_Key_Left)
    If direction <>#right:
      direction = #left
    EndIf
  ElseIf KeyboardPushed(#PB_Key_D) Or KeyboardPushed(#PB_Key_Right)
    If direction <> #left
      direction = #right
    EndIf
  ElseIf KeyboardReleased(#PB_Key_W) Or KeyboardPushed(#PB_Key_Down)
    If direction <> #down
      direction = #up
    EndIf
  ElseIf KeyboardPushed(#PB_Key_S) Or KeyboardPushed(#PB_Key_Up) 
    If direction <> #up
      direction = #down
    EndIf
  EndIf
  
  Select direction
     Case #right
       sn_direction(1, 0, #right, oldDirection)
     Case #left       
       sn_direction(-1, 0, #left, oldDirection)
     Case #up
       sn_direction(0, -1, #up, oldDirection)
     Case #down
       sn_direction(0, 1, #down, oldDirection)
   EndSelect  
 
  If isDead = #True
    If hasAnotherChance > 0
      isDead = #False  
    EndIf
    hasAnotherChance-1
  EndIf
  Delay(75)  
Until KeyboardPushed(#PB_Key_Escape) Or isDead = #True
CloseScreen()

Punkte = ListSize(SnakeElement())-2; Die Schlange hatte 2 Anfangsglieder -- jeder Apfel = 1 Punkt
  MessageRequester("Das Spiel ist zu Ende","Du hast "+Str(Punkte)+" Punkte von "+Str(maxSpielfeld)+" erreicht.",#PB_MessageRequester_Ok)
End
; IDE Options = PureBasic 4.51 (Linux - x86)
; CursorPosition = 323
; FirstLine = 306
; Folding = -
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError
; Executable = snake_32.exe
; EnableCompileCount = 281
; EnableBuildCount = 3
; EnableExeConstant