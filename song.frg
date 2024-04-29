#lang forge
-- Signatures define the basic elements
// abstract sig Tone {}

// rule of three
// -note -> chord -> chord progression
// key -> scale

// define the 12 tones
// one sig C, CSharp, D, DSharp, E, F, FSharp, G, GSharp, A, ASharp, B extends Tone {}
// C = 0, CSharp = 1, D = 2, DSharp = 3, E = 4, F = 5, FSharp = 6, G = 7, GSharp = 8, A = 9, ASharp = 10, B = 11

sig Note {
    tone: one Int,
    next: lone Note
}

// sig CMajorScale extends Note {}

sig Chord {
    root, third, fifth: one Note,
    nextChord: lone Chord
    // prevChord: lone Chord
}

pred ValidTone {
    all n: Note | n.tone >= 0 and n.tone < 12 and n.next != n
    // all n: Note | n.next != n.prev
}

pred CMajorScaleValid {
    // C = 0
    // D = 2
    // E = 4
    // F = 5
    // G = 7
    // A = 9
    // B = 11
    all n: Note | {
        n.tone = 0 => n.next.tone = 2 and
        n.tone = 2 => n.next.tone = 4 and
        n.tone = 4 => n.next.tone = 5 and
        n.tone = 5 => n.next.tone = 7 and
        n.tone = 7 => n.next.tone = 9 and
        n.tone = 9 => n.next.tone = 11 and
        n.tone = 11 => n.next.tone = 0 and
        n.tone != 1 and n.tone != 3 and n.tone != 6 and n.tone != 8 and n.tone != 10
    }
    // all n: Note | n.tone = 0 or n.tone = 2 or n.tone = 4 or n.tone = 5 or n.tone = 7 or n.tone = 9 or n.tone = 11
}

pred scaleRelationships {
    // ensure circular relationship
    all n: Note | reachable[n, n.next, next]
    
}
// chord progression

pred validChord {
    // major chord
    //2 + 1
    // find the min of the two things
    // min(a - b + 1 % 2, b - a + 13 % 2) = 1
    all c: Chord | {
        // remainder[min[add[subtract[c.third.tone, c.root.tone], 1], add[subtract[c.root.tone, c.third.tone], 13]], 2] = 1
        // remainder[min[add[subtract[c.fifth.tone, c.third.tone], 1], add[subtract[c.third.tone, c.fifth.tone], 13]], 2] = 1
        // add[subtract[c.third.tone, c.root.tone], 1] < add[subtract[c.root.tone, c.third.tone], 13] => remainder[add[subtract[c.third.tone, c.root.tone], 1], 2] = 0 else remainder[add[subtract[c.root.tone, c.third.tone], 13], 2] = 0
        // add[subtract[c.fifth.tone, c.third.tone], 1] < add[subtract[c.third.tone, c.fifth.tone], 13] => remainder[add[subtract[c.fifth.tone, c.third.tone], 1], 2] = 0 else remainder[add[subtract[c.third.tone, c.fifth.tone], 13], 2] = 0

        c.root.tone = 0 => c.third.tone = 4 and c.fifth.tone = 7 and
        c.root.tone = 2 => c.third.tone = 5 and c.fifth.tone = 9 and
        c.root.tone = 4 => c.third.tone = 7 and c.fifth.tone = 11 and
        c.root.tone = 5 => c.third.tone = 9 and c.fifth.tone = 0 and
        c.root.tone = 7 => c.third.tone = 11 and c.fifth.tone = 2 and
        c.root.tone = 9 => c.third.tone = 0 and c.fifth.tone = 4 and
        c.root.tone = 11 => c.third.tone = 2 and c.fifth.tone = 5 and
        c.root.tone != 1 and c.root.tone != 3 and c.root.tone != 6 and c.root.tone != 8 and c.root.tone != 10 and
        c.third.tone != 1 and c.third.tone != 3 and c.third.tone != 6 and c.third.tone != 8 and c.third.tone != 10 and
        c.fifth.tone != 1 and c.fifth.tone != 3 and c.fifth.tone != 6 and c.fifth.tone != 8 and c.fifth.tone != 10 and
        no c.fifth.next

    }

    // all the notes are different
    all c: Chord | c.root.tone != c.third.tone and c.root.tone != c.fifth.tone and c.third.tone != c.fifth.tone
}

pred ValidChordProgression[c1: Chord, c2: Chord] {
    c1.root.tone = 0 or c1.root.tone = 2 or c1.root.tone = 7
    c1.root.tone = 0 => c2.root.tone = 7
    c1.root.tone = 2 => c2.root.tone = 7
    c1.root.tone = 7 => c2.root.tone = 0
}

pred ChordProgression {
    all c: Chord | some c.nextChord => ValidChordProgression[c, c.nextChord]  
    all c: Chord | reachable[c, c.nextChord, nextChord]
}

pred NonRepetitiveProgression {
    all c: Chord | c.nextChord != none => (c != c.nextChord)
}


pred gernerateMusic {
    CMajorScaleValid and ValidTone and scaleRelationships and validChord and ChordProgression and NonRepetitiveProgression
}

run {gernerateMusic} for 5 Int, exactly 4 Chord, exactly 12 Note