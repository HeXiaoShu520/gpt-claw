import QtQuick

// Follows the companion's clock. No extra timer, window or input surface.
Canvas {
    id: feedback
    property real clock: 0
    property string pose: "idle"
    property real motionX: 0
    property real motionY: 0
    property vector3d headPosition: Qt.vector3d(0, 0, 0)
    property bool effectsEnabled: true
    property string reactionCaption: ""
    property var bubbles: []
    property var bursts: []
    property real lastClock: -1
    property real lastSpawn: -1
    property int sequence: 0
    property real poseStart: 0

    onPoseChanged: { poseStart = clock; requestPaint() }
    onEffectsEnabledChanged: { bubbles = []; bursts = []; requestPaint() }
    onClockChanged: advance()

    function bubbleIndex(x, y) {
        if (!effectsEnabled) return -1;
        for (let i=bubbles.length-1; i>=0; --i) {
            const b=bubbles[i];
            if (Math.hypot(x-b.x,y-b.y) <= b.radius*(.7+b.age/.8*.5)+5) return i;
        }
        return -1;
    }
    function popBubble(x, y) {
        const index=bubbleIndex(x,y);
        if (index < 0) return false;
        const alive=bubbles.slice(), b=alive.splice(index,1)[0];
        bubbles=alive;
        bursts=bursts.concat([{x:b.x,y:b.y,radius:b.radius,age:0,cyan:b.cyan}]);
        requestPaint();
        return true;
    }

    function advance() {
        if (clock < lastClock) { bubbles = []; bursts = []; lastSpawn = -1; poseStart = clock }
        const dt = lastClock < 0 ? 0 : Math.min(.1, Math.max(0, clock-lastClock));
        lastClock = clock;
        if (!effectsEnabled) return;
        const wasVisible = bubbles.length > 0 || bursts.length > 0;
        bursts=bursts.filter(function(b) { b.age+=dt; return b.age<.22; });
        let alive = [];
        for (let i=0; i<bubbles.length; ++i) {
            const b = bubbles[i];
            b.age += dt;
            b.x += (-motionX+b.drift)*dt;
            b.y += (-motionY-height*.055)*dt;
            if (b.age < .8) alive.push(b);
        }
        if (pose === "walk" && Math.hypot(motionX, motionY) > 8
                && clock-lastSpawn >= .15) {
            const n = sequence++;
            alive.push({x: width*(.5-(motionX>=0?1:-1)*.11),
                        y: height*(.69+.025*Math.sin(n*2.4)),
                        radius: width*(.008+.003*(1+Math.sin(n*1.7))),
                        age: 0, drift: width*.018*Math.sin(n*2.1), cyan: n%3===0});
            lastSpawn = clock;
        }
        bubbles = alive.slice(-12);
        if (wasVisible || bubbles.length || bursts.length || pose === "dizzy") requestPaint();
    }

    onPaint: {
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        if (!effectsEnabled) return;
        for (let i=0; i<bubbles.length; ++i) {
            const b = bubbles[i], p = b.age/.8;
            ctx.globalAlpha = Math.min(1,b.age/.08)*(1-p)*.65;
            ctx.strokeStyle = b.cyan ? "#9de7ed" : "#d1b6f5";
            ctx.fillStyle = b.cyan ? "#9de7ed" : "#d1b6f5";
            ctx.lineWidth = Math.max(1,width/420);
            ctx.beginPath(); ctx.arc(b.x,b.y,b.radius*(.7+p*.5),0,Math.PI*2);
            ctx.stroke();
            ctx.globalAlpha *= .2; ctx.fill();
        }
        for (let i=0; i<bursts.length; ++i) {
            const b=bursts[i], p=b.age/.22;
            ctx.globalAlpha=(1-p)*.8;
            ctx.strokeStyle=b.cyan ? "#9de7ed" : "#d1b6f5";
            for (let j=0; j<6; ++j) {
                const a=j*Math.PI/3, r=b.radius*(1+p*1.3);
                ctx.beginPath();
                ctx.moveTo(b.x+Math.cos(a)*r,b.y+Math.sin(a)*r);
                ctx.lineTo(b.x+Math.cos(a)*(r+3*(1-p)),b.y+Math.sin(a)*(r+3*(1-p)));
                ctx.stroke();
            }
        }
        if (pose === "dizzy") {
            const t = Math.max(0,clock-poseStart);
            ctx.globalAlpha = Math.max(0,Math.min(1,t/.18)*Math.min(1,(2.2-t)/.25))*.9;
            for (let i=0; i<3; ++i) {
                const a=t*3+i*Math.PI*2/3;
                const x=headPosition.x+Math.cos(a)*width*.115;
                const y=headPosition.y-height*.16+Math.sin(a)*height*.018;
                const r=width*.013;
                ctx.fillStyle=i===1?"#9de7ed":"#f3dfa5";
                ctx.beginPath();
                for (let j=0; j<10; ++j) {
                    const angle=-Math.PI/2+j*Math.PI/5, radius=j%2?r*.45:r;
                    if(j===0)ctx.moveTo(x+Math.cos(angle)*radius,y+Math.sin(angle)*radius);
                    else ctx.lineTo(x+Math.cos(angle)*radius,y+Math.sin(angle)*radius);
                }
                ctx.closePath();ctx.fill();
            }
        }
        ctx.globalAlpha=1;
    }

    Rectangle {
        visible: feedback.effectsEnabled && feedback.pose === "dizzy" && feedback.reactionCaption !== ""
        opacity: Math.max(0,Math.min(1,(feedback.clock-feedback.poseStart)/.2,
                                    (2.2-feedback.clock+feedback.poseStart)/.25))
        x: Math.max(8,Math.min(parent.width-width-8,feedback.headPosition.x-width/2))
        y: Math.max(8,feedback.headPosition.y-parent.height*.29-height)
        width: Math.min(parent.width-16,caption.implicitWidth+24)
        height: caption.implicitHeight+16
        radius: height/2
        color: "#ed252330"
        border.color: "#b4d1b6f5"
        Text {
            id: caption
            anchors.centerIn: parent
            width: Math.min(implicitWidth,parent.width-24)
            text: feedback.reactionCaption
            font.pixelSize: Math.max(11,feedback.width*.035)
            color: "#f4edf9"
            elide: Text.ElideRight
        }
    }
}
