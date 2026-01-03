// chartjs-plugin-annotation@3.1.0 downloaded from https://ga.jspm.io/npm:chartjs-plugin-annotation@3.1.0/dist/chartjs-plugin-annotation.esm.js

import{Element as t,DoughnutController as e,defaults as o,Animations as n,Chart as i}from"chart.js";import{distanceBetweenPoints as r,toRadians as s,isObject as a,valueOrDefault as l,isArray as c,toFont as d,defined as u,isFunction as h,callback as f,addRoundedRectPath as p,toTRBLCorners as y,RAD_PER_DEG as x,QUARTER_PI as g,PI as b,HALF_PI as m,TWO_THIRDS_PI as v,TAU as w,isNumber as S,isFinite as P,toPadding as A,getAngleFromPoint as C,toDegrees as M,clipArea as k,unclipArea as D}from"chart.js/helpers";
/**
 * @typedef { import("chart.js").ChartEvent } ChartEvent
 * @typedef { import('../../types/element').AnnotationElement } AnnotationElement
 */const L={modes:{
/**
     * Point mode returns all elements that hit test based on the event position
     * @param {AnnotationElement[]} visibleElements - annotation elements which are visible
     * @param {ChartEvent} event - the event we are find things at
     * @return {AnnotationElement[]} - elements that are found
     */
point(t,e){return filterElements(t,e,{intersect:true})},
/**
     * Nearest mode returns the element closest to the event position
     * @param {AnnotationElement[]} visibleElements - annotation elements which are visible
     * @param {ChartEvent} event - the event we are find things at
     * @param {Object} options - interaction options to use
     * @return {AnnotationElement[]} - elements that are found (only 1 element)
     */
nearest(t,e,o){return getNearestItem(t,e,o)},
/**
     * x mode returns the elements that hit-test at the current x coordinate
     * @param {AnnotationElement[]} visibleElements - annotation elements which are visible
     * @param {ChartEvent} event - the event we are find things at
     * @param {Object} options - interaction options to use
     * @return {AnnotationElement[]} - elements that are found
     */
x(t,e,o){return filterElements(t,e,{intersect:o.intersect,axis:"x"})},
/**
     * y mode returns the elements that hit-test at the current y coordinate
     * @param {AnnotationElement[]} visibleElements - annotation elements which are visible
     * @param {ChartEvent} event - the event we are find things at
     * @param {Object} options - interaction options to use
     * @return {AnnotationElement[]} - elements that are found
     */
y(t,e,o){return filterElements(t,e,{intersect:o.intersect,axis:"y"})}}};
/**
 * Returns all elements that hit test based on the event position
 * @param {AnnotationElement[]} visibleElements - annotation elements which are visible
 * @param {ChartEvent} event - the event we are find things at
 * @param {Object} options - interaction options to use
 * @return {AnnotationElement[]} - elements that are found
 */function getElements(t,e,o){const n=L.modes[o.mode]||L.modes.nearest;return n(t,e,o)}function inRangeByAxis(t,e,o){return o!=="x"&&o!=="y"?t.inRange(e.x,e.y,"x",true)||t.inRange(e.x,e.y,"y",true):t.inRange(e.x,e.y,o,true)}function getPointByAxis(t,e,o){return o==="x"?{x:t.x,y:e.y}:o==="y"?{x:e.x,y:t.y}:e}function filterElements(t,e,o){return t.filter((t=>o.intersect?t.inRange(e.x,e.y):inRangeByAxis(t,e,o.axis)))}function getNearestItem(t,e,o){let n=Number.POSITIVE_INFINITY;return filterElements(t,e,o).reduce(((t,i)=>{const s=i.getCenterPoint();const a=getPointByAxis(e,s,o.axis);const l=r(e,a);if(l<n){t=[i];n=l}else l===n&&t.push(i);return t}),[]).sort(((t,e)=>t._index-e._index)).slice(0,1)}
/**
 * @typedef {import('chart.js').Point} Point
 */
/**
 * Rotate a `point` relative to `center` point by `angle`
 * @param {Point} point - the point to rotate
 * @param {Point} center - center point for rotation
 * @param {number} angle - angle for rotation, in radians
 * @returns {Point} rotated point
 */function rotated(t,e,o){const n=Math.cos(o);const i=Math.sin(o);const r=e.x;const s=e.y;return{x:r+n*(t.x-r)-i*(t.y-s),y:s+i*(t.x-r)+n*(t.y-s)}}const isOlderPart=(t,e)=>e>t||t.length>e.length&&t.slice(0,e.length)===e
/**
 * @typedef { import('chart.js').Point } Point
 * @typedef { import('chart.js').InteractionAxis } InteractionAxis
 * @typedef { import('../../types/element').AnnotationElement } AnnotationElement
 */;const T=.001;const clamp=(t,e,o)=>Math.min(o,Math.max(e,t))
/**
 * @param {{value: number, start: number, end: number}} limit
 * @param {number} hitSize
 * @returns {boolean}
 */;const inLimit=(t,e)=>t.value>=t.start-e&&t.value<=t.end+e
/**
 * @param {Object} obj
 * @param {number} from
 * @param {number} to
 * @returns {Object}
 */;function clampAll(t,e,o){for(const n of Object.keys(t))t[n]=clamp(t[n],e,o);return t}
/**
 * @param {Point} point
 * @param {Point} center
 * @param {number} radius
 * @param {number} hitSize
 * @returns {boolean}
 */function inPointRange(t,e,o,n){return!(!t||!e||o<=0)&&Math.pow(t.x-e.x,2)+Math.pow(t.y-e.y,2)<=Math.pow(o+n,2)}
/**
 * @param {Point} point
 * @param {{x: number, y: number, x2: number, y2: number}} rect
 * @param {InteractionAxis} axis
 * @param {{borderWidth: number, hitTolerance: number}} hitsize
 * @returns {boolean}
 */function inBoxRange(t,{x:e,y:o,x2:n,y2:i},r,{borderWidth:s,hitTolerance:a}){const l=(s+a)/2;const c=t.x>=e-l-T&&t.x<=n+l+T;const d=t.y>=o-l-T&&t.y<=i+l+T;return r==="x"?c:(r==="y"||c)&&d}
/**
 * @param {Point} point
 * @param {rect: {x: number, y: number, x2: number, y2: number}, center: {x: number, y: number}} element
 * @param {InteractionAxis} axis
 * @param {{rotation: number, borderWidth: number, hitTolerance: number}}
 * @returns {boolean}
 */function inLabelRange(t,{rect:e,center:o},n,{rotation:i,borderWidth:r,hitTolerance:a}){const l=rotated(t,o,s(-i));return inBoxRange(l,e,n,{borderWidth:r,hitTolerance:a})}
/**
 * @param {AnnotationElement} element
 * @param {boolean} useFinalPosition
 * @returns {Point}
 */function getElementCenterPoint(t,e){const{centerX:o,centerY:n}=t.getProps(["centerX","centerY"],e);return{x:o,y:n}}
/**
 * @param {string} pkg
 * @param {string} min
 * @param {string} ver
 * @param {boolean} [strict=true]
 * @returns {boolean}
 */function requireVersion(t,e,o,n=true){const i=o.split(".");let r=0;for(const s of e.split(".")){const a=i[r++];if(parseInt(s,10)<parseInt(a,10))break;if(isOlderPart(a,s)){if(n)throw new Error(`${t} v${o} is not supported. v${e} or newer is required.`);return false}}return true}const isPercentString=t=>typeof t==="string"&&t.endsWith("%");const toPercent=t=>parseFloat(t)/100;const toPositivePercent=t=>clamp(toPercent(t),0,1);const boxAppering=(t,e)=>({x:t,y:e,x2:t,y2:e,width:0,height:0});const E={box:t=>boxAppering(t.centerX,t.centerY),doughnutLabel:t=>boxAppering(t.centerX,t.centerY),ellipse:t=>({centerX:t.centerX,centerY:t.centerX,radius:0,width:0,height:0}),label:t=>boxAppering(t.centerX,t.centerY),line:t=>boxAppering(t.x,t.y),point:t=>({centerX:t.centerX,centerY:t.centerY,radius:0,width:0,height:0}),polygon:t=>boxAppering(t.centerX,t.centerY)};
/**
 * @typedef { import('chart.js').FontSpec } FontSpec
 * @typedef { import('chart.js').Point } Point
 * @typedef { import('chart.js').Padding } Padding
 * @typedef { import('../../types/element').AnnotationBoxModel } AnnotationBoxModel
 * @typedef { import('../../types/element').AnnotationElement } AnnotationElement
 * @typedef { import('../../types/options').AnnotationPointCoordinates } AnnotationPointCoordinates
 * @typedef { import('../../types/label').CoreLabelOptions } CoreLabelOptions
 * @typedef { import('../../types/label').LabelPositionObject } LabelPositionObject
 */
