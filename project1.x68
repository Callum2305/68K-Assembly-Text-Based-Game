*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Title      :  PROJECT1 IRONBOUND
* Written by :  Callum Matthews C00306572
* Date       :  Started on the 19th of February. 
* Description:  An alternative physics game where gravity works against you. Collect scrap metal to weigh yourself down, and fight off enemies competing for the same resources.
*
* Issues encountered: When loading health or mass into D1, it would show a number like 65000. This is because MOVE.B only overwrites lower 8 bits of D1.
* Resolution:   To resolve, I used CLR.W D1 to set the lower 16 bits of D1 to 0, basically removing any garbage from earlier that was there, ensuring I can print or store only the value i need.
*               I did not use AI to resolve this issue. It was a very simple fix, i just forgot to clear the registers when i started writing this program.
*
* IMPORTANT NOTE: As can be seen under my variables, i store enemy health as an array, and each day we take a value from that array to give to the enemy we encounter. The enemy health depends on what day you are on.
*                 As each day you can choose whether to stay home or venture out, you may not encounter an enemy depending on this choice.
*                 Therefore, i need to chose enemy health from this array based off what day you are on. I could not figure this out myself, and ran into errors when assembling, and this was my major hurdle.
*                 I also needed help resolving a random number. My plan was to use time trap 8 to get time since midnight, which is different every time game is ran, but it returned a very long number.
*                 I needed to trim it down so its easier to allocate chance, so by making it a number 0 - 99, 100 numbers, i could set different ranges as different chances. 0 - 9 is 10%, 10 - 19 is 10% and so on.
*
* Resoltion:      To resolve this array issue, and the time issue, i had to use AI to get help. The four subroutines that needed AI help are as follows:
*
*                 GET_ENEMY_HP
*                 HP_LOOP
*                 HP_FOUND
*                 RANDOM_0_99 ------> i planned on using the time trap 8 regardless, just needed to figure out how to go about trimming number as time will give me a different number each time game is ran, appearing random
*
*                 I do now understand how these subroutines work. I have comments beside them explaining as such. However, it took AI help to explain how to go about navigating the array based off day, as i wanted to do.
*                 I felt it nesisary to highlight that these subroutines were AI assisted.
*                 For these four subroutines mentioned above, the AI used was ChatGpt. 
*                 I did not use it beyond the aforementioned subroutines above.
*
* Known bugs:   As of now, I have no confirmed known bugs. My main issue was not clearing registers and the issue with my choice to base enemy health off an array These are now both resolved.
*               I also had gameplay loop issues with random events messages printing, but now resolved.
*               However, random event selection works from time, with the trap task 8. So theoretically, event chance can be based off the time at which you run the code? I havent had issues with this, but i beleive that it could provide an issue?
*
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    MOVE.B  #1,DAY              ; initialise day counter to 1, because without it, when i restart program without closing it, day stays at 5
    MOVE.B #30, PLAYER_MASS     ; initialise mass to 30 before day 1. Therefor if you do not leave safe house any day you get a bad ending
    MOVE.B #60, PLAYER_HEALTH   ; initialise health to 60 before day 1
    
    
    BSR     WELCOME     ; branch to welcome to start game

    BSR     GAME_LOOP   ; branch to GAME_LOOP subroutine


    


*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*
*WELCOME. Starts game by printing title card and lore message.
*Pause for key press to continue
*
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WELCOME:
    BSR CLEAR_SCREEN    ; Branch to clear screen
    
    LEA MSG_TITLECARD, A1   ; load effective address of title card to a1
    BSR PRINT_STR           ; branch to print string, as now a1 contains the address of the string i want to print
    
    LEA MSG_GAME_START, A1  ; load effective address of game start message to a1
    BSR PRINT_STR           ; branch to print string, as now new message address in a1
    
    LEA MSG_OBJECTIVE, A1   ; load effective address of objective message to a1
    BSR PRINT_STR           ; branch to print string, as again i have a new message to print from address a1
    
    BSR CONTINUE            ; Branch to subroutine, in this case CONTINUE
    RTS                     ; Return to subroutine

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; PRINT_STR used to print any message
; uses TRAP #15 to print message
;  Allows me to not have to type this everytime, so i am calling a function for it to reduce lines of code
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRINT_STR:
    MOVE.B #14, D0  ; place literal 14 in register D0. a1 should already contain address of string to print at this point of calling this function   
    TRAP #15        ; kernal call will make the assembler print what i want. TRAP AND INTERPERATE VALUE IN D0: comment from starter kit
    RTS             ; return to subroutine
   
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; CONTINUE: press any key prompt and wait for my input
;   using 4 as it is instruction to read user input stored in D1. Load 4 into D0 and trap to execute
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CONTINUE:
    LEA MSG_CONTINUE, A1    ; load effective address of contnue message to a1
    BSR PRINT_STR           ; branch to print it
    
    MOVE.B #4, D0   ; read input from user, as continue message prompts for it
    TRAP #15        ; kernal call, trap 15 function 4
    RTS             ; return
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; CLEAR_SCREEN: clears the screen of any text there, subroutine to save writing every time as used often
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CLEAR_SCREEN:
    MOVE.B #11, D0      ; function 11 will clear the terminal screen
    MOVE.W #$FF00, D1   ; resets screen with a colour, but here im doing default FF is high 00 is low. From starter kit
    TRAP #15            ; interperate value in d0, which is 11 and execute
    RTS                 ; return to subroutine


; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Some AI assistance in this subroutine, outlined in above header comment.
; 
; RANDOM_0_99 random number generator, returns current time since midnight, but then trims it down to a number 0 - 99
; returns a number in range 0 - 99 into D0, so 100 possible numbers, making it easier to set percentages. 0 - 9 is a 10 % chance as it is first 10 possible numbers etc.
;
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RANDOM_0_99:
    MOVE.B  #8,D0      ; trap task 8 = time since midnight
    TRAP    #15        ; trap reads task in D0, which will put time since midnight into D1, so D1.L = time value
    MOVE.L  D1,D0      ; copy time into D0 so we can trip it down. currently it is a long number

    ; ai assisted part, DIVU, SWAP AND ANDI
    DIVU    #100,D0    ; divide by 100, DIVU provides a remainder and a quotuient, so upper word is remainder, lower is quotient. I want the remainder
    SWAP    D0         ; swap the remainder and quotient around, so remainder is in the lower word
    ANDI.W  #$00FF,D0  ; bitwise and immediate to mask value, keeping only lower 8 bits and clears rest of lower word, so can only be left with number in range 0 - 99
    
    RTS                ; return to subroutine, with a value 0 - 99 stored in D0

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; BEGIN GAMEPLAY LOOP
; subroutines used in day to day game loop below:
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GAME_LOOP:
DAY_LOOP:
    BSR     START_DAY        ; show status + day text + ask 1/2 and do rest/combat inside
    
  
    ; The following are my end of day checks 
    ; float-away ending if mass < 40
    MOVE.B  PLAYER_MASS,D0      ; move player mass into D0
    CMP.B   #40,D0              ; compare contents of player mass to 40
    BLT     END_BAD_FLOAT       ; branch if less than to bad ending "float away"

    ; if day = 5, must resolve ending type, either good or neutral
    MOVE.B  DAY,D0              ; move day count into D0
    CMP.B   #5,D0               ; compare day count to 5
    BEQ     END_RESOLVE         ; if day = 5, branch to ending resolve to pick between good or neutral ending

    ; in java: day++, i am increasing the day counter
    ADD.B   #1,DAY          ; add 1 to the day counter
    BSR     CONTINUE        ; branch subroutine CONTINUE
    BRA     DAY_LOOP        ; branch DAY_LOOP

END_BAD_FLOAT:
    LEA     MSG_BADENDING,A1    ;Load float away ending/ bad ending
    BSR     PRINT_STR           ; branch to print str routine to output the ending message
    BRA     GAME_END            ; return from print_str and then immediatly branch to GAME_END, which is SIMHAULT

END_RESOLVE:
    ; mass >= 40 already, now check good or neutral
    MOVE.B  PLAYER_MASS,D0  ; move player mass to D0 to check
    CMP.B   #75,D0          ; with compare, check if mass greater than 75, then
    BGE     END_GOOD        ; branch to good ending

    LEA     MSG_NEUTRALEND,A1   ; else, if less than 75, load neutral ending message and then
    BSR     PRINT_STR           ; use PRINT_STR subroutine to print it to screen
    BRA     GAME_END            ; Finally jump to game end for SIMHAULT

END_GOOD:
    LEA     MSG_GOODENDING,A1   ; if you jump here from resolve, load good ending message
    BSR     PRINT_STR           ; then print it
    BRA     GAME_END            ; again, once ending decided jump to end game which is SIMHAULT


