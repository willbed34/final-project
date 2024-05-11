d3 = require("d3");
require("tone");

d3.selectAll("svg > *").remove();

const chorus = new tone.Chorus(2, 2.5, 0.5).start().toDestination();
const synth = new tone.PolySynth().toDestination(); 

const notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];

const position = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6];

const isSharp = [
  false,
  true,
  false,
  true,
  false,
  false,
  true,
  false,
  true,
  false,
  true,
  false,
];

const bottom = 400;
const top = 300;
const left = 20;
const right = 365;
const w = 15;

function drawStaff() {
  let i;
  for (i = 0; i < 5; i++) {
    let yB = bottom - i * w - w;
    let yT = top - i * w - w;
    d3.select(svg)
      .append("line")
      .attr("x1", left)
      .attr("y1", yB)
      .attr("x2", left + right)
      .attr("y2", yB)
      .attr("stroke", "black");

    d3.select(svg)
      .append("line")
      .attr("x1", left)
      .attr("y1", yT)
      .attr("x2", left + right)
      .attr("y2", yT)
      .attr("stroke", "black");
  }
  d3.select(svg)
    .append("text")
    .attr("x", left)
    .attr("y", top)
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "120px") 
    .text("𝄞");
  d3.select(svg)
    .append("text")
    .attr("x", left)
    .attr("y", bottom - 1.5 * w) 
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "80px") 
    .text("𝄢");
  d3.select(svg)
    .append("line")
    .attr("x1", left)
    .attr("y1", top - w * 5)
    .attr("x2", left)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
  d3.select(svg)
    .append("line")
    .attr("x1", left + right)
    .attr("y1", top - w * 5)
    .attr("x2", left + right)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
  d3.select(svg)
    .append("line")
    .attr("x1", left + right - 5)
    .attr("y1", top - w * 5)
    .attr("x2", left + right - 5)
    .attr("y2", bottom - w)
    .attr("stroke", "black");
}

function getYPos(totalY) {
  var y;

  if (totalY <= 13) {
    y = bottom + 1 * w - totalY * (w / 2);
  } else {
    y = top + 6.5 * w - (totalY - 1) * (w / 2);
  }
  return y;
}

function drawEigth(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + 5)
    .attr("y1", y)
    .attr("x2", x + 8)
    .attr("y2", y - 30) 
    .attr("stroke", "black")
    .attr("stroke-width", 2);

  d3.select(svg)
    .append("path")
    .attr(
      "d",
      `M ${x + 8}, ${y - 30} C ${x + 12}, ${y - 35} ${x + 10}, ${y - 45} ${
        x + 8
      }, ${y - 40}`
    )
    .attr("stroke", "black")
    .attr("stroke-width", 2)
    .attr("fill", "none");
}

function drawQuarter(x, y, down) {
  var stemY = -30;
  var stemX = 5;

  if (down) {
    stemY = 30;
    stemX = -5;
  }

  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + stemX)
    .attr("y1", y)
    .attr("x2", x + stemX)
    .attr("y2", y + stemY) 
    .attr("stroke", "black")
    .attr("stroke-width", 2);
}

function drawHalf(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "black")
    .attr("stroke", "transparent")
    .attr("stroke-width", 3)
    .attr("transform", `rotate(-15, ${x}, ${y})`);

  // Draw stem (line)
  d3.select(svg)
    .append("line")
    .attr("x1", x + 5)
    .attr("y1", y)
    .attr("x2", x + 8)
    .attr("y2", y - 30)
    .attr("stroke", "black")
    .attr("stroke-width", 2);
}

function drawFull(x, y) {
  // Draw notehead (ellipse)
  d3.select(svg)
    .append("ellipse")
    .attr("cx", x)
    .attr("cy", y)
    .attr("rx", 6)
    .attr("ry", 4)
    .attr("fill", "transparent")
    .attr("stroke", "black")
    .attr("stroke-width", 3)
    .attr("transform", `rotate(-15, ${x}, ${y})`);
}

function drawSharp(x, y) {
  d3.select(svg)
    .append("text")
    .attr("x", x - 14)
    .attr("y", y + 5)
    .attr("fill", "black")
    .attr("font-family", "Arial, sans-serif")
    .attr("font-size", "15px")
    .text("#");
}