/**
 * @param {number} size
 * @param {number|string} position
 * @returns {number}
 */function getRelativePosition(t,e){return e==="start"?0:e==="end"?t:isPercentString(e)?toPositivePercent(e)*t:t/2}
/**
 * @param {number} size
 * @param {number|string} value
 * @param {boolean} [positivePercent=true]
 * @returns {number}
 */function getSize(t,e,o=true){return typeof e==="number"?e:isPercentString(e)?(o?toPositivePercent(e):toPercent(e))*t:t}
/**
 * @param {{x: number, width: number}} size
 * @param {CoreLabelOptions} options
 * @returns {number}
 */function calculateTextAlignment(t,e){const{x:o,width:n}=t;const i=e.textAlign;return i==="center"?o+n/2:i==="end"||i==="right"?o+n:o}
/**
 * @param {Point} point
 * @param {{height: number, width: number}} labelSize
 * @param {{borderWidth: number, position: {LabelPositionObject|string}, xAdjust: number, yAdjust: number}} options
 * @param {Padding|undefined} padding
 * @returns {{x: number, y: number, x2: number, y2: number, height: number, width: number, centerX: number, centerY: number}}
 */function measureLabelRectangle(t,e,{borderWidth:o,position:n,xAdjust:i,yAdjust:r},s){const l=a(s);const c=e.width+(l?s.width:0)+o;const d=e.height+(l?s.height:0)+o;const u=toPosition(n);const h=calculateLabelPosition$1(t.x,c,i,u.x);const f=calculateLabelPosition$1(t.y,d,r,u.y);return{x:h,y:f,x2:h+c,y2:f+d,width:c,height:d,centerX:h+c/2,centerY:f+d/2}}
/**
 * @param {LabelPositionObject|string} value
 * @param {string|number} defaultValue
 * @returns {LabelPositionObject}
 */function toPosition(t,e="center"){if(a(t))return{x:l(t.x,e),y:l(t.y,e)};t=l(t,e);return{x:t,y:t}}
/**
 * @param {CoreLabelOptions} options
 * @param {number} fitRatio
 * @returns {boolean}
 */const shouldFit=(t,e)=>t&&t.autoFit&&e<1
/**
 * @param {CoreLabelOptions} options
 * @param {number} fitRatio
 * @returns {FontSpec[]}
 */;function toFonts(t,e){const o=t.font;const n=c(o)?o:[o];return shouldFit(t,e)?n.map((function(t){const o=d(t);o.size=Math.floor(t.size*e);o.lineHeight=t.lineHeight;return d(o)})):n.map((t=>d(t)))}
/**
 * @param {AnnotationPointCoordinates} options
 * @returns {boolean}
 */function isBoundToPoint(t){return t&&(u(t.xValue)||u(t.yValue))}function calculateLabelPosition$1(t,e,o=0,n){return t-getRelativePosition(e,n)+o}
/**
 * @param {Chart} chart
 * @param {AnnotationBoxModel} properties
 * @param {CoreAnnotationOptions} options
 * @returns {AnnotationElement}
 */function initAnimationProperties(t,e,o){const n=o.init;if(n)return n===true?applyDefault(e,o):execCallback(t,e,o)}
/**
 * @param {Object} options
 * @param {Array} hooks
 * @param {Object} hooksContainer
 * @returns {boolean}
 */function loadHooks(t,e,o){let n=false;e.forEach((e=>{if(h(t[e])){n=true;o[e]=t[e]}else u(o[e])&&delete o[e]}));return n}function applyDefault(t,e){const o=e.type||"line";return E[o](t)}function execCallback(t,e,o){const n=f(o.init,[{chart:t,properties:e,options:o}]);return n===true?applyDefault(e,o):a(n)?n:void 0}const j=new Map;const notRadius=t=>isNaN(t)||t<=0;const fontsKey=t=>t.reduce((function(t,e){t+=e.string;return t}),"")
/**
 * @typedef { import('chart.js').Point } Point
 * @typedef { import('../../types/label').CoreLabelOptions } CoreLabelOptions
 * @typedef { import('../../types/options').PointAnnotationOptions } PointAnnotationOptions
 */
/**
 * Determine if content is an image or a canvas.
 * @param {*} content
 * @returns boolean|undefined
 * @todo move this function to chart.js helpers
 */;function isImageOrCanvas(t){if(t&&typeof t==="object"){const e=t.toString();return e==="[object HTMLImageElement]"||e==="[object HTMLCanvasElement]"}}
/**
 * Set the translation on the canvas if the rotation must be applied.
 * @param {CanvasRenderingContext2D} ctx - chart canvas context
 * @param {Point} point - the point of translation
 * @param {number} rotation - rotation (in degrees) to apply
 */function translate(t,{x:e,y:o},n){if(n){t.translate(e,o);t.rotate(s(n));t.translate(-e,-o)}}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {Object} options
 * @returns {boolean|undefined}
 */function setBorderStyle(t,e){if(e&&e.borderWidth){t.lineCap=e.borderCapStyle||"butt";t.setLineDash(e.borderDash);t.lineDashOffset=e.borderDashOffset;t.lineJoin=e.borderJoinStyle||"miter";t.lineWidth=e.borderWidth;t.strokeStyle=e.borderColor;return true}}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {Object} options
 */function setShadowStyle(t,e){t.shadowColor=e.backgroundShadowColor;t.shadowBlur=e.shadowBlur;t.shadowOffsetX=e.shadowOffsetX;t.shadowOffsetY=e.shadowOffsetY}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {CoreLabelOptions} options
 * @returns {{width: number, height: number}}
 */function measureLabelSize(t,e){const o=e.content;if(isImageOrCanvas(o)){const t={width:getSize(o.width,e.width),height:getSize(o.height,e.height)};return t}const n=toFonts(e);const i=e.textStrokeWidth;const r=c(o)?o:[o];const s=r.join()+fontsKey(n)+i+(t._measureText?"-spriting":"");j.has(s)||j.set(s,calculateLabelSize(t,r,n,i));return j.get(s)}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {{x: number, y: number, width: number, height: number}} rect
 * @param {Object} options
 */function drawBox(t,e,o){const{x:n,y:i,width:r,height:s}=e;t.save();setShadowStyle(t,o);const a=setBorderStyle(t,o);t.fillStyle=o.backgroundColor;t.beginPath();p(t,{x:n,y:i,w:r,h:s,radius:clampAll(y(o.borderRadius),0,Math.min(r,s)/2)});t.closePath();t.fill();if(a){t.shadowColor=o.borderShadowColor;t.stroke()}t.restore()}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {{x: number, y: number, width: number, height: number}} rect
 * @param {CoreLabelOptions} options
 * @param {number} fitRatio
 */function drawLabel(t,e,o,n){const i=o.content;if(isImageOrCanvas(i)){t.save();t.globalAlpha=getOpacity(o.opacity,i.style.opacity);t.drawImage(i,e.x,e.y,e.width,e.height);t.restore();return}const r=c(i)?i:[i];const s=toFonts(o,n);const a=o.color;const l=c(a)?a:[a];const d=calculateTextAlignment(e,o);const u=e.y+o.textStrokeWidth/2;t.save();t.textBaseline="middle";t.textAlign=o.textAlign;setTextStrokeStyle(t,o)&&applyLabelDecoration(t,{x:d,y:u},r,s);applyLabelContent(t,{x:d,y:u},r,{fonts:s,colors:l});t.restore()}function setTextStrokeStyle(t,e){if(e.textStrokeWidth>0){t.lineJoin="round";t.miterLimit=2;t.lineWidth=e.textStrokeWidth;t.strokeStyle=e.textStrokeColor;return true}}