; Start each day. Will branch to combat or rest based off player choice. Also keep track of day count.
START_DAY:
   
    BSR CLEAR_SCREEN        ; Clear the screen for a new message
    
       
    ;Print mass message, prints on new line the word MASS: 
    LEA MSG_MASS, A1        ; load mass message into A1
    BSR PRINT_STR           ; branch to print subroutine to display it
    
  
    
    ;Print current mass number directly beside message
    CLR.W D1                    ; clearing d1 because when i didnt do this i got some number like 65200. This resloved my issue with garbage numbers being displayed
    MOVE.B PLAYER_MASS, D1      ; move player mass into D1
    MOVE.B #3, D0               ; move 3 into D0, function 3 is to print number in D1, in this case print player mass
    TRAP #15                    ; trap kernal call to use function 3 in D0
    
    LEA CRLF, A1                ; load CRLF message
    BSR PRINT_STR               ; jump to PRINT so it can be put on screen to add a new line, or a gap, between other messages
    
    
    ;Print health message, prints new line saying VIGOR:
    LEA MSG_HEALTH, A1          ; load message into A1
    BSR PRINT_STR               ; use print subroutine to print it
    
    
    ;Print current health or vigor number directly beside message
    CLR.W D1                    ; clearing d1 because when i didnt do this i got some number like 65200 on screen
    MOVE.B PLAYER_HEALTH, D1    ; so move player health/vigor to D1
    MOVE.B #3, D0               ; Move 3 into D0. 3 is used to print a number stored in D1.
    TRAP #15                    ; Kernal call, checks D0 for for a function to do, in this case D0 has 3, which is print number in D1.
    
    LEA CRLF, A1    ; load effective address of CRLF into A1
    BSR PRINT_STR   ; use print subroutine to print message in A1, which is our Carriage return and line feed
    
    ; print day number, so "Day: X". X increases each day as day++
    LEA     MSG_DAY,A1      ; load address of Day message into A1
    BSR     PRINT_STR       ; use print function to display it
    CLR.W   D1              ; Again, clear D1
    MOVE.B  DAY,D1          ; Move the day count into D1
    MOVE.B  #3,D0           ; Again, 3 into D0 so we can print a number in D1, in this case its the Day
    TRAP    #15             ; kernal call to check instruction in D0
    LEA     CRLF,A1         ; load address of carrirage return and line feed into A1, for a new line
    BSR     PRINT_STR       ; print contents of A1, which is our new blank line to form a gap between messages
    

    ; random event chance each day except first
    CMP.B   #3, DAY         ; if day is greater than day 3, then do a chance of random event
    BGT     DO_RANDOM
    BRA     PRINT_DAY_MESSAGE



DO_RANDOM:
    BSR CHECK_RANDOM_EVENTS
    BRA PRINT_DAY_MESSAGE
 
PRINT_DAY_MESSAGE:
    LEA MSG_BEGIN_DAY,A1
    BSR PRINT_STR
    
; Check for player choice each day. Either 1 or 2 on keyboard input
DAY_CHOICE:
    MOVE.B  #4,D0          ; move 4 to D0. 4 is instruction to read keyboard input stored in D1, which should be either 1 or 2 depending on player choice
    TRAP    #15            ; D1 = input number, trap for kernal call to check instrunction in D0, which in this case is 4

    CMP.B   #1,D1          ; compare, check if value of D1 is 1.
    BEQ     DO_VENTURE     ; if it is 1, then player wants to go outside, so branch to venture subroutine

    CMP.B   #2,D1          ; compare again, this time if D1 value is 2, player wants to stay home and regen vigor
    BEQ     DO_REST        ; if 2, branch to rest subroutine

    LEA     MSG_INVALID_CHOICE,A1   ; if neither 1 or 2, load address of Invalid choice message to D1
    BSR     PRINT_STR               ; print message with PRINT subroutine
    BRA     DAY_CHOICE              ; branch back to Day Choice to read input again 

; If player selected 2, they want to stay home and rest, this function lets us clear screen and then jump to rest day to prep for its messages
DO_REST:
    BSR     CLEAR_SCREEN      ; clear screen before rest message
    BSR     REST_DAY          ; Branch to rest day subroutine
    RTS                       ; return to subroutine

; If player selected 1, they want to venture out and scavenge. This function again is used to clear screen to make way for combat messages and jump to combat
DO_VENTURE:
    BSR     CLEAR_SCREEN      ; clear screen before rest message
    BSR     COMBAT_DAY        ; branch to combat day subroutine
    RTS                       ; return to subroutine
    
