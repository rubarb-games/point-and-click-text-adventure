Is it <rule>generic</rule> though? If nothing else it is happening

    * auto_start
    -> tutorial_START_1
    * game
    -> generic_game
    * take
    -> generic_take
    
=== generic_look ===
.You look, but see nothing. Weird!

=== generic_game ===
.Yep. It's a game you're playing

=== generic_take ===
.You try to take. Huh, weird. Nothing happens

=== tutorial_START_1 ===
<location>tutorial</location>
<rule>clearHistory</rule>
Click words to <verb>start</start>

    * start
    -> tutorial_start_2
    * start__game
    -> tutorial_progress_a

    
=== tutorial_start_2 ===
.Welcome to the tutorial! You've already learnt to click word to proceed. All that's left to realise is that in this <noun>game</noun> , sometimes you'll want to <verb>take</verb> it <noun>back</noun> .

    * start__game
        -> tutorial_start_b
    * start
        -> tutorial_start_b
        
=== tutorial_start_b ===
.Hey, this is the tutorial. You can't start the game from here! <verb>take</verb> a breather, and head on <noun>back</noun> .

    * start__game
        -> tutorial_start_b
    * start
        -> tutorial_start_b

=== cheat ===
.Ayyy, what is this? How did you get here??
        

=== tutorial_progress_a ===
.You've started the game. Congratulations! I'm proud of you. Take a <verb>look</verb>

    *look
        -> office_a

=== office_a === 
<location>office</office>
Another late night, another blank document. The filtered light of your monitor dries your eyes out as you <verb>look</verb> at the blinking cursor. How long have you been sitting at this <noun>desk</noun> ? An hour? A day? A year? A lifetime, spent watching the little black bar blink on and off. Aren’t writers supposed to <verb>write</verb> ? And yet, you haven’t written a <noun>poem</noun> since [REDACTED]. You haven’t even come in the <noun>vicinity</noun> of writing a poem. Is tonight the night?

    * write__poem
        -> office_a_write_poem
    * look_at_vicinity
        -> office_a_look_vicinity
    * look_at_desk
        -> office_a_look_desk
    * look_at_window
        -> office_a_look_window
    * look_at_curtains
        -> office_a_look_curtains
    * open__curtains
        -> office_a_open_curtains


=== office_a_write_poem ===
.Your fingers poise themselves over the keys in anticipation of a stroke of inspiration that does not come. Try as you might, there are other things blocking your creativity… How could anyone be expected to create art when...

=== office_a_force_poem ===
.It's all about white knuckling your way through life. It's just words, you keep saying, yet they won't come out.

=== office_a_look_vicinity ===
.You’re in your office. It’s night out, and the <noun>curtains</noun> are drawn; the barest HINT of moonlight seeps through. The bare <noun>bulb</noun> that dangles from a crimped wire buzzes annoyingly overhead. Your <noun>desk</noun> is cluttered, as usual. There’s only one <noun>door</noun> to <noun>exit</noun> out of here, leading to the upstairs hallway.

    * open__curtains
        -> office_a_open_curtains
    * handle__curtains
        ->office_a_open_curtains
    * look_at_curtains
        ->office_a_look_curtains
    * open__window
        -> office_a_open_window
    * look_at_window
        -> office_a_look_window
    * look_at_desk
        -> office_a_look_desk
    * open__door
        -> office_a_open_door
    * look_at_door
        -> office_a_look_at_door
    * enter__door
        -> office_a_enter_hallway

=== office_a_look_desk ===
.Your computer is on, newmasterpiece.doc is <verb>open</verb> , and no words are written down - same as every night. The surface is a graveyard of half-drunk <noun>coffee</noun> cups, crisp packets, soda bottles, and takeout coupons.
    
    * take__coffee
        -> office_a_take_coffee
    * force__coffee
        -> office_a_force_coffee

=== office_a_force_coffee ===

.You force yourself to drink the semi-liquid, tarlike substance. It's awful and cold. Your quality of life has decreased significantly.

    * take__coffee
    -> office_a_take_coffee


=== office_a_take_coffee ===
.Eurgh, even you aren’t desperate enough for cold <noun>coffee</noun> dregs.

    * force__coffee
    -> office_a_force_coffee

=== office_a_open_curtains ===
.It’s a <noun>window</noun>

    * open__window
    -> office_a_open_window
    * look_at_window
    -> office_a_look_window

=== office_a_open_window ===   
.It’s painted shut.

    * look_at_window
    -> office_a_look_window

=== office_a_look_curtains ===
.They're long, beige annd made out of thick fabric. As to block out any light if you were to <verb>close</verb> them

    * look_at_window
    -> office_a_look_window
    
    * close__curtains
    -> office_a_close_curtains
    
=== office_a_close_curtains ===
.They've been stuck for a long time. No matter how much [verb]force you use, they're completely stuck

    * look_at_window
    -> office_a_look_window
    
    * look_at_curtains
    -> office_a_look_curtains

=== office_a_look_window ===
.It’s nighttime, but the pale glow of a crescent moon illuminates the wall your office faces in an insipid <verb>cast</verb> . You try to get inspired by the pattern of blank grey stucco. You <verb>enter a trance of swirling meters and metaphors for ennui. You can’t think of anything that rhymes with stucco.

=== office_a_look_at_door ===
.It's a door, wooden. Metal <verb>handle</verb> .

=== office_a_open_door ===
.The upstairs <noun>hallway</noun> waits beyond

    *enter__hallway
    -> office_a_enter_hallway

=== office_a_enter_hallway ===
.You've reached the hallway, and thus as long as Simon could be bothered to type in text.. Wow. You win? Maybe? Idk, pretty cool either way.
    
    -> END