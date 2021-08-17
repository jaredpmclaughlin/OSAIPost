/**
    Written by Jared McLaughlin ( jared.p.mclaughlin@gmail.com )
    
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


// need to have the ability to write comments to start
function writeComment(text){
    writeln(";"+ filterText(String(text).toUpperCase(), permittedCommentChars));
}

// this runs first?
// this _could_ correlate to the header
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

    writeComment("    "+"OSAIPost v0.1 by J.McLaughlin");
    writeComment("    "+"jared.p.mclaughlin@gmail.com");

    var d = new Date(); // current date and time
    writeComment("    "+localize("Date")+":"+d.toLocaleDateString() +" "+d.toLocaleTimeString());
}