/**
 * @param {CanvasRenderingContext2D} ctx
 * @param {{radius: number, options: PointAnnotationOptions}} element
 * @param {number} x
 * @param {number} y
 */function drawPoint(t,e,o,n){const{radius:i,options:r}=e;const s=r.pointStyle;const a=r.rotation;let l=(a||0)*x;if(isImageOrCanvas(s)){t.save();t.translate(o,n);t.rotate(l);t.drawImage(s,-s.width/2,-s.height/2,s.width,s.height);t.restore()}else notRadius(i)||drawPointStyle(t,{x:o,y:n,radius:i,rotation:a,style:s,rad:l})}function drawPointStyle(t,{x:e,y:o,radius:n,rotation:i,style:r,rad:s}){let a,l,c,d;t.beginPath();switch(r){default:t.arc(e,o,n,0,w);t.closePath();break;case"triangle":t.moveTo(e+Math.sin(s)*n,o-Math.cos(s)*n);s+=v;t.lineTo(e+Math.sin(s)*n,o-Math.cos(s)*n);s+=v;t.lineTo(e+Math.sin(s)*n,o-Math.cos(s)*n);t.closePath();break;case"rectRounded":d=n*.516;c=n-d;a=Math.cos(s+g)*c;l=Math.sin(s+g)*c;t.arc(e-a,o-l,d,s-b,s-m);t.arc(e+l,o-a,d,s-m,s);t.arc(e+a,o+l,d,s,s+m);t.arc(e-l,o+a,d,s+m,s+b);t.closePath();break;case"rect":if(!i){c=Math.SQRT1_2*n;t.rect(e-c,o-c,2*c,2*c);break}s+=g;case"rectRot":a=Math.cos(s)*n;l=Math.sin(s)*n;t.moveTo(e-a,o-l);t.lineTo(e+l,o-a);t.lineTo(e+a,o+l);t.lineTo(e-l,o+a);t.closePath();break;case"crossRot":s+=g;case"cross":a=Math.cos(s)*n;l=Math.sin(s)*n;t.moveTo(e-a,o-l);t.lineTo(e+a,o+l);t.moveTo(e+l,o-a);t.lineTo(e-l,o+a);break;case"star":a=Math.cos(s)*n;l=Math.sin(s)*n;t.moveTo(e-a,o-l);t.lineTo(e+a,o+l);t.moveTo(e+l,o-a);t.lineTo(e-l,o+a);s+=g;a=Math.cos(s)*n;l=Math.sin(s)*n;t.moveTo(e-a,o-l);t.lineTo(e+a,o+l);t.moveTo(e+l,o-a);t.lineTo(e-l,o+a);break;case"line":a=Math.cos(s)*n;l=Math.sin(s)*n;t.moveTo(e-a,o-l);t.lineTo(e+a,o+l);break;case"dash":t.moveTo(e,o);t.lineTo(e+Math.cos(s)*n,o+Math.sin(s)*n);break}t.fill()}function calculateLabelSize(t,e,o,n){t.save();const i=e.length;let r=0;let s=n;for(let a=0;a<i;a++){const i=o[Math.min(a,o.length-1)];t.font=i.string;const l=e[a];r=Math.max(r,t.measureText(l).width+n);s+=i.lineHeight}t.restore();return{width:r,height:s}}function applyLabelDecoration(t,{x:e,y:o},n,i){t.beginPath();let r=0;n.forEach((function(n,s){const a=i[Math.min(s,i.length-1)];const l=a.lineHeight;t.font=a.string;t.strokeText(n,e,o+l/2+r);r+=l}));t.stroke()}function applyLabelContent(t,{x:e,y:o},n,{fonts:i,colors:r}){let s=0;n.forEach((function(n,a){const l=r[Math.min(a,r.length-1)];const c=i[Math.min(a,i.length-1)];const d=c.lineHeight;t.beginPath();t.font=c.string;t.fillStyle=l;t.fillText(n,e,o+d/2+s);s+=d;t.fill()}))}function getOpacity(t,e){const o=S(t)?t:e;return S(o)?clamp(o,0,1):1}const O=["left","bottom","top","right"];
/**
 * @typedef { import('../../types/element').AnnotationElement } AnnotationElement
 */
/**
 * Drawa the callout component for labels.
 * @param {CanvasRenderingContext2D} ctx - chart canvas context
 * @param {AnnotationElement} element - the label element
 */function drawCallout(t,e){const{pointX:o,pointY:n,options:i}=e;const r=i.callout;const a=r&&r.display&&resolveCalloutPosition(e,r);if(!a||isPointInRange(e,r,a))return;t.save();t.beginPath();const l=setBorderStyle(t,r);if(!l)return t.restore();const{separatorStart:c,separatorEnd:d}=getCalloutSeparatorCoord(e,a);const{sideStart:u,sideEnd:h}=getCalloutSideCoord(e,a,c);if(r.margin>0||i.borderWidth===0){t.moveTo(c.x,c.y);t.lineTo(d.x,d.y)}t.moveTo(u.x,u.y);t.lineTo(h.x,h.y);const f=rotated({x:o,y:n},e.getCenterPoint(),s(-e.rotation));t.lineTo(f.x,f.y);t.stroke();t.restore()}function getCalloutSeparatorCoord(t,e){const{x:o,y:n,x2:i,y2:r}=t;const s=getCalloutSeparatorAdjust(t,e);let a,l;if(e==="left"||e==="right"){a={x:o+s,y:n};l={x:a.x,y:r}}else{a={x:o,y:n+s};l={x:i,y:a.y}}return{separatorStart:a,separatorEnd:l}}function getCalloutSeparatorAdjust(t,e){const{width:o,height:n,options:i}=t;const r=i.callout.margin+i.borderWidth/2;return e==="right"?o+r:e==="bottom"?n+r:-r}function getCalloutSideCoord(t,e,o){const{y:n,width:i,height:r,options:s}=t;const a=s.callout.start;const l=getCalloutSideAdjust(e,s.callout);let c,d;if(e==="left"||e==="right"){c={x:o.x,y:n+getSize(r,a)};d={x:c.x+l,y:c.y}}else{c={x:o.x+getSize(i,a),y:o.y};d={x:c.x,y:c.y+l}}return{sideStart:c,sideEnd:d}}function getCalloutSideAdjust(t,e){const o=e.side;return t==="left"||t==="top"?-o:o}function resolveCalloutPosition(t,e){const o=e.position;return O.includes(o)?o:resolveCalloutAutoPosition(t,e)}function resolveCalloutAutoPosition(t,e){const{x:o,y:n,x2:i,y2:a,width:l,height:c,pointX:d,pointY:u,centerX:h,centerY:f,rotation:p}=t;const y={x:h,y:f};const x=e.start;const g=getSize(l,x);const b=getSize(c,x);const m=[o,o+g,o+g,i];const v=[n+b,a,n,a];const w=[];for(let t=0;t<4;t++){const e=rotated({x:m[t],y:v[t]},y,s(p));w.push({position:O[t],distance:r(e,{x:d,y:u})})}return w.sort(((t,e)=>t.distance-e.distance))[0].position}function isPointInRange(t,e,o){const{pointX:n,pointY:i}=t;const r=e.margin;let s=n;let a=i;o==="left"?s+=r:o==="right"?s-=r:o==="top"?a+=r:o==="bottom"&&(a-=r);return t.inRange(s,a)}const I={xScaleID:{min:"xMin",max:"xMax",start:"left",end:"right",startProp:"x",endProp:"x2"},yScaleID:{min:"yMin",max:"yMax",start:"bottom",end:"top",startProp:"y",endProp:"y2"}};
/**
 * @typedef { import("chart.js").Chart } Chart
 * @typedef { import("chart.js").Scale } Scale
 * @typedef { import("chart.js").Point } Point
 * @typedef { import('../../types/element').AnnotationBoxModel } AnnotationBoxModel
 * @typedef { import('../../types/options').CoreAnnotationOptions } CoreAnnotationOptions
 * @typedef { import('../../types/options').LineAnnotationOptions } LineAnnotationOptions
 * @typedef { import('../../types/options').PointAnnotationOptions } PointAnnotationOptions
 * @typedef { import('../../types/options').PolygonAnnotationOptions } PolygonAnnotationOptions
 */
/**
 * @param {Scale} scale
 * @param {number|string} value
 * @param {number} fallback
 * @returns {number}
 */function scaleValue(t,e,o){e=typeof e==="number"?e:t.parse(e);return P(e)?t.getPixelForValue(e):o}
/**
 * Search the scale defined in chartjs by the axis related to the annotation options key.
 * @param {{ [key: string]: Scale }} scales
 * @param {CoreAnnotationOptions} options
 * @param {string} key
 * @returns {string}
 */function retrieveScaleID(t,e,o){const n=e[o];if(n||o==="scaleID")return n;const i=o.charAt(0);const r=Object.values(t).filter((t=>t.axis&&t.axis===i));return r.length?r[0].id:i}
/**
 * @param {Scale} scale
 * @param {{min: number, max: number, start: number, end: number}} options
 * @returns {{start: number, end: number}|undefined}
 */function getDimensionByScale(t,e){if(t){const o=t.options.reverse;const n=scaleValue(t,e.min,o?e.end:e.start);const i=scaleValue(t,e.max,o?e.start:e.end);return{start:n,end:i}}}
/**
 * @param {Chart} chart
 * @param {CoreAnnotationOptions} options
 * @returns {Point}
 */function getChartPoint(t,e){const{chartArea:o,scales:n}=t;const i=n[retrieveScaleID(n,e,"xScaleID")];const r=n[retrieveScaleID(n,e,"yScaleID")];let s=o.width/2;let a=o.height/2;i&&(s=scaleValue(i,e.xValue,i.left+i.width/2));r&&(a=scaleValue(r,e.yValue,r.top+r.height/2));return{x:s,y:a}}
/**
 * @param {Chart} chart
 * @param {CoreAnnotationOptions} options
 * @returns {AnnotationBoxModel}
 */function resolveBoxProperties(t,e){const o=t.scales;const n=o[retrieveScaleID(o,e,"xScaleID")];const i=o[retrieveScaleID(o,e,"yScaleID")];if(!n&&!i)return{};let{left:r,right:s}=n||t.chartArea;let{top:a,bottom:l}=i||t.chartArea;const c=getChartDimensionByScale(n,{min:e.xMin,max:e.xMax,start:r,end:s});r=c.start;s=c.end;const d=getChartDimensionByScale(i,{min:e.yMin,max:e.yMax,start:l,end:a});a=d.start;l=d.end;return{x:r,y:a,x2:s,y2:l,width:s-r,height:l-a,centerX:r+(s-r)/2,centerY:a+(l-a)/2}}
