#lang forge
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
            x.octave = 3 and
            y.octave = 4 
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
                x.third.octave = 1 and 
                x.fifth.octave = 1 and
                x.seventh.octave = 1) and validChords
        } for 7 Int is unsat

        misArrangedOctave: {
            (some x: Chord | 
                x.root.pitch = 0 and
                x.third.pitch = 5 and 
                x.fifth.pitch = 7 and
                x.seventh.pitch = 8 and
                x.root.octave = 4 and
                x.third.octave = 1 and 
                x.fifth.octave = 1 and
                x.seventh.octave = 6) and validChords
        } for 7 Int is unsat
    }
}

test suite for wellFormed {
    test expect {
        wellFormedTest : {
            some disj n1, n2, n3: Note | {
                n1.pitch = 0
                n2.pitch = 4
                n3.pitch = 7

                wellFormed
            }
        } for 7 Int is sat
        // wellFormedTestUnsat : {
        // } for 7 Int is unsat
    }
}

test suite for acceptableMajorNotes {
    test expect {
        acceptableMajorNotesTest : {
            some c: Chord | {
                c.root.pitch = 0
                c.third.pitch = 4
                c.fifth.pitch = 7

                acceptableMajorNotes[c]
            }
        } for 7 Int is sat
        acceptableMajorNotesTest2 : {
            some c: Chord | {
                c.root.pitch = 0
                c.third.pitch = 4
                c.fifth.pitch = 8

                acceptableMajorNotes[c]
            }
        } for 7 Int is unsat
    }
}

test suite for variedChords {
    test expect {
        // variedChordsTestUnsat : {
        // } for 7 Int is unsat
        variedChordsTest : {
            some disj c1, c2: Chord | {
                c1.next = c2
                c2.next = c1.next

                variedChords
            }
        } for 7 Int is sat
    }
}

test suite for commonTones {
    test expect {
        commonTonesTest : {
            some disj n1, n2: Note | {
                n1.pitch = 0
                n2.pitch = 0

                commonTones
            }
        } for 7 Int is sat
        // commonTonesTestUnsat : {
        // } for 7 Int is unsat
    }
}

test suite for ascendingFourNoteRun {
    test expect {
        ascendingFourNoteRunTest : {
            some disj n1, n2, n3, n4: Note | {
                n1.pitch = 0
                n2.pitch = 1
                n3.pitch = 2
                n4.pitch = 3

                ascendingFourNoteRun
            }
        } for 7 Int is sat
        // ascendingFourNoteRunTestUnsat : {
        // } for 7 Int is unsat
    }
}

test suite for validChordTypes {
    test expect {
        validChordTypesTest : {
            some c: Chord | {
                c.type = IChord
                c.root.pitch = 0
                c.third.pitch = 4
                c.fifth.pitch = 7
                c.root.octave = c.third.octave
                c.third.octave = c.fifth.octave

                validChordTypes
            }
        } for 7 Int is sat
        validChordTypesTestUnsat : {
            some c: Chord | {
                c.type = IChord
                c.root.pitch = 0
                c.third.pitch = 4
                c.fifth.pitch = 8
                c.root.octave = c.third.octave
                c.third.octave = c.fifth.octave

                validChordTypes
            }
        } for 7 Int is unsat
    }
}

test suite for I_VI_IV_V {
    test expect {
        I_VI_IV_VTest : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = VIChord
                c3.type = IVChord
                c4.type = VChord

                c1.next = c2
                c2.next = c3
                c3.next = c4

                I_VI_IV_V
            }
        } for 7 Int is sat
        I_VI_IV_VTestUnsat : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = VIChord
                c3.type = IVChord
                c4.type = VChord

                c1.next = c2
                c2.next = c3
                c3.next = c1

                I_VI_IV_V
            }
        } for 7 Int is unsat
    }
}

test suite for I_V_VI_IV {
    test expect {
        I_V_VI_IVTest : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = VChord
                c3.type = VIChord
                c4.type = IVChord

                c1.next = c2
                c2.next = c3
                c3.next = c4

                I_V_VI_IV
            }
        } for 7 Int is sat
        I_V_VI_IVTestUnsat : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = VChord
                c3.type = VIChord
                c4.type = IVChord

                c1.next = c2
                c2.next = c3
                c3.next = c1

                I_V_VI_IV
            }
        } for 7 Int is unsat
    }
}

test suite for I_IV_VI_V {
    test expect {
        I_IV_VI_VTest : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = IVChord
                c3.type = VIChord
                c4.type = VChord

                c1.next = c2
                c2.next = c3
                c3.next = c4

                I_IV_VI_V
            }
        } for 7 Int is sat
        I_IV_VI_VTestUnsat : {
            some disj c1, c2, c3, c4: Chord | {
                c1.type = IChord
                c2.type = IVChord
                c3.type = VIChord
                c4.type = VChord

                c1.next = c2
                c2.next = c3
                c3.next = c1

                I_IV_VI_V
            }
        } for 7 Int is unsat
    }
}

// test suite for MelodyFitsChords {
//     test expect {
//         MelodyFitsChordsTest : {
//         } is sat
//         MelodyFitsChordsTestUnsat : {
//         } is unsat
//     }
// }

test suite for SmoothMelody {
    // If you have tests for this predicate, put them here!
    test expect {
        SmoothMelodyTest : {
            some disj n1, n2: Note | {
                n1.pitch = 0
                n2.pitch = 1
                n1.octave = 3
                n2.octave = 4

                SmoothMelody
            }
        } for 7 Int is sat
        // SmoothMelodyTestUnsat : {
        // } for 7 Int is unsat
    }
}

// test suite for enoughMelodyNotes {
//     test expect {
//         enoughMelodyNotesTest : {
//         } for 7 Int is sat
//         enoughMelodyNotesTestUnsat : {
//         } for 7 Int is unsat
//     }
// }

test suite for cMajor {
    test expect {
        cMajorTest : {
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

            cMajor
        } for 7 Int is sat
    }
}

// takes a long time to run
// test suite for generateMusic {
//     // If you have tests for this predicate, put them here!
//     test expect {
//         generateMusicTest : {
//             generateMusic
//         } for 8 Int, exactly 12 Note, exactly 16 Chord, exactly 1 KeySignature is sat
//     }
// }