;After screen is cleared, restore player vigor/health to 100
REST_DAY:
    MOVE.B  #100,PLAYER_HEALTH  ; move 100 into health, overwriting previous value
    LEA     MSG_RESTED,A1       ; load address of rested message in A1
    BSR     PRINT_STR           ; jump to print subroutine to print the rest message
    RTS                         ; return to subroutine
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; CHECK_RANDOM_EVENTS
; 20 % chance of mass loss per game. 30 % chance of lucky find per game. Once these events occur once, the flag is set, so we need to check the flag each time
; Using number in D0 from random number generated (0 to 99), we check if it is in range 0 - 19 to go to mass loss, or 20 - 49 for lucky event. 99 for instant game over 1 % chance. Using BHS to skip over and check next event
; as number is range 0 - 99, thats 100 numbers, so can pick a percentage chance based off what number it is
;
; 
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CHECK_RANDOM_EVENTS:
    BSR     RANDOM_0_99     ; D0 will now contain a number of 0 - 99, based off time
    
    ; 1% break-in
    CMP.B   #99,D0          ; compare 99 to D0, if they are the same, branch if equal to break in event, instant game over
    BEQ     EVENT_BREAK_IN

    ; 20% chance mass loss (D0 equals number range 0 to 19), only once as checks flag
    CMP.B   #20,D0              ; compare number in D0 with 20
    BHS     CHECK_LUCKY         ; BHS Branch if higher or same, to check for lucky event flag
    TST.B   FLAG_REDUCE_MASS    ; test if mass event flag is 0, meaning has it occured yet? This is the else case of the compare
    BNE     CHECK_LUCKY          ; if not equal, it means it has occured, then check if lucky event can occur
    BSR     EVENT_REDUCE_MASS   ; else if equal, branch to the reduce mass subroutine
    RTS

CHECK_LUCKY:
    ; 30% chance lucky find (range 20 to 49), can only occur once due to flag i set
    CMP.B   #50,D0                ; compare random number from D0 with 50
    BHS     NO_EVENT              ; BHS = Branch if higher or Same. so if 50 or above, it is out of event scope, and we move to no event for rts
    TST.B   FLAG_LUCKY_FIND       ; check if flag is = 0 if the number in D0 is less than 40
    BNE     NO_EVENT              ; if flag is equal to 1, then event already occured, brnach to no event for rts
    BSR     EVENT_LUCKY_FIND      ; if flag is 0, and if within event chance, branch to lucky find event subroutine
    RTS

NO_EVENT:
    RTS                         ; if no event due to flags being set, rts to game loop again
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; RANDOM DAILY EVENTS
; I need to be careful with these, so as not to allow mass or health to increase past 100, so i need to reset them if they do
; As discussed with philip, i will use a counter, or flag, that increases once an event occurs. These are initialised to 0. If the event occurs, increase flag by 1.
; Once the event flag for a specific event becomes 1, it can never happen again in that play through, preventing repeating events.
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
; mass loss random event   
EVENT_REDUCE_MASS:
    BSR CLEAR_SCREEN        ; branch to clear screen
    LEA MSG_MASS_LOSS, A1   ;Load event mass loss
    BSR PRINT_STR           ; print message
    
    ; reduce mass by 10
    MOVE.B PLAYER_MASS, D0  ; move current mass to D0
    SUB.B #10, D0           ; SUBTRACT 10 from current mass in D0
    MOVE.B D0, PLAYER_MASS  ; move newly updated mass back into variable
    
    MOVE.B #1, FLAG_REDUCE_MASS     ; set event flag to 1, as it has now occured
    
    
    RTS
  
; mass and health gain +10 each random event  
EVENT_LUCKY_FIND:
    BSR CLEAR_SCREEN        ; branch to clear screen
    LEA MSG_LUCKY_FIND, A1  ; load lucky find event message
    BSR PRINT_STR           ; print message
    
    ; add 10 to mass
    MOVE.B PLAYER_MASS, D0      ; move player mass to D0
    ADD.B   #10, D0             ; ADD 10 to D0, which currently holds mass
    MOVE.B  D0, PLAYER_MASS     ; move contents of D0, which is new mass, back into variable PLAYER_MASS to update it
    
    CMP.B #100, PLAYER_MASS     ; CHECK IF PLAYER MASS INCREASED BEYOND 100, if so its a problemo
    BGT MASS_OVER_LOAD          ; if mass > 100, branch to subroutine to reduce it back to 100, as we increased by 10
    
    ; add 10 to vigor/health
    MOVE.B PLAYER_HEALTH, D0    ; move player health to D0
    ADD.B #10, D0               ; increase by 10
    MOVE.B D0, PLAYER_HEALTH    ; move contents of D0, whcih now hold new health, back into health variable
    
    CMP.B #100, PLAYER_HEALTH   ; check if health is greater than 100, to prevent overflow
    BGT HEALTH_OVER_LOAD        ; if health > 100, branch to subroutine to reduce it back to 100, as we increased by 10
    

    MOVE.B #1, FLAG_LUCKY_FIND  ; set event flag to 1, as it has now occured
    
    RTS
    