/**
 * @param {Chart} chart
 * @param {PointAnnotationOptions|PolygonAnnotationOptions} options
 * @returns {AnnotationBoxModel}
 */function resolvePointProperties(t,e){if(!isBoundToPoint(e)){const o=resolveBoxProperties(t,e);let n=e.radius;if(!n||isNaN(n)){n=Math.min(o.width,o.height)/2;e.radius=n}const i=n*2;const r=o.centerX+e.xAdjust;const s=o.centerY+e.yAdjust;return{x:r-n,y:s-n,x2:r+n,y2:s+n,centerX:r,centerY:s,width:i,height:i,radius:n}}return getChartCircle(t,e)}
/**
 * @param {Chart} chart
 * @param {LineAnnotationOptions} options
 * @returns {AnnotationBoxModel}
 */function resolveLineProperties(t,e){const{scales:o,chartArea:n}=t;const i=o[e.scaleID];const r={x:n.left,y:n.top,x2:n.right,y2:n.bottom};i?resolveFullLineProperties(i,r,e):resolveLimitedLineProperties(o,r,e);return r}
/**
 * @param {Chart} chart
 * @param {CoreAnnotationOptions} options
 * @param {boolean} [centerBased=false]
 * @returns {AnnotationBoxModel}
 */function resolveBoxAndLabelProperties(t,e){const o=resolveBoxProperties(t,e);o.initProperties=initAnimationProperties(t,o,e);o.elements=[{type:"label",optionScope:"label",properties:resolveLabelElementProperties$1(t,o,e),initProperties:o.initProperties}];return o}function getChartCircle(t,e){const o=getChartPoint(t,e);const n=e.radius*2;return{x:o.x-e.radius+e.xAdjust,y:o.y-e.radius+e.yAdjust,x2:o.x+e.radius+e.xAdjust,y2:o.y+e.radius+e.yAdjust,centerX:o.x+e.xAdjust,centerY:o.y+e.yAdjust,radius:e.radius,width:n,height:n}}function getChartDimensionByScale(t,e){const o=getDimensionByScale(t,e)||e;return{start:Math.min(o.start,o.end),end:Math.max(o.start,o.end)}}function resolveFullLineProperties(t,e,o){const n=scaleValue(t,o.value,NaN);const i=scaleValue(t,o.endValue,n);if(t.isHorizontal()){e.x=n;e.x2=i}else{e.y=n;e.y2=i}}function resolveLimitedLineProperties(t,e,o){for(const n of Object.keys(I)){const i=t[retrieveScaleID(t,o,n)];if(i){const{min:t,max:r,start:s,end:a,startProp:l,endProp:c}=I[n];const d=getDimensionByScale(i,{min:o[t],max:o[r],start:i[s],end:i[a]});e[l]=d.start;e[c]=d.end}}}function calculateX({properties:t,options:e},o,n,i){const{x:r,x2:s,width:a}=t;return calculatePosition({start:r,end:s,size:a,borderWidth:e.borderWidth},{position:n.x,padding:{start:i.left,end:i.right},adjust:e.label.xAdjust,size:o.width})}function calculateY({properties:t,options:e},o,n,i){const{y:r,y2:s,height:a}=t;return calculatePosition({start:r,end:s,size:a,borderWidth:e.borderWidth},{position:n.y,padding:{start:i.top,end:i.bottom},adjust:e.label.yAdjust,size:o.height})}function calculatePosition(t,e){const{start:o,end:n,borderWidth:i}=t;const{position:r,padding:{start:s,end:a},adjust:l}=e;const c=n-i-o-s-a-e.size;return o+i/2+l+getRelativePosition(c,r)}function resolveLabelElementProperties$1(t,e,o){const n=o.label;n.backgroundColor="transparent";n.callout.display=false;const i=toPosition(n.position);const r=A(n.padding);const s=measureLabelSize(t.ctx,n);const a=calculateX({properties:e,options:o},s,i,r);const l=calculateY({properties:e,options:o},s,i,r);const c=s.width+r.width;const d=s.height+r.height;return{x:a,y:l,x2:a+c,y2:l+d,width:c,height:d,centerX:a+c/2,centerY:l+d/2,rotation:n.rotation}}const R=["enter","leave"];
/**
 * @typedef { import("chart.js").Chart } Chart
 * @typedef { import('../../types/options').AnnotationPluginOptions } AnnotationPluginOptions
 */const Y=R.concat("click");
/**
 * @param {Chart} chart
 * @param {Object} state
 * @param {AnnotationPluginOptions} options
 */function updateListeners(t,e,o){e.listened=loadHooks(o,Y,e.listeners);e.moveListened=false;R.forEach((t=>{h(o[t])&&(e.moveListened=true)}));e.listened&&e.moveListened||e.annotations.forEach((t=>{!e.listened&&h(t.click)&&(e.listened=true);e.moveListened||R.forEach((o=>{if(h(t[o])){e.listened=true;e.moveListened=true}}))}))}
/**
 * @param {Object} state
 * @param {ChartEvent} event
 * @param {AnnotationPluginOptions} options
 * @return {boolean|undefined}
 */function handleEvent(t,e,o){if(t.listened)switch(e.type){case"mousemove":case"mouseout":return handleMoveEvents(t,e,o);case"click":return handleClickEvents(t,e,o)}}function handleMoveEvents(t,e,o){if(!t.moveListened)return;let n;n=e.type==="mousemove"?getElements(t.visibleElements,e,o.interaction):[];const i=t.hovered;t.hovered=n;const r={state:t,event:e};let s=dispatchMoveEvents(r,"leave",i,n);return dispatchMoveEvents(r,"enter",n,i)||s}function dispatchMoveEvents({state:t,event:e},o,n,i){let r;for(const s of n)i.indexOf(s)<0&&(r=dispatchEvent(s.options[o]||t.listeners[o],s,e)||r);return r}function handleClickEvents(t,e,o){const n=t.listeners;const i=getElements(t.visibleElements,e,o.interaction);let r;for(const t of i)r=dispatchEvent(t.options.click||n.click,t,e)||r;return r}function dispatchEvent(t,e,o){return f(t,[e.$context,o])===true}
/**
 * @typedef { import("chart.js").Chart } Chart
 * @typedef { import('../../types/options').AnnotationPluginOptions } AnnotationPluginOptions
 * @typedef { import('../../types/element').AnnotationElement } AnnotationElement
 */const X=["afterDraw","beforeDraw"];
/**
 * @param {Chart} chart
 * @param {Object} state
 * @param {AnnotationPluginOptions} options
 */function updateHooks(t,e,o){const n=e.visibleElements;e.hooked=loadHooks(o,X,e.hooks);e.hooked||n.forEach((t=>{e.hooked||X.forEach((o=>{h(t.options[o])&&(e.hooked=true)}))}))}
/**
 * @param {Object} state
 * @param {AnnotationElement} element
 * @param {string} hook
 */function invokeHook(t,e,o){if(t.hooked){const n=e.options[o]||t.hooks[o];return f(n,[e.$context])}}
/**
 * @typedef { import("chart.js").Chart } Chart
 * @typedef { import("chart.js").Scale } Scale
 * @typedef { import('../../types/options').CoreAnnotationOptions } CoreAnnotationOptions
 */
/**
 * @param {Chart} chart
 * @param {Scale} scale
 * @param {CoreAnnotationOptions[]} annotations
 */function adjustScaleRange(t,e,o){const n=getScaleLimits(t.scales,e,o);let i=changeScaleLimit(e,n,"min","suggestedMin");i=changeScaleLimit(e,n,"max","suggestedMax")||i;i&&h(e.handleTickRangeOptions)&&e.handleTickRangeOptions()}
