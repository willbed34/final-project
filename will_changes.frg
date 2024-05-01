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
}

//key sigs have partial func mapping note to int
one sig KeySignature {
    scale: pfunc Int -> Tone
}

// fun countPiece: one Int {
//   all
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
    
    // Sum of all chord lengths is 32
    // let totalLength = 0
    // all c:Chord | {
    //     totalLength = add[totalLength, c.length]
    // }
    // totalLength = 32
    // totalLength c: Chord | c.length = 32

    // //only one key signature (just changed sig def to one)
    // #{KeySignature} = 1
}

pred majorChord[c:Chord] {
    let notes = c.notes {
        some n1, n2, n3: notes |
            n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7
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
    }
    //all int:
    // scale[int % 12] = C?
}

pred validChords {
    all c:Chord | {
        let numNotes = #{c.notes} {
            numNotes = 1 or numNotes = 3 or numNotes = 5
        }
    }
}

//things to add 
//1: preds for chord progression in certain genres


pred generateMusic {
    wellFormed
    validChords
    some c:Chord | { majorChord[c]}
    cMajor
}

run {generateMusic} for 5 Int, exactly 3 Chord, exactly 1 KeySignature