;used only if mass exceeds 100 after event
MASS_OVER_LOAD:
    MOVE.B #100, PLAYER_MASS    ; replace overloaded mass (probably 110 mass if you are here), with 100 (intented maximum)
    RTS
    
    
;used only if health exceeds 100 after event
HEALTH_OVER_LOAD:
    MOVE.B #100, PLAYER_HEALTH    ; replace overloaded heath (probably 110 health if you are here), with 100 (intented maximum)
    RTS
    

  
; random event, killed in sleep at night
EVENT_BREAK_IN:
    BSR CLEAR_SCREEN            ; branch to clear screen
    LEA MSG_MURDER_EVENT, A1    ; Load effective message to murder message
    BSR PRINT_STR               ; Print message using subroutine
    
    BRA GAME_END               ; END GAME AS KILLED during night
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Beginning of AI assisted code:
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    
; Each day, enemy has different health, stored in ENEMY_HP_TABLE, basically an array
; array starts from 0, not 1, as indexing. need to subtract 1 to get position in array.
; we choose enemy health by day number, but array starts at 0, while day starts from 1. need to offset this
GET_ENEMY_HP:
    LEA     ENEMY_HP_TABLE,A0   ; load effective address of enemy health array into A0. A0 will point to 55, first num in array
    MOVEQ   #0,D0               ; clearing D0 to prevent garbage like issue with player health and mass like before
    MOVE.B  DAY,D0              ; move byte DAY counter into D0, which is now cleared. so load current day
    SUBQ.B  #1,D0               ; subtract 1 from D0 because array counts from 0 onwards, not 1. index positioning.

;loop though array using D0, which is 0-4 index of array
;when loop finishes, A0 points to correct enemy health stat for the day, and D0 is equal to 0
HP_LOOP:
    TST.B   D0                  ; test D0 to check if it is = 0, doesnt change D0, just checks and set zero flag
    BEQ     HP_FOUND            ; branch if equal to HP_FOUND as we are already at correct index flag. loop exit conditon
    ADDQ.L  #1,A0               ; increment A0 pointer by 1 byte. so incrementing moves pointer to next enemy health number in array
    SUBQ.B  #1,D0               ; subtract D0 by 1, which is index counter, so if D0 = 3 here, it then subtracts 1 and becomes D0=2. Counting down to zero
    BRA     HP_LOOP             ; unconditional branch back into loop, remeber if d0 is = 0, thats the exit condition
    
;loop finds correct hp stat for enemy each day, once found, we must store it somewhere to be used for combat comparisons
HP_FOUND:
    MOVEQ   #0,D2               ; move quick immediate value into D2, sets all bits of D2 to zero, clearing it off any waste or garbage bytes
    MOVE.B  (A0),D2             ; Move content of A0, which is current enemy health stat, into D2. so D2 = enemy hp
    RTS                         ; return to subroutine
    
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Ending of AI assisted code:
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
;If player chose to venture out, they will encounter an enemy. this is the combat sequence.
; to win, player must have higher vigor/health than the enemy. use compare to check.
COMBAT_DAY:
    LEA     MSG_COMBAT_INTRO,A1     ; load effective address of combat intro into A1
    BSR     PRINT_STR               ; branch to print subroutine to display message

    BSR     GET_ENEMY_HP            ; branch to get enemy hp subroutine above, to select enemy vigor/hp based on day coutner

    ; Show enemy HP
    LEA     MSG_ENEMY_HP,A1     ; load address of enemy hp message into a1
    BSR     PRINT_STR           ; use print subroutine to display it
    CLR.W   D1                  ; clear d1 to prevent garbage
    MOVE.B  D2,D1               ; move D2 to D1. D2 holds enemy hp from HP_lOOP and HP_Found function, must move to D1 to print
    MOVE.B  #3,D0               ; move 3 to D0 for trap, prints number stored in D1
    TRAP    #15                 ; kernal call to display enemy hp number which is now in D1
    LEA     CRLF,A1             ; load effecitve address of new line message to A1
    BSR     PRINT_STR           ; use print to print the new blank line

    ; Compare: if player health > enemy health, then you defeat them
    MOVE.B  PLAYER_HEALTH,D0    ; move player vigor/health to D0
    CMP.B   D2,D0               ; compare D2 with D0
    BGT     COMBAT_WIN          ; if d0/ player health is greater, branch if greater to combat win

    ; lose combat, you die and print death message.
    LEA     MSG_DEAD,A1         ; load death message game over
    BSR     PRINT_STR           ; print it with the subroutine
    BRA     GAME_END            ; unconditional branch to game over, as now player is dead
  
