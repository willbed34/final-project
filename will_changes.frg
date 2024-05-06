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
    notes: set Note,
    pitches: set Int,
    first: lone Note,
    last: lone Note,
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord,
    type: one ChordType,
    chordOctave: one Int

    //should it have a name?
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
       ( majorChord[c] or c.first.pitch = 0)
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

        //change later
        n.octave = 1
    }

    all c:Chord | {
        c.first != none
        // c.first in c.notes
        c.last != none
        // c.last in c.notes

        all n: c.notes | {
            n.pitch in c.pitches
        }

        // c.first.pitch in c.pitches
        // c.last.pitch in c.pitches
        // c.first.pitch < c.last.pitch
        // c.first.pitch = min[c.pitches]
        // c.last.pitch = max[c.pitches]

        // valid length
        // (c.length = -4 or c.length = -8)
        c.length < 0
        c.length >= -8

        all p: c.pitches | {
            p >= 0
            p <= 11
        }

        c.chordOctave >= 0
        c.chordOctave <= 3

    }

    all n: Note | {
        all n1: Note | {
            n != n1 => n.pitch != n1.pitch
        }
    }

    // (sum c: Chord | sum[c.length]) = -32
}

//valid chords
pred chordTypes {
    c.type = IChord implies {
        c.first.pitch = 0
        c.last.pitch = 7
    }
    c.type = VChord implies {
        c.first.pitch = 7
        c.last.pitch = 2
    }
    c.type = VIChord implies {
        c.first.pitch = 9
        c.last.pitch = 4
    }
    c.type = IVChord implies {
        c.first.pitch = 5
        c.last.pitch = 0
    }
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

//1 5 8 (this chord sucks, but its good we tried it)
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
    // majorChord[c] or majorSeventh[c] or neapolitan[c]  
    majorChord[c] or majorSeventh[c]

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

pred commonTones {
    all c:Chord | {
        some c.next => {
            not singleNote[c] and not singleNote[c.next] => {
                some p: c.pitches | {
                    p in c.next.pitches
                }
            }
        }
    }
}



pred acceptableMajorNotes[c: Chord] {
    all n: c.notes | {
        n.pitch = 0 or
        n.pitch = 2 or
        n.pitch = 4 or
        n.pitch = 5 or
        n.pitch = 7 or
        n.pitch = 9 or
        n.pitch = 11
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

// pred ValidGMajorNotes[c: Chord] {
//     all n: c.notes | {
//         n.pitch = 7 or
//         n.pitch = 9 or
//         n.pitch = 11 or
//         n.pitch = 12 or
//         n.pitch = 14 or
//         n.pitch = 16
//     }
// }

// pred ValidAMinorNotes[c: Chord] {
//     all n: c.notes | {
//         n.pitch = 9 or
//         n.pitch = 11 or
//         n.pitch = 12 or
//         n.pitch = 14 or
//         n.pitch = 16 or
//         n.pitch = 17
//     }
// }

// pred ValidFMajorNotes[c: Chord] {
//     all n: c.notes | {
//         n.pitch = 5 or
//         n.pitch = 7 or
//         n.pitch = 9 or
//         n.pitch = 10 or
//         n.pitch = 12 or
//         n.pitch = 14
//     }
// }


//things to add 
//1: preds for chord progression in certain genres
pred ValidChordProgression[c1: Chord, c2: Chord] {
    // // (c1.root.tone = 0 or c1.root.tone = 2 or c1.root.tone = 7)
    // c1.last.pitch = 0 => c2.first.pitch = 7
    // c1.last.pitch = 2 => c2.first.pitch = 7
    // c1.last.pitch = 4 => c2.first.pitch = 7
    // c1.last.pitch = 5 => c2.first.pitch = 7
    // c1.last.pitch = 9 => c2.first.pitch = 7
    // c1.last.pitch = 11 => c2.first.pitch = 7
    // c1.last.pitch = 7 => (c2.first.pitch = 0 or c2.first.pitch = 2 or c2.first.pitch = 4 or c2.first.pitch = 5 or c2.first.pitch = 9 or c2.first.pitch = 11)
    abs[subtract[c1.chordOctave, c2.chordOctave]] <= 1

    (c1.type = CMajor => c1.first.pitch = 0 and c1.last.pitch = 7)
    (c1.type = GMajor => c1.first.pitch = 7 and c1.last.pitch = 2)
    (c1.type = AMinor => c1.first.pitch = 9 and c1.last.pitch = 4)
    (c1.type = FMajor => c1.first.pitch = 5 and c1.last.pitch = 0)

    (c1.type = CMajor and c2.type = GMajor) implies c1.last = 0 and c2.first = 7
    (c1.type = CMajor and c2.type = AMinor) implies c1.last = 0 and c2.first = 9
    (c1.type = CMajor and c2.type = FMajor) implies c1.last = 0 and c2.first = 5
    (c1.type = GMajor and c2.type = CMajor) implies c1.last = 7 and c2.first = 0
    (c1.type = GMajor and c2.type = AMinor) implies c1.last = 7 and c2.first = 9
    (c1.type = GMajor and c2.type = FMajor) implies c1.last = 7 and c2.first = 5
    (c1.type = AMinor and c2.type = CMajor) implies c1.last = 9 and c2.first = 0
    (c1.type = AMinor and c2.type = GMajor) implies c1.last = 9 and c2.first = 7
    (c1.type = AMinor and c2.type = FMajor) implies c1.last = 9 and c2.first = 5
    (c1.type = FMajor and c2.type = CMajor) implies c1.last = 5 and c2.first = 0
    (c1.type = FMajor and c2.type = GMajor) implies c1.last = 5 and c2.first = 7
    (c1.type = FMajor and c2.type = AMinor) implies c1.last = 5 and c2.first = 9

}

pred ascendingFourNoteRun {
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
            n1 in c1.notes
            n2 in c2.notes
            n3 in c3.notes
            n4 in c4.notes
            //can't use 1 for difference
            multiply[n2.pitch, n2.octave] > multiply[n1.pitch, n1.octave]
            multiply[n3.pitch, n3.octave] > multiply[n2.pitch, n2.octave]
            multiply[n4.pitch, n4.octave] > multiply[n3.pitch, n3.octave]
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
            n1 in c1.notes
            n2 in c2.notes
            n3 in c3.notes
            n4 in c4.notes
            //can't use 1 for difference
            multiply[n2.pitch, n2.octave] < multiply[n1.pitch, n1.octave]
            multiply[n3.pitch, n3.octave] < multiply[n2.pitch, n2.octave]
            multiply[n4.pitch, n4.octave] < multiply[n3.pitch, n3.octave]
        }

    }
}

pred generateMusic {
    wellFormed
    validChords
    some c:Chord | { majorChord[c]}
    some c:Chord | { majorSeventh[c]}
    // some c:Chord | { neapolitan[c]}
    // some c:Chord | {singleNote[c]}
    all c: Chord | {
        (not definedChord[c]) => acceptableMajorNotes[c]
    }
    ascendingFourNoteRun
    // descendingFourNoteRun

    // validChord progressions
    all c:Chord | {
        some c.next => ValidChordProgression[c, c.next]
    }

    // cMajor
    variedChords
    commonTones

}

run {generateMusic} for 7 Int, exactly 12 Note, exactly 10 Chord, exactly 1 KeySignature