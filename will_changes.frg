#lang forge
option solver Glucose

//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
//for playing the music: https://signal.vercel.app/edit
abstract sig Tone {}

one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}

abstract sig ChordType {
    // offset: one Int
}

one sig CMajor, GMajor, AMinor, FMajor extends ChordType {}

sig Note {
    pitch: one Int,
    octave: one Int
}

sig Chord {
    notes: set Note,
    pitches: set Int,
    first: lone Note,
    last: lone Note,
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord,
    type: one ChordType
    //should it have a name?
}

//key sigs have partial func mapping note to int
one sig KeySignature {
    scale: pfunc Int -> Tone
}

pred wellFormed {
    //all reachable
    some c: Chord | {
        all c1: Chord | {
            c1 != c => reachable[c1, c, next]
        }
    }
    // all c: Chord | {
    //     some c.next => ValidChordProgression[c, c.next]
    // }
    //non cyclical
    all c: Chord | {
        not reachable[c, c, next]
    }
    //all pitch
    all n:Note | {
        n.pitch >= 0
        n.pitch <= 11

        n.octave = 1
    }

    all c:Chord | {
        c.first != none
        c.first in c.notes
        c.last != none
        c.last in c.notes

        // c.type = CMajor implies ValidCMajorNotes[c]
        // c.type = GMajor implies ValidGMajorNotes[c]
        // c.type = AMinor implies ValidAMinorNotes[c]
        // c.type = FMajor implies ValidFMajorNotes[c]

        // valid length
        // (c.length = -4 or c.length = -8)
        c.length < 0
        c.length >= -8

    }

    // (sum c: Chord | sum[c.length]) = -32
}

//0 4 7
pred majorChord[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes | {
            (n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7)
            n1.octave = n2.octave
            n2.octave = n3.octave
        }
    }

}

//0 4 7 e
pred majorSeventh[c:Chord] {
    let notes = c.notes {
        #{notes} = 4
        some n1, n2, n3, n4: notes | {
            (n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7 and n4.pitch = 11)
            n1.octave = n2.octave
            n2.octave = n3.octave
            n3.octave = n4.octave
        }
    }

}

//1 5 8
pred neapolitan[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes | {
            (n1.pitch = 1 and n2.pitch = 5 and n3.pitch = 8)
            n1.octave = n2.octave
            n2.octave = n3.octave
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
    KeySignature.scale[12] = C
    KeySignature.scale[13] = CSharp
    KeySignature.scale[14] = D
    KeySignature.scale[15] = DSharp
    KeySignature.scale[16] = E
    KeySignature.scale[17] = F
    KeySignature.scale[18] = FSharp
    all i:Int | {
        i < 0 => KeySignature.scale[i] = none
        i > 18 => KeySignature.scale[i] = none
    }
}

pred validChords {
    all c:Chord | {
        let numNotes = #{c.notes} {
            numNotes > 0
            numNotes < 5
        }
        let pitches = c.pitches {
            all n: c.notes | {
                n.pitch in pitches
            }
            #{pitches} = #{c.notes}
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
    // the notes can be the same, but the pitch must be different
    all c:Chord | {
        some c.next => {
            // #{c.pitches} < #{c.next.pitches} => {
            some p: c.pitches | {
                p not in c.next.pitches
            }
            // }
            // #{c.next.pitches} < #{c.pitches} => {
            some p: c.next.pitches | {
                p not in c.pitches
            }
            // }
        }
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
        n = 11 or 
        n = 12 or
        n = 14 or
        n = 16
    }
}

pred ValidCMajorNotes[c: Chord] {
    all n: c.notes | (
        n.pitch = 0 or   // C
        n.pitch = 2 or   // D
        n.pitch = 4 or   // E
        n.pitch = 5 or   // F
        n.pitch = 7 or   // G
        n.pitch = 9 or   // A
        n.pitch = 11     // B
    )
}

pred ValidGMajorNotes[c: Chord] {
    all n: c.notes | {
        n.pitch = 7 or
        n.pitch = 9 or
        n.pitch = 11 or
        n.pitch = 12 or
        n.pitch = 14 or
        n.pitch = 16
    }
}

pred ValidAMinorNotes[c: Chord] {
    all n: c.notes | {
        n.pitch = 9 or
        n.pitch = 11 or
        n.pitch = 12 or
        n.pitch = 14 or
        n.pitch = 16 or
        n.pitch = 17
    }
}

pred ValidFMajorNotes[c: Chord] {
    all n: c.notes | {
        n.pitch = 5 or
        n.pitch = 7 or
        n.pitch = 9 or
        n.pitch = 10 or
        n.pitch = 12 or
        n.pitch = 14
    }
}


//things to add 
//1: preds for chord progression in certain genres
pred ValidChordProgression[c1: Chord, c2: Chord] {
    // (c1.root.tone = 0 or c1.root.tone = 2 or c1.root.tone = 7)
    c1.last.pitch = 0 => c2.first.pitch = 7
    c1.last.pitch = 2 => c2.first.pitch = 7
    c1.last.pitch = 4 => c2.first.pitch = 7
    c1.last.pitch = 5 => c2.first.pitch = 7
    c1.last.pitch = 9 => c2.first.pitch = 7
    c1.last.pitch = 11 => c2.first.pitch = 7
    c1.last.pitch = 7 => (c2.first.pitch = 0 or c2.first.pitch = 2 or c2.first.pitch = 4 or c2.first.pitch = 5 or c2.first.pitch = 9 or c2.first.pitch = 11)
    
}

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

run {generateMusic} for 6 Int, exactly 12 Note, exactly 5 Chord, exactly 1 KeySignature