;if player wins combat, increase mass but decrease health
COMBAT_WIN:
    ; minus 10 helth when defeated enemy
    MOVE.B  PLAYER_HEALTH,D0    ;move player health to d0
    SUB.B   #10,D0              ; subtract 10 from player health as you tookn damage from enemy
    MOVE.B  D0,PLAYER_HEALTH    ; move new health in D0 after subtraction back into PLAYER_HEALTH variable, overwriting it to reflect change

    ; gain 10 mass when defeated enemy
    MOVE.B  PLAYER_MASS,D0      ; move player mass to D0
    ADD.B   #15,D0              ; add 15 to increase current mass
    MOVE.B  D0,PLAYER_MASS      ; move new mass stored in D0 back into PLAYER_MASS variable, overwriting previous player mass

    LEA     MSG_WIN_COMBAT,A1   ; load effective address of victory/survival message to A1
    BSR     PRINT_STR           ; branch to subroutine to print message to screen
    RTS                         ; return to subroutine and begin next day
    
    
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Game Over, I branch here after displaying appropriate endings to end program with SIMHAULT
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

GAME_END:
    SIMHALT                 ; end program





*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Variables and Constants
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


PLAYER_HEALTH: DC.B 1                   ; declare player vigor or health, this will be overwrited later
PLAYER_MASS: DC.B 1                     ; declare player mass, this will be overwrited later

DAY: DC.B 1                             ; declare day counter, this will increase on each turn

ENEMY_HP_TABLE: DC.B 55,65,70,75,85     ; using an array of values for enemy health, as each day i want enemy health to be different. 

FLAG_REDUCE_MASS:   DC.B 0                ; flags used to prevent repeated random events, increase to 1 when/if event occurs
FLAG_LUCKY_FIND:  DC.B 0


*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; All Messages in Game are under here
; $0D,$0A is used in messages to print new line carriage return and line feed, same as CRLF
;
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MSG_DAY:             DC.B $0D,$0A,'Day: ',0

MSG_INVALID_CHOICE:  DC.B $0D,$0A,'Invalid choice. Press 1 or 2.', $0D,$0A,0


MSG_RESTED:          DC.B $0D,$0A
                     DC.B 'You choose to stay in your safe house and gather your strenght for tomorrow. '
                     DC.B $0D,$0A
                     DC.B 'You tend to you wounds and rest, watching the sunset as they day comes to an end'
                     DC.B $0D,$0A
                     DC.B 'Vigor restored to 100'
                     DC.B $0D,$0A,0


; Combat messages
MSG_COMBAT_INTRO:   DC.B $0D,$0A
                    DC.B 'You venture out and enter a ruined building. You head inside in search of more rescources as usual'
                    DC.B $0D,$0A
                    DC.B 'There is another scanvenger in here, you cant run, so you must stand your ground. He is already raising his weapon at you. '
                    DC.B $0D,$0A
                    DC.B 'He will surely land the first hit, but if you are in better shape, you should be able to defeat them...'
                    DC.B $0D,$0A,0


MSG_ENEMY_HP:        DC.B 'Enemy Vigor: ',0

MSG_WIN_COMBAT:      DC.B $0D,$0A
                     DC.B 'You win the fight. Mass +15, Vigor -10.'
                     DC.B $0D,$0A,0

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Random event messages
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Debug message to make sure my random number works
MSG_RNG: DC.B 'RNG roll: ',0


; Mass loss event message
MSG_MASS_LOSS:  DC.B 'During the night, someone broke in. '
                DC.B $0D,$0A
                DC.B 'They scavenged your safehouse, and took what little they could find. '
                DC.B $0D,$0A
                DC.B 'Minus 10 mass.'
                DC.B $0D,$0A, 0
                