function drawSlash(x, y) {
  const slashLength = 18; // Length of the slash
  const slashOffset = slashLength / 2; // Half length for symmetric positioning
  var yPos;
  var yPos2;

  if (y == "bbb") {
    yPos = bottom + w;
    yPos2 = bottom;
  }

  if (y == "bb") {
    yPos2 = bottom;
  }

  if (y == "tb") {
    yPos = top;
  }

  if (y == "tt") {
    yPos = top - 6 * w;
  }

  d3.select(svg)
    .append("line")
    .attr("x1", x - slashOffset)
    .attr("y1", yPos)
    .attr("x2", x + slashOffset)
    .attr("y2", yPos)
    .attr("stroke", "black")
    .attr("stroke-width", 2); 
  d3.select(svg)
    .append("line")
    .attr("x1", x - slashOffset)
    .attr("y1", yPos2)
    .attr("x2", x + slashOffset)
    .attr("y2", yPos2)
    .attr("stroke", "black")
    .attr("stroke-width", 2);
}

function drawNote(note, idx) {
  const basePosition = position[note.pitch.toString()];
  const octaveAdjustment = (note.octave.toString() - 2) * 7;
  const totalY = basePosition + octaveAdjustment;

  var x = left + 55 + idx * 30;
  var y = getYPos(totalY);
  var down = true;

  if (totalY >= 14) {
    down = false;
  }

  if (totalY == 0) {
    drawSlash(x, "bbb");
  }

  if (totalY == 2) {
    drawSlash(x, "bb");
  }

  if (totalY == 14) {
    drawSlash(x, "tb");
  }

  if (totalY == 26) {
    drawSlash(x, "tt");
  }

  var sharp = isSharp[note.pitch.toString()];

  if (sharp) {
    drawSharp(x, y);
  }

  drawQuarter(x, y, down);
  // if (length.equals(-6)) {
  //   drawEigth(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if(length.equals(-4)){
  //     drawQuarter(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(0)) {
  //   drawHalf(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(16)) {
  //   drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else if (length.equals(16)) {
  //   drawFull(left + 50 + idx * 30, bottom - positionY * (w / 2), isBass);
  // }else{

  // }
}

function drawNotes(chords, melody) {
  chords.forEach((chord, idx) => {
    if (!chord.root.empty()) {
      drawNote(chord.root, idx);
    }

    if (!chord.third.empty()) {
      drawNote(chord.third, idx);
    }

    if (!chord.fifth.empty()) {
      drawNote(chord.fifth, idx);
    }

    if (!chord.seventh.empty()) {
      drawNote(chord.seventh, idx);
    }
  });

  melody.forEach((note, idx) => {
    if (!note.empty()) {
      drawNote(note, idx);
    }
  });
}

function constructVisualization(chords, melody) {
  drawStaff();
  drawNotes(chords, melody);
}

function fam(expr) {
  if (!expr.empty()) return expr.tuples()[0].atoms()[0];
  return "none";
}

function getNoteFromInt(intValue) {
  if (intValue >= 0 && intValue <= 11) {
    return notes[intValue];
  } else {
    return null;
  }
}

function playChords(chords, melody) {
  const now = tone.now();
  let i;
  synth.set({ detune: -1200 });

  for (i = 0; i < chords.length; i++) {
    var root;
    var third;
    var fifth;
    var seventh;
    var melodyNote;
    if (!chords[i].root.empty()) {
      root =
        getNoteFromInt(chords[i].root.pitch.toString()) +
        chords[i].root.octave.toString();
    }
    if (!chords[i].third.empty()) {
      third =
        getNoteFromInt(chords[i].third.pitch.toString()) +
        chords[i].third.octave.toString();
    }
    if (!chords[i].fifth.empty()) {
      fifth =
        getNoteFromInt(chords[i].fifth.pitch.toString()) +
        chords[i].fifth.octave.toString();
    }
    if (!chords[i].seventh.empty()) {
      seventh =
        getNoteFromInt(chords[i].seventh.pitch.toString()) +
        chords[i].seventh.octave.toString();
    }
    if (!melody[i].pitch.empty()) {
      melodyNote = getNoteFromInt(melody[i].pitch.toString()) + "4";
    }

    synth.triggerAttackRelease(
      [root, third, fifth, seventh, melodyNote],
      "8n",
      now + i * 0.5
    );
  }
}

function build(Chord, Melody) {
  const chord = Chord.atoms().map((ltup) => fam(ltup))[0];
  const m = Melody.atoms().map((ltup) => fam(ltup))[0];
  var chords = [];
  var melody = [];
  for (let i = 0; i < 10; i++) {
    melody.push(m.melodyNotes[i]);
    chords.push(chord.songChords[i]);
  }
  constructVisualization(chords, melody);
  playChords(chords, melody);
}

build(Song, Melody);
