#lang forge/bsl
open "chords_and_melody.frg"

test suite for validRoot{
    test expect{
        validRoot:{(
            some x,y,z : Chord|
            x.next = y and
            y.next = z and 
            z.next = x
        )and nonCyclical} is unsat
    }
}


test suite for nonCyclical{
    test expect{
        cyclic:{(
            some x,y,z : Chord|
            x.next = y and
            y.next = z and 
            z.next = x
        )and nonCyclical} is unsat

        cyclicToSelf:{(
            some x,y,z : Chord|
            x.next = y and
            y.next = z and 
            z.next = x
        )and nonCyclical} is unsat

        uncyclic:{(
            some x,y,z : Chord|
            x.next = y and
            y.next = z
        )and nonCyclical} is sat
    }
}

test suite for validPitchAndOctave{
    test expect{
        validPitchAndOctaves:{(
            some x,y : Note|
            x.pitch = 0 and
            y.pitch = 1 and 
            x.octave = 0 and
            y.octave = 1 
        )and validPitchAndOctave}for 7 Int is sat

        invalidPitchAndOctaves:{(
            some x,y : Note|
            x != y and
            x.pitch = -1 and
            y.pitch = 0 and 
            x.octave = 5 and
            y.octave = 0
        )and validPitchAndOctave}for 7 Int is unsat
    }

} 

test suite for differentPitches {
    test expect {
        invalidPitches: {
            (some x: Chord | 
                x.root.pitch = 0 and
                x.third.pitch = 1 and
                x.fifth.pitch = 1 and
                x.seventh.pitch = 1 and differentPitches[x])
        } is unsat

        validPitches: {
            (some x: Chord | 
                x.root.pitch = 0 and
                x.third.pitch = 1 and
                x.fifth.pitch = 3 and
                x.seventh.pitch = 5 and differentPitches[x])
        } is sat
    }
}


test suite for validChords {
    test expect {
        noThird: {
            (some x: Chord | 
                x.root.pitch = 0 and
                no x.third.pitch and 
                x.fifth.pitch = 1 and
                x.seventh.pitch = 2) and validChords
        } for 7 Int is unsat

        misArrangedChord: {
            (some x: Chord | 
                x.root.pitch = 0 and
                x.third.pitch = 5 and 
                x.fifth.pitch = 7 and
                x.seventh.pitch = 3 and
                x.root.octave = 4 and
                x.third.octave = 4 and 
                x.fifth.octave = 4 and
                x.seventh.octave = 4) and validChords
        } for 7 Int is unsat

        misArrangedOctave: {
            (some x: Chord | 
                x.root.pitch = 0 and
                x.third.pitch = 5 and 
                x.fifth.pitch = 7 and
                x.seventh.pitch = 8 and
                x.root.octave = 4 and
                x.third.octave = 3 and 
                x.fifth.octave = 4 and
                x.seventh.octave = 4) and validChords
        } for 7 Int is unsat
    }
}