; Lucky find event message
MSG_LUCKY_FIND: DC.B 'You decided to take a look around your safe house. '
                DC.B $0D,$0A
                DC.B 'It was a good choice, as you have found some scrap you didnt think'
                DC.B $0D,$0A
                DC.B ' that you had, and fastened it to your armour. '
                DC.B $0D,$0A
                DC.B 'You also found some extra food, allowing yourself '
                DC.B $0D,$0A
                DC.B 'to gain back some strenght.'
                DC.B $0D,$0A
                DC.B 'Plus 10 mass and Plus 10 Vigor '
                DC.B $0D,$0A, 0
                
; Murder event message
MSG_MURDER_EVENT: DC.B '********************************************************************************'
                  DC.B $0D,$0A
                  DC.B 'You thought you locked the door...'
                  DC.B $0D,$0A
                  DC.B 'As you were sleeping, someone came inside.'
                  DC.B $0D,$0A
                  DC.B 'They just wanted to take some of your scrap.'
                  DC.B $0D,$0A 
                  DC.B 'But you heard them, and they were left with one option.'
                  DC.B $0D,$0A 
                  DC.B 'They killed you to take what they need.'
                  DC.B $0D,$0A
                  DC.B '                            GAME OVER'
                  DC.B $0D,$0A
                  DC.B '********************************************************************************'
                  DC.B $0D,$0A, 0
                        


; gameover message with new line to keep tidy
MSG_GAMEOVER: DC.B 'Game Over',$0D,$0A,0     ; Will always display this message on game end, and follow it with one of the following conditional endings below.

;Continue message, with new line aswell
MSG_CONTINUE:   DC.B $0D,$0A
                DC.B 'Press any button to continue. '
                DC.B $0D,$0A,0


CRLF:   DC.B    $0D,$0A,0   ;Carriage return, line feed. Used for new lines in between messages

*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
; Game Begin messages
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Title Card to be displayed at very start of game
MSG_TITLECARD:  DC.B '********************************************************************************'
                DC.B $0D,$0A
                DC.B '                                IRON BOUND'
                DC.B $0D,$0A
                DC.B '********************************************************************************'
                DC.B $0D,$0A
                DC.B $0D,$0A, 0


; Lore message to come after title card
MSG_GAME_START: DC.B $0D,$0A
                DC.B '15 years ago, the planet reached its limit.' 
                DC.B 'Years of extraction of resources from the planets crust have finally caught up. '
                DC.B $0D,$0A
                DC.B 'The gravity started to wane, and now it isnt strong enough to keep you held down.'
                DC.B $0D,$0A
                DC.B 'Most people have floated away into the sky above, never to return.'
                DC.B $0D,$0A
                DC.B 'You, and those others remaining, have survived by fastening heavy scrap into'
                DC.B $0D,$0A
                DC.B 'armor that can keep you weighed down enough,'
                DC.B $0D,$0A
                DC.B 'however resources are running out. '
                DC.B $0D,$0A
                DC.B 'Those left fight for scraps, anything they can take to hold themselves down. '
                DC.B $0D,$0A
                DC.B 'There are rumors of a band of survivors, iron-clad in scrapmetal, '
                DC.B $0D,$0A 
                DC.B 'who roam the wasteland and protect their own.'
                DC.B $0D,$0A
                DC.B 'Maybe if you can fashion a suit of armour like theirs, they will let you join them?'
                DC.B $0D,$0A
                DC.B 'Or maybe, someone may come for your resources and leave you unable to keep yourself grounded.'
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B $0D,$0A, 0
                
; Display game objective, after title card. From here we will start day 1.

MSG_OBJECTIVE:  DC.B $0D,$0A
                DC.B 'Explore the wasteland and collect scrapmetal to weigh yourself down. '
                DC.B $0D,$0A
                DC.B 'If your mass drops below 40 before the end of day 5, then you are doomed. You have 5 days.'
                DC.B $0D,$0A, 0
                
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;   Game Loop basic messages for each day
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; display mass and display health status messages

MSG_STATUS: DC.B $0D,$0A,'Current Status: ', $0D,$0A,0
MSG_MASS: DC.B $0D,$0A,'Mass: ',0
MSG_HEALTH: DC.B $0D,$0A,'Vigor: ',0
   
  ; Start the first day with a choice
