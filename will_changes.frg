#lang forge
option solver Glucose

//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
abstract sig Tone {}

one sig A, Asharp, B, C, Csharp, D, Dsharp, E, F, Fsharp, G, Gsharp extends Tone {}


sig Note {
    pitch: one Int
}

sig Chord {
    notes: set Note,
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord
}

//key sigs have partial func mapping note to int
sig KeySignature {
    scale: pfunc Int -> Tone
}

// fun totalLength[]: Int {
//     sum c: Chord | c.length
// }

pred wellFormed {
    //all reachable
    some c:Chord | {
        all c1:Chord | {
            c1 != c => reachable[c1, c, next]
        }
    }
    //non cyclical
    all c:Chord | {
        c.next != c
    }
    // //length is 32
    // totalLength[] = 32
}

pred majorChord[c:Chord] {
    let notes = c.notes {
        some n1, n2, n3: notes |
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7
    }

}

pred validChords {
    all c:Chord | {
        let numNotes = #{c.notes} {
            numNotes = 1 or numNotes = 3 or numNotes = 5
        }
    }
}

pred generateMusic {
    wellFormed
    validChords
    some c:Chord | { majorChord[c]}
}

run {generateMusic} for 5 Int, exactly 3 Chord, exactly 1 KeySignature