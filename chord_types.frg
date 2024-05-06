#lang forge
option solver Glucose

//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
//for playing the music: https://signal.vercel.app/edit
abstract sig Tone {}

one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}

abstract sig ChordType {
    // offset: one Int
}

// one sig CMajor, GMajor, AMinor, FMajor extends ChordType {}
//this is a commmon chord progression
one sig IChord, VChord, VIChord, IVChord extends ChordType {}

sig Note {
    pitch: one Int,
    octave: one Int
}

sig Chord {
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord,
    type: lone ChordType,
    root: one Note, 
    third: lone Note,
    fifth: lone Note,
    seventh: lone Note
}


one sig Song {
    songChords: pfunc Int -> Chord
}

//key sigs have partial func mapping note to int
one sig KeySignature {
    scale: pfunc Int -> Tone
}



pred wellFormed {
    //all reachable
    some c: Chord | {
        majorChord[c] or c.root.pitch = 0
        all c1: Chord | {
            c1 != c => reachable[c1, c, next]
        }
        Song.songChords[0] = c
        Song.songChords[1] = c.next
        Song.songChords[2] = c.next.next
        Song.songChords[3] = c.next.next.next
        Song.songChords[4] = c.next.next.next.next
        Song.songChords[5] = c.next.next.next.next.next
        Song.songChords[6] = c.next.next.next.next.next.next
        Song.songChords[7] = c.next.next.next.next.next.next.next
        Song.songChords[8] = c.next.next.next.next.next.next.next.next
        Song.songChords[9] = c.next.next.next.next.next.next.next.next.next
    }
    //non cyclical
    all c: Chord | {
        not reachable[c, c, next]
    }
    //all pitch
    all n:Note | {
        n.pitch >= 0
        n.pitch <= 11

        //change later
        n.octave >= 0
        n.octave <= 3
    }

    all c:Chord | {
        c.root != none

        c.length < 0
        c.length >= -8

        differentPitches[c]

        //makes sure theres no 2-note chords
        some c.third iff some c.fifth

        //makes sure if theres a seventh, theres a fifth and third
        some c.seventh => (some c.fifth and some c.third)

        //third should be higher than root, fifth should be higher than third, seventh should be higher than fifth
        some c.third => add[multiply[11, c.third.octave], c.third.pitch] > add[multiply[11, c.root.octave], c.root.pitch]
        some c.fifth => add[multiply[11, c.fifth.octave], c.fifth.pitch] > add[multiply[11, c.third.octave], c.third.pitch]
        some c.seventh => add[multiply[11, c.seventh.octave], c.seventh.pitch] > add[multiply[11, c.fifth.octave], c.fifth.pitch]
    }
    //TODO: look at this, prolly remove once we add octaves
    all n: Note | {
        all n1: Note | {
            n != n1 => not (n.pitch = n1.pitch and n.octave = n1.octave)
        }
    }

    // (sum c: Chord | sum[c.length]) = -32
}



pred differentPitches[c:Chord] {
    some c.third => (c.root.pitch != c.third.pitch)
    some c.fifth => (c.root.pitch != c.fifth.pitch and c.third.pitch != c.fifth.pitch)
    //TODO: maybe change this to check if third is seventh
    some c.seventh => (c.root.pitch != c.seventh.pitch and c.third.pitch != c.seventh.pitch and c.fifth.pitch != c.seventh.pitch)
}

//valid chords
pred chordTypes {
    all c: Chord | {
        //most of the changes between will_changes are here
        c.type = IChord implies {
            c.root.pitch = 0
            c.third.pitch = 4
            c.fifth.pitch = 7
            c.root.octave = c.third.octave
            c.third.octave = c.fifth.octave
            no c.seventh
        }
        c.type = VChord implies {
            c.root.pitch = 7
            c.third.pitch = 11
            c.fifth.pitch = 2
            c.third.octave = c.root.octave
            c.fifth.octave = add[c.third.octave, 1]
            no c.seventh
        }
        c.type = VIChord implies {
            c.root.pitch = 9
            c.third.pitch = 0
            c.fifth.pitch = 4
            c.third.octave = add[c.root.octave, 1]
            c.fifth.octave = c.third.octave
            no c.seventh
        }
        c.type = IVChord implies {
            c.root.pitch = 5
            c.third.pitch = 9
            c.fifth.pitch = 0
            c.third.octave = c.root.octave
            c.fifth.octave = add[c.third.octave, 1]
            no c.seventh
        }
    }
}

