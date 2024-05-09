#lang forge
option solver Glucose

// RESOURCES USED:
//https://en.wikipedia.org/wiki/List_of_chords <-- USEFUL!!
//https://signal.vercel.app/edit <-- USEFUL!!

// ******************************************************* SIGS *******************************************************
// Tone sigs
// Each tone is a pitch, and each pitch is a number from 0-11 
// 0 = C, 1 = C#, 2 = D, 3 = D#, 4 = E, 5 = F, 6 = F#, 7 = G, 8 = G#, 9 = A, 10 = A#, 11 = B
// These int values are kept consistent throughout the program to represent the pitch of a note
// Not specifaclly used in the program, but useful for reference and understanding
abstract sig Tone {}
one sig A, ASharp, B, C, CSharp, D, DSharp, E, F, FSharp, G, GSharp extends Tone {}

// ChordType sigs
// Each chord type is a chord progression that is commonly used in music
// Generalized to I, V, VI, IV
// These are the most common chord progressions in music and are used in many songs
// There also exists other chord types such as IIIChord, but would complicate the model too much
abstract sig ChordType {}
// one sig CMajor, GMajor, AMinor, FMajor extends ChordType {}
one sig IChord, VChord, VIChord, IVChord extends ChordType {} // This is the most common chord progression in music

// Note sig
// Each note has a pitch and an octave
// The pitch is the note's position in the scale, and the octave helps to add more notes that are generated
sig Note {
    pitch: one Int,
    octave: one Int
}

// Chord sig
// Each chord has a length, a next chord, a chord type, and 4 notes
// The length is the duration of the chord, set to negative values to: TODO:
// The next chord is the chord that comes after the current chord
// The chord type is the type of chord that the chord is, and is one of the chord types defined above
// The root, third, fifth, and seventh are the notes that make up the chord 
// and can null to represent different types of chords under the same sig
sig Chord {
    length: one Int, //in 16th notes, so length of 4 means a quarter note
    next: lone Chord,
    type: lone ChordType,
    root: one Note, 
    third: lone Note,
    fifth: lone Note,
    seventh: lone Note
}

// Melody sig
// Each melody has a melodyNotes function that maps an int to a note
// This is used to generate a melody that fits the chords
one sig Melody {
    melodyNotes: pfunc Int -> Note
}

// ******************************************************* SEQUENCES *******************************************************
// We used the following sequences to help use understand how the song was generated
// This helps us understand the beginning and end of the song, and how the chords are connected to each other
one sig Song {
    songChords: pfunc Int -> Chord
}

// This sequences helps us to understand which notes are mapped to the int values in the model
one sig KeySignature {
    scale: pfunc Int -> Tone
}

// ******************************************************* PREDICATES *******************************************************
// The following predicates are used to help us generate the music