MSG_BEGIN_DAY: DC.B $0D,$0A
                DC.B '********************************************************************************' 
                DC.B $0D,$0A
                DC.B 'The sun rises yet again.'
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B 'You wake up hungry and tired as usual. '
                DC.B $0D,$0A
                DC.B 'You better decide if you want to venture out and search for more scrap.'
                DC.B $0D,$0A
                DC.B ' Afterall, you feel as if you get lighter by the day. '
                DC.B $0D,$0A
                DC.B 'You could also stay at home, and rest to gather your strength. '
                DC.B $0D,$0A
                DC.B 'Afterall, who knows what challenges you could face tomorrow? '
                DC.B $0D,$0A
                DC.B 'Make your choice. Press 1 to venture out or press 2 to gather your strength for tomorrow. '
                DC.B $0D,$0A
                DC.B '********************************************************************************'
                DC.B $0D,$0A, 0
   
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;
;   Conditional ending messages, depends on ending stats
;
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;   If mass is less than 40 at the end of any day
MSG_BADENDING: DC.B '********************************************************************************'
               DC.B $0D,$0A
               DC.B '                               GAME OVER'
               DC.B $0D,$0A
               DC.B '                               Bad Ending: '
               DC.B $0D,$0A
               DC.B 'You have fought hard for your freedom, however '
               DC.B 'what little scrap you could find to weld together into weighted boots wasnt enough. '
               DC.B $0D,$0A
               DC.B 'You can feel the weight leave your body as you slowly begin to float upwards. '
               DC.B $0D,$0A
               DC.B 'Maybe if you didnt go outside to watch the sunset tonight, '
               DC.B $0D,$0A
               DC.B 'you would have been lucky enough to hit the roof, '
               DC.B 'but the sky above you now offers no net to catch you. '
               DC.B $0D,$0A
               DC.B 'You are are doomed to be forgotten in the toxic atmosphere above. '
               DC.B $0D,$0A
               DC.B '********************************************************************************', 0



;   If mass is above or equal to 75 after day 5
MSG_GOODENDING: DC.B '********************************************************************************'
               DC.B $0D,$0A
               DC.B '                               GAME OVER'
               DC.B $0D,$0A
               DC.B '                              Good Ending: '
               DC.B $0D,$0A
               DC.B 'You have done it, you have gathered enough scrap to fasten a '
               DC.B $0D,$0A
               DC.B 'suit heavy enough to keep you on the ground.'
               DC.B $0D,$0A
               DC.B 'You have heard stories in the wasteland of a group of people '
               DC.B $0D,$0A
               DC.B 'who walk in iron suits, a brotherhood of sorts. '
               DC.B $0D,$0A
               DC.B 'Now you can head out and search for them, perhaps they will take you '
               DC.B $0D,$0A
               DC.B 'in so that you may finally have safe company in this god forsaken reality.'
               DC.B $0D,$0A
               DC.B 'You should head out tomorrow morning, take what you can and start a new life with purpose.'
               DC.B $0D,$0A
               DC.B '********************************************************************************', 0
               
;   If mass is above or equal to 40 but less than 85 on day 5
MSG_NEUTRALEND: DC.B '********************************************************************************'
               DC.B $0D,$0A
               DC.B '                               GAME OVER'
               DC.B $0D,$0A
               DC.B '                             Neutral Ending: '
               DC.B $0D,$0A
               DC.B 'You managed to gather what you could and fasten your boots to be heavy enough to weigh you down. '
               DC.B $0D,$0A
               DC.B 'You wont float away into an endless void, but now there is no one left but you. '
               DC.B $0D,$0A
               DC.B 'What is the point of this struggle if you cant share it with another soul? '
               DC.B $0D,$0A
               DC.B 'It seems you are doomed to live your life in this wasteland, barely held down to the ground. '
               DC.B $0D,$0A
               DC.B '********************************************************************************', 0

;   If you are killed by an enemy
MSG_DEAD: DC.B '********************************************************************************'
               DC.B $0D,$0A
               DC.B '                               GAME OVER'
               DC.B $0D,$0A
               DC.B 'You have been killed by another scavenger: '
               DC.B $0D,$0A
               DC.B 'You delved too deep, and met someone stronger than you. '
               DC.B $0D,$0A
               DC.B 'It was kill or be killed, you understood that. '
               DC.B $0D,$0A
               DC.B 'Maybe your opponent was like you, struggling to survive.'
               DC.B $0D,$0A
               DC.B 'At least your gear may help them, until someone else comes along to take what '
               DC.B $0D,$0A
               DC.B 'is theirs, as they have done to you.'
               DC.B $0D,$0A
               DC.B '********************************************************************************', 0
               
               
    END    START        ; last line of source

           















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
