/**
    Written by Jared McLaughlin ( jared.p.mclaughlin@gmail.com ) and David Scutar.
    
    No license claimed, copy and modify at will.
*/

description = "OSAI/Leonardo";
vendor = "OSAI";

longDescription = "Post processor for a waterjet running an OSAI controller.";
extension = "nc";
setCodePage("ascii");

capabilities = CAPABILITY_JET;
tolerance = spatial(0.002, MM);

minimumChordLength = spatial(0.25, MM);
minimumCircularRadius = spatial(.01, MM);
maximumCircularRadius = spatial(1000, MM);
minimumCircularSweep = toRad(0.01);
maximumCircularSweep = toRad(180);
allowHelicalMoves = false;
allowedCircularPlanes = 1 << PLANE_XY; // 

// user-defined properties
properties = {
  writeMachine: {
    title: "Write machine",
    description: "Output the machine settings in the header of the code.",
    group: 0,
    type: "boolean",
    value: true,
    scope: "post"
  },
  showSequenceNumbers: {
    title: "Use sequence numbers",
    description: "Use sequence numbers for each block of outputted code.",
    group: 1,
    type: "boolean",
    value: true,
    scope: "post"
  },
  sequenceNumberStart: {
    title: "Start sequence number",
    description: "The number at which to start the sequence numbers.",
    group: 1,
    type: "integer",
    value: 10,
    scope: "post"
  },
  sequenceNumberIncrement: {
    title: "Sequence number increment",
    description: "The amount by which the sequence number is incremented by in each block.",
    group: 1,
    type: "integer",
    value: 1,
    scope: "post"
  },
  separateWordsWithSpace: {
    title: "Separate words with space",
    description: "Adds spaces between words if 'yes' is selected.",
    type: "boolean",
    value: true,
    scope: "post"
  }
};

// need to have the ability to write comments to start
function writeComment(text){
    writeln(";"+ String(text).toUpperCase());
}

// write blocks with sequence number to output file
function writeBlock() {
  if (getProperty("showSequenceNumbers")) {
    writeWords2("N" + sequenceNumber, arguments);
    sequenceNumber += getProperty("sequenceNumberIncrement");
  } else {
    writeWords(arguments);
  }
}

function onOpen(){
    // write the initial comments
   /* from the post manual:
    1. Define settings based on properties
    2. Define multi-axis configuration
    3. Output program name and header
    4. Perform checks for duplicate tools and work offsets
    5. Output initial startup codes
   */

    // #3 Ouput program name and header.
    // Copied from post-processor manual
    // According to OSAI manual, program names can be 48 characters

    sequenceNumber = getProperty("sequenceNumberStart");

    if(programName){
        writeComment(programName);
    }
    if(programComment){
        writeComment(programComment);
    }

    /* 
        Current run info.
    */

    if(hasParameter("generated-by")&&getParameter("generated-by")){
        writeComment("    "+localize("CAM")+":"+getParamter("generated-by"));
    }

     if(hasParameter("document-path")&&getParameter("document-path")){
        writeComment("    :"+getParamter("document-path"));
    }

    writeComment("    "+"OSAIPost v0.1 by J.McLaughlin and David Scutar.");
    writeComment("    "+"jared.p.mclaughlin@gmail.com");

    var d = new Date(); // current date and time
    writeComment(" NC program genereated at : ");
    writeComment("    "+localize("Date")+":"+d.toLocaleDateString() +" "+d.toLocaleTimeString());

    // #5. Output initial startup codes
    writeBlock("G01 F1000") //setting feedrate
    writeBlock("E100=2") //defining local variables. the cnc probably needs them to operate.
    writeBlock("E101=1")
    writeBlock("E102=0.65")
}

function onLinear(_x,_y,_z,feed){
    //var x = xOutput.format(_x);
    //var y = yOutput.format(_y);
    //var z = zOutput.format(_z);
    //var f = getFeed(feed);

    // we'll have to deal with kerf in here
    // spit everything out to start with
    writeln("G01 "+" X"+_x+" Y"+_y+" Z"+_z+" F"+feed);

}

function onClose(){
    writeln("");

    // making this close correlation with the original Lisp post
    // with the intent to modify later 
    writeln("G00 X-1 Y1218");
    writeln("(DLY,1)");
    writeln("M2");
    writeln("%");
}