//0 4 7
pred majorChord[c:Chord] {
    // let notes = c.notes {
    //     #{notes} = 3
    //     some n1, n2, n3: notes | {
    //         (n1.pitch = 0 and n2.pitch = 4 and n3.pitch = 7)
    //         n1.octave = n2.octave
    //         n2.octave = n3.octave
    //     }
    // }
    c.root.pitch = 0
    c.third.pitch = 4
    c.fifth.pitch = 7
    no c.seventh
}

//0 4 7 e
pred majorSeventh[c:Chord] {
    c.root.pitch = 0
    c.third.pitch = 4
    c.fifth.pitch = 7
    c.seventh.pitch = 11
}

//1 5 8 (this chord sucks, but its good we tried it)
pred neapolitan[c:Chord] {
    c.root.pitch = 1
    c.third.pitch = 5
    c.fifth.pitch = 8
    no c.seventh
}

pred singleNote[c:Chord] {
    // let notes = c.notes {
    //     #{notes} = 1
    // }
    some c.root
    no c.third
    no c.fifth
    no c.seventh

    //makes sure its not an "accidental"
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
    // KeySignature.scale[12] = C
    // KeySignature.scale[13] = CSharp
    // KeySignature.scale[14] = D
    // KeySignature.scale[15] = DSharp
    // KeySignature.scale[16] = E
    // KeySignature.scale[17] = F
    // KeySignature.scale[18] = FSharp
    all i:Int | {
        i < 0 => KeySignature.scale[i] = none
        i > 11 => KeySignature.scale[i] = none
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
    // majorChord[c] or majorSeventh[c] or neapolitan[c]  
    majorChord[c] or majorSeventh[c]

}

//no two chords are the same in a row
pred variedChords {
    //TODO: MAKE it so that checks to make sure each consecutive chord has one note with a different pitch,
    // and the prev one also has a pitch that the next doesnt have
    // the notes can be the same, but the pitch must be different
    //TODO: maybe clean up and write c2 = c.next
    all c:Chord | {
        some c.next => {
            singleNote[c] or
            singleNote[c.next] or
            (some n1, n2: Note | {
                n1 = c.root or n1 = c.third or n1 = c.fifth or n1 = c.seventh
                n2 = c.next.root or n2 = c.next.third or n2 = c.next.fifth or n2 = c.next.seventh
                n1.pitch != n2.pitch
            })
        }
    }
}

pred commonTones {
    all c:Chord | {
        some c.next => {
            singleNote[c] or
            singleNote[c.next] or
            (some n1, n2:Note | {
                n1 = c.root or n1 = c.third or n1 = c.fifth or n1 = c.seventh
                n2 = c.next.root or n2 = c.next.third or n2 = c.next.fifth or n2 = c.next.seventh
                n1.pitch = n2.pitch
            })
        }
    }
}



pred acceptableMajorNotes[c: Chord] {
    some c.root => {
        c.root.pitch = 0 or
        c.root.pitch = 2 or
        c.root.pitch = 4 or
        c.root.pitch = 5 or
        c.root.pitch = 7 or
        c.root.pitch = 9 or
        c.root.pitch = 11
    }
    some c.third => {
        c.third.pitch = 0 or
        c.third.pitch = 2 or
        c.third.pitch = 4 or
        c.third.pitch = 5 or
        c.third.pitch = 7 or
        c.third.pitch = 9 or
        c.third.pitch = 11
    }
    some c.fifth => {
        c.fifth.pitch = 0 or
        c.fifth.pitch = 2 or
        c.fifth.pitch = 4 or
        c.fifth.pitch = 5 or
        c.fifth.pitch = 7 or
        c.fifth.pitch = 9 or
        c.fifth.pitch = 11
    }
    some c.seventh => {
        c.seventh.pitch = 0 or
        c.seventh.pitch = 2 or
        c.seventh.pitch = 4 or
        c.seventh.pitch = 5 or
        c.seventh.pitch = 7 or
        c.seventh.pitch = 9 or
        c.seventh.pitch = 11
    }
}




pred ascendingFourNoteRun {
    //TODO: make sure that the notes are within an octave of each other
    some disj c1, c2, c3, c4: Chord | {
        singleNote[c1]
        singleNote[c2]
        singleNote[c3]
        singleNote[c4]

        c1.next = c2
        c2.next = c3
        c3.next = c4
        c1.length = -1
        c2.length = -1
        c3.length = -1
        c4.length = -1

        some disj n1, n2, n3, n4:Note | {
            c1.root = n1
            c2.root = n2
            c3.root = n3
            c4.root = n4
            //can't use 1 for difference
            add[multiply[11, n2.octave], n2.pitch] > add[multiply[11, n1.octave], n1.pitch]
            add[multiply[11, n3.octave], n3.pitch] > add[multiply[11, n2.octave], n2.pitch]
            add[multiply[11, n4.octave], n4.pitch] > add[multiply[11, n3.octave], n3.pitch]
        }

    }
}

pred descendingFourNoteRun {
    some disj c1, c2, c3, c4: Chord | {
        singleNote[c1]
        singleNote[c2]
        singleNote[c3]
        singleNote[c4]

        c1.next = c2
        c2.next = c3
        c3.next = c4
        c1.length = -1
        c2.length = -1
        c3.length = -1
        c4.length = -1

        some disj n1, n2, n3, n4:Note | {
            c1.root = n1
            c2.root = n2
            c3.root = n3
            c4.root = n4
            add[multiply[11, n2.octave], n2.pitch] < add[multiply[11, n1.octave], n1.pitch]
            add[multiply[11, n3.octave], n3.pitch] < add[multiply[11, n2.octave], n2.pitch]
            add[multiply[11, n4.octave], n4.pitch] < add[multiply[11, n3.octave], n3.pitch]
        }

    }
}

pred I_VI_IV_V {
    some disj c1, c2, c3, c4: Chord | {
        c1.type = IChord
        c2.type = VIChord
        c3.type = IVChord
        c4.type = VChord

        c1.next = c2
        c2.next = c3
        c3.next = c4
        c1.length = -1
        c2.length = -1
        c3.length = -1
        c4.length = -1
    }
}

pred I_V_VI_IV {
    some disj c1, c2, c3, c4: Chord | {
        c1.type = IChord
        c2.type = VChord
        c3.type = VIChord
        c4.type = IVChord

        c1.next = c2
        c2.next = c3
        c3.next = c4
        c1.length = -1
        c2.length = -1
        c3.length = -1
        c4.length = -1
    }
}


pred I_IV_VI_V {
    some disj c1, c2, c3, c4: Chord | {
        c1.type = IChord
        c2.type = IVChord
        c3.type = VIChord
        c4.type = VChord

        c1.next = c2
        c2.next = c3
        c3.next = c4
        c1.length = -1
        c2.length = -1
        c3.length = -1
        c4.length = -1
    }
}

// pred I_VII_III_VI {
//     some disj c1, c2, c3, c4: Chord | {
//         c1.type = IChord
//         c2.type = VIIChord
//         c3.type = IIIChord
//         c4.type = VIChord

//         c1.next = c2
//         c2.next = c3
//         c3.next = c4
//         c1.length = -1
//         c2.length = -1
//         c3.length = -1
//         c4.length = -1
//     }
// }

pred generateMusic {
    wellFormed
    // some c:Chord | { majorChord[c]}
    // some c:Chord | { majorSeventh[c]}
    // some c:Chord | { neapolitan[c]}
    // some c:Chord | {singleNote[c]}
    // all c: Chord | {
    //     (not definedChord[c]) => acceptableMajorNotes[c]
    // }
    ascendingFourNoteRun
    // descendingFourNoteRun

    // validChord progressions
    // all c:Chord | {
    //     some c.next => ValidChordProgression[c, c.next]
    // }


    cMajor
    variedChords
    commonTones
    //IS UNSAT vvv 
    // chordTypes
    I_VI_IV_V
    // I_V_VI_IV
    // I_IV_VI_V
    // I_VII_III_VI
}

run {generateMusic} for 7 Int, exactly 12 Note, exactly 16 Chord, exactly 1 KeySignature