/**
 * @param {CoreAnnotationOptions[]} annotations
 * @param {{ [key: string]: Scale }} scales
 */function verifyScaleOptions(t,e){for(const o of t)verifyScaleIDs(o,e)}function changeScaleLimit(t,e,o,n){if(P(e[o])&&!scaleLimitDefined(t.options,o,n)){const n=t[o]!==e[o];t[o]=e[o];return n}}function scaleLimitDefined(t,e,o){return u(t[e])||u(t[o])}function verifyScaleIDs(t,e){for(const o of["scaleID","xScaleID","yScaleID"]){const n=retrieveScaleID(e,t,o);n&&!e[n]&&verifyProperties(t,o)&&console.warn(`No scale found with id '${n}' for annotation '${t.id}'`)}}function verifyProperties(t,e){if(e==="scaleID")return true;const o=e.charAt(0);for(const e of["Min","Max","Value"])if(u(t[o+e]))return true;return false}function getScaleLimits(t,e,o){const n=e.axis;const i=e.id;const r=n+"ScaleID";const s={min:l(e.min,Number.NEGATIVE_INFINITY),max:l(e.max,Number.POSITIVE_INFINITY)};for(const a of o)a.scaleID===i?updateLimits(a,e,["value","endValue"],s):retrieveScaleID(t,a,r)===i&&updateLimits(a,e,[n+"Min",n+"Max",n+"Value"],s);return s}function updateLimits(t,e,o,n){for(const i of o){const o=t[i];if(u(o)){const t=e.parse(o);n.min=Math.min(n.min,t);n.max=Math.max(n.max,t)}}}class BoxAnnotation extends t{inRange(t,e,o,n){const{x:i,y:r}=rotated({x:t,y:e},this.getCenterPoint(n),s(-this.options.rotation));return inBoxRange({x:i,y:r},this.getProps(["x","y","x2","y2"],n),o,this.options)}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){t.save();translate(t,this.getCenterPoint(),this.options.rotation);drawBox(t,this,this.options);t.restore()}get label(){return this.elements&&this.elements[0]}resolveElementProperties(t,e){return resolveBoxAndLabelProperties(t,e)}}BoxAnnotation.id="boxAnnotation";BoxAnnotation.defaults={adjustScaleRange:true,backgroundShadowColor:"transparent",borderCapStyle:"butt",borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderRadius:0,borderShadowColor:"transparent",borderWidth:1,display:true,init:void 0,hitTolerance:0,label:{backgroundColor:"transparent",borderWidth:0,callout:{display:false},color:"black",content:null,display:false,drawTime:void 0,font:{family:void 0,lineHeight:void 0,size:void 0,style:void 0,weight:"bold"},height:void 0,hitTolerance:void 0,opacity:void 0,padding:6,position:"center",rotation:void 0,textAlign:"start",textStrokeColor:void 0,textStrokeWidth:0,width:void 0,xAdjust:0,yAdjust:0,z:void 0},rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,xMax:void 0,xMin:void 0,xScaleID:void 0,yMax:void 0,yMin:void 0,yScaleID:void 0,z:0};BoxAnnotation.defaultRoutes={borderColor:"color",backgroundColor:"color"};BoxAnnotation.descriptors={label:{_fallback:true}};class DoughnutLabelAnnotation extends t{inRange(t,e,o,n){return inLabelRange({x:t,y:e},{rect:this.getProps(["x","y","x2","y2"],n),center:this.getCenterPoint(n)},o,{rotation:this.rotation,borderWidth:0,hitTolerance:this.options.hitTolerance})}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const e=this.options;if(e.display&&e.content){drawBackground(t,this);t.save();translate(t,this.getCenterPoint(),this.rotation);drawLabel(t,this,e,this._fitRatio);t.restore()}}resolveElementProperties(t,e){const o=getDatasetMeta(t,e);if(!o)return{};const{controllerMeta:n,point:i,radius:r}=getControllerMeta(t,e,o);let s=measureLabelSize(t.ctx,e);const a=getFitRatio(s,r);shouldFit(e,a)&&(s={width:s.width*a,height:s.height*a});const{position:l,xAdjust:c,yAdjust:d}=e;const u=measureLabelRectangle(i,s,{borderWidth:0,position:l,xAdjust:c,yAdjust:d});return{initProperties:initAnimationProperties(t,u,e),...u,...n,rotation:e.rotation,_fitRatio:a}}}DoughnutLabelAnnotation.id="doughnutLabelAnnotation";DoughnutLabelAnnotation.defaults={autoFit:true,autoHide:true,backgroundColor:"transparent",backgroundShadowColor:"transparent",borderColor:"transparent",borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderShadowColor:"transparent",borderWidth:0,color:"black",content:null,display:true,font:{family:void 0,lineHeight:void 0,size:void 0,style:void 0,weight:void 0},height:void 0,hitTolerance:0,init:void 0,opacity:void 0,position:"center",rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,spacing:1,textAlign:"center",textStrokeColor:void 0,textStrokeWidth:0,width:void 0,xAdjust:0,yAdjust:0};DoughnutLabelAnnotation.defaultRoutes={};function getDatasetMeta(t,o){return t.getSortedVisibleDatasetMetas().reduce((function(n,i){const r=i.controller;return r instanceof e&&isControllerVisible(t,o,i.data)&&(!n||r.innerRadius<n.controller.innerRadius)&&r.options.circumference>=90?i:n}),void 0)}function isControllerVisible(t,e,o){if(!e.autoHide)return true;for(let e=0;e<o.length;e++)if(!o[e].hidden&&t.getDataVisibility(e))return true}function getControllerMeta({chartArea:t},e,o){const{left:n,top:i,right:r,bottom:s}=t;const{innerRadius:a,offsetX:l,offsetY:c}=o.controller;const d=(n+r)/2+l;const u=(i+s)/2+c;const h={left:Math.max(d-a,n),right:Math.min(d+a,r),top:Math.max(u-a,i),bottom:Math.min(u+a,s)};const f={x:(h.left+h.right)/2,y:(h.top+h.bottom)/2};const p=e.spacing+e.borderWidth/2;const y=a-p;const x=f.y>u;const g=x?i+p:s-p;const b=getAngles(g,d,u,y);const m={_centerX:d,_centerY:u,_radius:y,_counterclockwise:x,...b};return{controllerMeta:m,point:f,radius:Math.min(a,Math.min(h.right-h.left,h.bottom-h.top)/2)}}function getFitRatio({width:t,height:e},o){const n=Math.sqrt(Math.pow(t,2)+Math.pow(e,2));return o*2/n}function getAngles(t,e,o,n){const i=Math.pow(o-t,2);const r=Math.pow(n,2);const s=e*-2;const a=Math.pow(e,2)+i-r;const l=Math.pow(s,2)-4*a;if(l<=0)return{_startAngle:0,_endAngle:w};const c=(-s-Math.sqrt(l))/2;const d=(-s+Math.sqrt(l))/2;return{_startAngle:C({x:e,y:o},{x:c,y:t}).angle,_endAngle:C({x:e,y:o},{x:d,y:t}).angle}}function drawBackground(t,e){const{_centerX:o,_centerY:n,_radius:i,_startAngle:r,_endAngle:s,_counterclockwise:a,options:l}=e;t.save();const c=setBorderStyle(t,l);t.fillStyle=l.backgroundColor;t.beginPath();t.arc(o,n,i,r,s,a);t.closePath();t.fill();c&&t.stroke();t.restore()}class LabelAnnotation extends t{inRange(t,e,o,n){return inLabelRange({x:t,y:e},{rect:this.getProps(["x","y","x2","y2"],n),center:this.getCenterPoint(n)},o,{rotation:this.rotation,borderWidth:this.options.borderWidth,hitTolerance:this.options.hitTolerance})}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const e=this.options;const o=!u(this._visible)||this._visible;if(e.display&&e.content&&o){t.save();translate(t,this.getCenterPoint(),this.rotation);drawCallout(t,this);drawBox(t,this,e);drawLabel(t,getLabelSize(this),e);t.restore()}}resolveElementProperties(t,e){let o;if(isBoundToPoint(e))o=getChartPoint(t,e);else{const{centerX:n,centerY:i}=resolveBoxProperties(t,e);o={x:n,y:i}}const n=A(e.padding);const i=measureLabelSize(t.ctx,e);const r=measureLabelRectangle(o,i,e,n);return{initProperties:initAnimationProperties(t,r,e),pointX:o.x,pointY:o.y,...r,rotation:e.rotation}}}LabelAnnotation.id="labelAnnotation";LabelAnnotation.defaults={adjustScaleRange:true,backgroundColor:"transparent",backgroundShadowColor:"transparent",borderCapStyle:"butt",borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderRadius:0,borderShadowColor:"transparent",borderWidth:0,callout:{borderCapStyle:"butt",borderColor:void 0,borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderWidth:1,display:false,margin:5,position:"auto",side:5,start:"50%"},color:"black",content:null,display:true,font:{family:void 0,lineHeight:void 0,size:void 0,style:void 0,weight:void 0},height:void 0,hitTolerance:0,init:void 0,opacity:void 0,padding:6,position:"center",rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,textAlign:"center",textStrokeColor:void 0,textStrokeWidth:0,width:void 0,xAdjust:0,xMax:void 0,xMin:void 0,xScaleID:void 0,xValue:void 0,yAdjust:0,yMax:void 0,yMin:void 0,yScaleID:void 0,yValue:void 0,z:0};LabelAnnotation.defaultRoutes={borderColor:"color"};function getLabelSize({x:t,y:e,width:o,height:n,options:i}){const r=i.borderWidth/2;const s=A(i.padding);return{x:t+s.left+r,y:e+s.top+r,width:o-s.left-s.right-i.borderWidth,height:n-s.top-s.bottom-i.borderWidth}}const pointInLine=(t,e,o)=>({x:t.x+o*(e.x-t.x),y:t.y+o*(e.y-t.y)});const interpolateX=(t,e,o)=>pointInLine(e,o,Math.abs((t-e.y)/(o.y-e.y))).x;const interpolateY=(t,e,o)=>pointInLine(e,o,Math.abs((t-e.x)/(o.x-e.x))).y;const sqr=t=>t*t;const rangeLimit=(t,e,{x:o,y:n,x2:i,y2:r},s)=>s==="y"?{start:Math.min(n,r),end:Math.max(n,r),value:e}:{start:Math.min(o,i),end:Math.max(o,i),value:t};const coordInCurve=(t,e,o,n)=>(1-n)*(1-n)*t+2*(1-n)*n*e+n*n*o;const pointInCurve=(t,e,o,n)=>({x:coordInCurve(t.x,e.x,o.x,n),y:coordInCurve(t.y,e.y,o.y,n)});const coordAngleInCurve=(t,e,o,n)=>2*(1-n)*(e-t)+2*n*(o-e);const angleInCurve=(t,e,o,n)=>-Math.atan2(coordAngleInCurve(t.x,e.x,o.x,n),coordAngleInCurve(t.y,e.y,o.y,n))+.5*b;class LineAnnotation extends t{inRange(t,e,o,n){const i=(this.options.borderWidth+this.options.hitTolerance)/2;if(o!=="x"&&o!=="y"){const o={mouseX:t,mouseY:e};const{path:r,ctx:s}=this;if(r){setBorderStyle(s,this.options);s.lineWidth+=this.options.hitTolerance;const{chart:i}=this.$context;const a=t*i.currentDevicePixelRatio;const l=e*i.currentDevicePixelRatio;const c=s.isPointInStroke(r,a,l)||isOnLabel(this,o,n);s.restore();return c}const a=sqr(i);return intersects(this,o,a,n)||isOnLabel(this,o,n)}return inAxisRange(this,{mouseX:t,mouseY:e},o,{hitSize:i,useFinalPosition:n})}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const{x:e,y:o,x2:n,y2:i,cp:r,options:s}=this;t.save();if(!setBorderStyle(t,s))return t.restore();setShadowStyle(t,s);const a=Math.sqrt(Math.pow(n-e,2)+Math.pow(i-o,2));if(s.curve&&r){drawCurve(t,this,r,a);return t.restore()}const{startOpts:l,endOpts:c,startAdjust:d,endAdjust:u}=getArrowHeads(this);const h=Math.atan2(i-o,n-e);t.translate(e,o);t.rotate(h);t.beginPath();t.moveTo(0+d,0);t.lineTo(a-u,0);t.shadowColor=s.borderShadowColor;t.stroke();drawArrowHead(t,0,d,l);drawArrowHead(t,a,-u,c);t.restore()}get label(){return this.elements&&this.elements[0]}resolveElementProperties(t,e){const o=resolveLineProperties(t,e);const{x:n,y:i,x2:s,y2:a}=o;const l=isLineInArea(o,t.chartArea);const c=l?limitLineToArea({x:n,y:i},{x:s,y:a},t.chartArea):{x:n,y:i,x2:s,y2:a,width:Math.abs(s-n),height:Math.abs(a-i)};c.centerX=(s+n)/2;c.centerY=(a+i)/2;c.initProperties=initAnimationProperties(t,c,e);if(e.curve){const t={x:c.x,y:c.y};const o={x:c.x2,y:c.y2};c.cp=getControlPoint(c,e,r(t,o))}const d=resolveLabelElementProperties(t,c,e.label);d._visible=l;c.elements=[{type:"label",optionScope:"label",properties:d,initProperties:c.initProperties}];return c}}LineAnnotation.id="lineAnnotation";const B={backgroundColor:void 0,backgroundShadowColor:void 0,borderColor:void 0,borderDash:void 0,borderDashOffset:void 0,borderShadowColor:void 0,borderWidth:void 0,display:void 0,fill:void 0,length:void 0,shadowBlur:void 0,shadowOffsetX:void 0,shadowOffsetY:void 0,width:void 0};LineAnnotation.defaults={adjustScaleRange:true,arrowHeads:{display:false,end:Object.assign({},B),fill:false,length:12,start:Object.assign({},B),width:6},borderDash:[],borderDashOffset:0,borderShadowColor:"transparent",borderWidth:2,curve:false,controlPoint:{y:"-50%"},display:true,endValue:void 0,init:void 0,hitTolerance:0,label:{backgroundColor:"rgba(0,0,0,0.8)",backgroundShadowColor:"transparent",borderCapStyle:"butt",borderColor:"black",borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderRadius:6,borderShadowColor:"transparent",borderWidth:0,callout:Object.assign({},LabelAnnotation.defaults.callout),color:"#fff",content:null,display:false,drawTime:void 0,font:{family:void 0,lineHeight:void 0,size:void 0,style:void 0,weight:"bold"},height:void 0,hitTolerance:void 0,opacity:void 0,padding:6,position:"center",rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,textAlign:"center",textStrokeColor:void 0,textStrokeWidth:0,width:void 0,xAdjust:0,yAdjust:0,z:void 0},scaleID:void 0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,value:void 0,xMax:void 0,xMin:void 0,xScaleID:void 0,yMax:void 0,yMin:void 0,yScaleID:void 0,z:0};LineAnnotation.descriptors={arrowHeads:{start:{_fallback:true},end:{_fallback:true},_fallback:true}};LineAnnotation.defaultRoutes={borderColor:"color"};function inAxisRange(t,{mouseX:e,mouseY:o},n,{hitSize:i,useFinalPosition:r}){const s=rangeLimit(e,o,t.getProps(["x","y","x2","y2"],r),n);return inLimit(s,i)||isOnLabel(t,{mouseX:e,mouseY:o},r,n)}function isLineInArea({x:t,y:e,x2:o,y2:n},{top:i,right:r,bottom:s,left:a}){return!(t<a&&o<a||t>r&&o>r||e<i&&n<i||e>s&&n>s)}function limitPointToArea({x:t,y:e},o,{top:n,right:i,bottom:r,left:s}){if(t<s){e=interpolateY(s,{x:t,y:e},o);t=s}if(t>i){e=interpolateY(i,{x:t,y:e},o);t=i}if(e<n){t=interpolateX(n,{x:t,y:e},o);e=n}if(e>r){t=interpolateX(r,{x:t,y:e},o);e=r}return{x:t,y:e}}function limitLineToArea(t,e,o){const{x:n,y:i}=limitPointToArea(t,e,o);const{x:r,y:s}=limitPointToArea(e,t,o);return{x:n,y:i,x2:r,y2:s,width:Math.abs(r-n),height:Math.abs(s-i)}}function intersects(t,{mouseX:e,mouseY:o},n=T,i){const{x:r,y:s,x2:a,y2:l}=t.getProps(["x","y","x2","y2"],i);const c=a-r;const d=l-s;const u=sqr(c)+sqr(d);const h=u===0?-1:((e-r)*c+(o-s)*d)/u;let f,p;if(h<0){f=r;p=s}else if(h>1){f=a;p=l}else{f=r+h*c;p=s+h*d}return sqr(e-f)+sqr(o-p)<=n}function isOnLabel(t,{mouseX:e,mouseY:o},n,i){const r=t.label;return r.options.display&&r.inRange(e,o,i,n)}function resolveLabelElementProperties(t,e,o){const n=o.borderWidth;const i=A(o.padding);const r=measureLabelSize(t.ctx,o);const s=r.width+i.width+n;const a=r.height+i.height+n;return calculateLabelPosition(e,o,{width:s,height:a,padding:i},t.chartArea)}function calculateAutoRotation(t){const{x:e,y:o,x2:n,y2:i}=t;const r=Math.atan2(i-o,n-e);return r>b/2?r-b:r<b/-2?r+b:r}function calculateLabelPosition(t,e,o,n){const{width:i,height:r,padding:a}=o;const{xAdjust:l,yAdjust:c}=e;const d={x:t.x,y:t.y};const u={x:t.x2,y:t.y2};const h=e.rotation==="auto"?calculateAutoRotation(t):s(e.rotation);const f=rotatedSize(i,r,h);const p=calculateT(t,e,{labelSize:f,padding:a},n);const y=t.cp?pointInCurve(d,t.cp,u,p):pointInLine(d,u,p);const x={size:f.w,min:n.left,max:n.right,padding:a.left};const g={size:f.h,min:n.top,max:n.bottom,padding:a.top};const b=adjustLabelCoordinate(y.x,x)+l;const m=adjustLabelCoordinate(y.y,g)+c;return{x:b-i/2,y:m-r/2,x2:b+i/2,y2:m+r/2,centerX:b,centerY:m,pointX:y.x,pointY:y.y,width:i,height:r,rotation:M(h)}}function rotatedSize(t,e,o){const n=Math.cos(o);const i=Math.sin(o);return{w:Math.abs(t*n)+Math.abs(e*i),h:Math.abs(t*i)+Math.abs(e*n)}}function calculateT(t,e,o,n){let i;const r=spaceAround(t,n);i=e.position==="start"?calculateTAdjust({w:t.x2-t.x,h:t.y2-t.y},o,e,r):e.position==="end"?1-calculateTAdjust({w:t.x-t.x2,h:t.y-t.y2},o,e,r):getRelativePosition(1,e.position);return i}function calculateTAdjust(t,e,o,n){const{labelSize:i,padding:r}=e;const s=t.w*n.dx;const a=t.h*n.dy;const l=s>0&&(i.w/2+r.left-n.x)/s;const c=a>0&&(i.h/2+r.top-n.y)/a;return clamp(Math.max(l,c),0,.25)}function spaceAround(t,e){const{x:o,x2:n,y:i,y2:r}=t;const s=Math.min(i,r)-e.top;const a=Math.min(o,n)-e.left;const l=e.bottom-Math.max(i,r);const c=e.right-Math.max(o,n);return{x:Math.min(a,c),y:Math.min(s,l),dx:a<=c?1:-1,dy:s<=l?1:-1}}function adjustLabelCoordinate(t,e){const{size:o,min:n,max:i,padding:r}=e;const s=o/2;if(o>i-n)return(i+n)/2;n>=t-r-s&&(t=n+r+s);i<=t+r+s&&(t=i-r-s);return t}function getArrowHeads(t){const e=t.options;const o=e.arrowHeads&&e.arrowHeads.start;const n=e.arrowHeads&&e.arrowHeads.end;return{startOpts:o,endOpts:n,startAdjust:getLineAdjust(t,o),endAdjust:getLineAdjust(t,n)}}function getLineAdjust(t,e){if(!e||!e.display)return 0;const{length:o,width:n}=e;const i=t.options.borderWidth/2;const r={x:o,y:n+i};const s={x:0,y:i};return Math.abs(interpolateX(0,r,s))}function drawArrowHead(t,e,o,n){if(!n||!n.display)return;const{length:i,width:r,fill:s,backgroundColor:a,borderColor:l}=n;const c=Math.abs(e-i)+o;t.beginPath();setShadowStyle(t,n);setBorderStyle(t,n);t.moveTo(c,-r);t.lineTo(e+o,0);t.lineTo(c,r);if(s===true){t.fillStyle=a||l;t.closePath();t.fill();t.shadowColor="transparent"}else t.shadowColor=n.borderShadowColor;t.stroke()}function getControlPoint(t,e,o){const{x:n,y:i,x2:r,y2:s,centerX:a,centerY:l}=t;const c=Math.atan2(s-i,r-n);const d=toPosition(e.controlPoint,0);const u={x:a+getSize(o,d.x,false),y:l+getSize(o,d.y,false)};return rotated(u,{x:a,y:l},c)}function drawArrowHeadOnCurve(t,{x:e,y:o},{angle:n,adjust:i},r){if(r&&r.display){t.save();t.translate(e,o);t.rotate(n);drawArrowHead(t,0,-i,r);t.restore()}}function drawCurve(t,e,o,n){const{x:i,y:r,x2:s,y2:a,options:l}=e;const{startOpts:c,endOpts:d,startAdjust:u,endAdjust:h}=getArrowHeads(e);const f={x:i,y:r};const p={x:s,y:a};const y=angleInCurve(f,o,p,0);const x=angleInCurve(f,o,p,1)-b;const g=pointInCurve(f,o,p,u/n);const m=pointInCurve(f,o,p,1-h/n);const v=new Path2D;t.beginPath();v.moveTo(g.x,g.y);v.quadraticCurveTo(o.x,o.y,m.x,m.y);t.shadowColor=l.borderShadowColor;t.stroke(v);e.path=v;e.ctx=t;drawArrowHeadOnCurve(t,g,{angle:y,adjust:u},c);drawArrowHeadOnCurve(t,m,{angle:x,adjust:h},d)}class EllipseAnnotation extends t{inRange(t,e,o,n){const i=this.options.rotation;const r=(this.options.borderWidth+this.options.hitTolerance)/2;if(o!=="x"&&o!=="y")return pointInEllipse({x:t,y:e},this.getProps(["width","height","centerX","centerY"],n),i,r);const{x:a,y:l,x2:c,y2:d}=this.getProps(["x","y","x2","y2"],n);const u=o==="y"?{start:l,end:d}:{start:a,end:c};const h=rotated({x:t,y:e},this.getCenterPoint(n),s(-i));return h[o]>=u.start-r-T&&h[o]<=u.end+r+T}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const{width:e,height:o,centerX:n,centerY:i,options:r}=this;t.save();translate(t,this.getCenterPoint(),r.rotation);setShadowStyle(t,this.options);t.beginPath();t.fillStyle=r.backgroundColor;const s=setBorderStyle(t,r);t.ellipse(n,i,o/2,e/2,b/2,0,2*b);t.fill();if(s){t.shadowColor=r.borderShadowColor;t.stroke()}t.restore()}get label(){return this.elements&&this.elements[0]}resolveElementProperties(t,e){return resolveBoxAndLabelProperties(t,e)}}EllipseAnnotation.id="ellipseAnnotation";EllipseAnnotation.defaults={adjustScaleRange:true,backgroundShadowColor:"transparent",borderDash:[],borderDashOffset:0,borderShadowColor:"transparent",borderWidth:1,display:true,hitTolerance:0,init:void 0,label:Object.assign({},BoxAnnotation.defaults.label),rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,xMax:void 0,xMin:void 0,xScaleID:void 0,yMax:void 0,yMin:void 0,yScaleID:void 0,z:0};EllipseAnnotation.defaultRoutes={borderColor:"color",backgroundColor:"color"};EllipseAnnotation.descriptors={label:{_fallback:true}};function pointInEllipse(t,e,o,n){const{width:i,height:r,centerX:a,centerY:l}=e;const c=i/2;const d=r/2;if(c<=0||d<=0)return false;const u=s(o||0);const h=Math.cos(u);const f=Math.sin(u);const p=Math.pow(h*(t.x-a)+f*(t.y-l),2);const y=Math.pow(f*(t.x-a)-h*(t.y-l),2);return p/Math.pow(c+n,2)+y/Math.pow(d+n,2)<=1.0001}class PointAnnotation extends t{inRange(t,e,o,n){const{x:i,y:r,x2:s,y2:a,width:l}=this.getProps(["x","y","x2","y2","width"],n);const c=(this.options.borderWidth+this.options.hitTolerance)/2;if(o!=="x"&&o!=="y")return inPointRange({x:t,y:e},this.getCenterPoint(n),l/2,c);const d=o==="y"?{start:r,end:a,value:e}:{start:i,end:s,value:t};return inLimit(d,c)}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const e=this.options;const o=e.borderWidth;if(e.radius<.1)return;t.save();t.fillStyle=e.backgroundColor;setShadowStyle(t,e);const n=setBorderStyle(t,e);drawPoint(t,this,this.centerX,this.centerY);if(n&&!isImageOrCanvas(e.pointStyle)){t.shadowColor=e.borderShadowColor;t.stroke()}t.restore();e.borderWidth=o}resolveElementProperties(t,e){const o=resolvePointProperties(t,e);o.initProperties=initAnimationProperties(t,o,e);return o}}PointAnnotation.id="pointAnnotation";PointAnnotation.defaults={adjustScaleRange:true,backgroundShadowColor:"transparent",borderDash:[],borderDashOffset:0,borderShadowColor:"transparent",borderWidth:1,display:true,hitTolerance:0,init:void 0,pointStyle:"circle",radius:10,rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,xAdjust:0,xMax:void 0,xMin:void 0,xScaleID:void 0,xValue:void 0,yAdjust:0,yMax:void 0,yMin:void 0,yScaleID:void 0,yValue:void 0,z:0};PointAnnotation.defaultRoutes={borderColor:"color",backgroundColor:"color"};class PolygonAnnotation extends t{inRange(t,e,o,n){if(o!=="x"&&o!=="y")return this.options.radius>=.1&&this.elements.length>1&&pointIsInPolygon(this.elements,t,e,n);const i=rotated({x:t,y:e},this.getCenterPoint(n),s(-this.options.rotation));const r=this.elements.map((t=>o==="y"?t.bY:t.bX));const a=Math.min(...r);const l=Math.max(...r);return i[o]>=a&&i[o]<=l}getCenterPoint(t){return getElementCenterPoint(this,t)}draw(t){const{elements:e,options:o}=this;t.save();t.beginPath();t.fillStyle=o.backgroundColor;setShadowStyle(t,o);const n=setBorderStyle(t,o);let i=true;for(const o of e)if(i){t.moveTo(o.x,o.y);i=false}else t.lineTo(o.x,o.y);t.closePath();t.fill();if(n){t.shadowColor=o.borderShadowColor;t.stroke()}t.restore()}resolveElementProperties(t,e){const o=resolvePointProperties(t,e);const{sides:n,rotation:i}=e;const r=[];const s=2*b/n;let a=i*x;for(let i=0;i<n;i++,a+=s){const n=buildPointElement(o,e,a);n.initProperties=initAnimationProperties(t,o,e);r.push(n)}o.elements=r;return o}}PolygonAnnotation.id="polygonAnnotation";PolygonAnnotation.defaults={adjustScaleRange:true,backgroundShadowColor:"transparent",borderCapStyle:"butt",borderDash:[],borderDashOffset:0,borderJoinStyle:"miter",borderShadowColor:"transparent",borderWidth:1,display:true,hitTolerance:0,init:void 0,point:{radius:0},radius:10,rotation:0,shadowBlur:0,shadowOffsetX:0,shadowOffsetY:0,sides:3,xAdjust:0,xMax:void 0,xMin:void 0,xScaleID:void 0,xValue:void 0,yAdjust:0,yMax:void 0,yMin:void 0,yScaleID:void 0,yValue:void 0,z:0};PolygonAnnotation.defaultRoutes={borderColor:"color",backgroundColor:"color"};function buildPointElement({centerX:t,centerY:e},{radius:o,borderWidth:n,hitTolerance:i},r){const s=(n+i)/2;const a=Math.sin(r);const l=Math.cos(r);const c={x:t+a*o,y:e-l*o};return{type:"point",optionScope:"point",properties:{x:c.x,y:c.y,centerX:c.x,centerY:c.y,bX:t+a*(o+s),bY:e-l*(o+s)}}}function pointIsInPolygon(t,e,o,n){let i=false;let r=t[t.length-1].getProps(["bX","bY"],n);for(const s of t){const t=s.getProps(["bX","bY"],n);t.bY>o!==r.bY>o&&e<(r.bX-t.bX)*(o-t.bY)/(r.bY-t.bY)+t.bX&&(i=!i);r=t}return i}const W={box:BoxAnnotation,doughnutLabel:DoughnutLabelAnnotation,ellipse:EllipseAnnotation,label:LabelAnnotation,line:LineAnnotation,point:PointAnnotation,polygon:PolygonAnnotation};Object.keys(W).forEach((t=>{o.describe(`elements.${W[t].id}`,{_fallback:"plugins.annotation.common"})}));const z={update:Object.assign};const _=Y.concat(X);const resolve=(t,e)=>a(e)?resolveObj(t,e):t
