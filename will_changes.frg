#lang forge
option solver Glucose

//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
abstract sig Tone {}

one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}

sig Note {
    pitch: one Int,
    octave: one Int
}

sig Chord {
    notes: set Note,
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord
    //should it have a name?
}

//key sigs have partial func mapping note to int
one sig KeySignature {
    scale: pfunc Int -> Tone
}

pred wellFormed {
    //all reachable
    some c:Chord | {
        all c1:Chord | {
            c1 != c => reachable[c1, c, next]
        }
    }
    //non cyclical
    all c:Chord | {
        not reachable[c, c, next]
    }
    //all pitch
    all n:Note | {
        n.pitch >= 0
        n.pitch <= 11

        n.octave = 1
    }
}

//0 4 7
pred majorChord[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes | {
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7
        }
    }

}

//0 4 7 e
pred majorSeventh[c:Chord] {
    let notes = c.notes {
        #{notes} = 4
        some n1, n2, n3, n4: notes | {
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7 and n4.pitch = 11
        }
    }

}

//1 5 8
pred neapolitan[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes | {
            n1.pitch = 1 and n2.pitch = 5 and n3.pitch = 8 
        }
    }
}

pred singleNote[c:Chord] {
    let notes = c.notes {
        #{notes} = 1
    }
    acceptableMajorNotes[c]
}

//scale definition
pred cMajor {
    KeySignature.scale[0] = C
    KeySignature.scale[1] = CSharp
    KeySignature.scale[2] = D
    KeySignature.scale[3] = DSharp
    KeySignature.scale[4] = E
    KeySignature.scale[5] = F
    KeySignature.scale[6] = FSharp
    KeySignature.scale[7] = G
    KeySignature.scale[8] = GSharp
    KeySignature.scale[9] = A
    KeySignature.scale[10] = ASharp
    KeySignature.scale[11] = B
    all i:Int | {
        i < 0 => KeySignature.scale[i] = none
        i >= 12 => KeySignature.scale[i] = none
        // i >= 0 => KeySignature.scale[i] = KeySignature.scale[remainder[i, 12]]
    }
    //all int:
    // scale[int % 12] = C?
}

pred validChords {
    all c:Chord | {
        let numNotes = #{c.notes} {
            numNotes >= 1
            numNotes < 5
        }
    }
}

pred validLength {
    // sum[]
    // let totalLength = 0 {
    //     all c:Chord | {
    //         subtract[totalLength, c.length]
    //     }
    //     totalLength = 32
    // }
}

pred definedChord[c:Chord] {
    majorChord[c] or majorSeventh[c] or neapolitan[c]

}

//no two chords are the same in a row
pred variedChords {
    //TODO: MAKE it so that checks to make sure each consecutive chord has one note with a different pitch,
    // and the prev one also has a pitch that the next doesnt have

    //make sure each have one element that isnt in the other
    // all c:Chord | {
    //     some c.next => {
    //         some n: Note {
    //             n in c.notes
    //             n.pitch
    //         }
    //     }
        // (not singleNote[c.next] and not singleNote[c] and c.next != none) => {
        //     #{c.notes - c.next.notes} > 0
        //     #{c.next.notes - c.notes} > 0
        // }
    }
}



pred acceptableMajorNotes[c: Chord] {
    all n: c.notes | {
        n = 0 or
        n = 2 or
        n = 4 or
        n = 5 or
        n = 7 or
        n = 9 or
        n = 11 
    }
}

//things to add 
//1: preds for chord progression in certain genres


pred generateMusic {
    wellFormed
    validChords
    some c:Chord | { majorChord[c]}
    some c:Chord | { majorSeventh[c]}
    some c:Chord | { neapolitan[c]}
    // some c:Chord | {singleNote[c]}
    all c: Chord | {
        (not definedChord[c]) => acceptableMajorNotes[c]
    }
    cMajor
    variedChords
}

run {generateMusic} for 5 Int, exactly 12 Note, exactly 8 Chord, exactly 1 KeySignature