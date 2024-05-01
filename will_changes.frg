#lang forge
option solver Glucose

//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
abstract sig Tone {}

one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}

sig Note {
    pitch: one Int
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
        c.next != c
    }
}

//0 4 7
pred majorChord[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes |
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7
    }

}

//0 4 7 e
pred majorSeventh[c:Chord] {
    let notes = c.notes {
        #{notes} = 4
        some n1, n2, n3, n4: notes |
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7 and n4.pitch = 11
    }

}

//1 5 8
pred neapolitan[c:Chord] {
    let notes = c.notes {
        #{notes} = 3
        some n1, n2, n3: notes |
            n1.pitch = 1 and n2.pitch = 5 and n3.pitch = 8 
    }
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
        i >= 0 => KeySignature.scale[i] = KeySignature.scale[remainder[i, 12]]
    }
    //all int:
    // scale[int % 12] = C?
}

pred validChords {
    all c:Chord | {
        let numNotes = #{c.notes} {
            numNotes >= 1
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



//things to add 
//1: preds for chord progression in certain genres


pred generateMusic {
    wellFormed
    validChords
    some c:Chord | { majorChord[c]}
    some c:Chord | { majorSeventh[c]}
    some c:Chord | { neapolitan[c]}
    cMajor
}

run {generateMusic} for 6 Int, exactly 4 Chord, exactly 1 KeySignature