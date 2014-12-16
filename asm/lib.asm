; -----------------------
; lib.asm
; @brief	Trigonometry
; @author	Jaan Janno
; @date		15.12.2014
; -----------------------
%include "macros.inc"

section .data
	two dd 2.0
	one dd 1

globalfunc siinusLihtsamalt, arg:dword
	prologue
	fld .arg
	fsin
	epilogue

; sin x = x^1 / 1! - x^3 / 3! + x^5 / 5! - ...

globalfunc siinus, arg:dword
	uses esi
	prologue
		fninit ; Küsimus: miskipärast ilma selleta ta ei tööta, kuigi FPU stacki olukord peaks lõpus sama olema, mis siinusLihtsamalt() funktsioonis. Teen vahepeal midagi, mis ilma init'ita katki läheb?

		; float vastus = arg % (2 * pi); - jada esimene liige ehk x^1 / 1!, kasulik pi-ga, sest kuigi vastus tuleb sama, lähevad arvutatud astmed suure argumendiga kiiresti suht suureks.
		fldpi			
		fld dword[two] ; Küsimus: saaks seda ka ilma .data-sse panemata teha?
		fmulp st1, st0 
		fld .arg
		fprem

		; float argAstmes = arg; jada esimese liikme murru lugeja ehk x^1, mis praegu = ka x^1 / 1!
		fld st0

		; float argRuudus = arg * arg; astmete lugejate astendajate samm on 2, seega kasulik sellega korrutamisi teha
		fld st0
		fmul st0, st0

		; Küsimus: kas on mõistlikum siin faktoriaale int'idena või floatidena käsitleda? Sisuliselt peab ta vist ikka mingi teisenduse tagasi floadiks tegema, kui sellega jagamist teeb. Samas korrutamine ja liitmine ehk on intidega kiirem teha ka FPU peal?
		; int jargmFaktoriaaliLiige = 1;
		fild dword[one]
		; int faktoriaal = 1; sest 1! = 1
		fild dword[one]

		; int i = 6; alates 6-st näib, et annab alati sisse ehitatud variandiga samat vastust
		mov esi, 6 ; Küsimus: kas on mõistlik siin teha counter tavalises registris? Alternatiiv oleks kontrollida faktoriaali liikme suurust - siis peaks aga makro ümber tegema, jäi laiskuse taha.
		; while (i != 0) {
		.while esi != 0

			; faktoriaal *= jargmFaktoriaaliLiige++;
			fild dword[one] ; Küsimus: kas see on mõistlik, või oleks parem fld1, mis ei pea mällu minema? Samas on intide kokku liitmine floadi otsa liitmisest ehk selle võrra vähemalt kiirem?
			faddp st1		
			fmul st1, st0

			; faktoriaal *= jargmFaktoriaaliLiige++;
			fild dword[one]
			faddp st1		
			fmul st1, st0

			; argAstmes *= argRuudus;
			fxch st2 ; Küsimus: kas see excange on parem/kiirem stacki lõppu st2 kopeerimisest?
			fmul st3, st0
			fxch st2

			; vastus -= argAstmes / faktoriaal;
			fld st3
			fdiv st0, st2
			fsubp st5, st0

			; faktoriaal *= jargmFaktoriaaliLiige++;
			fild dword[one]
			faddp st1
			fmul st1, st0

			; faktoriaal *= jargmFaktoriaaliLiige++;
			fild dword[one]
			faddp st1
			fmul st1, st0

			; argAstmes *= argRuudus;
			fxch st2
			fmul st3, st0
			fxch st2

			; vastus += argAstmes / faktoriaal;
			fld st3
			fdiv st0, st2
			faddp st5, st0

			dec esi ; i--;

		.endwhile

		fdecstp ; Küsimus: kas oleks parem tava lihtsalt fxch teha, et vastus tippu tuua? Kiiruse vahe on siin vist igatpidi tühine. 
		fdecstp
		fdecstp
		fdecstp
	epilogue