/**
 * @typedef { import("chart.js").Chart } Chart
 * @typedef { import("chart.js").UpdateMode } UpdateMode
 * @typedef { import('../../types/options').AnnotationPluginOptions } AnnotationPluginOptions
 */
/**
 * @param {string} prop
 * @returns {boolean}
 */;const isIndexable=t=>t==="color"||t==="font"
/**
 * Resolve the annotation type, checking if is supported.
 * @param {string} [type=line] - annotation type
 * @returns {string} resolved annotation type
 */;function resolveType(t="line"){if(W[t])return t;console.warn(`Unknown annotation type: '${t}', defaulting to 'line'`);return"line"}
/**
 * @param {Chart} chart
 * @param {Object} state
 * @param {AnnotationPluginOptions} options
 * @param {UpdateMode} mode
 */function updateElements(t,e,o,n){const i=resolveAnimations(t,o.animations,n);const r=e.annotations;const s=resyncElements(e.elements,r);for(let e=0;e<r.length;e++){const o=r[e];const n=getOrCreateElement(s,e,o.type);const a=o.setContext(getContext(t,n,s,o));const l=n.resolveElementProperties(t,a);l.skip=toSkip(l);if("elements"in l){updateSubElements(n,l.elements,a,i);delete l.elements}u(n.x)||Object.assign(n,l);Object.assign(n,l.initProperties);l.options=resolveAnnotationOptions(a);i.update(n,l)}}function toSkip(t){return isNaN(t.x)||isNaN(t.y)}function resolveAnimations(t,e,o){return o==="reset"||o==="none"||o==="resize"?z:new n(t,e)}function updateSubElements(t,e,o,n){const i=t.elements||(t.elements=[]);i.length=e.length;for(let t=0;t<e.length;t++){const r=e[t];const s=r.properties;const a=getOrCreateElement(i,t,r.type,r.initProperties);const l=o[r.optionScope].override(r);s.options=resolveAnnotationOptions(l);n.update(a,s)}}function getOrCreateElement(t,e,o,n){const i=W[resolveType(o)];let r=t[e];if(!r||!(r instanceof i)){r=t[e]=new i;Object.assign(r,n)}return r}function resolveAnnotationOptions(t){const e=W[resolveType(t.type)];const o={};o.id=t.id;o.type=t.type;o.drawTime=t.drawTime;Object.assign(o,resolveObj(t,e.defaults),resolveObj(t,e.defaultRoutes));for(const e of _)o[e]=t[e];return o}function resolveObj(t,e){const o={};for(const n of Object.keys(e)){const i=e[n];const r=t[n];isIndexable(n)&&c(r)?o[n]=r.map((t=>resolve(t,i))):o[n]=resolve(r,i)}return o}function getContext(t,e,o,n){return e.$context||(e.$context=Object.assign(Object.create(t.getContext()),{element:e,get elements(){return o.filter((t=>t&&t.options))},id:n.id,type:"annotation"}))}function resyncElements(t,e){const o=e.length;const n=t.length;if(n<o){const e=o-n;t.splice(n,0,...new Array(e))}else n>o&&t.splice(o,n-o);return t}var H="3.1.0";const V=new Map;const isNotDoughnutLabel=t=>t.type!=="doughnutLabel";const N=Y.concat(X);var $={id:"annotation",version:H,beforeRegister(){requireVersion("chart.js","4.0",i.version)},afterRegister(){i.register(W)},afterUnregister(){i.unregister(W)},beforeInit(t){V.set(t,{annotations:[],elements:[],visibleElements:[],listeners:{},listened:false,moveListened:false,hooks:{},hooked:false,hovered:[]})},beforeUpdate(t,e,o){const n=V.get(t);const i=n.annotations=[];let r=o.annotations;a(r)?Object.keys(r).forEach((t=>{const e=r[t];if(a(e)){e.id=t;i.push(e)}})):c(r)&&i.push(...r);verifyScaleOptions(i.filter(isNotDoughnutLabel),t.scales)},afterDataLimits(t,e){const o=V.get(t);adjustScaleRange(t,e.scale,o.annotations.filter(isNotDoughnutLabel).filter((t=>t.display&&t.adjustScaleRange)))},afterUpdate(t,e,o){const n=V.get(t);updateListeners(t,n,o);updateElements(t,n,o,e.mode);n.visibleElements=n.elements.filter((t=>!t.skip&&t.options.display));updateHooks(t,n,o)},beforeDatasetsDraw(t,e,o){draw(t,"beforeDatasetsDraw",o.clip)},afterDatasetsDraw(t,e,o){draw(t,"afterDatasetsDraw",o.clip)},beforeDatasetDraw(t,e,o){draw(t,e.index,o.clip)},beforeDraw(t,e,o){draw(t,"beforeDraw",o.clip)},afterDraw(t,e,o){draw(t,"afterDraw",o.clip)},beforeEvent(t,e,o){const n=V.get(t);handleEvent(n,e.event,o)&&(e.changed=true)},afterDestroy(t){V.delete(t)},getAnnotations(t){const e=V.get(t);return e?e.elements:[]},_getAnnotationElementsAtEventForMode(t,e,o){return getElements(t,e,o)},defaults:{animations:{numbers:{properties:["x","y","x2","y2","width","height","centerX","centerY","pointX","pointY","radius"],type:"number"},colors:{properties:["backgroundColor","borderColor"],type:"color"}},clip:true,interaction:{mode:void 0,axis:void 0,intersect:void 0},common:{drawTime:"afterDatasetsDraw",init:false,label:{}}},descriptors:{_indexable:false,_scriptable:t=>!N.includes(t)&&t!=="init",annotations:{_allKeys:false,_fallback:(t,e)=>`elements.${W[resolveType(e.type)].id}`},interaction:{_fallback:true},common:{label:{_indexable:isIndexable,_fallback:true},_indexable:isIndexable}},additionalOptionScopes:[""]};function draw(t,e,o){const{ctx:n,chartArea:i}=t;const r=V.get(t);o&&k(n,i);const s=getDrawableElements(r.visibleElements,e).sort(((t,e)=>t.element.options.z-e.element.options.z));for(const t of s)drawElement(n,i,r,t);o&&D(n)}function getDrawableElements(t,e){const o=[];for(const n of t){n.options.drawTime===e&&o.push({element:n,main:true});if(n.elements&&n.elements.length)for(const t of n.elements)t.options.display&&t.options.drawTime===e&&o.push({element:t})}return o}function drawElement(t,e,o,n){const i=n.element;if(n.main){invokeHook(o,i,"beforeDraw");i.draw(t,e);invokeHook(o,i,"afterDraw")}else i.draw(t,e)}export{$ as default};

