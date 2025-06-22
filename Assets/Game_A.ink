.Click words to [verb]start .
    * start
    -> tutorial_start_a
    
=== tutorial_start_a ===
.Welcome to the tutorial! You've already learnt to click word to proceed. All that's left to realise is that in this [noun]game , sometimes you'll want to [verb]take it [noun]back .

    * start__game
        -> tutorial_start_b
    * start
        -> tutorial_start_b
    * back
        -> tutorial_progress_a
    * take__back
        -> tutorial_progress_a
        
=== tutorial_start_b ===
.Hey, this is the tutorial. You can't start the game from here! [verb]take a breather, and head on [noun]back .

    * start__game
        -> tutorial_start_b
    * start
        -> tutorial_start_b
    * back
        -> tutorial_progress_a
    * take__back
        -> tutorial_progress_a

=== tutorial_progress_a ===
.You've started the game. Congratulations! I'm proud of you. Take a [verb]look .
    
    *look
        -> main_room_a
        
=== main_room_a === 
.Main room A
    -> END