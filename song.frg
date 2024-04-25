#lang forge
-- Signatures define the basic elements
abstract sig Tone {}
-- 12 total
one sig C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B extends Tone {}

abstract sig MajorKeySignature {
    var acceptableTones : set Tone,
}
-- 15 total
// one sig CMajor, GMajor, DMajor, AMajor, EMajor, BMajor, FSharpMajor, CSharpMajor, AFlatMajor, EFlatMajor, BFlatMajor, FMajor, DFlatMajor, GFlatMajor, CFlatMajor extends MajorKeySignature {}
//start with just 3 for simplicity
one sig CMajor, GMajor, DMajor extends MajorKeySignature {}

//cmajor: C, D, E, F, G, A, B
//gmajor: D, E, F#, G, A, B, C#
//dmajor: G, A, B, C, D, E, F#



sig Interval {}
-- 13 total
// one sig Unison, MinorSecond, MajorSecond, MinorThird, MajorThird, PerfectFourth, Tritone, PerfectFifth, MinorSixth, MajorSixth, MinorSeventh, MajorSeventh, Octave extends Interval {}
one sig Unison, MinorSecond, MajorSecond, MinorThird, MajorThird, PerfectFourth, Tritone, PerfectFifth, MinorSixth, MajorSixth, MinorSeventh, MajorSeventh, Octave extends Interval {}


sig Chord { tones: set Tone }
one sig MajorChord, MinorChord, DiminishedChord, AugmentedChord extends Chord {}


pred KeyConstraints {
    -- Define notes in C Major for simplicity
    all n: NoteInKeySignature | n.keySignature = CMajor => 
        (n.note in C + D + E + F + G + A + B)
}

pred ChordDefinitions {
    -- Example: C Major Chord
    MajorChord.notes = C + E + G
}

-- Define sequences of notes
sig Melody {
    notes: seq Note,
    key: KeySignature
}

-- Example constraints to form a valid melody
pred ValidMelody(m: Melody) {
    -- All notes are within the key signature
    all n: Note | n in m.notes.elems => some niks: NoteInKeySignature | niks.note = n and niks.keySignature = m.key
    -- Simple melodic progression: adjacent notes should be within an octave
    all i: Int, j: Int | i = j + 1 and i < #m.notes.elems and j >= 0 => 
        let n1 = m.notes.elems[i], n2 = m.notes.elems[j] | 
            some intv: Interval | (intv in MinorSecond + MajorSecond + MinorThird + MajorThird + PerfectFourth + PerfectFifth + MinorSixth + MajorSixth + MinorSeventh + MajorSeventh + Octave)
}

-- Generate music with specific constraints
pred generateMusic {
    some m: Melody | ValidMelody(m) and #m.notes.elems = 5
}



pred alwaysInTune {
   -- TODO: Fill me in!
    always 
}

-- Run command to generate examples
run generateMusic for exactly 5 Note, exactly 1 KeySignature, exactly 5 Interval, exactly 1 Chord