// Ensure the start of the song is a valid root and leads to a correct progression of chords
pred validRoot {
    some c: Chord | {
        // makes sure that the root note is a valid note
        majorChord[c] or c.root.pitch = 0

        // makes sure that all the chords are connected and reachable from the root
        all c1: Chord | {
            c1 != c => reachable[c1, c, next]
        }

        // defines the first 10 chords of the song in a sequence
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
}

// Ensure that the chords are not cyclical
pred nonCyclical {
    all c: Chord | {
        not reachable[c, c, next]
    }
}

// Ensure that the pitches and octaves of the notes are within the correct range we want
pred validPitchAndOctave {
    all n: Note | {
        n.pitch >= 0
        n.pitch <= 11
        n.octave >= 0
        n.octave <= 3
    }
}

// Ensure that the notes in the chords are different so we don't get repeated notes
pred differentPitches[c:Chord] {
    some c.third => (c.root.pitch != c.third.pitch)
    some c.fifth => (c.root.pitch != c.fifth.pitch and c.third.pitch != c.fifth.pitch)
    some c.seventh => (c.root.pitch != c.seventh.pitch and c.third.pitch != c.seventh.pitch and c.fifth.pitch != c.seventh.pitch)
}

// Define a chord with a valid length
pred validLength[c:Chord] {
    c.length < 0
    c.length >= -8
}

// Ensure that the chords are valid and fit the progression we want
pred validChords {
    all c: Chord | {
        c.root != none

        // makes sure that the length of the chord is within the correct range
        validLength[c]

        // ensures that the notes in the chord are different so we don't get repeated notes
        differentPitches[c]

        // makes sure that there are no 2-note chords
        some c.third iff some c.fifth

        // makes sure that if there is a seventh, there is a fifth and third
        some c.seventh => (some c.fifth and some c.third)

        // makes sure that the third is higher than the root, the fifth is higher than the third, and the seventh is higher than the fifth
        some c.third => add[multiply[11, c.third.octave], c.third.pitch] > add[multiply[11, c.root.octave], c.root.pitch]
        some c.fifth => add[multiply[11, c.fifth.octave], c.fifth.pitch] > add[multiply[11, c.third.octave], c.third.pitch]
        some c.seventh => add[multiply[11, c.seventh.octave], c.seventh.pitch] > add[multiply[11, c.fifth.octave], c.fifth.pitch]
    }
}

pred wellFormed {
    validRoot
    nonCyclical
    validPitchAndOctave
    validChords

    //Ensures notes are unique
    all n: Note | {
        all n1: Note | {
            n != n1 => not (n.pitch = n1.pitch and n.octave = n1.octave)
        }
    }

    // (sum c: Chord | sum[c.length]) = -32
}


// Given a chord type, set the pitches and octaves of the notes
// TODO: Incorporate this
pred validChordTypes {
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

// Define a major chord: a chord with a root, third, and fifth, often 0, 4, and 7
pred majorChord[c:Chord] {
    c.root.pitch = 0
    c.third.pitch = 4
    c.fifth.pitch = 7
    no c.seventh
}

// Define a major seventh chord: a chord with a root, third, fifth, and seventh, often 0, 4, 7, and 11
pred majorSeventh[c:Chord] {
    c.root.pitch = 0
    c.third.pitch = 4
    c.fifth.pitch = 7
    c.seventh.pitch = 11
}

//1 5 8 (this chord is not incorporated well, but its good we tried it)
pred neapolitan[c:Chord] {
    c.root.pitch = 1
    c.third.pitch = 5
    c.fifth.pitch = 8
    no c.seventh
}

// Determine if a chord has acceptable notes for a major chord
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

// Define a chord with only one note
pred singleNote[c:Chord] {
    some c.root
    no c.third
    no c.fifth
    no c.seventh

    //makes sure its not an "accidental"
    acceptableMajorNotes[c]
}

// TODO: Not used, delete?
pred definedChord[c:Chord] {
    // majorChord[c] or majorSeventh[c] or neapolitan[c]  
    majorChord[c] or majorSeventh[c]
}

pred variedChords {
    //checks to make sure each consecutive chord has one note with a different pitch
    all c:Chord | {
        some c.next => {
            singleNote[c]
            or
            singleNote[c.next] 
            or
            (some n1, n2: Note | {
                n1 = c.root or n1 = c.third or n1 = c.fifth or n1 = c.seventh
                n2 = c.next.root or n2 = c.next.third or n2 = c.next.fifth or n2 = c.next.seventh
                n1.pitch != n2.pitch
            })
        }
    }
}


// Predicate to make sure that consecutive chords have a shared note for better transitions
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

// Define a valid run of chords/notes that ascend in pitch
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
            c1.root = n1
            c2.root = n2
            c3.root = n3
            c4.root = n4
            add[multiply[11, n2.octave], n2.pitch] > add[multiply[11, n1.octave], n1.pitch]
            add[multiply[11, n3.octave], n3.pitch] > add[multiply[11, n2.octave], n2.pitch]
            add[multiply[11, n4.octave], n4.pitch] > add[multiply[11, n3.octave], n3.pitch]
        }
        //make sure that the notes are within an octave and a half of each other
        add[add[multiply[11, n1.octave], n1.pitch], 18] > add[multiply[11, n4.octave], n4.pitch]

    }
}

// Define a valid run of chords/notes that descend in pitch
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

// Define a valid progression of chords
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

// Define a valid progression of chords
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

// Define a valid progression of chords
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

// Ensure that the molody fits the chords, suhc that it has the same pitch as the root, third, fifth, or seventh of the corresponding chord
pred MelodyFitsChords {
    all i: Int | {
        some Song.songChords[i] => {
            let c = Song.songChords[i] {
                let n = Melody.melodyNotes[i] {
                    (n.pitch = c.root.pitch or n.pitch = c.third.pitch or n.pitch = c.fifth.pitch or n.pitch = c.seventh.pitch)
                    n.octave = c.root.octave
                }
            }
        }
    }
}

// Ensures that the difference in octaves is at most 1
pred SmoothMelody {
    all i: Int | {
        some Melody.melodyNotes[i] => {
            let n = Melody.melodyNotes[i] {
                let n1 = Melody.melodyNotes[i+1] {
                    add[multiply[11, n1.octave], n1.pitch] - add[multiply[11, n.octave], n.pitch] <= 1
                    add[multiply[11, n1.octave], n1.pitch] - add[multiply[11, n.octave], n.pitch] >= -1
                }
            }
        }
    }
}

// Defines the sequence of chords that show the mappings of tones to ints
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
        i > 11 => KeySignature.scale[i] = none
    }
}

pred generateMusic {
    wellFormed
    ascendingFourNoteRun
    // descendingFourNoteRun

    // TODO: Needed? If not, remove
    // all c:Chord | {
    //     some c.next => ValidChordProgression[c, c.next]
    // }

    // cMajor // For visualization purposes, not needed for testing

    // Ensure that the chords are varies and not repeated
    variedChords

    // Ensure that the chords have common tones
    commonTones
    
    // chordTypes //IS UNSAT TODO: FIX

    // Use the following chord progressions
    I_VI_IV_V
    I_V_VI_IV
    I_IV_VI_V

    // Creates a melody that fits the chords
    MelodyFitsChords
}

run {generateMusic} for 7 Int, exactly 12 Note, exactly 16 Chord, exactly 1 KeySignature