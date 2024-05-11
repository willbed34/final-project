# Music Generation with Forge
# Developed by David Doan, Isaac Jenemann, and William Bednarz

# How you structured your mode?
We structured our model with the following structs:
abstract sig Tone {}
one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}
sig Note {
    pitch: one Int,
    octave: one Int
}

We used these tones to help other users, and stakeholders to understand our model. We thought the best approach to handle the constant values of these tone were to assign them an integer value. This way, we could easily compare and contrast the tones. We also used the integer values to help us with the logic of the model.

abstract sig ChordType {}

one sig IChord, VChord, VIChord, IVChord extends ChordType {}

sig Chord {
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord,
    type: lone ChordType,
    root: one Note, 
    third: one Note,
    fifth: one Note,
    seventh: lone Note
}

Using these chords, we were able to create a simple model that could be used to create a song. We used the chords to help us understand the progression of the song. We also used the chords to help us understand the structure of the song. By using these chords we were able to combine notes together. Additionally, we were able to create valid chord progressions between chords such that the transitions sound smooth and natural.

one sig Melody {
    melodyNotes: pfunc Int -> Note
}

To fully complete creating a song, we added a Melody struct to be played along with the chords. This is representative of someone singing to a song or playing a melody on an instrument.

one sig Song {
    songChords: pfunc Int -> Chord
}

We used to sequence to better help us developer and understand the model. This provides users with a logical way to look at the output of our model and understand the progression of the song.

one sig KeySignature {
    scale: pfunc Int -> Tone
}

We also had a sig for the key signature. As most of the logic operates by using integers, the key signature is responsible for providing musical context to the notes i.e. assigning them a note value, like F or C#.

Overall, the sigs used in our model drew inspiration from real life. Because music composition is very structured, we found it appropriate to follow most musical conventions.

We then used predicates to help us create the song, constraining what notes should be played and the transitions between chords such that they sound natural and follow the rules of music theory.

# What your model proved

Our model proved that we could create a simple song using the Forge. Through developing this project with Forge, we could see how logical and mathematical music construction was. At the same time, we were also able to determine how complex music making was, as Forge performance began to diminish significantly as we added more constraints and chords. There were many concepts still that could have been added to this model but proved to not be feasible due to the limitations of Forge. We found that even after 10 minutes, a song consisting of 20+ chords could not be computed. 

Our model also proved that Forge can be utilized to dictate creation of music. For instance, if we wanted certain elements to appear in our composed melody, we would simply constrain the model as such. This proved effective, but in a way removed some of the creative expressiveness we wanted to see.

All in all, in developing this model, we could see the mathematical and logical side of music creation. However, at the same time, there are many other factors than math that make music sound good, and may not be seemingly logical at the same time. There is a concept of irregularities that are introduced to song to make them sound fresh and interesting. This is something that we could not capture in our model and would be difficult to do so, because although music creation has general and logical rules, it is also a creative process subject to the whims of the composer. 

Overall, We found that our results lead to good sounding music, and that by using Forge and music theory, we could create a song that sounded good.
We proved that using just logic and mathematical reasoning, we can construct a good song, but at the same time we proved that this removes the creative and human element of music creation. Additionally, we proved how complex music creation is, and how many factors are involved in creating a song that sounds good. There were many more concepts that we looked at and wanted to implement, but we found that it was not feasible to do so due to the limitations of Forge, given that we were limited to generating 16 chords within a reasonable amount of time.

# What tradeoffs did you make in choosing your representation? What else did you try that didn’t work as well?

In our representation, we made a tradeoff in choosing to make the model simpler and understandable. Considering the number of keys available on an instrument such as a piano, we decided to limit the number of tones to 12 and use math to reach these different notes. However, this limits us with how much we can represent in our model. 

In addition, although we tried to generalize our code to cover as much about music theory as possible, there were many things that we could not represent in our model as it would make the computation not feasible. For example, we could not represent the concept of irregularities in music, such as the use of accidentals, but Forge is a logical language rather than a generative language. 

Furthermore, we found that increasing the number of chords in the song past 16 chords resulted in a significant increase in computation time. This was a limitation of Forge, and we could not create a song that was longer than 16 chords, so we could not create a longer song.

# What assumptions did you make about scope? What are the limits of your model?

We assumed that we could create a simple song using the Forge. We assumed that we could create a song that was 16 bars long. However, we found that the Forge could not handle the computation of a song that was 20 chords long. This was a limitation of the Forge, and therefore we could not create a longer song. 

Additionally, due to computation time would could not make our model more complex, such as adding more complex chords or more complex melodies. We found that the Forge could not handle the computation of a song that was more complex than what we had created.

# Did your goals change at all from your proposal? Did you realize anything you planned was unrealistic, or that anything you thought was unrealistic was doable?

Although our foundation goals did not change from our proposal from the development of the project, we found our reach goal to be more unrealistic than we realized. We found how complicated a song would be with limited parameters and with a constrained scope, and we determined that it would be unrealistic to create a song that was 24 chords long or longer due to the limitations of Forge. Upon discovering the limitations of Forge, we soon thereafter abandoned plans to implement more advanced musical concepts, as anticipated Forge would not be effective in representing them. Another change in our project was the removal of length as a parameter of our chords. While feasible from a logic perspective the complexity of implementing length both visually and sonically using Tone.js proved outside the scope of this project.

# How should we understand an instance of your model and what your visualization shows (whether custom or default)?
An instance of our model is a generated sequence of music that fits within the rules of western music theory. Currently the music is generated in CMajor although by constraining the notes it's quite easy to create snippets of music in different keys and styles. Our visualizer takes the songChords and melodies and maps them on to a bass and treble clef. The visualizer also generates an audio version of the music to help the user have a better sense of the program results. This was super helpful for us, as we created this project as it let us fine tune our generator, and figure out what was and wasn't working more easily than a simple testing file.  

# Stakeholders

The stakeholders for our project are anyone who wants to learn more about music and music theory. Additionally, users of logical languages such as Forge may be interested in our project as it shows how music can be created using a logical language. Music creators may also be interested in our project as it shows how music can be created using a logical language.

# Testing:
See our testing file for more information on how we tested our model. As discussed, while we've created a series of tests that ensure the predicates are working as anticipated, to actually test our system - we found working with the visualizer/audio a much easier way to debug and find out what was and wasn't working. 

# Collaborators
Ezra Rocha

# Opt-out Statement
We are comfortable sharing our final project.
